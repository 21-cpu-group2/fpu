`timescale 1us / 100ns
`default_nettype none

module test_fsqrt();
    wire [31:0] op1;
    logic [31:0] result;
    wire clk;
    logic ready;
    logic reset;
    logic [31:0] op1logic;
    logic clklogic;

    bit [31:0] op1bit;
    shortreal op1shortreal;

    shortreal fsqrtresult;
    shortreal fsqrtresult_square;
    int i;

    real gosa;

    bit [31:0] dump;
   assign op1 = op1logic;
   assign clk = clklogic;
   
   fsqrt f(op1, result, clk, reset, ready);

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

            dump = $urandom();
            op1logic = {1'b0, dump[30:0]};
            op1bit = op1logic;
            op1shortreal = $bitstoshortreal(op1bit);
            // while (~ready) begin
            //     #2;
            // end
            #6;
            fsqrtresult = $bitstoshortreal(result);
            fsqrtresult_square = fsqrtresult * fsqrtresult;
            gosa = op1shortreal - fsqrtresult_square;
        end
        $finish;
   end
endmodule
`default_nettype wire
