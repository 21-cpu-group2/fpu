`timescale 1ns / 100ps
`default_nettype none
module fiszero
    (input wire [31:0] op,
    output reg result,
    input clk
    );

    always @(posedge clk) begin
        result <= ~|op[30:23];
    end

endmodule
`default_nettype wire