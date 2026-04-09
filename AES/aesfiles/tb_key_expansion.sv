`timescale 1ns/1ps

module tb_key_expansion;

    // 1. Declare inputs/outputs
    reg clk;
    reg [3:0] tb_round;
    reg [255:0] tb_key;
    wire [127:0] tb_round_key;

    // Array to hold the 15 expected round keys
    reg [127:0] expected_rk [0:14];

    // 2. Instantiate UUT
    key_expansion uut (
        .round(tb_round),
        .key(tb_key),
        .round_key(tb_round_key)
    );

    // 3. Clock Generation
    initial clk = 0;
    always #5 clk = ~clk;

    // 4. Test Stimulus
    initial begin
        $dumpfile("key_expansion.vcd");
        $dumpvars(0, tb_key_expansion);

        $display("--- Starting key_expansion Testbench ---");

        // FIPS 197 standard AES-256 Master Key
        tb_key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;

        // PERFECTLY derived Round Keys according to AES-256 mathematics
        expected_rk[0]  = 128'h000102030405060708090a0b0c0d0e0f; 
        expected_rk[1]  = 128'h101112131415161718191a1b1c1d1e1f; 
        expected_rk[2]  = 128'ha573c29fa176c498a97fce93a572c09c;
        expected_rk[3]  = 128'h1651a8cd0244beda1a5da4c10640bade;
        expected_rk[4]  = 128'hae87dff00ff11b68a68ed5fb03fc1567;
        expected_rk[5]  = 128'h6de1f1486fa54f9275f8eb5373b8518d;
        expected_rk[6]  = 128'hc656827fc9a799176f294cec6cd5598b;
        expected_rk[7]  = 128'h3de23a75524775e727bf9eb45407cf39;
        expected_rk[8]  = 128'h0bdc905fc27b0948ad5245a4c1871c2f;
        expected_rk[9]  = 128'h45f5a66017b2d387300d4d33640a820a;
        expected_rk[10] = 128'h7ccff71cbeb4fe5413e6bbf0d261a7df;
        expected_rk[11] = 128'hf01afafee7a82979d7a5644ab3afe640;
        expected_rk[12] = 128'h2541fe719bf500258813bbd55a721c0a;
        expected_rk[13] = 128'h4e5a6699a9f24fe07e572baacdf8cdea;
        expected_rk[14] = 128'h24fc79ccbf0979e9371ac23c6d68de36;

        @(posedge clk);

        // Loop through all 15 rounds
        for (integer i = 0; i <= 14; i = i + 1) begin
            tb_round = i;
            
            // Wait for combinational logic to evaluate
            @(posedge clk);
            #1; // Offset slightly for clean GTKWave viewing
            
            if (tb_round_key == expected_rk[i])
                $display("[PASS] Round %0d Key Validated: %h", i, tb_round_key);
            else
                $display("[FAIL] Round %0d Key \n  Expected: %h\n       Got: %h", i, expected_rk[i], tb_round_key);
        end

        @(posedge clk);
        $display("--- Testbench Complete ---");
        $finish;
    end
endmodule
