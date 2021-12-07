`timescale 1ns / 100ps
`default_nettype none
module fispos
    (input wire [31:0] op,
    output reg result,
    output reg ready,
    input wire reset,
    input wire clk
    );

    wire iszero = ~|op[30:0];

    always @(posedge clk) begin
        if (~reset) begin
            result <= 1'b0;
            ready <= 1'b0;
        end
        if (ready) begin
            ready <= 1'b0;
        end
        if (iszero) begin
            result <= 1'b0;
            ready <= 1'b1;
        end else begin
            result <= ~op[31];
            ready <= 1'b1;
        end
    end

endmodule
`default_nettype wire