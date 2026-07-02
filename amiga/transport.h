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

/* RX bring-up gate. While 0, the RX doorbell is treated as unverified: the
 * device installs NO INTB_PORTS receive server and transport_poll_rx() is
 * inert, so a stuck/misread FLAG line cannot storm interrupts or wedge the
 * machine at open. TX is unaffected. Flip to 1 only after the doorbell bit
 * and polarity are confirmed against the Rev 2A schematic. Keep this in sync
 * with the RX code path in transport.c. */
#define PAR2SER_RX_ENABLED 0

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
