`timescale 1us / 100ns
`default_nettype none

module test_fadd();
    wire [31:0] op1;
    wire [31:0] op2;
    logic [31:0] result;
    wire clk;
    logic ready;
    logic valid;
    logic [31:0] op1logic;
    logic [31:0] op2logic;
    logic clklogic;
    logic reset;

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
    real gosa2, gosa3;
    shortreal faddresult;
    bit error;
    bit error_in_bit;

    shortreal op1_plus, op2_plus;
    logic [31:0] op1_plus_logic;
    logic [31:0] op2_plus_logic;

   assign op1 = op1logic;
   assign op2 = op2logic;
   assign clk = clklogic;
   
   fadd f(op1, op2, result, clk , ready, valid, reset);


   always begin
       #1 clklogic <= ~clklogic;
   end

   initial begin
       clklogic =0;
       reset = 0;
       #2;
       reset = 1;
       #2;
       epsiron = 2 ** (-126);
       for(sig1 = 0; sig1 < 2; sig1++) begin
           for(sig2 = 0; sig2 < 2; sig2++) begin
               for(exp1 = 1; exp1 < 256; exp1++) begin
                   for(exp2 = 1; exp2 < 256; exp2++) begin 
                        #1;
                        error = 1'b0;

                        {fra1, dum1} = $urandom();
                        {fra2, dum2} = $urandom();

                        op1logic = {sig1[0], exp1[7:0], fra1};
                        op2logic = {sig2[0], exp2[7:0], fra2};
                        op1real = $bitstoshortreal(op1logic);
                        op2real = $bitstoshortreal(op2logic);
                        resultreal = op1real + op2real;
                        resultbit = $shortrealtobits(resultreal);

                        op1_plus_logic = {1'b0, exp1[7:0], fra1};
                        op2_plus_logic = {1'b0, exp2[7:0], fra2};
                        op1_plus = $bitstoshortreal(op1_plus_logic);
                        op2_plus = $bitstoshortreal(op2_plus_logic);

                        gosa = resultreal * 2 ** (-23);
                        gosa2 = op1_plus * 2 ** (-23);
                        gosa3 = op2_plus * 2 ** (-23);
                        #6;
                        faddresult = $bitstoshortreal(result);
                        if (faddresult - resultreal > 0) begin
                            abs = faddresult - resultreal;
                        end else begin
                            abs = resultreal - faddresult;
                        end
                        if (abs > gosa && abs > gosa2 && abs > gosa3) begin
                            $display("result is not correct\n");
                            $display("op1 = %b\n", op1logic);
                            $display("op2 = %b\n", op2logic);
                            error = 1'b1;
                        end
                        if (~(result == resultbit)) begin
                            error_in_bit = 1'b1;
                        end
                    end
                end
            end
        end
        $finish;
   end
endmodule
`default_nettype wire
