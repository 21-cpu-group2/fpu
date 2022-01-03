`timescale 1us / 100ns
`default_nettype none

module samplemake_fisneg();
    wire [31:0] op;
    logic result;
    logic [31:0] oplogic;

    int i;
    bit sig;
    bit [22:0] fra;
    bit [7:0] exp;

    bit [31:0] dum;

   assign op = oplogic;
   
   fisneg f(op, result);

   initial begin
        oplogic = 32'd0;
        #1;
        $display("%b %b", oplogic, result);//ゼロ
        for (i = 0; i < 10000; i++) begin
            oplogic = $urandom();
            #1;
            $display("%b %b", oplogic, result);//ランダム
        end
        $finish;
   end
endmodule
`default_nettype wire
