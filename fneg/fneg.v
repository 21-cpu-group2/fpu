module fneg(
    input wire [31:0] op,
    output wire [31:0] result
);

assign result[31] = (~op[31] & |op[30:23]);
assign result[30:0] = op[30:0];

endmodule