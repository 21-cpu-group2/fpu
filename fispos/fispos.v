module fispos (
    input wire [31:0] op,
    output wire result
);
    
wire iszero;
assign notzero = |op[30:0];
assign result = notzero & ~op[31]; 

endmodule