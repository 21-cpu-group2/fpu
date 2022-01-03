`timescale 1us / 100ns
`default_nettype none

module samplemake_ftoi();
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
   
   ftoi f(op, result, clk, reset);

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
        #4;
        $display("%b %b", oplogic, result);//ゼロ
        for (i = 0; i < 1000; i++) begin
            dum = $urandom();
            sig = dum[31];
            exp = {3'b100, dum[27:23]};
            fra = dum[22:0];
            oplogic = {sig, exp, fra};
            #4;
            $display("%b %b", oplogic, result);//expが127付近
        end
        for (i = 0; i < 10000; i++) begin
            oplogic = $urandom();
            #4;
            $display("%b %b", oplogic, result);//ランダム
        end
        $finish;
   end
endmodule
`default_nettype wire
