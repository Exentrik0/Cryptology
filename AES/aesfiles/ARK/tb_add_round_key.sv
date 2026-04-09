`timescale 1ns/1ps

module tb_add_round_key;

    // 1. Declare testbench signals
    reg clk;  // Added clock!
    reg  [127:0] tb_state;
    reg  [127:0] tb_round_key;
    wire [127:0] tb_out;
    
    // Internal variable to hold expected result for comparison
    reg  [127:0] expected_out;

    // 2. Instantiate the Unit Under Test (UUT)
    add_round_key uut (
        .state(tb_state),
        .round_key(tb_round_key),
        .out(tb_out)
    );

    // --- CLOCK GENERATOR ---
    // 100MHz Clock (10ns period: 5ns HIGH, 5ns LOW)
    initial clk = 0;
    always #5 clk = ~clk; 

    // 3. Test Stimulus Process
    initial begin
        $dumpfile("add_round_key.vcd");
        $dumpvars(0, tb_add_round_key);
        
        $display("--- Starting add_round_key Testbench ---");

        // Wait a couple of clock cycles before sending data
        @(posedge clk);
        @(posedge clk);

        // ---- TEST CASE 1: NIST FIPS-197 Round 0 ----
        tb_state     = 128'h3243f6a8_885a308d_313198a2_e0370734;
        tb_round_key = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;
        expected_out = 128'h193de3be_a0f4e22b_9ac68d2a_e9f84808;

        // Wait one clock cycle to simulate registering the output
        @(posedge clk); 
        #1; // Add 1ns delay so we can see the check happening clearly AFTER the edge

        if (tb_out == expected_out)
            $display("[PASS] Test 1: NIST Vector. Output: %h", tb_out);
        else
            $display("[FAIL] Test 1: NIST Vector. \n  Expected: %h\n  Got:      %h", expected_out, tb_out);


        // ---- TEST CASE 2: Edge Case (Zeroes ^ Ones) ----
        @(posedge clk); 
        tb_state     = 128'h00000000_00000000_00000000_00000000;
        tb_round_key = 128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
        expected_out = 128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;

        @(posedge clk); 
        #1;

        if (tb_out == expected_out)
            $display("[PASS] Test 2: Edge Case.   Output: %h", tb_out);
        else
            $display("[FAIL] Test 2: Edge Case.\n  Expected: %h\n  Got:      %h", expected_out, tb_out);

        // End of simulation
        @(posedge clk); 
        $display("--- Testbench Complete ---");
        $finish;
    end

endmodule
