# Par2Ser CPLD Verilog

Verilog implementation of the Par2Ser bridge for the Lattice
**LC4064V-75TN48C** (ispMACH 4000V, 48-pin TQFP, 64 macrocells, -75 speed
grade). Ports Niklas Ekström's 2E parallel-port protocol (from
[amiga-par-to-spi-adapter](https://github.com/niklasekstrom/amiga-par-to-spi-adapter))
into Verilog, bridged to an FT240X USB FIFO.

> ⚠️ **Untested on real hardware.** Verified in Icarus Verilog simulation
> (WRITE smoke test and READ-hold test pass) and in the ispLEVER fitter.
> No board has been built yet — bring-up may reveal issues that simulation
> didn't catch.

## Files

- **`rtl/par2ser_top.v`** — Top-level. Pin declarations, input
  synchronizers, edge detectors, tristate drivers (with reset-aware OE),
  and FSM instantiation. Drives the LED outputs and the FT240X SIWU#
  signal.
- **`rtl/par2ser_fsm.v`** — Transaction FSM, **one-hot encoded** for
  better product-term sharing on the LC4064V. Decodes the command byte,
  handles the READ and WRITE per-byte loops clocked by POUT, drives
  BUSY/ACK back to the Amiga, and generates RD#/WR strobes for the
  FT240X.
- **`sim/par2ser_tb.v`** — Icarus Verilog smoke testbench (WRITE1 path).
- **`isplever/Par2Ser.lci`** — ispLEVER Classic pin/IO-type constraints
  (tracked); `Par2Ser.lct` is the tool's working copy (not tracked).

## Current fit status

```
Device:       LC4064V-75TN48C  (-75 speed grade)
Macrocells:   62 of 64        (97% — 2 cells of headroom)
Registers:    48
Product terms: 118
Timing:       worst path 11.20 ns vs 83.33 ns budget @ 12 MHz
              -> 72 ns slack, runs comfortably at the clock target
```

## Architecture decisions worth knowing

**Clock source.** The CPLD is clocked at 12 MHz from FT240X CBUS5 (CLKOUT
function, configured in FT_PROG — see top-level README). POUT is NOT the
clock — it's a synchronized input with any-edge detection ("one POUT
transition = one byte advances"). This sidesteps the dual-edge problem of
using POUT as a literal clock.

**Reset.** Amiga `_IORESET` is sensed on CLK1/I (CPLD pin 18), buffered
to 3.3 V externally, synchronized inside the CPLD, and used to force all
driven outputs to high-Z plus snap the FSM to IDLE. This ensures the
CPLD releases the parallel bus during an Amiga reboot.

**FSM encoding.** One-hot, 9 states (IDLE, DECODE, WRITE_WAIT,
WRITE_LATCH, WRITE_FT, READ_FETCH, READ_PRESENT, DRAIN, CTRL). Each
`state == N` test becomes a single wire instead of a 4-bit AND tree.
On this CPLD that reduced product terms from ~195 (binary FSM) to ~118
(one-hot), which is what enables all three activity LEDs to fit. Each
state bit has both an entry term and an explicit hold term
`state[N] & ~exit_condition` — without those, waiting states would clear
themselves after one cycle and the FSM would die.

**Tristate.** All bus tristates are done in per-pin logic with a reset
gate on each OE — not via the hardware GOE0/GOE1 nets. The two
dual-function pins (pin 41 = D14/GOE1, pin 44 = A0/GOE0) are otherwise
used as plain I/O: pin 44 is the SIWU# output to the FT240X; pin 41 is
unused and available.

**RX-ready interrupt.** The Amiga driver expects an interrupt when a
byte arrives from the PC. We drive `amiga_ack_n` (open-drain to
CIA-A FLAG) low whenever the FT240X has data waiting (RXF# low) AND
we're in IDLE. The H->L edge triggers /FLAG and the driver's
`INTB_PORTS` handler reads the byte.

**SIWU# (FT240X Send Immediate).** The Amiga driver can request an
FT240X TX buffer flush by issuing a control command (D7=1, D6=1 in the
command byte). The FSM enters S_CTRL and holds SIWU# low for the
duration of the command; the FT240X acts on the falling edge to flush
its TX FIFO to USB immediately rather than waiting for its 16 ms
latency timer. Useful for snappy interactive response (single-keystroke
echoes) without globally lowering the FT240X latency timer on the host
side.

**Activity LEDs.** All three LEDs are combinational decodes of existing
FSM signals — zero added flops:
- `led_act` = `~state[S_IDLE]` (any transaction in progress)
- `led_tx`  = `drive_ft_d`    (we are driving the FT bus, i.e. writing
                              a byte out)
- `led_rx`  = `drive_amiga_d` (we are driving the Amiga bus, i.e.
                              presenting a byte in)

Visible during sustained traffic (typing, file transfers). Single
isolated bytes pass through too quickly (~10–50 µs) to be visible by
themselves; this is the same "lit while active" approach used in the
[SDBox-v2 AVR firmware fork](https://github.com/jbilander/amiga-par-to-spi-adapter/blob/master/avr/main.c)
where the LED is asserted together with the SPI chip-select for the
duration of a transaction.

**Milestone-1 scope.** Only READ1 and WRITE1 commands (counts 1–64) are
implemented. READ2/WRITE2 (long-form, >64 bytes) and the broader
control-command space (D7=1, D6=1) reach states that idle cleanly on
REQ release; only the SIWU# flush function of CTRL is wired in. Extend
these once basic byte flow is proven on hardware. Adding READ2/WRITE2
would need roughly +10 macrocells which **will not fit** the LC4064V at
the current utilization — that's a feature for an LC4128V (different
package, board respin) or an RP2350-based redesign.

## Building

You need **ispLEVER Classic 2.1** (Lattice's free legacy toolchain,
Windows-only). Open `isplever/Par2Ser.syn` in the Project Navigator,
then **Process → Fit Design**. The tool runs synthesis (LSE), fits,
and generates `par2ser.jed`.

The `Par2Ser.lci` constraint file in this repo carries:
- Pin assignments matching the Rev 2A schematic
- IO types (LVTTL for most, LVTTL_5V for the `rst_n` input, LVCMOS33_OD
  for the open-drain `amiga_ack_n` output)
- SLOW slew rate on all outputs
- Timing constraint: 83.33 ns clock period (12 MHz)

The `Par2Ser.lct` file is the tool's working copy and is regenerated on
load — it is not tracked in git.

## Programming the CPLD

The CPLD is programmed via JTAG using **ispVM System** (also part of the
free ispLEVER toolchain). A cheap FT4232H-Mini-Module can act as the
JTAG cable: with the FTDI driver bound to channel A (interface 0), ispVM
sees it as a generic FTDI cable and can scan/program the device.

The recommended bring-up sequence:

1. Power the board via USB-C. The PWR LED should light.
2. With ispVM connected, **Scan Board** — the LC4064V's IDCODE should
   appear in the chain.
3. **Add Device → par2ser.jed**, then **Program**. The chain status
   should update to "PASS".

## Simulation

The smoke testbench in `sim/par2ser_tb.v` exercises a WRITE1 single-byte
path: command 0x01, drives POUT, checks that a WR pulse appears on the
FT side and that BUSY behaves correctly through REQ assert/deassert.
Run with Icarus Verilog:

```sh
cd cpld
iverilog -g2005 -o sim_par2ser rtl/par2ser_top.v rtl/par2ser_fsm.v sim/par2ser_tb.v
vvp sim_par2ser
```

Expected output ends with `WR pulses observed: 1 (expected >= 1)` and
`BUSY after release: 1 (expected 1/z)`.

## Bring-up sequence (on real hardware — pending)

1. **Confirm the fit** (already done — 62/64 macrocells).
2. **Generate JEDEC** — Process → Fit produces `par2ser.jed` in the
   ispLEVER working directory.
3. **Hardware sanity:**
   a. Power the board (USB-C plugged in). PWR LED on. CPLD should
      enumerate via JTAG (scan in ispVM returns the LC4064V IDCODE).
      The FT240X should enumerate as a VCP COM port (assuming CBUS5
      is configured for CLK12MHz — see top-level README).
   b. With the board on the Amiga parallel port and `par2ser.device`
      loaded, `set line par2ser.device` in kermit. The driver trace
      (KPrintF) should show open + SDCMD_QUERY succeeding as it did
      in Milestone 1.
   c. `connect` and type. The TX LED should light during keystrokes
      (Amiga → PC). On the PC side, the COM port should receive the
      bytes.
   d. Send bytes from the PC side. The RX LED should light and the
      bytes should arrive in `par2ser.device`'s ring buffer.

4. **What can fail and how to read it:**
   - PWR LED off: power section issue, not CPLD.
   - ispVM IDCODE scan fails: JTAG wiring or driver binding.
   - LEDs never light on Amiga traffic: FSM not entering DECODE,
     likely SELECT sync or pin assignment issue. Add a state-debug
     LED if needed (one of the 2 spare macrocells could be a
     `state[1]` decode out on pin 41).
   - TX works but RX doesn't: ACK/INTB_PORTS path. Check `drive_ack`
     in the FSM and that the driver has the rx_install code path
     enabled (`-DPAR2SER_HW`).
   - Garbled bytes: lane integrity (verify D0..D7 mapping
     end-to-end in the fitter report against the schematic netlist).

## What's deferred

- **READ2/WRITE2** for byte counts >64. Niklas's longer-transaction
  form; not needed for terminal-rate serial traffic, useful for bulk
  transfers. Won't fit the LC4064V at current utilization — needs an
  LC4128V (which doesn't exist in 48-TQFP, so a board respin) or an
  RP2350-based redesign.
- **Control command for FT240X status query.** Would let the driver
  poll exact FT240X FIFO state instead of just sensing /RXF. Could
  fit in the remaining 2 macrocells if found necessary.

## Conventions

- All registered logic is `always @(posedge clk)` with synchronous reset
  feeding into the IDLE state. The exception is the reset synchronizer
  itself, which has an async assert + sync deassert pattern.
- Tristate drivers use ternary `(oe ? value : 1'bz)` per-pin, gated by
  reset. The top-level explicitly forces high-Z during reset.
- No latches, no combinational feedback loops. The fitter produces a
  clean register-only synthesis (48 D flip-flops + a handful of T
  flip-flops the synthesizer picked for byte_count toggle bits).

## Lessons learned (so you don't repeat them)

Several things bit us during the long road to fitting this design.
Capturing them here in case they save someone else time:

- **On a near-full CPLD, the synthesizer's choice of flop type matters
  enormously.** Inferring `DFFRS` or `DFFSH` (flops with both async set
  and async clear) when the macrocell only supports one async path
  causes per-flop emulation that explodes macrocell count. Stick to
  single-async-path patterns (`always @(posedge clk or posedge X)`
  where there's only one X), or pure synchronous designs.
- **Internally-generated clocks are expensive.** If you do
  `reg div2; always @(posedge clk_in) div2 <= ~div2;` and then
  `always @(posedge div2)`, that `div2` becomes a clock net that
  consumes scarce CPLD clock-routing resources. On a tight design
  this can cost ~10 macrocells of cross-domain bridging structure.
  Stick to one (or few, pin-sourced) clock domains.
- **One-hot FSM encoding is often a CPLD win**, but only with the hold
  terms (`state[N] & ~exit_condition`) included for every waiting
  state. Omitting them gives a smaller fit *that doesn't work*.
- **The fitter results are sensitive to small perturbations in
  near-full designs.** Adding one signal can sometimes *reduce*
  macrocell count by nudging the placement search into a better
  basin. Adding a *correct, useful* signal that costs zero net cells
  isn't a paradox — it's the search landscape.
