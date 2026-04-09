`timescale 1ns/1ps

module tb_aes_controller;

    // 1. Declare testbench signals
    reg clk;
    reg rst;
    reg start;
    reg round_done;
    
    wire [3:0] round;
    wire done;

    // 2. Instantiate the Unit Under Test (UUT)
    aes_controller uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .round_done(round_done),
        .round(round),
        .done(done)
    );

    // 3. Clock Generation (100MHz)
    initial clk = 0;
    always #5 clk = ~clk;

    // 4. Test Stimulus Process
    initial begin
        $dumpfile("aes_controller.vcd");
        $dumpvars(0, tb_aes_controller);

        $display("--- Starting aes_controller Testbench ---");

        // Step 1: Initialize values and Hold Reset
        rst = 1;
        start = 0;
        round_done = 0;

        @(posedge clk);
        @(posedge clk);
        
        // Release Reset
        rst = 0;
        @(posedge clk);

        // Step 2: Send Start Pulse
        $display("[Time %0t] Sending START pulse...", $time);
        start = 1;
        @(posedge clk);
        start = 0;

        // Step 3: Simulate the 15 AES Rounds (0 through 14)
        for (integer i = 0; i <= 14; i = i + 1) begin
            // Wait 2 clock cycles to pretend the pipeline is "doing math"
            @(posedge clk);
            @(posedge clk);
            
            // Pulse round_done to tell controller to move forward
            $display("[Time %0t] Controller is currently at Round: %d", $time, round);
            round_done = 1;
            @(posedge clk);
            round_done = 0;
        end

        // Step 4: Verify the DONE signal
        @(posedge clk); // Allow state to update
        if (done)
             $display("[PASS] SUCCESS! Controller issued DONE pulse after Round 14!");
        else
             $display("[FAIL] Controller did not issue DONE pulse!");
             
        @(posedge clk);
        @(posedge clk);
        $display("--- Testbench Complete ---");
        $finish;
    end

endmodule
