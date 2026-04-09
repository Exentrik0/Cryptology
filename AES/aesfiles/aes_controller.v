module aes_controller(
    input clk,
    input rst,
    input start,
    input round_done,
    output reg [3:0] round,
    output reg done
);

    reg active;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            round  <= 0;
            done   <= 0;
            active <= 0;
        end 

        // Start encryption
        else if (start && !active) begin
            active <= 1;
            round  <= 0;
            done   <= 0;
        end 

        // Active encryption
        else if (active) begin

            // Move to next round ONLY when round_done pulse comes
            if (round_done) begin

                if (round == 4'd14) begin
                    // Last round completed
                    done   <= 1;
                    active <= 0;
                end 
                else begin
                    round <= round + 1;
                end

            end
        end

        //  clear done after 1 cycle (clean pulse)
        else begin
            done <= 0;
        end
    end

endmodule
