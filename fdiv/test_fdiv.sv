`timescale 1us / 100ns
`default_nettype none

module test_fdiv();
    wire [31:0] op1;
    wire [31:0] op2;
    logic [31:0] result;
    wire clk;
    logic reset;
    logic [31:0] op1logic;
    logic [31:0] op2logic;
    logic clklogic;

    bit [31:0] op1bit;
    shortreal op1shortreal;

    bit [31:0] op2bit;
    shortreal op2shortreal;

    bit [31:0] resultbit;
    shortreal resultshortreal;
    bit error;
    bit error_in_bit;
    int i;

    real gosa;
    shortreal fdivresultshortreal;

   assign op1 = op1logic;
   assign op2 = op2logic;
   assign clk = clklogic;
   
   fdiv2 f(op1, op2, result, clk, reset);

   always begin
       #1 clklogic <= ~clklogic;
   end

   initial begin
       clklogic = 0;
       reset = 0;
       #2;
       reset = 1;
       #2;
        for(i = 0; i < 1000; i++)begin
            #2;
            error = 1'b0;

            op1logic = $urandom();
            op1bit = op1logic;
            op1shortreal = $bitstoshortreal(op1bit);
            op2logic = $urandom();
            op2bit = op2logic;
            op2shortreal = $bitstoshortreal(op2bit);
            resultshortreal = op1shortreal / op2shortreal;
            resultbit = $shortrealtobits(resultshortreal);
            #12;
            fdivresultshortreal = $bitstoshortreal(result);
            gosa = fdivresultshortreal - resultshortreal;
            if (~(result == resultbit)) begin
                error_in_bit = 1'b1;
                $display("result is not correct\n");
                $display("op1 = %b\n", op1logic);
                $display("op2 = %b\n", op2logic);
            end
        end
        $finish;
   end
endmodule
`default_nettype wire
