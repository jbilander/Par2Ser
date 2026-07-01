/*
 * adapter.c -- low-level 2E par-adapter transport for Par2Ser.
 *
 * Derived from Niklas Ekström's spi.c (April 2020 / July 2021, card-present
 * variant). The byte-level transfer routines are his; the wire protocol and
 * the WRITE1/READ1 command encoding are decoded bit-for-bit by the Par2Ser
 * CPLD FSM (par2ser_fsm.v). See adapter_low.s for the framing cross-check.
 *
 * REMOVED vs. the original spi.c (not applicable to a UART bridge):
 *   - spi_select / spi_deselect        : no SPI chip-select on Par2Ser.
 *   - spi_get_card_present             : no SD card; the 0xc2 probe is decoded
 *                                        by the FSM as is_ctrl (SIWU flush).
 *   - the CIA-A FLAG (AddICRVector)     : on Par2Ser the FLAG line is the
 *     interrupt install                  FT240X RX doorbell, owned by
 *                                        par2ser.c's INTB_PORTS rx_server.
 *
 * ADOPTED from the SDBox production code (jbilander/sdbox common/):
 *   - Disable()/Enable() bracketing around each transfer. Par2Ser RX is
 *     CIA-A FLAG interrupt driven, so without masking an rx_server could
 *     reenter the CIA lines mid-write. The fast path masks in adapter_low.s;
 *     the slow path masks here.
 *
 * adapter_init() only opens misc.resource, allocs the parallel port + bits,
 * and sets the CIA idle line state. adapter_shutdown() frees them again.
 * Neither touches any interrupt vector.
 */

#include <exec/types.h>
#include <exec/libraries.h>
#include <hardware/cia.h>
#include <resources/misc.h>

#include <proto/exec.h>
#include "misc_protos.h"

#include "adapter.h"

#define REQ_BIT		CIAB_PRTRSEL
#define CLK_BIT		CIAB_PRTRPOUT
#define ACT_BIT		CIAB_PRTRBUSY

#define REQ_MASK	(1 << REQ_BIT)
#define CLK_MASK	(1 << CLK_BIT)
#define ACT_MASK	(1 << ACT_BIT)

/* Fast-path block transfer implemented in adapter_low.s (masks interrupts
 * itself and does its own SELECT/POUT framing). */
extern void adapter_read_fast (UBYTE *buf       asm("a0"), ULONG size asm("d0"));
extern void adapter_write_fast(const UBYTE *buf asm("a0"), ULONG size asm("d0"));

static volatile UBYTE *cia_a_prb  = (volatile UBYTE *)0xbfe101;
static volatile UBYTE *cia_a_ddrb = (volatile UBYTE *)0xbfe301;

static volatile UBYTE *cia_b_pra  = (volatile UBYTE *)0xbfd000;
static volatile UBYTE *cia_b_ddra = (volatile UBYTE *)0xbfd200;

static long current_speed = ADAPTER_SPEED_SLOW;

static const char adapter_lib_name[] = "par2ser-adapter";

static struct Library *miscbase;

/* Track which resources we grabbed so shutdown frees only those. */
static BOOL got_port;
static BOOL got_bits;

/* Wait (bounded) for the adapter to clear BUSY (ACT). Returns remaining
 * count (0 = timed out). Caller runs with interrupts disabled. */
static int wait_until_active(void)
{
	int count = 32;
	UBYTE ctrl = *cia_b_pra;
	while (count > 0 && (ctrl & ACT_MASK))
	{
		count--;
		ctrl = *cia_b_pra;
	}
	return count;
}

void adapter_set_speed(long speed)
{
	/* Speed-set is itself a control command: assert SELECT, wait BUSY. */
	Disable();
	*cia_a_prb = speed == ADAPTER_SPEED_FAST ? 0xc5 : 0xc4;

	UBYTE prev = *cia_b_pra;
	*cia_b_pra = prev & ~REQ_MASK;

	wait_until_active();

	*cia_b_pra = prev;
	Enable();

	current_speed = speed;
}

/* Inter-byte settling delay for the slow (bit-bang) path: 32 reads of a CIA
 * register. Each CIA access is paced by the ~1.4 us E-clock cycle, so this is
 * ~45 us. It gives the adapter time to accept/present a byte between clocks;
 * the original derived ~32 us from the AVR's 250 kHz SPI byte time, which no
 * longer applies on Par2Ser -- here it is just a settling margin. */
static void wait_40_us(void)
{
	UBYTE tmp;
	for (int i = 0; i < 32; i++)
		tmp = *cia_b_pra;
	(void)tmp;
}

static void adapter_write_slow(const UBYTE *buf asm("a0"), ULONG size asm("d0"))
{
	UBYTE ctrl;

	Disable();
	ctrl = *cia_b_pra;

	if (size <= 64) /* WRITE1: 00xxxxxx */
	{
		*cia_a_prb = (size - 1) & 0x3f;

		ctrl &= ~REQ_MASK;              /* assert SELECT -> FSM DECODE */
		*cia_b_pra = ctrl;

		wait_until_active();
	}
	else /* WRITE2: 10xxxxxx 0xxxxxxx -- NOT decoded by the Par2Ser FSM */
	{
		*cia_a_prb = 0x80 | (((size - 1) >> 7) & 0x3f);

		ctrl &= ~REQ_MASK;
		*cia_b_pra = ctrl;

		wait_until_active();

		*cia_a_prb = (size - 1) & 0x7f;

		ctrl ^= CLK_MASK;
		*cia_b_pra = ctrl;
	}

	for (ULONG i = 0; i < size; i++)
	{
		*cia_a_prb = *buf++;

		ctrl ^= CLK_MASK;               /* clock this byte (POUT edge) */
		*cia_b_pra = ctrl;

		wait_40_us();
	}

	ctrl |= REQ_MASK;                   /* deassert SELECT -> FSM IDLE */
	*cia_b_pra = ctrl;
	Enable();
}

static void adapter_read_slow(UBYTE *buf asm("a0"), ULONG size asm("d0"))
{
	UBYTE ctrl;

	Disable();
	ctrl = *cia_b_pra;

	if (size <= 64) /* READ1: 01xxxxxx */
	{
		*cia_a_prb = 0x40 | ((size - 1) & 0x3f);

		ctrl &= ~REQ_MASK;              /* assert SELECT */
		*cia_b_pra = ctrl;

		wait_until_active();
	}
	else /* READ2: 10xxxxxx 1xxxxxxx -- NOT decoded by the Par2Ser FSM */
	{
		*cia_a_prb = 0x80 | (((size - 1) >> 7) & 0x3f);

		ctrl &= ~REQ_MASK;
		*cia_b_pra = ctrl;

		wait_until_active();

		*cia_a_prb = 0x80 | ((size - 1) & 0x7f);

		ctrl ^= CLK_MASK;
		*cia_b_pra = ctrl;
	}

	*cia_a_ddrb = 0;                    /* turn Amiga data bus to INPUT */

	for (ULONG i = 0; i < size; i++)
	{
		wait_40_us();

		ctrl ^= CLK_MASK;               /* clock a byte in (POUT edge) */
		*cia_b_pra = ctrl;

		*buf++ = *cia_a_prb;
	}

	ctrl |= REQ_MASK;                   /* deassert SELECT -> FSM IDLE */
	*cia_b_pra = ctrl;

	*cia_a_ddrb = 0xff;                 /* drive the data bus again */
	Enable();
}

void adapter_read(UBYTE *buf asm("a0"), ULONG size asm("d0"))
{
	if (current_speed == ADAPTER_SPEED_FAST)
		adapter_read_fast(buf, size);
	else
		adapter_read_slow(buf, size);
}

void adapter_write(const UBYTE *buf asm("a0"), ULONG size asm("d0"))
{
	if (current_speed == ADAPTER_SPEED_FAST)
		adapter_write_fast(buf, size);
	else
		adapter_write_slow(buf, size);
}

int adapter_init(void)
{
	int success = 0;

	got_port = FALSE;
	got_bits = FALSE;
	current_speed = ADAPTER_SPEED_SLOW;

	miscbase = (struct Library *)OpenResource((CONST_STRPTR)MISCNAME);
	if (!miscbase)
	{
		success = -1;
		goto fail_out1;
	}

	if (AllocMiscResource(miscbase, MR_PARALLELPORT, adapter_lib_name))
	{
		success = -3;
		goto fail_out1;
	}
	got_port = TRUE;

	if (AllocMiscResource(miscbase, MR_PARALLELBITS, adapter_lib_name))
	{
		success = -4;
		goto fail_out2;
	}
	got_bits = TRUE;

	/* Idle line state: REQ (SELECT) high, CLK (POUT) high, ACT (BUSY) input. */
	*cia_b_pra  = (*cia_b_pra  & ~ACT_MASK) | (REQ_MASK | CLK_MASK);
	*cia_b_ddra = (*cia_b_ddra & ~ACT_MASK) | (REQ_MASK | CLK_MASK);

	*cia_a_prb  = 0xff;
	*cia_a_ddrb = 0xff;

	return 0;

fail_out2:
	FreeMiscResource(miscbase, MR_PARALLELPORT);
	got_port = FALSE;

fail_out1:
	return success;
}

void adapter_shutdown(void)
{
	/* Float the control lines and stop driving data. */
	*cia_b_ddra &= ~(ACT_MASK | REQ_MASK | CLK_MASK);
	*cia_a_ddrb = 0;

	if (got_bits)
	{
		FreeMiscResource(miscbase, MR_PARALLELBITS);
		got_bits = FALSE;
	}
	if (got_port)
	{
		FreeMiscResource(miscbase, MR_PARALLELPORT);
		got_port = FALSE;
	}
}
