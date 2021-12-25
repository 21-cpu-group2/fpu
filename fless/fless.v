module fless (
    input wire [31:0] op1,
    input wire [31:0] op2,
    output wire result
);

    wire sig1 = op1[31];
    wire sig2 = op2[31];
    wire exp1 = op1[30:23];
    wire exp2 = op2[30:23];

    assign result = ((sig1 == sig2) && (exp1 == exp2)) ? (op1[22:0] < op2[22:0]) ^ sig1 :
                    (sig1 == sig2) ? (exp1 < exp2) ^ sig1 : sig1;

endmodule