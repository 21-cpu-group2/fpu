`timescale 1us / 100ns
`default_nettype none

module test_ftoi();
    wire [31:0] op1;
    logic [31:0] result;
    wire clk;
    logic valid;
    logic reset;
    logic [31:0] op1logic;
    logic clklogic;

    bit [31:0] op1bit;
    shortreal op1shortreal;
    real op1real;
    int resultint;
    logic [31:0] resultbit;
    int ftoiresult;
    bit error;
    bit error_in_bit;
    int i;
    bit invalid;



   assign op1 = op1logic;
   assign clk = clklogic;
   
   ftoi f(op1, result, clk, reset, valid);

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
            #1;
            error = 1'b0;

            op1logic = $urandom();
            op1bit = op1logic;
            op1shortreal = $bitstoshortreal(op1bit);
            op1real = real'(op1shortreal);
            resultint = $rtoi(op1real);
            if (op1real > 2**31 || op1real < -2**31) begin
                invalid = 1'b1;
                #4;
                continue;
            end
            invalid = 1'b0;
            #4;
            if (~(result == resultint)) begin
                error_in_bit = 1'b1;
                $display("result is not correct\n");
                $display("op1 = %b\n", op1logic);
            end
        end
        $finish;
   end
endmodule
`default_nettype wire
