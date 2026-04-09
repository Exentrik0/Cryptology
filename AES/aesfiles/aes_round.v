module aes_round(
    input clk,
    input [3:0] round,
    input [127:0] state_in,
    input [127:0] round_key,

    output [127:0] state_out,
    output round_done,


    // DEBUG OUTPUTS
    output [127:0] subbytes_out,
    output [127:0] shiftrows_out,
    output [127:0] mixcolumns_out
);

/////////////////////////
// Internal wires
/////////////////////////

wire [127:0] sb_out;
wire [127:0] sr_out;
wire [127:0] mc_out;
wire [127:0] ark_in;
wire [127:0] next_state;

/////////////////////////
// AES STAGES
/////////////////////////

// SubBytes
sub_bytes SB (
    .state_in(state_in),
    .state_out(sb_out)
);

// ShiftRows
shift_rows SR (
    .state_in(sb_out),
    .state_out(sr_out)
);

// MixColumns
mix_columns MC (
    .state_in(sr_out),
    .state_out(mc_out)
);

/////////////////////////
// DEBUG OUTPUTS (FIXED)
/////////////////////////

assign subbytes_out  = sb_out;
assign shiftrows_out = sr_out;
assign mixcolumns_out = (round == 4'd14) ? 128'b0 : mc_out;

/////////////////////////
// AddRoundKey
/////////////////////////

assign ark_in = (round == 4'd14) ? sr_out : mc_out;

add_round_key ARK (
    .state(ark_in),
    .round_key(round_key),
    .out(next_state)
);

/////////////////////////
// SEQUENTIAL OUTPUT
/////////////////////////

reg done_reg;

/////////////////////////
// COMBINATIONAL OUTPUT
/////////////////////////

assign state_out = next_state;
assign round_done = 1'b1;



endmodule
