/*
 * transport.c -- STUB transport for par2ser.device (Milestone 1).
 *
 * Lets you load par2ser.device and run kermit's `set line` / status
 * negotiation in WinUAE with NO hardware attached:
 *   - transport_write()  : swallows bytes, reports them all "sent"
 *   - transport_poll_rx(): never returns data (RX stays empty)
 *
 * MILESTONE 2 -- real hardware:
 *   Add Niklas's spi-lib (spi.c / spi_low.asm / spi.h) to OBJECTS and replace
 *   the stub bodies below. The wire protocol is unchanged from his AVR repo,
 *   so spi_low.asm is reused verbatim (the D0-5/D6-7 split is invisible on the
 *   Amiga side). Sketch:
 *
 *     #include "spi.h"
 *     BOOL transport_init(void)  { return spi_initialize(NULL) == 0; }
 *     void transport_shutdown(void) { spi_shutdown(); }
 *     LONG transport_write(const UBYTE *b, ULONG n) { spi_write((UBYTE*)b, n); return n; }
 *     LONG transport_poll_rx(UBYTE *out) {
 *         // requires a CPLD status command (free cmd slot 3+) that exposes /RXF,
 *         // OR drive CIA-A FLAG from /RXF and read one byte per FLAG. Then:
 *         //   if (!rx_available()) return 0;
 *         //   spi_read(out, 1); return 1;
 *     }
 *
 * Note: spi-lib's spi_read(buf,size) wants a known count. For a stream we read
 * one byte at a time while the adapter says a byte is available -- which is why
 * transport_poll_rx is the single-byte primitive the ISR loops on.
 */

#include "transport.h"

#if DEBUG
extern void KPrintF(CONST_STRPTR fmt, ...);
#define DBG(...) KPrintF((CONST_STRPTR)__VA_ARGS__)
#else
#define DBG(...)
#endif

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
