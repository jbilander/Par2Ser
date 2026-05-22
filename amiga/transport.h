/*
 * transport.h -- byte-pipe interface between par2ser.device and the
 *                parallel-port adapter (Niklas's 2E protocol -> FT240X).
 *
 * The device layer never speaks the wire protocol directly; it only calls
 * these four functions. Today they are stubbed (transport.c) so kermit can be
 * exercised in WinUAE with no hardware. The real implementation wraps Niklas's
 * spi-lib transport (spi_low.asm): a WRITE command for transport_write(), and a
 * READ command driven by the /RXF line for transport_poll_rx().
 */
#ifndef TRANSPORT_H
#define TRANSPORT_H

#include <exec/types.h>

/* One-time setup / teardown. transport_init() returns FALSE on failure
 * (e.g. parallel port resource busy). Called from device Open/Close. */
BOOL transport_init(void);
void transport_shutdown(void);

/* Push len bytes to the adapter (FT240X TX FIFO, respecting /TXE).
 * Blocking 2E transfer. Returns the number of bytes actually sent. */
LONG transport_write(const UBYTE *buf, ULONG len);

/* Pull one received byte if the adapter has one ready (/RXF asserted).
 * Returns 1 and stores into *out if a byte was read, 0 if none available.
 * Called in a tight loop from the INTB_PORTS receive interrupt server. */
LONG transport_poll_rx(UBYTE *out);

#endif /* TRANSPORT_H */
