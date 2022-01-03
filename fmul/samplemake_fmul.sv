`timescale 1ns / 100ps
`default_nettype none

module samplemake_fmul();
    wire [31:0] op1;
    wire [31:0] op2;
    logic [31:0] result;
    wire clk;
    logic [31:0] op1logic;
    logic [31:0] op2logic;
    logic reset;
    logic clklogic;

    int i;
    bit sig1, sig2;
    bit [22:0] fra1, fra2;
    bit [7:0] exp1, exp2;

    bit [31:0] dum;

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
        op1logic = 32'd0;
        op2logic = 32'd0;
        #6;
        $display("%b %b %b", op1logic, op2logic, result);//どっちもゼロ
        for (i = 0; i < 1000; i++) begin
            op1logic = 32'd0;
            op2logic = $urandom();
            #6;
            $display("%b %b %b", op1logic, op2logic, result);//op1がゼロ
        end
        for (i = 0; i < 1000; i++) begin
            op2logic = 32'd0;
            op1logic = $urandom();
            #6;
            $display("%b %b %b", op1logic, op2logic, result);//op2がゼロ
        end
        for (i = 0; i < 1000; i++) begin
            dum = $urandom();
            sig1 = dum[31];
            exp1 = 8'b11111110;
            fra1 = dum[22:0];
            op1logic = {sig1, exp1, fra1};
            op2logic = $urandom();
            #6;
            $display("%b %b %b", op1logic, op2logic, result);//op1が大きい
        end
        for (i = 0; i < 1000; i++) begin
            dum = $urandom();
            sig2 = dum[31];
            exp2 = 8'b11111110;
            fra2 = dum[22:0];
            op2logic = {sig2, exp2, fra2};
            op1logic = $urandom();
            #6;
            $display("%b %b %b", op1logic, op2logic, result);//op2が大きい
        end
        for (i = 0; i < 10000; i++) begin
            op2logic = $urandom();
            op1logic = $urandom();
            #6;
            $display("%b %b %b", op1logic, op2logic, result);//どっちもランダム
        end
        $finish;
   end
endmodule
`default_nettype wire
