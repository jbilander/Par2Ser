# par2ser.device

A `serial.device`-compatible driver that bridges the Amiga parallel port to a
USB FIFO (FT240X) via Niklas Ekström's 2E par-to-spi protocol, so unmodified
comms programs (c-kermit, NComm, …) can `set line par2ser.device`.

Built in the style of [SimpleDevice](https://github.com/jbilander/SimpleDevice)
for the Bartman `m68k-amiga-elf` (gcc 15.1) toolchain. The serial machinery
(receive ring buffer, `CMD_READ` satisfied from buffer, `SDCMD_QUERY` count from
a software counter) is ported from Iain Barclay's `8n1.device` 43.5.

## Files
- `par2ser.c` — device skeleton + serial command set + receive ring buffer
- `transport.h` / `transport.c` — byte-pipe to the adapter (**stubbed** for now)
- `debug.c` — `KPrintF` over `RawDoFmt`/`RawPutChar` (verbatim from SimpleDevice)
- `Makefile`

## Build
```
make debug      # build-debug/par2ser.device, with KPrintF tracing
make release    # build-release/par2ser.device, stripped
```
Adjust `INCDIRS` for your NDK path as in SimpleDevice.

## Milestone 1 — does kermit accept it? (no hardware needed)
1. `make debug`, copy `build-debug/par2ser.device` to `DEVS:` in WinUAE.
2. Open a serial debug console (the same `RawPutChar` path SimpleDevice uses).
3. In kermit: `set line par2ser.device`. Watch the trace — you should see
   `do_open()`, then the commands kermit issues (`SDCMD_SETPARAMS`,
   `SDCMD_QUERY`, …) with their parameters and the status word we return.

In this milestone `transport_write()` discards bytes (reports them sent) and no
RX data ever arrives, so a `CMD_READ` will stay pending — expected with no
hardware. The goal here is purely to confirm acceptance and observe the
negotiation, especially the carrier check.

## Carrier / `/CD` handling
kermit checks carrier-detect before it will use the line. We have no real CIA
serial lines on the parallel port, so `SDCMD_QUERY` **synthesizes** the status
word. `serial.device` returns the raw (active-low) CIA-B control lines, i.e.
`0` = signal asserted, so the default `ST_CARRIER_PRESENT = 0` reports
CD/CTS/DSR all asserted.

The full word is `KPrintF`'d in `sdcmd_Query`, so if kermit still reports
**NO CARRIER**, flip the polarity in `par2ser.c`:
```c
#define ST_CARRIER_PRESENT  ST_CD   /* try this if 0 doesn't satisfy kermit */
```
and compare the logged status against what kermit expects.

## Milestone 2 — real adapter
1. Add Niklas's `spi.c`, `spi_low.asm`, `spi.h` to the project.
2. In the `Makefile`, uncomment `-DPAR2SER_HW` and the `spi.o spi_low.o` objects.
3. Replace the stub bodies in `transport.c` (sketch is in that file). `spi_low.asm`
   is reused unchanged — the protocol is identical to the AVR repo, and the
   D0–5/D6–7 data split is invisible on the Amiga side.

`-DPAR2SER_HW` also compiles in the CIA-A FLAG receive interrupt server
(`INTB_PORTS`): the adapter pulses its IRQ line (the ACK pin Niklas uses for
card-present) when the FT240X RX FIFO is non-empty, the server drains it into
the ring buffer and completes pending reads — the same event-driven model the
OS expects, with clients `Wait()`ing on their reply ports.
