`timescale 1ns / 100ps
`default_nettype none

module fmul
    (input wire [31:0] op1,
    input wire [31:0] op2,
    output reg [31:0] result,
    input wire clk,
    output reg ready,
    output reg valid
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
    
    always @(posedge clk) begin
        HH <= H1 * H2;
        HL <= H1 * L2;
        LH <= L1 * H2;
        res_exp <= ex_exp1 + ex_exp2 + 9'd129;
        res_sig <= sig1 ^ sig2; //XOR      
    end

    reg [25:0] sum;
    reg [8:0] res_exp_plus1;
    reg [8:0] res_exp_2;
    reg res_sig_2;

    always @(posedge clk) begin
        sum <= HH + (HL >> 11) + (LH >> 11) + 26'd2;
        res_exp_plus1 <= res_exp + 9'b1;
        res_sig_2 <= res_sig;
        res_exp_2 <= res_exp;
    end

    always @(posedge clk) begin
        if (ready) begin
            valid <= 1'b0;
            ready <= 1'b0;
        end
        if (sum[25]) begin
            if (res_exp_plus1[8]) begin
                result <= {res_sig_2, res_exp_plus1[7:0], sum[24:2]};
                ready <= 1;
                valid <= 1;
            end else begin
                valid <= 1;
                ready <= 0;
            end
        end else begin
            if (res_exp_2[8]) begin
                result <= {res_sig_2, res_exp_2[7:0], sum[23:1]};
                ready <= 1;
                valid <= 1;
            end else begin
                valid <= 1;
                ready <= 0;
            end
        end
    end



endmodule
`default_nettype wire