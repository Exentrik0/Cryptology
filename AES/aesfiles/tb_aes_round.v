`timescale 1ns/1ps

module tb_aes_round;

    // 1. Declare signals
    reg clk;
    reg [3:0] tb_round;
    reg [127:0] tb_state_in;
    reg [127:0] tb_round_key;

    wire [127:0] tb_state_out;
    wire tb_round_done;

    // Debug wires (Great for GTKWave)
    wire [127:0] tb_sb_out;
    wire [127:0] tb_sr_out;
    wire [127:0] tb_mc_out;
    
    reg [127:0] expected_out;

    // 2. Instantiate UUT
    aes_round uut (
        .clk(clk),
        .round(tb_round),
        .state_in(tb_state_in),
        .round_key(tb_round_key),
        .state_out(tb_state_out),
        .round_done(tb_round_done),
        
        .subbytes_out(tb_sb_out),
        .shiftrows_out(tb_sr_out),
        .mixcolumns_out(tb_mc_out)
    );

    // 3. Clock Gen (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // 4. Test Stimulus
    initial begin
        $dumpfile("aes_round.vcd");
        $dumpvars(0, tb_aes_round);

        $display("--- Starting aes_round Testbench ---");
        
        @(posedge clk);
        @(posedge clk);

        // ---- TEST CASE: Full Normal Round (Round 1) ----
        tb_round = 4'd1;     // Ensure it's not round 14 so MixColumns runs
        
        tb_state_in  = 128'h193de3be_a0f4e22b_9ac68d2a_e9f84808;
        tb_round_key = 128'ha0fafe17_88542cb1_23a33939_2a6c7605;
        expected_out = 128'ha49c7ff2_689f352b_6b5bea43_026a5049;

        // Since aes_round is Sequential, we wait exactly 1 clock edge
        // for the registers to capture the combinational result
        @(posedge clk);
        #1; 

        if (tb_state_out == expected_out)
            $display("[PASS] Round 1 Validated! Output: %h", tb_state_out);
        else
            $display("[FAIL] \n  Expected: %h\n  Got:      %h", expected_out, tb_state_out);

        @(posedge clk);
        $display("--- Testbench Complete ---");
        $finish;
    end
endmodule
