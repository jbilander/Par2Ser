// =============================================================================
//  par2ser_fsm.v -- Transaction FSM, one-hot encoded for the ispMACH 4000.
//
//  One-hot encoding: every state is its own flop, every state test is a
//  single wire (no 4-bit AND tree). On a CPLD that's product-term bound,
//  this typically reduces pterms enough to free macrocells -- exactly what
//  we need to fit all three LEDs.
//
//  CRITICAL one-hot discipline: for each state bit, the next-state
//  expression is ALWAYS:
//
//      state[N] <= (enter_from_X if cond_X) | (enter_from_Y if cond_Y)
//                  | (state[N] & ~any_exit_condition)
//
//  The 'state[N] & ~exits' term is what makes the state STICKY -- without
//  it, every "waiting" state would clear itself after one cycle and the
//  FSM would die. (This is exactly what bit a previous one-hot attempt:
//  it omitted the stay terms and fit beautifully, but the FSM didn't work.)
//
//  Behavior is preserved bit-for-bit from the binary FSM that was tested
//  in WinUAE with the par2ser.device driver.
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

    // One-hot state bit indices.
    localparam
        S_IDLE         = 0,
        S_DECODE       = 1,
        S_WRITE_WAIT   = 2,
        S_WRITE_LATCH  = 3,
        S_WRITE_FT     = 4,
        S_READ_FETCH   = 5,
        S_READ_PRESENT = 6,
        S_DRAIN        = 7,
        S_CTRL         = 8;

    reg [8:0] state;
    reg [6:0] byte_count;

    // Common sub-expressions, each a single wire.
    wire has_data  = ~ft_rxf_n;
    wire can_write = ~ft_txe_n;
    wire is_write  = ~amiga_d_in[7] & ~amiga_d_in[6];   // D7=0, D6=0 -> WRITE1
    wire is_read   = ~amiga_d_in[7] &  amiga_d_in[6];   // D7=0, D6=1 -> READ1
    wire is_drain  =  amiga_d_in[7] & ~amiga_d_in[6];   // D7=1, D6=0 -> READ2/WRITE2 (drains)
    wire is_ctrl   =  amiga_d_in[7] &  amiga_d_in[6];   // D7=1, D6=1 -> control cmd
    wire bc_zero   = (byte_count == 7'd0);

    // -------------------------------------------------------------------------
    //  State register -- per-bit next-state. Each bit:
    //     state[N] <= (entry conditions) | (state[N] & ~exit conditions)
    //  This preserves bit-for-bit the binary FSM's transitions.
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            state <= 9'b000000001;   // IDLE
        end else begin
            state[S_IDLE]         <= (state[S_IDLE]         & ~req_assert)
                                   | (state[S_WRITE_WAIT]   &  req_deassert)
                                   | (state[S_READ_FETCH]   &  req_deassert)
                                   | (state[S_READ_PRESENT] &  req_deassert)
                                   | (state[S_DRAIN]        &  req_deassert)
                                   | (state[S_CTRL]         &  req_deassert);

            state[S_DECODE]       <= (state[S_IDLE]         &  req_assert);
                                    // DECODE always transitions out in one cycle, no hold term.

            state[S_WRITE_WAIT]   <= (state[S_DECODE]       &  is_write)
                                   | (state[S_WRITE_FT]     & ~bc_zero)
                                   | (state[S_WRITE_WAIT]   & ~req_deassert & ~pout_edge);

            state[S_WRITE_LATCH]  <= (state[S_WRITE_WAIT]   & ~req_deassert &  pout_edge)
                                   | (state[S_WRITE_LATCH]  & ~can_write);

            state[S_WRITE_FT]     <= (state[S_WRITE_LATCH]  &  can_write);
                                    // WRITE_FT always transitions out in one cycle, no hold term.

            state[S_READ_FETCH]   <= (state[S_DECODE]       &  is_read)
                                   | (state[S_READ_PRESENT] & ~req_deassert &  pout_edge & ~bc_zero)
                                   | (state[S_READ_FETCH]   & ~req_deassert & ~has_data);

            state[S_READ_PRESENT] <= (state[S_READ_FETCH]   & ~req_deassert &  has_data)
                                   | (state[S_READ_PRESENT] & ~req_deassert & ~pout_edge);

            state[S_DRAIN]        <= (state[S_DECODE]       &  is_drain)
                                   | (state[S_WRITE_FT]     &  bc_zero)
                                   | (state[S_READ_PRESENT] & ~req_deassert &  pout_edge &  bc_zero)
                                   | (state[S_DRAIN]        & ~req_deassert);

            state[S_CTRL]         <= (state[S_DECODE]       &  is_ctrl)
                                   | (state[S_CTRL]         & ~req_deassert);
        end
    end

    // -------------------------------------------------------------------------
    //  Byte counter -- single-condition enables, same as binary version.
    // -------------------------------------------------------------------------
    wire count_load = state[S_DECODE] & ~amiga_d_in[7];
    wire count_dec  = (state[S_WRITE_FT]     & ~bc_zero)
                    | (state[S_READ_PRESENT] & pout_edge & ~req_deassert & ~bc_zero);

    always @(posedge clk) begin
        if (reset)           byte_count <= 7'd0;
        else if (count_load) byte_count <= {1'b0, amiga_d_in[5:0]};
        else if (count_dec)  byte_count <= byte_count - 1'b1;
    end

    // -------------------------------------------------------------------------
    //  Data path -- unchanged from binary version (already optimal).
    // -------------------------------------------------------------------------
    always @(posedge clk) ft_d_out <= amiga_d_in;

    reg rd_capture;
    always @(posedge clk) rd_capture <= ft_rd_pulse;
    always @(posedge clk) if (rd_capture) amiga_d_out <= ft_d_in;

    // -------------------------------------------------------------------------
    //  Output registers -- now driven from single-wire state[N] signals.
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
            drive_busy    <= ~state[S_IDLE];
            drive_amiga_d <=  state[S_READ_PRESENT];
            drive_ft_d    <=  state[S_WRITE_FT];
            ft_wr_pulse   <=  state[S_WRITE_LATCH] & can_write;
            ft_rd_pulse   <=  state[S_READ_FETCH]  & has_data & ~req_deassert;
            drive_ack     <=  state[S_IDLE]        & has_data;
        end
    end

    // -------------------------------------------------------------------------
    //  LED outputs -- free decodes of existing signals.
    // -------------------------------------------------------------------------
    assign led_act_state = ~state[S_IDLE];
    assign led_tx_pulse  =  drive_ft_d;       // lit while we drive FT bus
    assign led_rx_pulse  =  drive_amiga_d;    // lit while we drive Amiga bus

endmodule
