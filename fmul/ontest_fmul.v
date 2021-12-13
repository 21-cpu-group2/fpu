`timescale 1us / 100ns
`default_nettype wire
module ontest_fmul (
    input wire clk,
    input wire reset,
    (* mark_debug = "true" *) output wire [31:0] result_debug
);

wire sig1;
wire [7:0] exp1;
wire [22:0] fra1;
wire sig2;
wire [7:0] exp2;
wire [22:0] fra2;

make_sig1 sig1_test(clk, reset, sig1);
make_exp1 exp1_test(clk, reset, exp1);
make_fra1 fra1_test(clk, reset, fra1);

make_sig2 sig2_test(clk, reset, sig2);
make_exp2 exp2_test(clk, reset, exp2);
make_fra2 fra2_test(clk, reset, fra2);

(* mark_debug = "true" *) wire [31:0] op1;
assign op1 = {sig1, exp1, fra1};
(* mark_debug = "true" *) wire [31:0] op2;
assign op2 = {sig2, exp2, fra2};

fmul fmul_test(op1, op2, result_debug, clk, reset);
    
endmodule

`default_nettype wire
