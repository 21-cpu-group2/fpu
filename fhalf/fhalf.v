`timescale 1ns / 100ps
`default_nettype none
module fhalf
    (input wire [31:0] op,
    output reg [31:0] result,
    input wire clk,
    output reg ready,
    output reg valid,
    input wire reset
    );

    wire [7:0] exp = op[30:23];
    wire [7:0] exp_sub1 = (op[30:23] - 8'b1);
    wire [22:0] fra_shift = op[22:0] >> 1;

    always @(posedge clk) begin
        if (~reset) begin
            result <= 32'b0;
            ready <= 1'b0;
            valid <= 1'b0;
        end
        if (ready) begin
            ready <= 1'b0;
            valid <= 1'b0;
        end
        if (exp == 8'b0) begin
            result <= {op[31:23], fra_shift};
            ready <= 1'b1;
            valid <= 1'b1;
        end else if (exp == 8'b1) begin
            result <= {op[31], 8'b0, 1'b1, fra_shift[21:0]};
            ready <= 1'b1;
            valid <= 1'b1;
        end else begin
            result <= {op[31], exp_sub1, fra_shift};
            ready <= 1'b1;
            valid <= 1'b1;
        end
    end

endmodule
`default_nettype wire