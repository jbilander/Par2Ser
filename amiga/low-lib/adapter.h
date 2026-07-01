/*
 * adapter.h -- low-level wire interface to the Par2Ser parallel-port adapter.
 *
 * Derived from Niklas Ekström's spi.h (April 2020 / July 2021). The transport
 * here is Niklas's 2E par-adapter protocol, NOT SPI: on Par2Ser there is no
 * SPI peripheral, no chip-select, and no SD card. The command encoding
 * (WRITE1 00xxxxxx / READ1 01xxxxxx, length in the low 6 bits) is unchanged,
 * so the bit-level transfer code is his; only the SD-card-specific parts
 * (chip-select, card-present, and the CIA-A FLAG "card change" interrupt)
 * have been removed -- on Par2Ser the FLAG line is the FT240X RX doorbell and
 * is owned by par2ser.c's INTB_PORTS receive server, not by this layer.
 *
 * Transfer paths: two implementations, selected by adapter_set_speed().
 *   SLOW = C bit-bang with a per-byte delay (adapter_*_slow).
 *   FAST = tight-loop assembly with no inter-byte delay (adapter_low.s).
 * The original slow/fast labels meant the AVR's SPI clock to the SD card
 * (250 kHz / 8 MHz); those frequencies do NOT apply to Par2Ser (12 MHz CPLD,
 * no SPI). Here the only difference is inter-byte delay vs none -- both are
 * kept because FAST is a meaningful throughput win and costs nothing to
 * retain. SLOW is the default after adapter_init() and is the safe, debuggable
 * bring-up path. (The SPEED_SLOW/SPEED_FAST names are a mild SPI-era holdover.)
 */
#ifndef ADAPTER_H
#define ADAPTER_H

#include <exec/types.h>

#define ADAPTER_SPEED_SLOW 0
#define ADAPTER_SPEED_FAST 1

/* Grab the parallel port (misc.resource) and set the CIA lines to the idle
 * state the protocol expects. Returns 0 on success, negative on failure:
 *   -1 misc.resource unavailable
 *   -3 MR_PARALLELPORT busy
 *   -4 MR_PARALLELBITS busy
 * NOTE: unlike Niklas's spi_initialize(), this does NOT install any CIA-A
 * FLAG interrupt and does NOT probe for a card. The caller (par2ser.c) owns
 * the FLAG/INTB_PORTS receive path. */
int  adapter_init(void);

/* Release the parallel port and float the CIA lines. Safe to call even if
 * adapter_init() partially failed. Does not touch any interrupt vector. */
void adapter_shutdown(void);

/* Select transfer path: ADAPTER_SPEED_SLOW (C bit-bang, per-byte delay) or
 * ADAPTER_SPEED_FAST (tight-loop asm, no delay). SLOW by default after
 * adapter_init(). Not an adapter clock rate -- see the header comment. */
void adapter_set_speed(long speed);

/* Blocking block transfer. 1 <= size <= 64 for a single WRITE1/READ1 command
 * on the current CPLD (the WRITE2/READ2 >64 path is not implemented in the
 * Par2Ser FSM -- callers must chunk at 64). Register-pinned (a0=buf, d0=size)
 * to match the fast-path assembly in adapter_low.s. */
void adapter_read (UBYTE *buf       asm("a0"), ULONG size asm("d0"));
void adapter_write(const UBYTE *buf asm("a0"), ULONG size asm("d0"));

#endif /* ADAPTER_H */
