module sub_bytes(
    input [127:0] state_in,
    output [127:0] state_out
);
   
genvar i;
generate
for(i=0;i<16;i=i+1)
begin
  sbox s(
    .in(state_in[8*i +:8]),
    .out(state_out[8*i +:8])
);
end
endgenerate

endmodule
