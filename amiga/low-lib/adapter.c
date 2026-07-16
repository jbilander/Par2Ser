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
 *                                        par2ser.c (which installs its own
 *                                        FLAG ICR vector via cia.resource).
 *
 * INTERRUPT-CONTEXT CONTRACT: the slow transfer paths (adapter_read_slow /
 * adapter_write_slow) contain NO Disable()/Enable() masking. Masking is the
 * CALLER's job, and only task-context callers need it (transport_write does
 * it). The FLAG ICR receive handler calls adapter_read() from interrupt
 * context, where masking is unnecessary (task code cannot preempt) and
 * Enable() is actively fatal: exec does not run interrupt handlers under
 * Disable(), so a Disable()/Enable() pair inside a handler drops the SR
 * interrupt mask to 0 on Enable() while the level-2 interrupt is still
 * asserted -> immediate recursive re-entry -> stack overflow. (This crashed
 * the machine on first use of the FLAG handler.) The FAST asm paths in
 * adapter_low.s still mask internally and therefore MUST NOT be called from
 * interrupt context as-is; adapter_set_speed likewise masks and is
 * task-context only.
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

/* KS 1.3 compatibility guard -- MUST be last, after all system/NDK headers,
 * so their unconditional declarations are seen before the poison pragmas.
 * Any KS 2.0+ call below this point becomes a compile error. */
#include <ks13_compat.h>

#define REQ_BIT		CIAB_PRTRSEL
#define CLK_BIT		CIAB_PRTRPOUT
#define ACT_BIT		CIAB_PRTRBUSY

#define REQ_MASK	(1 << REQ_BIT)
#define CLK_MASK	(1 << CLK_BIT)
#define ACT_MASK	(1 << ACT_BIT)

/* Fast-path block transfer implemented in adapter_low.s: a0=buf, d0=size.
 * That register convention is crossed ONLY here, via explicit register
 * variables + inline jsr (the same proven mechanism as misc/cia_protos.h) --
 * NOT via asm() parameter annotations, which this gcc ignores on the caller
 * side (see adapter.h). The asm saves d2/a5-a6 itself and scratches d1/a1.
 * NOTE: the fast paths Disable()/Enable() internally, so they are
 * task-context only, and currently unused (current_speed stays SLOW). */
static inline void call_read_fast(UBYTE *buf, ULONG size)
{
	register UBYTE *b asm("a0") = buf;
	register ULONG  s asm("d0") = size;
	__asm__ __volatile__ (
		"jsr    adapter_read_fast"
		: "+r" (b), "+r" (s)
		:
		: "d1", "a1", "cc", "memory");
}

static inline void call_write_fast(const UBYTE *buf, ULONG size)
{
	register const UBYTE *b asm("a0") = buf;
	register ULONG        s asm("d0") = size;
	__asm__ __volatile__ (
		"jsr    adapter_write_fast"
		: "+r" (b), "+r" (s)
		:
		: "d1", "a1", "cc", "memory");
}

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

/* Inter-byte pacing for the slow (bit-bang) write path. Each iteration is one
 * CIA-register read (~1.4us E-clock cycle), so the delay is ~TX_BYTE_DELAY *
 * 1.4us. This is the ONLY flow control between consecutive bytes on the write
 * side -- the data loop toggles CLK per byte with no per-byte BUSY handshake,
 * so this delay must be long enough for the CPLD FSM to consume one byte
 * (WRITE_WAIT -> WRITE_LATCH -> WRITE_FT -> WRITE_WAIT) before the next POUT
 * edge, AND for the FT240X to accept the write.
 *
 * OPTIMIZATION KNOB: the original value (32 -> ~45us) came from Niklas's SD
 * card needing ~32us/byte at 250kHz SPI -- irrelevant here. The FSM per-byte
 * cycle is sub-microsecond at 12MHz and two CIA writes are already ~1.4us
 * apart, so this is almost certainly far larger than needed. Reduce and test
 * for dropped/corrupted bytes (kermit Error Count). If 0 works reliably the
 * delay can be removed entirely; if not, it finds the real margin. */
#ifndef TX_BYTE_DELAY
#define TX_BYTE_DELAY 4      /* was 32; sweep this down toward 0 */
#endif

static void wait_tx_byte(void)
{
	UBYTE tmp;
	for (int i = 0; i < TX_BYTE_DELAY; i++)
		tmp = *cia_b_pra;
	(void)tmp;
}

/* Inter-byte pacing for the slow READ path: gives the FT240X/CPLD time to
 * present a byte on the bus before the Amiga clocks and reads it. Kept at the
 * original value for now -- RX already runs faster than TX and in the current
 * driver this loop only ever runs with size==1 (one byte per FLAG), so it is
 * NOT the RX bottleneck. Left as a separate knob so TX tuning cannot perturb
 * the working receive path; revisit when RX burst-drain is implemented. */
#ifndef RX_BYTE_DELAY
#define RX_BYTE_DELAY 32
#endif

static void wait_rx_byte(void)
{
	UBYTE tmp;
	for (int i = 0; i < RX_BYTE_DELAY; i++)
		tmp = *cia_b_pra;
	(void)tmp;
}

static void adapter_write_slow(const UBYTE *buf, ULONG size)
{
	UBYTE ctrl;

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

		wait_tx_byte();
	}

	ctrl |= REQ_MASK;                   /* deassert SELECT -> FSM IDLE */
	*cia_b_pra = ctrl;
}

static void adapter_read_slow(UBYTE *buf, ULONG size)
{
	UBYTE ctrl;

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
		wait_rx_byte();

		ctrl ^= CLK_MASK;               /* clock a byte in (POUT edge) */
		*cia_b_pra = ctrl;

		*buf++ = *cia_a_prb;
	}

	ctrl |= REQ_MASK;                   /* deassert SELECT -> FSM IDLE */
	*cia_b_pra = ctrl;

	*cia_a_ddrb = 0xff;                 /* drive the data bus again */
}

void adapter_read(UBYTE *buf, ULONG size)
{
	if (current_speed == ADAPTER_SPEED_FAST)
		call_read_fast(buf, size);
	else
		adapter_read_slow(buf, size);
}

void adapter_write(const UBYTE *buf, ULONG size)
{
	if (current_speed == ADAPTER_SPEED_FAST)
		call_write_fast(buf, size);
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
