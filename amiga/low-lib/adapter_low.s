| =============================================================================
|  adapter_low.s -- fast-path (8 MHz) block transfer for the Par2Ser adapter.
|
|  GNU as (m68k-amiga-elf-as) syntax. Implements the Par2Ser 2E framing:
|  SELECT (REQ) brackets each command, POUT (CLK) clocks each byte, and BUSY
|  (ACT) is the adapter's "working" handshake. This matches the Par2Ser CPLD
|  FSM (par2ser_fsm.v):
|      req_assert   = SELECT falling  -> S_IDLE  -> S_DECODE
|      pout_edge    = POUT toggling   -> clocks WRITE_WAIT/READ bytes
|      req_deassert = SELECT rising   -> back to S_IDLE
|      drive_busy   = ~S_IDLE         -> BUSY low while the FSM is working
|
|  Lineage note: this is the SELECT-per-command clocking from Niklas's
|  card-present spi_low.asm (the variant the Par2Ser FSM was written
|  against), NOT the SDBox common/spi-par-low.s clocking (which holds SELECT
|  as an SD chip-select across a whole multi-byte command and would leave the
|  Par2Ser FSM stuck in S_IDLE). From the SDBox production code we DO adopt
|  the Disable()/Enable() bracketing around each transfer -- important here
|  because Par2Ser RX is CIA-A FLAG interrupt driven, so an rx_server could
|  otherwise reenter the CIA lines mid-transfer.
|
|  Only WRITE1 (00xxxxxx) / READ1 (01xxxxxx), size 1..64, are decoded by the
|  current LC4064V FSM. The >64 WRITE2/READ2 paths are kept for completeness
|  but must not be reached until a larger CPLD implements them; callers chunk
|  at 64 (see transport.c).
|
|  a0 = buf, d0 = size. assert 1 <= size < 2^13.
|
|  Register prefix: written Motorola-style (no % on registers), matching the
|  m68k-amiga-elf-as default. If your assembler requires %-prefixed registers,
|  add --register-prefix-optional to ASFLAGS, or sed 's/\b\([da][0-7]\)\b/%\1/g'.
| =============================================================================

        .globl  adapter_read_fast
        .globl  adapter_write_fast
        .text

        .set    CIAB_PRTRSEL,   2
        .set    CIAB_PRTRPOUT,  1
        .set    CIAB_PRTRBUSY,  0

        .set    CIAA_BASE,      0xbfe001
        .set    CIAB_BASE,      0xbfd000
        .set    CIAPRB,         0x0100
        .set    CIADDRB,        0x0300

        .set    REQ_BIT,        CIAB_PRTRSEL    | SELECT
        .set    CLK_BIT,        CIAB_PRTRPOUT   | POUT
        .set    ACT_BIT,        CIAB_PRTRBUSY   | BUSY

        .set    LVO_Disable,    -120
        .set    LVO_Enable,     -126

| -----------------------------------------------------------------------------
|  adapter_write_fast(a0=buf, d0=size)
| -----------------------------------------------------------------------------
adapter_write_fast:
        and.w   #0x1fff,d0
        bne.b   1f
        rts
1:
        movem.l d2/a5-a6,-(a7)
        move.l  0x4,a6                  | SysBase (ExecBase at abs 4)
        jsr     LVO_Disable(a6)

        lea.l   CIAA_BASE+CIAPRB,a1     | a1 -> CIA-A PRB (data)
        lea.l   CIAB_BASE,a5            | a5 -> CIA-B PRA (control), CIAPRA=0

        move.b  (a5),d2                 | d2 = current control-line state

        subq.l  #1,d0                   | d0 = size - 1

        cmp.w   #63,d0
        ble.b   2f                      | size <= 64 -> WRITE1

        | WRITE2 = 10xxxxxx 0xxxxxxx  (NOT decoded by current FSM)
        move.w  d0,d1
        lsr.w   #7,d1
        or.b    #0x80,d1
        move.b  d1,(a1)                 | first command byte
        bclr    #REQ_BIT,d2             | assert SELECT (REQ low)
        move.b  d2,(a5)
3:      move.b  (a5),d2                 | wait for BUSY (ACT) to clear
        btst    #ACT_BIT,d2
        bne.b   3b
        move.b  d0,d1
        and.b   #0x7f,d1
        move.b  d1,(a1)                 | second command byte
        bchg    #CLK_BIT,d2             | clock it (POUT edge)
        move.b  d2,(a5)
        bra.b   4f

2:      | WRITE1 = 00xxxxxx
        move.b  d0,(a1)                 | command byte = (size-1) in D5..D0
        bclr    #REQ_BIT,d2             | assert SELECT (REQ low) -> FSM DECODE
        move.b  d2,(a5)
5:      move.b  (a5),d2                 | wait for BUSY (ACT) to clear
        btst    #ACT_BIT,d2
        bne.b   5b

4:      | ---- data phase: one byte per POUT edge ----
        addq.l  #1,d0                   | d0 = size
        btst    #0,d0
        beq.b   6f                      | even count -> skip the odd leader
        move.b  (a0)+,(a1)
        bchg    #CLK_BIT,d2
        move.b  d2,(a5)
6:      lsr.w   #1,d0
        beq.b   7f                      | no pairs left -> done
        subq.w  #1,d0
        move.b  d2,d1
        bchg    #CLK_BIT,d1             | d1 = d2 with CLK toggled (other phase)
8:      move.b  (a0)+,(a1)
        move.b  d1,(a5)                 | edge A
        move.b  (a0)+,(a1)
        move.b  d2,(a5)                 | edge B
        dbra    d0,8b

7:      | ---- end of command ----
        move.b  d2,(a5)                 | settle
        bset    #REQ_BIT,d2             | deassert SELECT (REQ high) -> FSM IDLE
        move.b  d2,(a5)

        jsr     LVO_Enable(a6)
        movem.l (a7)+,d2/a5-a6
        rts

| -----------------------------------------------------------------------------
|  adapter_read_fast(a0=buf, d0=size)
| -----------------------------------------------------------------------------
adapter_read_fast:
        and.w   #0x1fff,d0
        bne.b   1f
        rts
1:
        movem.l d2/a5-a6,-(a7)
        move.l  0x4,a6                  | SysBase
        jsr     LVO_Disable(a6)

        lea.l   CIAA_BASE+CIAPRB,a1     | a1 -> CIA-A PRB (data)
        lea.l   CIAB_BASE,a5            | a5 -> CIA-B PRA (control)

        move.b  (a5),d2

        subq.l  #1,d0                   | d0 = size - 1

        cmp.w   #63,d0
        ble.b   2f                      | size <= 64 -> READ1

        | READ2 = 10xxxxxx 1xxxxxxx  (NOT decoded by current FSM)
        move.w  d0,d1
        lsr.w   #7,d1
        or.b    #0x80,d1
        move.b  d1,(a1)
        bclr    #REQ_BIT,d2
        move.b  d2,(a5)
3:      move.b  (a5),d2
        btst    #ACT_BIT,d2
        bne.b   3b
        move.b  d0,d1
        or.b    #0x80,d1
        move.b  d1,(a1)
        bchg    #CLK_BIT,d2
        move.b  d2,(a5)
        bra.b   4f

2:      | READ1 = 01xxxxxx
        move.b  d0,d1
        or.b    #0x40,d1
        move.b  d1,(a1)                 | command byte
        bclr    #REQ_BIT,d2             | assert SELECT
        move.b  d2,(a5)
5:      move.b  (a5),d2                 | wait BUSY clear
        btst    #ACT_BIT,d2
        bne.b   5b

4:      | ---- turn the Amiga data bus around to INPUT for the read ----
        move.b  #0,CIADDRB-CIAPRB(a1)   | CIA-A DDRB = 0 (a1+0x200): stop driving

        addq.l  #1,d0                   | d0 = size
        btst    #0,d0
        beq.b   6f
        bchg    #CLK_BIT,d2
        move.b  d2,(a5)                 | clock a byte in
        move.b  (a1),(a0)+
6:      lsr.w   #1,d0
        beq.b   7f
        subq.w  #1,d0
        move.b  d2,d1
        bchg    #CLK_BIT,d1
8:      move.b  d1,(a5)                 | edge A
        move.b  (a1),(a0)+
        move.b  d2,(a5)                 | edge B
        move.b  (a1),(a0)+
        dbra    d0,8b

7:      | ---- end of command: restore bus to OUTPUT, deassert SELECT ----
        bset    #REQ_BIT,d2
        move.b  d2,(a5)                 | deassert SELECT -> FSM IDLE
        move.b  #0xff,CIADDRB-CIAPRB(a1)| CIA-A DDRB = 0xff: drive data again

        jsr     LVO_Enable(a6)
        movem.l (a7)+,d2/a5-a6
        rts
