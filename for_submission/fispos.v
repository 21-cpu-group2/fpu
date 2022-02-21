module fispos (
    input wire [31:0] op,
    output wire result
);
    
wire notzero;
assign notzero = |op[30:23];
assign result = notzero & ~op[31]; 

endmodule