`timescale 1ns / 100ps
`default_nettype none
module fless
    (input wire [31:0] op1,
    input wire [31:0] op2,
    output reg result,
    input clk
    );

    wire sig1 = op1[31];
    wire sig2 = op2[31];
    wire exp1 = op1[30:23];
    wire exp2 = op2[30:23];

    always @(posedge clk) begin
        if (sig1 == sig2) begin
            if (exp1 == exp2) begin
                result <= (op1[22:0] < op2[22:0]);
            end else begin
                result <= (exp1 < exp2);
            end
        end else begin
            result <= sig1;
        end
    end

endmodule
`default_nettype wire