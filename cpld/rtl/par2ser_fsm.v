// =============================================================================
//  par2ser_fsm.v -- Transaction FSM, CPLD-optimized for the ispMACH 4000.
//
//  KEY LESSON (from the prefit log): the earlier version put data-register
//  loads inside conditional case branches, which made synthesis build a
//  huge clock-enable (.CE) expression per register bit -- each needing an
//  extra macrocell ("An node") and many product terms. 96 registers became
//  114 logic functions / 602 pterms and overflowed even the LC4064V.
//
//  This version avoids that by:
//    * Data registers (amiga_d_out, ft_d_out) load from a SINGLE simple
//      enable wire each, computed once -- not buried in the case.
//    * FSM next-state logic kept lean; no data movement mixed into it.
//    * Narrow byte_count (7-bit) with a simple decrement enable.
//  The result is simple flops with small enables -- cheap on a CPLD.
// =============================================================================

module par2ser_fsm (
    input  wire        clk,
    input  wire        reset,

    input  wire        req_assert,
    input  wire        req_deassert,
    input  wire        pout_edge,
    input  wire [7:0]  amiga_d_in,

    output reg         drive_amiga_d,
    output reg  [7:0]  amiga_d_out,
    output reg         drive_busy,
    output reg         drive_ack,

    input  wire        ft_rxf_n,
    input  wire        ft_txe_n,
    input  wire [7:0]  ft_d_in,

    output reg         ft_wr_pulse,
    output reg         ft_rd_pulse,
    output reg         drive_ft_d,
    output reg  [7:0]  ft_d_out,

    output wire        led_tx_pulse,
    output wire        led_rx_pulse,
    output wire        led_act_state
);

    localparam [3:0]
        S_IDLE        = 4'd0,
        S_DECODE      = 4'd1,
        S_WRITE_WAIT  = 4'd2,
        S_WRITE_LATCH = 4'd3,
        S_WRITE_FT    = 4'd4,
        S_READ_FETCH  = 4'd5,
        S_READ_PRESENT= 4'd6,
        S_DRAIN       = 4'd7,
        S_CTRL        = 4'd8;

    reg [3:0] state;
    reg [6:0] byte_count;

    // -------------------------------------------------------------------------
    //  Next-state logic (combinational) -- pure control, no data movement.
    //  Keeping data loads OUT of here is what avoids the giant clock-enables.
    // -------------------------------------------------------------------------
    reg [3:0] next_state;
    always @(*) begin
        next_state = state;
        case (state)
            S_IDLE:        if (req_assert)            next_state = S_DECODE;
            S_DECODE:      if (!amiga_d_in[7])        next_state = amiga_d_in[6] ? S_READ_FETCH : S_WRITE_WAIT;
                           else if (!amiga_d_in[6])   next_state = S_DRAIN;
                           else                       next_state = S_CTRL;
            S_WRITE_WAIT:  if (req_deassert)          next_state = S_IDLE;
                           else if (pout_edge)        next_state = S_WRITE_LATCH;
            S_WRITE_LATCH: if (!ft_txe_n)             next_state = S_WRITE_FT;
            S_WRITE_FT:    next_state = (byte_count == 7'd0) ? S_DRAIN : S_WRITE_WAIT;
            S_READ_FETCH:  if (req_deassert)          next_state = S_IDLE;
                           else if (!ft_rxf_n)        next_state = S_READ_PRESENT;
            S_READ_PRESENT:if (req_deassert)          next_state = S_IDLE;
                           else if (pout_edge)        next_state = (byte_count == 7'd0) ? S_DRAIN : S_READ_FETCH;
            S_DRAIN:       if (req_deassert)          next_state = S_IDLE;
            S_CTRL:        if (req_deassert)          next_state = S_IDLE;
            default:       next_state = S_IDLE;
        endcase
    end

    // -------------------------------------------------------------------------
    //  Simple, single-condition enables for the data registers.
    //  Each is ONE expression -> small clock-enable -> cheap.
    // -------------------------------------------------------------------------
    wire count_dec       = ((state == S_WRITE_FT) && (byte_count != 7'd0)) ||
                           ((state == S_READ_PRESENT) && pout_edge && !req_deassert && (byte_count != 7'd0));
    wire count_load      = (state == S_DECODE) && !amiga_d_in[7];

    // -------------------------------------------------------------------------
    //  State register
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) state <= S_IDLE;
        else       state <= next_state;
    end

    // -------------------------------------------------------------------------
    //  Byte counter -- one load source, one decrement, simple enable.
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset)           byte_count <= 7'd0;
        else if (count_load) byte_count <= {1'b0, amiga_d_in[5:0]};
        else if (count_dec)  byte_count <= byte_count - 1'b1;
    end

    // -------------------------------------------------------------------------
    //  Data registers.
    //  ft_d_out (WRITE direction): tracks the Amiga bus UNCONDITIONALLY -- no
    //  clock-enable, cheap. We only drive it onto ft_d during WRITE_FT, and
    //  the byte we want is the one latched at the POUT edge, which is what the
    //  bus holds at that point. Correct and free.
    //
    //  amiga_d_out (READ direction): MUST capture-and-hold the byte from the
    //  RD# strobe, because after RD# the FT240X stops driving and ft_d_in
    //  changes. So this one needs a guarded load -- but we keep the enable
    //  CHEAP by using a single pre-registered pulse (rd_capture), not a
    //  multi-term state decode. One signal => small clock-enable.
    // -------------------------------------------------------------------------
    always @(posedge clk) ft_d_out <= amiga_d_in;     // unconditional, no CE

    reg rd_capture;
    always @(posedge clk) rd_capture <= ft_rd_pulse;  // 1-cycle pulse, simple
    always @(posedge clk)
        if (rd_capture) amiga_d_out <= ft_d_in;       // single-signal enable

    // -------------------------------------------------------------------------
    //  Control outputs -- derived simply from state (mostly combinational
    //  decode, registered only where a clean edge matters).
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            drive_busy    <= 1'b0;
            drive_amiga_d <= 1'b0;
            drive_ft_d    <= 1'b0;
            ft_wr_pulse   <= 1'b0;
            ft_rd_pulse   <= 1'b0;
            drive_ack     <= 1'b0;
        end else begin
            // BUSY: low (asserted) whenever not idle.
            drive_busy    <= (next_state != S_IDLE);
            // Drive Amiga bus during read present/fetch.
            drive_amiga_d <= (next_state == S_READ_PRESENT);
            // Drive FT bus during the write strobe window.
            drive_ft_d    <= (next_state == S_WRITE_FT);
            // WR pulse: assert entering WRITE_FT (one cycle high).
            ft_wr_pulse   <= (state == S_WRITE_LATCH) && !ft_txe_n;
            // RD pulse: assert entering READ_PRESENT.
            ft_rd_pulse   <= (state == S_READ_FETCH) && !ft_rxf_n && !req_deassert;
            // ACK: RX-ready IRQ while idle and FT has data.
            drive_ack     <= (state == S_IDLE) && !ft_rxf_n;
        end
    end

    // -------------------------------------------------------------------------
    //  LED activity -- cheap, using a registered "byte happened" pulse so the
    //  sticky-set enable is a single signal (not a state decode). led_act is
    //  combinational. The set conditions are pre-registered as 1-bit pulses
    //  to keep the sticky-flop clock-enables tiny.
    // -------------------------------------------------------------------------
    reg [2:0] led_div;
    reg       tx_active, rx_active;
    reg       tx_set, rx_set;            // 1-cycle pulses, simple to compute
    wire      tick = led_div[2];

    always @(posedge clk) led_div <= led_div + 1'b1;

    // Pre-register the set pulses (single-term sources).
    always @(posedge clk) begin
        tx_set <= ft_wr_pulse;           // a write strobe = TX activity
        rx_set <= ft_rd_pulse;           // a read strobe  = RX activity
    end

    always @(posedge clk) begin
        if (reset)        tx_active <= 1'b0;
        else if (tx_set)  tx_active <= 1'b1;
        else if (tick)    tx_active <= 1'b0;
    end
    always @(posedge clk) begin
        if (reset)        rx_active <= 1'b0;
        else if (rx_set)  rx_active <= 1'b1;
        else if (tick)    rx_active <= 1'b0;
    end

    assign led_tx_pulse  = tx_active;
    assign led_rx_pulse  = rx_active;
    assign led_act_state = (state != S_IDLE);

endmodule
