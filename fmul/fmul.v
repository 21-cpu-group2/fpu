`timescale 1ns / 100ps
`default_nettype none

module fmul
    (input wire [31:0] op1,
    input wire [31:0] op2,
    output reg [31:0] result,
    input wire clk,
    input wire reset
    );

    wire [12:0] H1;
    wire [12:0] H2;
    wire [10:0] L1;
    wire [10:0] L2;
    wire [7:0] exp1;
    wire [7:0] exp2;
    wire sig1;
    wire sig2;

    assign L1 = op1[10:0];
    assign L2 = op2[10:0];
    assign H1 = {1'b1, op1[22:11]};
    assign H2 = {1'b1, op2[22:11]};
    assign exp1 = op1[30:23];
    assign exp2 = op2[30:23];
    assign sig1 = op1[31];
    assign sig2 = op2[31];

    reg [25:0] HH;
    reg [25:0] HL;
    reg [25:0] LH;
    reg [8:0] res_exp;
    reg res_sig;

    wire [8:0] ex_exp1;
    assign ex_exp1 = {1'b0, exp1};
    wire [8:0] ex_exp2;
    assign ex_exp2 = {1'b0, exp2};

    reg [25:0] sum;
    reg [8:0] res_exp_plus1;
    reg [8:0] res_exp_2;
    reg res_sig_2;

    wire is_zero;
    assign is_zero = (exp1 == 8'd0) | (exp2 == 8'd0);
    reg is_zero_reg;
    reg is_zero_reg2;

    always @(posedge clk) begin
        if(~reset) begin
            result <= 32'd0;
            HH <= 26'd0;
            HL <= 26'd0;
            LH <= 26'd0;
            res_exp <= 9'd0;
            res_sig <= 1'd0;
            sum <= 26'd0;
            res_exp_plus1 <= 9'd0;
            res_exp_2 <= 9'd0;
            res_sig_2 <= 1'd0;
            is_zero_reg <= 1'd0;
            is_zero_reg2 <= 1'd0;
        end else begin
            HH <= H1 * H2;
            HL <= H1 * L2;
            LH <= L1 * H2;
            res_exp <= ex_exp1 + ex_exp2 + 9'd129;
            res_sig <= sig1 ^ sig2; //XOR 
            is_zero_reg <= is_zero;

            sum <= HH + (HL >> 11) + (LH >> 11) + 26'd2;
            res_exp_plus1 <= res_exp + 9'b1;
            res_sig_2 <= res_sig;
            res_exp_2 <= res_exp;
            is_zero_reg2 <= is_zero_reg;
            
            if (is_zero_reg2) begin
                result <= 32'd0;
            end else begin
                if (sum[25]) begin
                    if (res_exp_plus1[8]) begin
                        result <= {res_sig_2, res_exp_plus1[7:0], sum[24:2]};
                    end else begin
                        result <= 32'd0;
                    end
                end else begin
                    if (res_exp_2[8]) begin
                        result <= {res_sig_2, res_exp_2[7:0], sum[23:1]};
                    end else begin
                        result <= 32'd0;
                    end
                end 
            end
        end
    end

endmodule
`default_nettype wire
