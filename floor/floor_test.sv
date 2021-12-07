`timescale 1us / 100ns
`default_nettype none

module test_floor();
    wire [31:0] op1;
    logic [31:0] result;
    wire clk;
    logic valid;
    logic reset;
    logic [31:0] op1logic;
    logic clklogic;

    bit [31:0] op1bit;
    shortreal op1shortreal;
    shortreal floorresult;
    bit error;
    int i;



   assign op1 = op1logic;
   assign clk = clklogic;
   
   floor f(op1, result, clk, reset, valid);

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
            #4;
            floorresult = $bitstoshortreal(result);
            if (op1shortreal - floorresult >= 1 || op1shortreal - floorresult < 0) begin
                error = 1'b1;
                $display("result is not correct\n");
                $display("op1 = %b\n", op1logic);
            end
        end
        $finish;
   end
endmodule
`default_nettype wire
