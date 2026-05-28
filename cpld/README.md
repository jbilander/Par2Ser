# Par2Ser CPLD Verilog

Milestone-1 implementation of the Par2Ser bridge for the Lattice LC4032V-5TN48C.
Ports Niklas Ekstrom's 2E parallel-port protocol (from amiga-par-to-spi-adapter)
into Verilog, bridged to an FT240X USB FIFO.

## Files

- **par2ser_top.v** — Top-level. Pin declarations, input synchronizers, edge
  detectors, tristate drivers (with reset-aware OE), and FSM instantiation.
- **par2ser_fsm.v** — Transaction FSM. Decodes the command byte, handles the
  READ and WRITE per-byte loops clocked by POUT, drives BUSY/ACK back to the
  Amiga, and generates RD#/WR strobes for the FT240X.
- **par2ser.lci** — ispLEVER Classic pin constraints, mechanically derived
  from the schematic netlist.

## Architecture decisions worth knowing

**Clock source.** The CPLD is clocked at 12 MHz from FT240X CBUS5 (CLKOUT
function, configured in FT_PROG). POUT is NOT the clock — it's a synchronized
input with any-edge detection ("one POUT transition = one byte advances").
This sidesteps the dual-edge problem of using POUT as a literal clock.

**Reset.** Amiga `_IORESET` is sensed on CLK1/I (CPLD pin 18), synchronized,
and used to force all driven outputs to high-Z plus snap the FSM to IDLE.
This ensures the CPLD releases the parallel bus during an Amiga reboot.

**Tristate.** All bus tristates are done in per-pin logic with a reset gate
on each OE. We have GOE0 and GOE1 free as a fallback if macrocell pressure
ever demands the hardware global-OE path.

**RX-ready interrupt.** The Amiga driver expects an interrupt when a byte
arrives from the PC. We drive `amiga_ack_n` (open-drain to CIA-A FLAG) low
whenever the FT240X has data waiting (RXF# low) AND we're in IDLE. The H->L
edge triggers /FLAG and the driver's INTB_PORTS handler reads the byte.

**Milestone-1 scope.** Only READ1 and WRITE1 commands (counts 1..64) are
implemented. READ2/WRITE2 (long-form, >64 bytes) and the control-command
space (D7=D6=1) reach states that idle cleanly on REQ release but are
no-ops. Extend these once basic byte flow is proven on hardware.

## Bring-up sequence

1. **Build in ispLEVER Classic.** Confirm the fit:
   - The fitter report should show all pins located as specified.
   - Read the macrocell utilization. The LC4032V has 32 macrocells; the
     FSM with byte counter (14-bit), LED stretch counters (2x 18-bit), and
     synchronizers is at the edge of what fits. If it overflows, the
     pin-compatible LC4064V (same 48-TQFP, 64 macrocells) is a drop-in.
   - Confirm "Unused I/O" default is "Input with pull-up" in the
     fitter/global settings.

2. **Generate JEDEC, convert nothing** — we program direct via ispVM System
   with the FT4232H-as-FTDI cable (Interface 0 on FTDI driver), or with a
   genuine HW-USBN-2A/2B if available.

3. **Bring-up tests, in order:**
   a. Power the board (USB-C plugged in). The PWR LED should light, the
      CPLD should enumerate via JTAG (scan in ispVM returns the LC4032V
      IDCODE). The FT240X should enumerate as a COM port in Windows.
   b. With the board on the Amiga parallel port and par2ser.device loaded,
      `set line par2ser.device` in kermit. The driver trace (KPrintF)
      should show open + SDCMD_QUERY succeeding as it did in Milestone 1.
   c. `connect` and type. The TX LED should blink per keystroke (Amiga ->
      PC). On the PC side, the COM port should receive the bytes.
   d. Send bytes from the PC side. The RX LED should blink and the bytes
      should arrive in par2ser.device's ring buffer.

4. **What can fail and how to read it:**
   - PWR LED off: power section issue, not CPLD.
   - ispVM IDCODE scan fails: JTAG wiring or driver binding.
   - LEDs never blink on Amiga traffic: FSM not entering DECODE, likely
     SELECT sync or pin assignment issue. Add a state-debug LED if needed.
   - TX works but RX doesn't: ACK/INTB_PORTS path. Check `drive_ack`
     logic in the FSM and that the driver has the rx_install code path
     enabled (`-DPAR2SER_HW`).
   - Garbled bytes: lane integrity (verify D0..D7 mapping end-to-end in
     fitter report).

## What's deferred

- **READ2/WRITE2** for byte counts >64. Niklas's longer-transaction form;
  not needed for terminal-rate serial traffic but useful for bulk transfers.
- **Control command** for FT240X status query (D7=D6=1 space). Would let
  the driver poll exact FT240X FIFO state instead of just `/RXF`.
- **Latency-timer-aware SIWU#** to force-flush short PC-bound responses.
  Currently SIWU# is tied to 3V3 (deasserted); driving it from the FSM
  could reduce small-packet latency at the cost of one more output pin.

## Conventions

- All registered logic is `always @(posedge clk)` with synchronous reset
  feeding into the IDLE state. The exception is the reset synchronizer
  itself, which has an async assert + sync deassert pattern.
- Tristate drivers use ternary `(oe ? value : 1'bz)` per-pin, gated by
  reset. The top-level explicitly forces high-Z during reset.
- No latches, no combinational feedback loops. The fitter should produce
  a clean register-only synthesis.
