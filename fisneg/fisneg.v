`timescale 1ns / 100ps
`default_nettype none
module fisneg
    (input wire [31:0] op,
    output reg result,
    input wire reset,
    input wire clk
    );

    wire iszero;
    assign iszero = ~|op[30:23];//指数部が0ならすべてゼロ

    always @(posedge clk) begin
        if (~reset) begin
            result <= 1'b0;
        end else begin
            if (iszero) begin
                result <= 1'b0;
            end else begin
                result <= op[31];
            end
        end
    end

endmodule
`default_nettype wire