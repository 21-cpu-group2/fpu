`timescale 1us / 100ns
`default_nettype none

module samplemake_fsqrt();
    wire [31:0] op;
    logic [31:0] result;
    wire clk;
    logic [31:0] oplogic;
    logic reset;
    logic clklogic;

    int i;
    bit sig;
    bit [22:0] fra;
    bit [7:0] exp;

    bit [31:0] dum;

   assign op = oplogic;
   assign clk = clklogic;
   
   fsqrt f(op, result, clk, reset);

   always begin
       #1 clklogic <= ~clklogic;
   end

   initial begin
        clklogic =0;
        reset = 0;
        #2;
        reset = 1;
        #2;
        oplogic = 32'd0;
        #6;
        $display("%b %b", oplogic, result);//ゼロ
        for (i = 0; i < 1000; i++) begin
            dum = $urandom();
            sig = dum[31];
            exp = 8'b11111110;
            fra = dum[22:0];
            oplogic = {sig, exp, fra};
            #6;
            $display("%b %b", oplogic, result);//opが大きい
        end
        for (i = 0; i < 10000; i++) begin
            oplogic = $urandom();
            #6;
            $display("%b %b", oplogic, result);//ランダム
        end
        $finish;
   end
endmodule
`default_nettype wire
