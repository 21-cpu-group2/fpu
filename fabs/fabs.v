`timescale 1ns / 100ps
`default_nettype none
module fabs
    (input wire [31:0] op,
    output reg [31:0] result,
    output reg ready,
    input wire reset,
    input wire clk
    );

    always @(posedge clk) begin
        if (~reset) begin
            result <= 32'd0;
            ready <= 1'b0;
        end else begin
           if (ready) begin
                ready <= 1'b0;
            end
            result <= {1'b0, op[30:0]};
            ready <= 1'b1; 
        end
    end
endmodule
`default_nettype wire