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
 * Controlled by PAR2SER_RX_ENABLED in transport.h (shared with par2ser.c,
 * which gates the FLAG ICR vector install on the same switch). While off,
 * transport_poll_rx() is inert and no receive interrupt is hooked. */
#define RX_ENABLED PAR2SER_RX_ENABLED

/* RX model: there is NO readable doorbell bit. The adapter's ACK (open-drain,
 * DB25 pin 10) goes only to CIA-A /FLAG, an interrupt-only input -- confirmed
 * against the KiCad netlist (CPLD pin 31 -> J1 pin 10, nothing else). The
 * FLAG interrupt itself is the "data available" signal: par2ser.c registers
 * on the FLAG ICR bit via cia.resource, and its handler calls
 * transport_poll_rx() exactly once per FLAG. We read one byte
 * unconditionally; if the FIFO holds more, the CPLD re-asserts ACK when its
 * FSM returns to idle (drive_ack = S_IDLE & has_data), producing a fresh
 * /FLAG falling edge and another handler call. Self-clocking, no loop. */

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
        /* Mask interrupts around each chunk: transport_write runs in task
         * context and the FLAG ICR handler issues READ1s from interrupt
         * context -- a FLAG mid-WRITE1 would interleave two transactions on
         * the same CIA lines and corrupt the FSM handshake. Masking lives
         * HERE (task side), never inside the adapter transfer functions,
         * because the ICR handler also calls those and Enable() inside an
         * interrupt handler causes recursive re-entry (see adapter.c). Per
         * chunk (<= 64 bytes, ~3 ms slow-path) rather than around the whole
         * write, so RX latency stays bounded. */
        Disable();
        adapter_write(buf + sent, chunk);   /* blocking 2E WRITE1 */
        Enable();
        sent += chunk;
    }
    DBG((CONST_STRPTR)"transport_write(%ld) -> %ld\n", (LONG)len, (LONG)sent);
    return (LONG)sent;
}

LONG transport_poll_rx(UBYTE *out)
{
#if RX_ENABLED
    /* Called from the FLAG ICR handler: FLAG fired, so the adapter had a
     * byte when its FSM was idle. Read exactly one -- unconditionally,
     * because /FLAG is not a readable level, only an edge-latched event. */
    adapter_read(out, 1);                   /* blocking 2E READ1, one byte */
    return 1;
#else
    (void)out;
    return 0;                               /* RX gated off */
#endif
}

void transport_rx_prime(void)
{
#if RX_ENABLED
    /* One harmless CTRL command (0xc4 = speed slow -> FT240X SIWU flush) to
     * cycle the FSM out of and back into IDLE. If RX data was already
     * waiting before the FLAG interrupt was enabled, ACK was held low with
     * no edge for the CIA to latch; the IDLE re-entry re-asserts ACK and
     * generates the missing falling edge. Empty FIFO -> no edge -> no-op. */
    adapter_set_speed(ADAPTER_SPEED_SLOW);
    DBG((CONST_STRPTR)"transport_rx_prime()\n");
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

void transport_rx_prime(void)
{
    /* stub: nothing to prime */
}

#endif /* PAR2SER_HW */
