// =============================================================================
//  par2ser_top.v -- Top-level for the Par2Ser CPLD bridge.
//
//  Bridges the Amiga parallel port (Niklas Ekstrom's 2E protocol) to an
//  FT240X USB FIFO. Targets the Lattice LC4064V-75TN48C (ispMACH 4000V,
//  64 macrocells, 48-TQFP, -75 speed grade).
//
//  Pin assignments are taken directly from the Par2Ser Rev. 2A schematic
//  netlist (CPLD = U1). The reference column in each comment is the
//  CPLD pin number on the 48-TQFP package.
//
//  Signal direction is from the CPLD's perspective:
//      input  = the Amiga or the FT240X drives, we sense
//      output = we drive
//      inout  = bidirectional; the FSM controls the OE per phase
//
//  Single clock domain: clk (12 MHz from FT240X CBUS5) drives the whole
//  design.
//
//  LED indicators are pure combinational decodes of FSM state and signals:
//      led_act = ~state[S_IDLE]    -- any transaction in progress
//      led_tx  = drive_ft_d        -- we are driving the FT bus (write byte)
//      led_rx  = drive_amiga_d     -- we are driving the Amiga bus (read byte)
//  Visible during sustained traffic (typing, transfers); single isolated
//  bytes pass too quickly (~10-50 us) to be seen. This is the same
//  "lit during activity" approach used in the SDBox-v2 AVR firmware fork
//  (see avr/main.c in jbilander/amiga-par-to-spi-adapter), where the LED
//  is asserted together with the SPI chip-select for the duration of a
//  transaction rather than blinked per byte.
//
//  Bank/tolerance notes:
//      A-bank pins carry FT240X signals at 3.3 V (no 5 V exposure).
//      B-bank pins carry Amiga signals at 5 V into 5V-tolerant inputs;
//      our outputs on those pins drive at 3.3 V, which satisfies the
//      CIA's TTL high threshold.
// =============================================================================

module par2ser_top (
    // ---- System clock from FT240X CLKOUT (CBUS5, configured to 12 MHz) ----
    input  wire        clk,            // CPLD pin 43 (CLK0/I)

    // ---- Amiga reset (active low, from buffered _IORESET) -----------------
    input  wire        rst_n,          // CPLD pin 18 (CLK1/I)

    // ---- Amiga parallel data bus D0..D7 (bidirectional) -------------------
    //      All on the B bank (5 V tolerant). The FSM drives these during
    //      a READ phase only; otherwise they are high-Z so the Amiga drives.
    inout  wire [7:0]  amiga_d,        // pins 20,21,22,23,24,26,27,28

    // ---- Amiga control lines ----------------------------------------------
    //      SELECT = REQ ("Amiga wants to run a command"),    active low
    //      POUT   = CLK (per-byte clock, toggled by Amiga),  any-edge
    //      BUSY   = ACT ("device is busy / processing"),     active low; out
    //      ACK    = IRQ to Amiga (open-drain, hits CIA-A FLAG)
    inout  wire        amiga_select,   // pin 34 (B11) - bidir per protocol
    inout  wire        amiga_pout,     // pin 33 (B10) - bidir per protocol
    inout  wire        amiga_busy,     // pin 32 (B9)  - bidir per protocol
    output wire        amiga_ack_n,    // pin 31 (B8)  - open-drain output

    // ---- FT240X data bus D0..D7 (bidirectional, A bank, 3.3 V) ------------
    inout  wire [7:0]  ft_d,           // pins 9,45,7,2,8,4,3,46

    // ---- FT240X handshake -------------------------------------------------
    //      RXF# low = byte available to read       (input to us)
    //      TXE# low = TX FIFO has room to write    (input to us)
    //      RD#  low = read strobe to FT240X        (output from us)
    //      WR   high-to-low edge = write to FIFO   (output from us)
    input  wire        ft_rxf_n,       // pin 14 (A12)
    input  wire        ft_txe_n,       // pin 15 (A13)
    output wire        ft_rd_n,        // pin 47 (A3)
    output wire        ft_wr,          // pin 48 (A4)

    // ---- Activity LEDs (active high; CPLD drives, LED to GND via resistor)
    output wire        led_tx,         // pin 38 (B12)
    output wire        led_rx,         // pin 39 (B13)
    output wire        led_act         // pin 16 (A14)
);

    // =========================================================================
    //  Reset synchronization
    // =========================================================================
    //  rst_n is asynchronous (CIA-driven _IORESET, totem-pole 5 V buffer)
    //  and routed via the dedicated CLK1/I global net. Synchronize it to clk
    //  before use; asynchronously assert, synchronously deassert.
    reg rst_n_sync0, rst_n_sync1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rst_n_sync0 <= 1'b0;
            rst_n_sync1 <= 1'b0;
        end else begin
            rst_n_sync0 <= 1'b1;
            rst_n_sync1 <= rst_n_sync0;
        end
    end
    wire reset = ~rst_n_sync1;          // active-high internal reset

    // =========================================================================
    //  Input synchronizers (macrocell-budget aware for the LC4032V)
    // =========================================================================
    //  SELECT/POUT are SLOW Amiga signals (microsecond-scale) that we
    //  oversample at 12 MHz; a single sync flop is sufficient because by the
    //  time we act, the signal has been stable for many clocks. RXF#/TXE#
    //  (FT240X) can change faster relative to our clock, so they keep a
    //  two-flop synchronizer. This trades a small (negligible here)
    //  metastability margin on the slow signals for ~2 macrocells.
    reg       select_sync, pout_sync;          // 1-flop, slow Amiga signals
    reg [1:0] rxf_sync, txe_sync;              // 2-flop, FT240X strobes
    always @(posedge clk) begin
        select_sync <= amiga_select;
        pout_sync   <= amiga_pout;
        rxf_sync     <= {rxf_sync[0], ft_rxf_n};
        txe_sync     <= {txe_sync[0], ft_txe_n};
    end
    wire select_n = select_sync;
    wire pout_s   = pout_sync;
    wire rxf_n    = rxf_sync[1];
    wire txe_n    = txe_sync[1];

    // POUT edge detector: any transition advances one byte.
    reg pout_prev;
    always @(posedge clk) pout_prev <= pout_s;
    wire pout_edge = pout_s ^ pout_prev;

    // SELECT edge detect.
    reg select_n_prev;
    always @(posedge clk) select_n_prev <= select_n;
    wire req_assert   = ( select_n_prev & ~select_n);
    wire req_deassert = (~select_n_prev &  select_n);

    // Bus sampling: we pass the raw amiga_d bus to the FSM. The FSM samples
    // it combinationally for command decode (the Amiga holds the command
    // stable while REQ is asserted) and registers it into ft_d_out for the
    // write path. Removing a separate 8-bit amiga_d_in register saves ~8
    // macrocells -- the ft_d_out register IS the write-path capture.

    // =========================================================================
    //  FSM instance -- the protocol logic lives in par2ser_fsm.v
    // =========================================================================
    wire        drive_amiga_d;          // when 1, we drive amiga_d
    wire [7:0]  amiga_d_out;            // value to drive on amiga_d
    wire        drive_busy;             // when 1, we pull BUSY low (open-drain style)
    wire        drive_ack;              // when 1, we pull ACK low
    wire        ft_wr_pulse;            // 1 = generate WR pulse this cycle
    wire        ft_rd_pulse;            // 1 = generate RD# active this cycle
    wire        drive_ft_d;             // when 1, we drive ft_d (write to FT)
    wire [7:0]  ft_d_out;
    wire        led_tx_pulse;
    wire        led_rx_pulse;
    wire        led_act_state;

    par2ser_fsm fsm (
        .clk            (clk),
        .reset          (reset),

        // Amiga side - sensed
        .req_assert     (req_assert),
        .req_deassert   (req_deassert),
        .pout_edge      (pout_edge),
        .amiga_d_in     (amiga_d),

        // Amiga side - driven
        .drive_amiga_d  (drive_amiga_d),
        .amiga_d_out    (amiga_d_out),
        .drive_busy     (drive_busy),
        .drive_ack      (drive_ack),

        // FT240X side - sensed
        .ft_rxf_n       (rxf_n),
        .ft_txe_n       (txe_n),
        .ft_d_in        (ft_d),

        // FT240X side - driven
        .ft_wr_pulse    (ft_wr_pulse),
        .ft_rd_pulse    (ft_rd_pulse),
        .drive_ft_d     (drive_ft_d),
        .ft_d_out       (ft_d_out),

        // LEDs
        .led_tx_pulse   (led_tx_pulse),
        .led_rx_pulse   (led_rx_pulse),
        .led_act_state  (led_act_state)
    );

    // =========================================================================
    //  Tristate drivers (per-pin output enables, reset-aware)
    // =========================================================================
    //  When `reset` is asserted, we force all outputs to high-Z so the
    //  Amiga owns the bus during reboot. This is the bus-tristate-on-reset
    //  behavior we agreed to do in per-pin logic rather than via GOE.
    wire oe_amiga_d = drive_amiga_d & ~reset;
    wire oe_ft_d    = drive_ft_d    & ~reset;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : bus_drivers
            assign amiga_d[i] = oe_amiga_d ? amiga_d_out[i] : 1'bz;
            assign ft_d[i]    = oe_ft_d    ? ft_d_out[i]    : 1'bz;
        end
    endgenerate

    // Amiga control lines: BUSY/SELECT/POUT are bidirectional in Niklas's
    // protocol (the Amiga programs the DDR to switch direction). We only
    // drive BUSY (low = busy) during a transaction; SELECT and POUT we
    // never drive (always sensed). POUT is sensed only.
    assign amiga_busy   = (drive_busy & ~reset) ? 1'b0 : 1'bz;  // active-low pull
    assign amiga_select = 1'bz;                                  // never driven
    assign amiga_pout   = 1'bz;                                  // never driven

    // ACK is the open-drain RX-ready IRQ to the Amiga (hits CIA-A /FLAG).
    // Drive low to assert; high-Z when not asserting (motherboard 10k pulls high).
    assign amiga_ack_n  = (drive_ack & ~reset) ? 1'b0 : 1'bz;

    // FT240X strobes: idle high, pulse low to assert. Forced inactive during
    // reset.
    assign ft_rd_n = (ft_rd_pulse & ~reset) ? 1'b0 : 1'b1;
    assign ft_wr   = (ft_wr_pulse & ~reset) ? 1'b1 : 1'b0;
    //  Note: FT240X WR is "high-to-low edge writes". We hold it high in the
    //  WR-pulse cycle, then return low; ft_wr_pulse asserts for one clock
    //  to produce that falling edge. See FSM for exact sequencing.

    // LEDs - driven directly from the FSM signals. Reset gating keeps them
    // dark while the Amiga is in reset.
    assign led_tx  = led_tx_pulse  & ~reset;
    assign led_rx  = led_rx_pulse  & ~reset;
    assign led_act = led_act_state & ~reset;

endmodule
