module fhalf(
    input wire [31:0] op,
    output wire [31:0] result
);

    wire [7:0] exp = op[30:23];
    wire [7:0] exp_sub1 = (op[30:23] - 8'd1);
    wire [22:0] fra_shift = op[22:0] >> 1;

    assign result = (exp == 8'd0)? {op[31:23], fra_shift} :
                    (exp == 8'd1)? {op[31], 8'd0, 1'b1, fra_shift[21:0]} : {op[31], exp_sub1, fra_shift};

endmodule