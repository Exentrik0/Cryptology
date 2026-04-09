module key_expansion(
    input  [3:0]   round,
    input  [255:0] key,
    output [127:0] round_key
);

    
    wire [31:0] w [0:59];
    
    
    wire [31:0] rcon [0:6];
    assign rcon[0] = 32'h01000000; assign rcon[1] = 32'h02000000;
    assign rcon[2] = 32'h04000000; assign rcon[3] = 32'h08000000;
    assign rcon[4] = 32'h10000000; assign rcon[5] = 32'h20000000;
    assign rcon[6] = 32'h40000000;

    
    assign w[0] = key[255:224];
    assign w[1] = key[223:192];
    assign w[2] = key[191:160];
    assign w[3] = key[159:128];
    assign w[4] = key[127:96];
    assign w[5] = key[95:64];
    assign w[6] = key[63:32];
    assign w[7] = key[31:0];

    
    genvar i;
    generate
        for (i = 8; i < 60; i = i + 1) begin : gen_w
            wire [31:0] sub_out;
            
            if (i % 8 == 0) begin
                
                subword_module sw_inst (
                    .in({w[i-1][23:0], w[i-1][31:24]}), 
                    .out(sub_out)
                );
                assign w[i] = w[i-8] ^ sub_out ^ rcon[(i/8)-1];
            end 
            else if (i % 8 == 4) begin
                
                subword_module sw_inst (
                    .in(w[i-1]), 
                    .out(sub_out)
                );
                assign w[i] = w[i-8] ^ sub_out;
            end 
            else begin
                
                assign w[i] = w[i-8] ^ w[i-1];
            end
        end
    endgenerate

    assign round_key = {w[round*4], w[round*4+1], w[round*4+2], w[round*4+3]};

endmodule


module subword_module(
    input  [31:0] in,
    output [31:0] out
);
    sbox s0(.in(in[31:24]), .out(out[31:24]));
    sbox s1(.in(in[23:16]), .out(out[23:16]));
    sbox s2(.in(in[15:8]),  .out(out[15:8]));
    sbox s3(.in(in[7:0]),   .out(out[7:0]));
endmodule

