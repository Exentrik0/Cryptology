`include "aes_round.v"
`include "sub_bytes.v"
`include "shift_rows.v"
`include "mix_columns.v"
`include "add_round_key.v"
`include "sbox.v"
`include "key_expansion.v"
`include "aes_controller.v"

module aes_top(
    input clk,
    input rst,
    input start,
    input [127:0] plaintext,
    input [255:0] key,

    output [127:0] ciphertext,
    output done,

    // Debug
    output [127:0] round_state [0:14],
    output [127:0] round_key   [0:14],
    output [127:0] subbytes_state  [0:14],
    output [127:0] shiftrows_state [0:14],
    output [127:0] mixcolumns_state[0:14],
    output [127:0] ark_state       [0:14]   
);

/////////////////////////
// Internal signals
/////////////////////////

wire [3:0] current_round;
wire [127:0] round_output;
wire round_done;

reg  [127:0] state_reg;

/////////////////////////
// Key Expansion
/////////////////////////

wire [127:0] round_key_wire;
reg  [127:0] round_key_reg_internal;

always @(posedge clk)
    round_key_reg_internal <= round_key_wire;

key_expansion keyexp (
    .round(current_round),
    .key(key),
    .round_key(round_key_wire)
);

/////////////////////////
// AES Round
/////////////////////////

wire [127:0] sb_out, sr_out, mc_out;

aes_round round_inst (
    .clk(clk),
    .round(current_round),
    .state_in(state_reg),
    .round_key(round_key_wire),  
    .state_out(round_output),
    .round_done(round_done),

    .subbytes_out(sb_out),
    .shiftrows_out(sr_out),
    .mixcolumns_out(mc_out)
);
/////////////////////////
// Controller
/////////////////////////

aes_controller ctrl (
    .clk(clk),
    .rst(rst),
    .start(start),
    .round_done(round_done),
    .round(current_round),
    .done(done)
);

/////////////////////////
// STATE REGISTER
/////////////////////////

always @(posedge clk or posedge rst) begin
    if (rst)
        state_reg <= 128'b0;

    else if (start)
        state_reg <= plaintext;

    // Round 0 (AddRoundKey only)
    else if (round_done && current_round == 4'd0)
        state_reg <= state_reg ^ round_key_wire; 

    else if (round_done && !done)
        state_reg <= round_output;
end

/////////////////////////
// DEBUG STORAGE
/////////////////////////

reg [127:0] round_state_reg [0:14];
reg [127:0] round_key_reg   [0:14];

reg [127:0] subbytes_reg    [0:14];
reg [127:0] shiftrows_reg   [0:14];
reg [127:0] mixcolumns_reg  [0:14];
reg [127:0] ark_reg         [0:14]; 

always @(posedge clk) begin

    if (start) begin
        round_state_reg[0] <= plaintext;
        round_key_reg[0]   <= round_key_wire;

        subbytes_reg[0]    <= 0;
        shiftrows_reg[0]   <= 0;
        mixcolumns_reg[0]  <= 0;

        ark_reg[0]         <= plaintext ^ round_key_wire; 
    end

    else if (round_done) begin
        round_state_reg[current_round] <= state_reg;
        round_key_reg[current_round]   <= round_key_reg_internal;

        subbytes_reg[current_round]    <= sb_out;
        shiftrows_reg[current_round]   <= sr_out;
        mixcolumns_reg[current_round]  <= mc_out;

        ark_reg[current_round]         <= round_output; 
    end
end

/////////////////////////
// OUTPUT REGISTER
/////////////////////////

reg [127:0] cipher_reg;

always @(posedge clk or posedge rst) begin
    if (rst)
        cipher_reg <= 0;

    else if (round_done && current_round == 4'd14)
        cipher_reg <= round_output;
end

assign ciphertext = cipher_reg;

/////////////////////////
// CONNECT OUTPUTS
/////////////////////////

genvar i;
generate
    for (i = 0; i <= 14; i = i + 1) begin : OUT_ASSIGN
        assign round_state[i]      = round_state_reg[i];
        assign round_key[i]        = round_key_reg[i];
        assign subbytes_state[i]   = subbytes_reg[i];
        assign shiftrows_state[i]  = shiftrows_reg[i];
        assign mixcolumns_state[i] = mixcolumns_reg[i];
        assign ark_state[i]        = ark_reg[i];
    end
endgenerate

endmodule