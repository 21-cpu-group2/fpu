`timescale 1ns / 100ps
`default_nettype none
module fneg
    (input wire [31:0] op,
    output reg [31:0] result,
    input wire clk,
    input wire reset
    );

    always @(posedge clk) begin
        if (~reset) begin
            result <= 32'd0;
        end else begin
            result <= {~op[31], op[30:0]};
        end
    end

endmodule
`default_nettype wire