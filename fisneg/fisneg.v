module fisneg (
    input wire [31:0] op,
    output wire result
);

    wire iszero;
    assign notzero = |op[30:23];
    assign result = notzero & op[31];
    
endmodule