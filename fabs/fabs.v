module fabs(
    input wire [31:0] op,
    output wire [31:0] result
);

assign result[31] = 1'b0;
assign result[30:0] = op[30:0];

endmodule