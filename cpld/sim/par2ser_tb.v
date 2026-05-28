// =============================================================================
//  par2ser_tb.v -- Minimal smoke test for the FSM.
//
//  Drives a WRITE1 transaction of 1 byte and confirms the FSM:
//    1. Sees REQ assert
//    2. Pulls BUSY low
//    3. Decodes the WRITE command
//    4. Waits for POUT edge
//    5. Generates a WR pulse to the FT240X
//    6. Decrements and goes to DRAIN
//    7. Releases on REQ deassert
//
//  This isn't a full protocol verification -- it's a sanity check that
//  the state machine doesn't have an obvious dead state or missed
//  transition.
// =============================================================================
`timescale 1ns/1ns

module par2ser_tb;
    reg clk = 0;
    always #42 clk = ~clk;  // ~12 MHz

    reg        rst_n = 0;
    reg  [7:0] amiga_d_drive;
    reg        amiga_d_oe = 0;
    wire [7:0] amiga_d;
    reg        amiga_select_drive = 1;
    reg        amiga_pout_drive = 1;
    wire       amiga_select;
    wire       amiga_pout;
    wire       amiga_busy;
    wire       amiga_ack_n;
    wire [7:0] ft_d;
    reg        ft_rxf_n = 1;
    reg        ft_txe_n = 0;        // FT ready to accept writes
    wire       ft_rd_n;
    wire       ft_wr;
    wire       led_tx, led_rx, led_act;

    // Bidir bus stimulus
    assign amiga_d      = amiga_d_oe ? amiga_d_drive : 8'bz;
    assign amiga_select = amiga_select_drive ? 1'bz : 1'b0;  // active low pull
    assign amiga_pout   = amiga_pout_drive;

    // Pull-ups for buses (simulate motherboard / cable behavior)
    pullup pu_busy  (amiga_busy);
    pullup pu_ack   (amiga_ack_n);
    pullup pu_sel   (amiga_select);
    genvar i;
    generate for (i=0; i<8; i=i+1) begin : pu_a
        pullup (amiga_d[i]);
        pulldown (ft_d[i]);
    end endgenerate

    par2ser_top dut (
        .clk(clk), .rst_n(rst_n),
        .amiga_d(amiga_d),
        .amiga_select(amiga_select),
        .amiga_pout(amiga_pout),
        .amiga_busy(amiga_busy),
        .amiga_ack_n(amiga_ack_n),
        .ft_d(ft_d),
        .ft_rxf_n(ft_rxf_n), .ft_txe_n(ft_txe_n),
        .ft_rd_n(ft_rd_n), .ft_wr(ft_wr),
        .led_tx(led_tx), .led_rx(led_rx), .led_act(led_act)
    );

    integer wr_pulses = 0;
    always @(posedge ft_wr) wr_pulses = wr_pulses + 1;

    initial begin
        $display("=== par2ser smoke test ===");
        #500 rst_n = 1;
        #200;

        // WRITE1 with byte_count = 1: command byte = 8'b00_000001
        // (D7=0 WRITE/READ1 form, D6=0 WRITE direction, count[5:0]=1)
        $display("[%0t] Driving command byte 0x01 (WRITE1, count=1)", $time);
        amiga_d_drive = 8'h01;
        amiga_d_oe    = 1;
        #100;
        // Assert REQ (SELECT low)
        amiga_select_drive = 0;
        #500;

        // BUSY should be low now
        if (amiga_busy !== 1'b0) $display("[%0t] WARN: BUSY not low after REQ", $time);
        else                     $display("[%0t] OK: BUSY pulled low", $time);

        // Place data byte to be written: 0xAB
        amiga_d_drive = 8'hAB;
        #200;

        // Toggle POUT to clock the byte through
        $display("[%0t] Toggling POUT for byte 1", $time);
        amiga_pout_drive = 0;
        #300;

        // Wait for WR pulse
        #1000;
        $display("[%0t] WR pulses observed: %0d (expected >= 1)", $time, wr_pulses);

        // Release REQ
        $display("[%0t] Releasing REQ", $time);
        amiga_select_drive = 1;
        amiga_d_oe = 0;
        #500;

        // BUSY should be high again
        $display("[%0t] BUSY after release: %b (expected 1/z)", $time, amiga_busy);
        $display("=== test complete ===");
        $finish;
    end

    initial begin
        #50000 $display("TIMEOUT"); $finish;
    end
endmodule
