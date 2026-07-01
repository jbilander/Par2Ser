# Par2Ser low-lib — integration notes (task 1)

Wire-layer transport for `par2ser.device`, brought in from Niklas Ekström's
`spi-lib` and renamed/adapted for Par2Ser. This is the 2E par-adapter
protocol, NOT SPI (no chip-select, no SD card, no SPI peripheral).

## File map

| origin (Niklas / SDBox)      | here                        |
| ---------------------------- | --------------------------- |
| `spi.h`                      | `adapter.h`                 |
| `spi.c`                      | `adapter.c`                 |
| `spi_low.asm` (vasm)         | `adapter_low.s` (GNU as)    |
| `misc_protos.h`              | `misc_protos.h` (rewritten) |
| `cia_protos.h`               | removed (no FLAG vector here)|

Functions renamed so symbols match filenames: `adapter_{init,shutdown,
set_speed,read,write}`, `adapter_{read,write}_fast`.

## Substantive changes (not just renames)

1. **Assembly ported vasm → GNU as.** Niklas's upstream `spi_low.asm` is
   vasm/Devpac syntax (`;` comments, `XDEF`, `.`-local labels) and does NOT
   assemble under `m68k-amiga-elf-as`. `adapter_low.s` is GNU-as syntax and is
   verified to assemble (binutils m68k `as`, same family as your toolchain).

2. **SELECT-per-command framing chosen deliberately.** There are two upstream
   clocking models. Cross-checking against the Par2Ser CPLD FSM (par2ser_fsm.v
   + par2ser_top.v) shows the FSM requires:
     - `req_assert`  = SELECT (REQ) falling → S_IDLE → S_DECODE
     - `pout_edge`   = POUT (CLK) toggling  → clocks each byte
     - `req_deassert`= SELECT rising        → back to S_IDLE
     - `drive_busy`  = ~S_IDLE              → BUSY low while working
   That is the **card-present spi_low.asm** clocking (SELECT brackets each
   command, POUT clocks bytes). The **SDBox `common/spi-par-low.s`** clocking is
   different (SELECT held as an SD chip-select across a whole multi-byte
   command, everything clocked on POUT) and would leave the Par2Ser FSM stuck
   in S_IDLE — so it was NOT used. `adapter_low.s` follows the FSM-correct model.

3. **Disable()/Enable() bracketing adopted from SDBox production code.** Each
   transfer masks interrupts for its duration. This matters more on Par2Ser
   than on SDBox because RX is CIA-A FLAG interrupt driven — without masking, an
   `rx_server` FLAG could reenter the CIA lines mid-write. The fast path masks
   in `adapter_low.s` (`move.l 0x4,a6 / jsr Disable(a6)` … `Enable`, saving
   `d2/a5-a6`); the slow path masks in `adapter.c` (`Disable()`/`Enable()`).

4. **SD-card init removed.** `adapter_init()` drops `spi_get_card_present()`
   (its 0xc2 probe decodes as the FSM's is_ctrl/SIWU flush), the `AddICRVector`
   CIA-A FLAG install (that line is the RX doorbell owned by par2ser.c), and
   `spi_select`/`spi_deselect`. It only opens misc.resource, allocs the port +
   bits, and sets the CIA idle line state.

5. **VBCC `__reg(...)` → gcc `asm(...)`** on every register-pinned parameter,
   matching the house style already in `par2ser.c`. `misc_protos.h` prefers the
   NDK's `<proto/misc.h>` and only falls back to a gcc-syntax inline stub.

## Command encoding (verified against the FSM)

- WRITE1 `00xxxxxx`, length = size-1 in D5..D0  ↔ FSM `is_write`, `count_load`. ✓
- READ1  `01xxxxxx`                              ↔ FSM `is_read`.               ✓
- The >64 WRITE2/READ2 two-byte forms are NOT decoded by the current LC4064V
  (D7=1 routes to S_DRAIN). Callers chunk at 64 (transport.c). The asm keeps the
  >64 path for a future larger CPLD but it must not be reached today.

## Not compile-tested here (verify on your toolchain)

I have GNU `as` for m68k (so the ASSEMBLY is verified) but not
`m68k-amiga-elf-gcc` or your NDK 3.2 headers, so the C is not compile-tested:

1. **`asm("a0")` on declarations** — `par2ser.c` uses it on definitions; the
   pattern should carry. `make debug` will confirm.
2. **`<proto/misc.h>` availability** — if your NDK has it, the fallback stub in
   `misc_protos.h` is dead code. If not, verify the fallback LVOs (-6/-12).
3. **Register prefix in `adapter_low.s`** — written no-`%` (Motorola, the Amiga
   norm). If your `as` demands `%`, add `--register-prefix-optional` to ASFLAGS.

## Still open for task 2 (flagged, not blocking task 1)

`transport.c`'s `rx_data_pending()` reads CIA-A PRA bit 0 as the RX doorbell
(active-low), per the FSM's `drive_ack = S_IDLE & has_data` and top.v's
`amiga_ack_n` open-drain to CIA-A FLAG. **Confirm the exact bit + polarity on
`Par2Ser_rev2a_schematic.pdf`.** If ACK isn't readable as a CIA-A PRA bit,
`transport_poll_rx()` must be driven purely by the FLAG interrupt latch (one
unconditional READ1 per rx_server entry) instead of polled.
