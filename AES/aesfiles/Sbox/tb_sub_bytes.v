`timescale 1ns/1ps

module tb_sub_bytes;

    // 1. Declare testbench signals
    reg clk;
    reg  [127:0] tb_state_in;
    wire [127:0] tb_state_out;
    
    reg  [127:0] expected_out;

    // 2. Instantiate the Unit Under Test (UUT)
    sub_bytes uut (
        .state_in(tb_state_in),
        .state_out(tb_state_out)
    );

    // --- CLOCK GENERATOR ---
    initial clk = 0;
    always #5 clk = ~clk; 

    // 3. Test Stimulus Process
    initial begin
        $dumpfile("sub_bytes.vcd");
        $dumpvars(0, tb_sub_bytes);
        
        $display("--- Starting sub_bytes Testbench ---");

        // Wait a couple of clock cycles
        @(posedge clk);
        @(posedge clk);

        // ---- TEST CASE 1: NIST FIPS-197 ----
        tb_state_in  = 128'h193de3be_a0f4e22b_9ac68d2a_e9f84808;
        expected_out = 128'hd42711ae_e0bf98f1_b8b45de5_1e415230;

        @(posedge clk); 
        #1; 

        if (tb_state_out == expected_out)
            $display("[PASS] Test 1: NIST Vector. Output: %h", tb_state_out);
        else
            $display("[FAIL] Test 1: NIST Vector. \n  Expected: %h\n  Got:      %h", expected_out, tb_state_out);

        // ---- TEST CASE 2: All Zeroes ----
        @(posedge clk); 
        tb_state_in  = 128'h00000000_00000000_00000000_00000000;
        expected_out = 128'h63636363_63636363_63636363_63636363;

        @(posedge clk); 
        #1;

        if (tb_state_out == expected_out)
            $display("[PASS] Test 2: Edge Case.   Output: %h", tb_state_out);
        else
            $display("[FAIL] Test 2: Edge Case.\n  Expected: %h\n  Got:      %h", expected_out, tb_state_out);

        // End of simulation
        @(posedge clk); 
        $display("--- Testbench Complete ---");
        $finish;
    end

endmodule
