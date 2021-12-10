`timescale 1us / 100ns
`default_nettype none

module test_fadd();
    wire [31:0] op1;
    wire [31:0] op2;
    logic [31:0] result;
    wire clk;
    logic [31:0] op1logic;
    logic [31:0] op2logic;
    logic clklogic;
    logic reset;

    // int sig1, sig2, exp1, exp2;
    int i;
    shortreal op1real, op2real;
    shortreal resultreal;
    logic [31:0] resultbit;
    bit ovf;
    shortreal abs;
    real gosa;
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
   
   fadd f(op1, op2, result, clk, reset);


   always begin
       #1 clklogic <= ~clklogic;
   end

   initial begin
       clklogic = 0;
       reset = 0;
       #2;
       reset = 1;
       #2;
       for(i = 0; i < 1000; i++) begin
            #1;
            error = 1'b0;

            op1logic = $urandom();
            op2logic = $urandom();

            op1real = $bitstoshortreal(op1logic);
            op2real = $bitstoshortreal(op2logic);
            resultreal = op1real + op2real;
            resultbit = $shortrealtobits(resultreal);

            op1_plus_logic = {1'b0, op1logic[30:0]};
            op2_plus_logic = {1'b0, op2logic[30:0]};
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
        $finish;
   end
endmodule
`default_nettype wire
