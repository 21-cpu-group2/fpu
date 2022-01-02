`timescale 1ns / 100ps
`default_nettype none

module test_fmul();
    wire [31:0] op1;
    wire [31:0] op2;
    logic [31:0] result;
    wire clk;
    logic [31:0] op1logic;
    logic [31:0] op2logic;
    logic reset;
    logic clklogic;

    int sig1, sig2, exp1, exp2;
    int i;
    bit [22:0] fra1, fra2;
    bit [8:0] dum1, dum2;
    shortreal op1real, op2real;
    shortreal resultreal;
    logic [31:0] resultbit;
    bit ovf;
    shortreal abs;
    real gosa, epsiron;
    shortreal fmulresult;
    bit error;
    bit error_in_bit;

   assign op1 = op1logic;
   assign op2 = op2logic;
   assign clk = clklogic;
   
   fmul f(op1,op2,result,clk , reset);


   always begin
       #1 clklogic <= ~clklogic;
   end

   initial begin
       reset = 0;
       #2;
       reset = 1;
       #2;
       clklogic =0;
       epsiron = 2 ** (-126);
       op1logic = 32'd0;
       op2logic = 32'd0;
       #6;
    //    for(sig1 = 0; sig1 < 2; sig1++) begin
    //        for(sig2 = 0; sig2 < 2; sig2++) begin
    //            for(exp1 = 1; exp1 < 256; exp1++) begin
    //                for(exp2 = 1; exp2 < 256; exp2++) begin 
    //                     #1;
    //                     error = 1'b0;

    //                     {fra1, dum1} = $urandom();
    //                     {fra2, dum2} = $urandom();

    //                     op1logic = {sig1[0], exp1[7:0], fra1};
    //                     op2logic = {sig2[0], exp2[7:0], fra2};
    //                     op1real = $bitstoshortreal(op1logic);
    //                     op2real = $bitstoshortreal(op2logic);
    //                     resultreal = op1real * op2real;
    //                     resultbit = $shortrealtobits(resultreal);
    //                     gosa = resultreal * 2 ** (-22);
    //                     #6;
    //                     fmulresult = $bitstoshortreal(result);
    //                     if (fmulresult - resultreal > 0) begin
    //                         abs = fmulresult - resultreal;
    //                     end else begin
    //                         abs = resultreal - fmulresult;
    //                     end
    //                     // if (resultbit[30:23] == 8'b0 || resultbit[30:23] == 8'd255)begin
    //                     //     if (valid)begin
    //                     //         $display("return is not valid\n");
    //                     //         ovf = 1'b1;
    //                     //     end
    //                     // end else
    //                     if (abs >= gosa && abs >= epsiron) begin
    //                         $display("result is not correct\n");
    //                         $display("op1 = %b\n", op1logic);
    //                         $display("op2 = %b\n", op2logic);
    //                         error = 1'b1;
    //                     end
    //                     if (~(result == resultbit)) begin
    //                         error_in_bit = 1'b1;
    //                     end
    //                 end
    //             end
    //         end
    //     end
        $finish;
   end
endmodule
`default_nettype wire
