/*
 * transport.h -- byte-pipe interface between par2ser.device and the
 *                parallel-port adapter (Niklas's 2E protocol -> FT240X).
 *
 * The device layer never speaks the wire protocol directly; it only calls
 * these four functions. The stub bodies (no PAR2SER_HW) let kermit be
 * exercised in WinUAE with no hardware. The real implementation (PAR2SER_HW)
 * wraps the low-lib adapter transport: chunked WRITE1 commands for
 * transport_write(), and a single READ1 per CIA-A /FLAG interrupt for
 * transport_poll_rx().
 */
#ifndef TRANSPORT_H
#define TRANSPORT_H

#include <exec/types.h>

/* RX gate. While 0, no receive interrupt is installed and
 * transport_poll_rx() is inert; TX is unaffected. Set to 1 for the
 * cia.resource FLAG ICR receive path (one byte per /FLAG, hardware
 * self-retriggering via the CPLD's IDLE-gated ACK). Keep in sync with the
 * RX code path in transport.c. */
#define PAR2SER_RX_ENABLED 1

/* One-time setup / teardown. transport_init() returns FALSE on failure
 * (e.g. parallel port resource busy). Called from device Open/Close. */
BOOL transport_init(void);
void transport_shutdown(void);

/* Push len bytes to the adapter (FT240X TX FIFO, respecting /TXE).
 * Blocking 2E transfer. Returns the number of bytes actually sent. */
LONG transport_write(const UBYTE *buf, ULONG len);

/* Pull one received byte. In the hardware build this reads exactly one byte
 * unconditionally (the caller is the FLAG ICR handler, and /FLAG firing IS
 * the "byte available" signal -- there is no readable doorbell level).
 * Returns 1 and stores into *out; returns 0 only when RX is gated off or in
 * the stub build. Called once per CIA-A /FLAG from the cia.resource ICR handler. */
LONG transport_poll_rx(UBYTE *out);

/* Kick the RX doorbell after the FLAG interrupt is enabled. CIA-A /FLAG
 * latches on a FALLING EDGE only: if the FT240X already held data before
 * AbleICR (ACK already low), no edge ever occurs and RX stays dormant until
 * the first command cycles the CPLD FSM. This issues one harmless control
 * command (speed=slow, an FT240X SIWU flush) purely to cycle the FSM through
 * IDLE -- if data is pending, ACK re-asserts on the return to IDLE and the
 * fresh edge fires FLAG. No-op when the FIFO is empty. Task context only. */
void transport_rx_prime(void);

#endif /* TRANSPORT_H */
