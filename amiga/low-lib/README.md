# Par2Ser low-lib (2E par-adapter transport)

Low-level wire transport for the Par2Ser parallel-port adapter. Derived from
Niklas Ekström's `spi-lib` (from amiga-par-to-spi-adapter), which spoke the
same 2E protocol to an SD-card SPI adapter. Renamed and trimmed for Par2Ser:

- `adapter.h` / `adapter.c` -- API + slow-path (250 kHz) transfer, port setup.
- `adapter_low.s` -- fast-path (8 MHz) block transfer (GNU as / m68k-amiga-elf).
- `misc_protos.h` -- inline stubs for Alloc/FreeMiscResource.

Removed from the original spi.c (not applicable to a UART bridge):
chip-select, card-present probing, and the CIA-A FLAG "card change" interrupt
(on Par2Ser the FLAG line is the FT240X RX doorbell, owned by par2ser.c).

The wire protocol and WRITE1/READ1 command encoding are unchanged from Niklas's
original and are decoded bit-for-bit by the Par2Ser CPLD FSM. Only WRITE1/READ1
(<= 64 bytes/command) are implemented on the current LC4064V; callers chunk at 64.

Original spi-lib (c) Niklas Ekström, April 2020 / July 2021.
