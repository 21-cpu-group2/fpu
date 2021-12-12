`timescale 1us / 100ns
`default_nettype none

module test_itof();
    wire [31:0] op1;
    logic [31:0] result;
    wire clk;
    // logic valid;
    logic reset;
    logic [31:0] op1logic;
    logic clklogic;

    int op1int;
    shortreal resultshortreal;
    real resultreal;
    logic [31:0] resultbit;
    shortreal itofresult;
    bit error;
    bit error_in_bit;
    int i;

   assign op1 = op1logic;
   assign clk = clklogic;
   
   itof f(op1,result,clk , reset);

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
            op1int = op1logic;

            resultreal = $itor(op1int);
            resultshortreal = shortreal'(resultreal);
            resultbit = $shortrealtobits(resultreal);
            #6;
            itofresult = $bitstoshortreal(result);
            if (~(result == resultbit)) begin
                error_in_bit = 1'b1;
                $display("result is not correct\n");
                $display("op1 = %b\n", op1logic);
            end
        end
        $finish;
   end
endmodule
`default_nettype wire
