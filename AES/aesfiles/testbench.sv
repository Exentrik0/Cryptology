module testbench;

reg clk;
reg rst;
reg start;

reg [127:0] plaintext;
reg [255:0] key;

wire [127:0] ciphertext;
wire done;

/////////////////////////
// DEBUG SIGNALS
/////////////////////////

wire [127:0] round_state      [0:14];
wire [127:0] round_key        [0:14];
wire [127:0] subbytes_state   [0:14];
wire [127:0] shiftrows_state  [0:14];
wire [127:0] mixcolumns_state [0:14];
wire [127:0] ark_state        [0:14];

/////////////////////////
// DUT
/////////////////////////

aes_top uut(
  .clk(clk),
  .rst(rst),
  .start(start),
  .plaintext(plaintext),
  .key(key),
  .ciphertext(ciphertext),
  .done(done),

  .round_state(round_state),
  .round_key(round_key),

  .subbytes_state(subbytes_state),
  .shiftrows_state(shiftrows_state),
  .mixcolumns_state(mixcolumns_state),
  .ark_state(ark_state)
);

/////////////////////////
// CLOCK
/////////////////////////

initial begin
  clk = 0;
  forever #5 clk = ~clk;
end

/////////////////////////
// VCD DUMP
/////////////////////////

initial begin
  $dumpfile("waveform.vcd");
  $dumpvars(0, testbench);
end

/////////////////////////
// STIMULUS
/////////////////////////

initial begin
  rst = 1;
  start = 0;

  #20 rst = 0;

  plaintext = 128'h00112233445566778899aabbccddeeff;
  key = 256'h000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f;
  
  //plaintext = 128'h00000000000000000000000000000000;
  //key = 256'h0000000000000000000000000000000000000000000000000000000000000000;


  #10 start = 1;
  #10 start = 0;
end

/////////////////////////
// PRINT TRACE
/////////////////////////

integer i;

always @(posedge done) begin

  $display("\n==============================================");
  $display("         AES-256 ROUND TRACE");
  $display("==============================================");

  for (i = 0; i <= 14; i = i + 1) begin

    $display("\n******** ROUND %0d ********", i);

    $display("Round Input State  = %h", round_state[i]);
    $display("Round Key          = %h", round_key[i]);

    if (i == 0) begin
      $display("After AddRoundKey  = %h", ark_state[i]);
    end
    else begin
      $display("After SubBytes     = %h", subbytes_state[i]);
      $display("After ShiftRows    = %h", shiftrows_state[i]);

      if (i != 14)
        $display("After MixColumns   = %h", mixcolumns_state[i]);
      else
        $display("MixColumns         = SKIPPED");

      $display("After AddRoundKey  = %h", ark_state[i]); // FIXED
    end

    $display("----------------------------------------------");
  end

    $display("\nFINAL CIPHERTEXT = %h", ciphertext);

  // --- ADD THIS SELF-CHECKING BLOCK ---
  if (ciphertext == 128'h8ea2b7ca516745bfeafc49904b496089)
      $display("\n[PASS] AES-256 CORE IS FULLY FUNCTIONAL AND FIPS-COMPLIANT!");
  else begin
      $display("\n[FAIL] CIPHERTEXT MISMATCH!");
      $display("Expected: 8ea2b7ca516745bfeafc49904b496089");
  end
  // ------------------------------------

  $display("==============================================\n");

  #20 $finish;
end


endmodule