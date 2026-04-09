module mix_columns(
  input  [127:0] state_in,
  output [127:0] state_out
);

/////////////////////////
// Galois Field Ops
/////////////////////////

function [7:0] xtime;
  input [7:0] b;
  xtime = {b[6:0],1'b0} ^ (8'h1b & {8{b[7]}});
endfunction

function [7:0] mul2;
  input [7:0] b;
  mul2 = xtime(b);
endfunction

function [7:0] mul3;
  input [7:0] b;
  mul3 = xtime(b) ^ b;
endfunction

/////////////////////////
// Mix one column
/////////////////////////

function [31:0] mix_col;
  input [31:0] c;
  reg [7:0] s0, s1, s2, s3;
  begin
    s0 = c[31:24];
    s1 = c[23:16];
    s2 = c[15:8];
    s3 = c[7:0];

    mix_col[31:24] = mul2(s0) ^ mul3(s1) ^ s2 ^ s3;
    mix_col[23:16] = s0 ^ mul2(s1) ^ mul3(s2) ^ s3;
    mix_col[15:8]  = s0 ^ s1 ^ mul2(s2) ^ mul3(s3);
    mix_col[7:0]   = mul3(s0) ^ s1 ^ s2 ^ mul2(s3);
  end
endfunction

/////////////////////////
// Correct Column Mapping
/////////////////////////

wire [31:0] col0, col1, col2, col3;

// AES column-major extraction
assign col0 = {state_in[127:120], state_in[119:112], state_in[111:104], state_in[103:96]};
assign col1 = {state_in[95:88],   state_in[87:80],   state_in[79:72],   state_in[71:64]};
assign col2 = {state_in[63:56],   state_in[55:48],   state_in[47:40],   state_in[39:32]};
assign col3 = {state_in[31:24],   state_in[23:16],   state_in[15:8],    state_in[7:0]};
  
/////////////////////////
// Apply MixColumns
/////////////////////////

wire [31:0] mix0, mix1, mix2, mix3;

assign mix0 = mix_col(col0);
assign mix1 = mix_col(col1);
assign mix2 = mix_col(col2);
assign mix3 = mix_col(col3);

/////////////////////////
// Reassemble State
/////////////////////////

assign state_out = {
  mix0[31:24], mix0[23:16], mix0[15:8], mix0[7:0],
  mix1[31:24], mix1[23:16], mix1[15:8], mix1[7:0],
  mix2[31:24], mix2[23:16], mix2[15:8], mix2[7:0],
  mix3[31:24], mix3[23:16], mix3[15:8], mix3[7:0]
};

endmodule