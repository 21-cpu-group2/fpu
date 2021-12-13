`timescale 1us / 100ns
`default_nettype wire
module ontest_itof (
    input wire clk,
    input wire reset,
    (* mark_debug = "true" *) output wire [31:0] result_debug
);

wire sig;
wire [7:0] exp;
wire [22:0] fra;

make_sig1 sig1(clk, reset, sig);
make_exp1 exp1(clk, reset, exp);
make_fra1 fra1(clk, reset, fra);

(* mark_debug = "true" *) wire [31:0] op;
assign op = {sig, exp, fra};

itof itof_test(op, result_debug, clk, reset);
    
endmodule

`default_nettype wire
