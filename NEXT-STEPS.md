# NEXT-STEPS.md — Milestone 2 handoff

Working document for wiring `par2ser.device` to real hardware.
Complements the top-level `README.md` (which documents the completed
milestones — hardware bring-up and Milestone 1 driver skeleton) by
capturing open questions and the immediate next tasks.

## Where we are (as of this document)

**Hardware bring-up: complete.** The Par2Ser Rev 2A board is
programmed with `par2ser.jed` and validated end-to-end:

- FT240X MTP configured (CBUS5 → 12 MHz CPLD clock, VCP driver mode,
  descriptor strings), verified enumerating cleanly on macOS Catalina,
  Linux Mint, and Windows 8.1 SP2.
- LC4064V CPLD programmed via JTAG using an FT4232H-56Q Mini Module
  as generic FTDI cable through ispVM Classic 2.1, with
  TCK Low Pulse Width Delay = 3 to work around flywire signal
  integrity at the default 15 MHz TCK.
- A blink test design was flashed first to validate the toolchain
  (24-bit counter, alternating LEDs at ~0.7 Hz) — the LEDs blink
  correctly when the board is plugged into a USB host that
  enumerates the FT240X (needed for CBUS5 clock output).
- The real `par2ser.jed` is now programmed and the board sits in
  the FSM's S_IDLE state (all activity LEDs dark) when powered
  with no Amiga traffic.

**Milestone 1 (driver skeleton with stub transport): complete.**
`par2ser.device` was verified on a real Amiga 500 with KS 3.1.4 in
ROM + WB 3.1 booted from Gotek ADF:

- Driver loads and integrates with the OS (romtag/autoinit works).
- `cki196.exe` accepts `set line par2ser.device` — reports
  "Connecting thru par2ser.device, speed 9600" — and `connect` /
  escape work correctly.
- SDCMD_QUERY / SDCMD_SETPARAMS negotiation completes.
- With the stubbed `transport.c`, no bytes actually reach the
  FT240X (as designed for Milestone 1 — the point was to validate
  the driver architecture without hardware in the loop).

## What Milestone 2 is

Replace the stub transport with real hardware I/O so that bytes
typed in kermit on the Amiga arrive at `/dev/ttyUSB0` (or
`/dev/cu.usbserial-*` on macOS, or the COM port on Windows) on the
USB host — and vice versa.

The transport layer contract is defined in `amiga/transport.h`
(4 functions: `transport_init` / `_shutdown` / `_write` /
`_poll_rx`). The stub sketch in `amiga/transport.c` shows the
intended integration with Niklas Ekström's SPI library.

## Immediate next tasks

1. **Integrate Niklas's `spi.c`, `spi_low.asm`, and `spi.h`** from
   [github.com/niklasekstrom/amiga-par-to-spi-adapter](https://github.com/niklasekstrom/amiga-par-to-spi-adapter)
   into `amiga/`. Reference for how this was done in a sibling
   project: `jbilander/SDBox` uses the same protocol.

2. **Wire `transport.c` bodies to call `spi_initialize` /
   `spi_shutdown` / `spi_write`.** The transport.c stub already
   contains the sketch as a comment; it's a small mechanical change
   once the SPI library files are in place.

3. **Uncomment `-DPAR2SER_HW` and `spi.o` / `spi_low.o` in the
   Makefile** to compile in the real transport and the CIA-A FLAG
   receive interrupt server.

4. **Build, copy to A500, load par2ser.device, run kermit.** First
   test: send a single character from the Amiga and confirm it
   appears on the USB host terminal. This validates
   TX (Amiga → CPLD → FT240X → PC).

5. **Then RX**: type a character on the PC terminal, confirm it
   appears in kermit on the Amiga. This validates
   RX (PC → FT240X → CPLD → Amiga).

## Open questions to resolve during Milestone 2

Some of these are architectural questions that came up during
planning and were not fully resolved. Answering them requires
looking at the schematic, the CPLD Verilog (`cpld/par2ser_fsm.v`
and related), and Niklas's SPI code.

### Q1: Is `/RXF` wired to CIA-A FLAG on the Par2Ser board?

The FT240X's `/RXF` signal goes low when the RX FIFO has data
available (i.e., the PC has sent bytes that the Amiga hasn't read
yet). For the receive interrupt path to work efficiently, `/RXF`
needs to trigger a CPU interrupt.

Two possible routings on the Rev 2A hardware:

- **`/RXF` → CIA-A FLAG directly** (like SDBox does for its
  SD-card interrupt). This is what the driver's INTB_PORTS
  interrupt server expects: on every FT240X RX byte, the CPU
  wakes up, `rx_server()` runs, calls `transport_poll_rx()`,
  which issues a READ command via SPI protocol to drain the
  FIFO. **Efficient, event-driven.**

- **`/RXF` visible only to the CPLD.** In this case the CPLD
  would need to expose a status command (unused CPLD command
  slot exists in the FSM) that the Amiga could poll to check
  "is FT240X RX FIFO non-empty?" Requires either CPLD firmware
  changes (add the status command) or a polling loop with all
  its CPU overhead.

**Where to look:** `Par2Ser_rev2a_schematic.pdf` at the CIA-A FLAG
pin (parallel port pin 10 = ACK = CIA-A PA/FLAG) — trace
back to see what drives it. Also `cpld/par2ser_fsm.v` to see if
`/RXF` from the FT240X is a CPLD input pin and where it goes.

### Q2: Does the Par2Ser CPLD command encoding (D7/D6) match what `spi_low.asm` sends?

Both the SDBox and Par2Ser CPLDs use `D7`/`D6` as command bits and
`D5..D0` as data / partial-nibble. The Par2Ser FSM decodes:
- CTRL command (SIWU flush) when `D7=1, D6=1`
- WRITE command when a specific D7/D6 pattern is seen (need to
  verify exact encoding)
- READ command when another pattern is seen

If Niklas's spi_low.asm assumes the SDBox encoding (which was
originally an SD-card SPI adapter), and the Par2Ser CPLD FSM
decodes those bits with a different meaning, we'll get either
"nothing happens" or "wrong bytes on the FT240X TX FIFO."

**Where to look:** `cpld/par2ser_fsm.v` for the CPLD's D7/D6
decode logic. Compare to spi_low.asm's D7/D6 output patterns.
Also worth checking what the `par2ser.c` file header comment
means by "the D0-5/D6-7 split is invisible on the Amiga side" —
possibly Niklas's code just sends 8-bit payloads and D7/D6 are
the "command flavor" bits that spi_low knows to set for
READ vs WRITE.

### Q3: How does `transport_poll_rx()` return "one byte if available"?

Niklas's `spi_read(buf, count)` takes a known count and blocks
until that many bytes are read. But the driver's
`transport_poll_rx()` is a **peek-and-grab** primitive: "if a
byte is available return 1 and store it, else return 0 without
blocking."

Options:
- Check `/RXF` status first (via CIA FLAG state or CPLD status
  cmd) — if asserted, call `spi_read(out, 1)`; if not, return 0.
  Requires knowing how to read `/RXF` state cheaply.
- If the CPLD's READ command returns something in-band that
  means "no byte available" (e.g., a specific TDO pattern), we
  can call it unconditionally and interpret the result. Requires
  studying the FSM's READ command return value.

**This is what the transport.c stub's comment is honest about
being uncertain on.** Resolving this is the hardest part of the
Milestone 2 integration.

### Q4: Parallel-port resource acquisition

`par2ser.device` needs to grab the parallel port cleanly, so that
AmigaOS's built-in `parallel.device` or `PAR:` doesn't fight it.
The standard pattern is:

```
OpenResource("misc.resource")
AllocMiscResource(MR_PARALLELPORT, ...)
OpenResource("parallel.resource")
```

Niklas's `spi_initialize()` presumably does this — verify what
its return code contract is (`transport.c` sketch says
`spi_initialize(NULL) == 0` for success, need to confirm).

Also verify the port is released on `transport_shutdown()` so
other tools can use it after par2ser.device is closed.

## Testing plan for Milestone 2

Once the code is in place and building:

**Stage 0 — sanity check (no software yet):**
Power A500 with KS 3.1.4 in ROM, boot WB 3.1 from Gotek. Plug
Par2Ser into parallel port, USB-C into Linux Mint. Open
`sudo cat /dev/ttyUSB0` in a terminal. Observe: all Par2Ser
LEDs except PWR stay dark, no data on the terminal. If anything
appears (LEDs, garbage bytes), the CPLD FSM is decoding something
during boot that we need to understand before proceeding.

**Stage 1 — driver loads (already validated in Milestone 1):**
Skip re-testing; we already know this works.

**Stage 2 — TX path (first real test):**
Load par2ser.device, run cki196.exe, `set line par2ser.device`,
`connect`. Type a single character 'A'. Expected: TX LED on
Par2Ser briefly flashes; 'A' appears on the Linux terminal.

If nothing happens: check TX LED activity when typing (does the
CPLD FSM see the WRITE command?), check `/dev/ttyUSB0` is really
receiving nothing (not just terminal buffering).

**Stage 3 — RX path:**
Still in kermit `connect` mode, on the Linux side, type a character
into a terminal that has `/dev/ttyUSB0` open for write (e.g.,
`echo "B" > /dev/ttyUSB0`). Expected: RX LED on Par2Ser briefly
flashes; 'B' appears in kermit on the Amiga.

**Stage 4 — bidirectional / kermit protocol:**
Once both TX and RX work at the character level, try the full
kermit protocol: transfer a small file from Amiga to PC using
kermit on the PC side (using the FTDI VCP as the serial device
for kermit to talk to). This is the eventual end-user use case.

## KS 1.3 compatibility (deferred)

The current driver builds with the Bartman m68k-amiga-elf toolchain
using NDK 3.2 headers. The `gen_ks13_compat.py` script guards
against 2.0+ symbol usage at link time. c-Kermit (cki196.exe)
requires KS 3.1+ so KS 1.3 testing will need a different serial
client (NComm, Term, 1.3-era kermit port, etc.).

Recommended approach after Milestone 2 is working on KS 3.1.4:
1. Flash KS 1.3 to the Meggy ROM board.
2. Boot WB 1.3 from Gotek.
3. Try loading par2ser.device — likely to work given the compat guard.
4. Use NComm or similar as the serial client.
5. Document any 1.3-specific issues found.

## Reference / file inventory

Files in the Par2Ser repo that Milestone 2 will touch:

- `amiga/par2ser.c` — device driver main. Look for the
  `PAR2SER_HW` guard around `rx_install()`/`rx_remove()` calls.
- `amiga/transport.c` / `transport.h` — the stub that needs to
  be replaced with real SPI calls.
- `amiga/debug.c` — KPrintF via RawDoFmt + RawPutChar. Useful
  during Milestone 2 bring-up.
- `amiga/Makefile` — uncomment `-DPAR2SER_HW` and add `spi.o` /
  `spi_low.o` to OBJECTS when integration is ready.

Files to bring in from Niklas Ekström's repo
[amiga-par-to-spi-adapter](https://github.com/niklasekstrom/amiga-par-to-spi-adapter):

- `spi.h` — API declarations.
- `spi.c` — C wrapper around spi_low.
- `spi_low.asm` — assembly implementation of the 2E protocol on
  the CIA parallel port.

Files worth reading for context:

- `cpld/par2ser_fsm.v` — CPLD state machine. Answers Q1 and Q2.
- `cpld/README.md` — CPLD architecture rationale.
- `Par2Ser_rev2a_schematic.pdf` — for tracing `/RXF` routing and
  CIA-A FLAG connectivity.

## Bring-up gotchas to remember (from earlier sessions)

- **Power Par2Ser from a separate USB charger during JTAG
  programming**, not from the same PC running ispVM (otherwise
  the Par2Ser's FT240X appears as a competing "USB Serial
  Converter" that confuses ispVM). For running the device
  during Amiga testing, this doesn't matter — plug into any
  USB host that enumerates the FT240X, which is required for
  the CBUS5 12 MHz clock to run (chargers put FT240X into
  USB suspend with clocks off).
- **The TCK Low Pulse Width Delay = 3 setting is per-project
  in ispVM**, so it has to be re-set every time you switch
  between the blink and par2ser ispLEVER projects.
- **RN2 (10k pull-up for TMS) is optional for initial
  JTAG bring-up** — the FT4232H actively drives TMS and the
  LC4064V has an internal pull-up per IEEE 1149.1 — but should
  be populated before final use for noise immunity.
