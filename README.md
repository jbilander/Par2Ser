# par2ser.device

> ⚠️ **Status: Pre-release / untested on real hardware.**
> This project is being made public as a work-in-progress. The Verilog and
> driver code have only been validated in simulation and WinUAE. **No Rev 2A
> board has been fabricated or tested yet.** Expect bugs, expect to need an
> oscilloscope, and **build at your own risk** — there are no tagged
> releases until the hardware is verified to work end-to-end. PRs and
> issues are welcome but be aware the design may still change in
> incompatible ways before the first release.

A `serial.device`-compatible Amiga driver that bridges the parallel port to a
USB FIFO (FT240X) via Niklas Ekström's 2E par-to-spi protocol, so unmodified
comms programs (c-kermit, NComm, …) can `set line par2ser.device`.

The hardware side is a small board built around a Lattice **LC4064V-75TN48C**
CPLD that speaks the 2E protocol to the Amiga and presents the bytes to an
**FT240X** USB FIFO. The PC sees a standard USB serial port (VCP).

## Repository layout

- **`amiga/`** — `par2ser.device` driver source (m68k, Bartman gcc).
- **`cpld/`** — Verilog firmware for the Lattice LC4064V CPLD.
  - `rtl/` — design sources (`par2ser_top.v`, `par2ser_fsm.v`).
  - `sim/` — Icarus Verilog smoke testbench.
  - `isplever/` — Lattice ispLEVER Classic 2.1 project files and pin
    constraints (`Par2Ser.lci`).
- **`hardware/`** — KiCad schematic and PCB (Rev 2A).

## Hardware overview (Rev 2A)

- **Lattice LC4064V-75TN48C** CPLD (48-pin TQFP, 64 macrocells, -75 speed)
- **FTDI FT240X** USB-to-parallel-FIFO (SSOP-24), USB-C connector
- **8-bit bidirectional buffer** between the Amiga DB-25 and the CPLD
- **JTAG header** for programming the CPLD via ispVM System with a
  cheap FT4232H-mini-module-based cable

The driver is built in the style of [SimpleDevice](https://github.com/jbilander/SimpleDevice)
for the Bartman `m68k-amiga-elf` (gcc 15.1) toolchain. The serial machinery
(receive ring buffer, `CMD_READ` satisfied from buffer, `SDCMD_QUERY` count
from a software counter) is ported from Iain Barclay's `8n1.device` 43.5.

## Files (amiga/)

- `par2ser.c` — device skeleton + serial command set + receive ring buffer
- `transport.h` / `transport.c` — byte-pipe to the adapter (**stubbed** for now)
- `debug.c` — `KPrintF` over `RawDoFmt`/`RawPutChar` (verbatim from SimpleDevice)
- `Makefile`

## Build (amiga/)

```sh
cd amiga
make debug      # build-debug/par2ser.device, with KPrintF tracing
make release    # build-release/par2ser.device, stripped
```

Adjust `INCDIRS` for your NDK path as in SimpleDevice.

## Programming the FT240X (one-time, before first use)

The CPLD needs a 12 MHz clock from the FT240X to operate. By default the
FT240X's CBUS5 pin is not configured as a clock output — you have to set
its function in the chip's internal MTP (one-time-programmable) memory
using FTDI's FT_PROG utility.

### What you'll need
- FTDI **FT_PROG** (free download from <https://ftdichip.com/utilities/>)
- The Rev 2A board, powered via USB, on a Windows machine (FT_PROG is
  Windows-only; users on Linux/macOS can use a Windows VM, or the
  open-source `ftdi_eeprom` from libftdi as an alternative)

### Steps

1. Plug the Rev 2A board into a Windows PC via USB-C. Windows should
   detect the FT240X and bind the default VCP driver, presenting a
   COM port.

2. Launch FT_PROG. Click **Devices → Scan and Parse**. Your FT240X should
   appear in the device tree as something like *"FT240X (Device 0)"*.

3. In the device tree, navigate to **Hardware Specific → CBUS Signals**.

4. Set **C5** (CBUS5) to **`CLK12MHz`** from the drop-down. The other
   CBUS pin (C6) can be left at its default (`TRI-STATE`) or set to
   `SLEEP#` if you want a power-state indicator — it doesn't matter for
   the bridge's operation.

5. Optionally update the **USB String Descriptors** to identify the
   device as a Par2Ser (e.g. set the Product Description to
   *"Par2Ser USB Serial"*). Useful when several FTDI devices are plugged
   into the same host.

6. Click **Devices → Program** (the lightning-bolt icon). The settings
   are written to the FT240X's MTP memory. **This is a one-time step
   per board** — the configuration persists across power cycles.

7. Unplug and replug the board. Windows will re-enumerate the device.
   You should hear the USB plug/unplug sound; the CPLD should now be
   receiving its 12 MHz clock and the on-board PWR LED should be lit.

### Verifying the configuration
- The CPLD is unprogrammed when shipped from JLC/your PCB house, so no
  parallel-port activity will happen yet — but the CBUS5 clock should
  still be driving the CPLD's clock pin. With an oscilloscope on the
  clock trace, you should see a clean 12 MHz square wave.
- The PC should see the board as a standard USB serial port (VCP).
  On Linux this is `/dev/ttyUSB0` (or similar); on macOS it's
  `/dev/cu.usbserial-*`; on Windows it's a COM port number visible in
  Device Manager.

### Linux/macOS alternative (libftdi)
On non-Windows systems, the same MTP programming can be done with
`ftdi_eeprom` from the `libftdi` package. You'll need a small config
file pointing at the FT240X and setting `cbus5=CLK12`. See the libftdi
documentation for the exact syntax — this hasn't been tested by the
author, so YMMV.

## Milestone 1 — does kermit accept it? (no hardware needed) ✅

This milestone is **done**. It validates the driver in WinUAE without
any hardware:

1. `make debug` in `amiga/`, copy `build-debug/par2ser.device` to `DEVS:`
   in WinUAE.
2. Open a serial debug console (the same `RawPutChar` path SimpleDevice
   uses).
3. In kermit: `set line par2ser.device`. The trace shows `do_open()`,
   then the commands kermit issues (`SDCMD_SETPARAMS`, `SDCMD_QUERY`, …)
   with their parameters and the status word we return.

In this milestone `transport_write()` discards bytes (reports them sent)
and no RX data ever arrives, so a `CMD_READ` will stay pending — expected
with no hardware. The goal is purely to confirm acceptance and observe
the negotiation, especially the carrier check.

## Carrier / `/CD` handling

kermit checks carrier-detect before it will use the line. We have no real
CIA serial lines on the parallel port, so `SDCMD_QUERY` **synthesizes**
the status word. `serial.device` returns the raw (active-low) CIA-B
control lines, i.e. `0` = signal asserted, so the default
`ST_CARRIER_PRESENT = 0` reports CD/CTS/DSR all asserted.

The full word is `KPrintF`'d in `sdcmd_Query`, so if kermit reports
**NO CARRIER**, flip the polarity in `par2ser.c`:
```c
#define ST_CARRIER_PRESENT  ST_CD   /* try this if 0 doesn't satisfy kermit */
```
and compare the logged status against what kermit expects.

## Milestone 2 — real adapter (in progress) 🚧

1. Build the CPLD firmware in ispLEVER Classic 2.1 — see `cpld/README.md`
   for details. The result is a `par2ser.jed` file.
2. Program the FT240X's CBUS5 to CLK12MHz output (see above).
3. Program the CPLD via ispVM System using a JTAG cable.
4. Add Niklas's `spi.c`, `spi_low.asm`, `spi.h` to the Amiga driver
   project (sources live in his
   [amiga-par-to-spi-adapter](https://github.com/niklasekstrom/amiga-par-to-spi-adapter)
   repo).
5. In the `Makefile`, uncomment `-DPAR2SER_HW` and the
   `spi.o spi_low.o` objects.
6. Replace the stub bodies in `transport.c` (sketch in that file).
   `spi_low.asm` is reused unchanged — the protocol is identical to the
   AVR repo, and the D0–5/D6–7 data split is invisible on the Amiga
   side.

`-DPAR2SER_HW` also compiles in the CIA-A FLAG receive interrupt server
(`INTB_PORTS`): the adapter pulses its IRQ line (the ACK pin Niklas
uses for card-present) when the FT240X RX FIFO is non-empty, the server
drains it into the ring buffer and completes pending reads — the same
event-driven model the OS expects, with clients `Wait()`ing on their
reply ports.

## Credits

- **Niklas Ekström** — the 2E par-to-spi protocol and the SDBox
  adapter that this project is derived from. See his
  [amiga-par-to-spi-adapter](https://github.com/niklasekstrom/amiga-par-to-spi-adapter).
- **Iain Barclay** — `8n1.device` 43.5, the serial machinery template.
- **Bartman** — the `m68k-amiga-elf` toolchain and SimpleDevice template.

## License

Licensed under [Creative Commons Attribution-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/)
(CC-BY-SA 4.0). You're free to use, modify, and redistribute this work
(including commercially), provided you give appropriate credit and
distribute derivative works under the same license.

Consistent with Niklas Ekström's
[amiga-par-to-spi-adapter](https://github.com/niklasekstrom/amiga-par-to-spi-adapter)
upstream.
