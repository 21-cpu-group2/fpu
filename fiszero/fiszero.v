module fiszero (
    input wire [31:0] op,
    output wire result
);
    
assign result = ~|op[30:23];    

endmodule