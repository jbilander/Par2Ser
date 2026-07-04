/*
 * transport.c -- byte-pipe transport for par2ser.device.
 *
 * Two implementations selected at compile time:
 *
 *   default (Milestone 1, no PAR2SER_HW): STUB. Lets you load par2ser.device
 *   and run kermit's `set line` / status negotiation in WinUAE with NO
 *   hardware -- transport_write() swallows bytes, transport_poll_rx() never
 *   returns data.
 *
 *   PAR2SER_HW (Milestone 2): real transport over low-lib/adapter.* (Niklas
 *   Ekström's 2E par-adapter protocol -> FT240X).
 *
 * Layering:
 *   par2ser.device  <-- serial.device kermit talks to (upward face)
 *   transport.c     <-- this file: the abstraction seam
 *   adapter.c/.s    <-- 2E wire protocol (downward face)
 */

#include "transport.h"

#if DEBUG
extern void KPrintF(CONST_STRPTR fmt, ...);
#define DBG(...) KPrintF((CONST_STRPTR)__VA_ARGS__)
#else
#define DBG(...)
#endif

#ifdef PAR2SER_HW
/* ================= Milestone 2: real hardware transport ================= */

#include <proto/exec.h>
#include <hardware/cia.h>
#include "low-lib/adapter.h"

/* KS 1.3 compatibility guard -- MUST be last, after all system/NDK headers,
 * so their unconditional declarations are seen before the poison pragmas.
 * Any KS 2.0+ call below this point becomes a compile error. */
#include <ks13_compat.h>

/* Max bytes per WRITE1/READ1 command on the current CPLD: the length field is
 * 6 bits, encoded as size-1, so 1..64. Anything larger would emit a 10xxxxxx
 * first byte the FSM routes to S_DRAIN and silently drops. Chunk here. */
#define ADAPTER_CHUNK 64

/* --- RX bring-up gate -----------------------------------------------------
 * Controlled by PAR2SER_RX_ENABLED in transport.h (shared with par2ser.c so
 * the INTB_PORTS server is also not installed while RX is gated off). While
 * off, transport_poll_rx() is inert and no receive interrupt is hooked, so a
 * stuck/misread FLAG line cannot storm interrupts at open. TX is unaffected. */
#define RX_ENABLED PAR2SER_RX_ENABLED

/* RX doorbell: par2ser.c owns CIA-A FLAG via an INTB_PORTS server. The CPLD
 * asserts ACK (drive_ack = S_IDLE & has_data) while the FT240X RX FIFO is
 * non-empty. We read that line to decide "is a byte waiting?".
 *
 * TODO(hw): confirm the exact bit + polarity against
 * Par2Ser_rev2a_schematic.pdf. ACK is nominally CIA-A PA0 and active-low on
 * the connector. If ACK is NOT readable as a CIA-A PRA bit on Rev 2A, this
 * must be driven from the FLAG interrupt latch instead (read once per
 * rx_server entry) rather than polled. */
#if RX_ENABLED
static volatile UBYTE *cia_a_pra = (volatile UBYTE *)0xbfe001;
#define RXF_PENDING_MASK  0x01

static BOOL rx_data_pending(void)
{
    return (*cia_a_pra & RXF_PENDING_MASK) ? FALSE : TRUE;  /* active-low */
}
#endif

BOOL transport_init(void)
{
    int rc = adapter_init();
    DBG((CONST_STRPTR)"transport_init() adapter_init=%ld\n", (LONG)rc);
    return rc == 0 ? TRUE : FALSE;
}

void transport_shutdown(void)
{
    DBG((CONST_STRPTR)"transport_shutdown()\n");
    adapter_shutdown();
}

LONG transport_write(const UBYTE *buf, ULONG len)
{
    ULONG sent = 0;
    while (sent < len) {
        ULONG chunk = len - sent;
        if (chunk > ADAPTER_CHUNK)
            chunk = ADAPTER_CHUNK;
        adapter_write(buf + sent, chunk);   /* blocking 2E WRITE1 */
        sent += chunk;
    }
    DBG((CONST_STRPTR)"transport_write(%ld) -> %ld\n", (LONG)len, (LONG)sent);
    return (LONG)sent;
}

LONG transport_poll_rx(UBYTE *out)
{
#if RX_ENABLED
    if (!rx_data_pending())
        return 0;
    adapter_read(out, 1);                   /* blocking 2E READ1, one byte */
    return 1;
#else
    (void)out;
    return 0;                               /* RX gated off until doorbell verified */
#endif
}

#else
/* ===================== Milestone 1: STUB transport ====================== */

BOOL transport_init(void)
{
    DBG((CONST_STRPTR)"transport_init() [STUB]\n");
    return TRUE;
}

void transport_shutdown(void)
{
    DBG((CONST_STRPTR)"transport_shutdown() [STUB]\n");
}

LONG transport_write(const UBYTE *buf, ULONG len)
{
    (void)buf;
    DBG((CONST_STRPTR)"transport_write(%ld) [STUB: discarded]\n", (ULONG)len);
    return (LONG)len;          /* pretend everything went out */
}

LONG transport_poll_rx(UBYTE *out)
{
    (void)out;
    return 0;                  /* no hardware -> never any RX data */
}

#endif /* PAR2SER_HW */
