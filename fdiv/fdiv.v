`timescale 1us / 100ns
`default_nettype none
module fdiv
    (input wire [31:0] op1,
    input wire [31:0] op2,
    output reg [31:0] result,
    input wire clk,
    input wire reset
    );

    wire [24:0] fra1;
    wire [24:0] fra2;
    wire [7:0] exp1;
    wire [7:0] exp2;
    wire sig1;
    wire sig2;


    assign fra1 = (op1[30:23] == 8'b0) ? {2'b00, op1[22:0]} : {2'b01, op1[22:0]};
    assign fra2 = (op2[30:23] == 8'b0) ? {2'b00, op2[22:0]} : {2'b01, op2[22:0]};
    assign exp1 = op1[30:23];
    assign exp2 = op2[30:23];
    assign sig1 = op1[31];
    assign sig2 = op2[31];

    reg [8:0] exp1_reg;
    reg [8:0] exp2_reg;
    reg ans_sig_reg;

//x / fra2 = ans ... amari
    wire [11:0] ans_high;
    wire [24:0] sub1 = fra1 - fra2;
    wire [24:0] x1 = (sub1[24] == 1'b1) ? (fra1 << 1) : (sub1 << 1);
    assign ans_high[11] = (sub1[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub2 = x1 - fra2;
    wire [24:0] x2 = (sub2[24] == 1'b1) ? (x1 << 1) : (sub2 << 1);
    assign ans_high[10] = (sub2[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub3 = x2 - fra2;
    wire [24:0] x3 = (sub3[24] == 1'b1) ? (x2 << 1) : (sub3 << 1);
    assign ans_high[9] = (sub3[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub4 = x3 - fra2;
    wire [24:0] x4 = (sub4[24] == 1'b1) ? (x3 << 1) : (sub4 << 1);
    assign ans_high[8] = (sub4[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub5 = x4 - fra2;
    wire [24:0] x5 = (sub5[24] == 1'b1) ? (x4 << 1) : (sub5 << 1);
    assign ans_high[7] = (sub5[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub6 = x5 - fra2;
    wire [24:0] x6 = (sub6[24] == 1'b1) ? (x5 << 1) : (sub6 << 1);
    assign ans_high[6] = (sub6[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub7 = x6 - fra2;
    wire [24:0] x7 = (sub7[24] == 1'b1) ? (x6 << 1) : (sub7 << 1);
    assign ans_high[5] = (sub7[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub8 = x7 - fra2;
    wire [24:0] x8 = (sub8[24] == 1'b1) ? (x7 << 1) : (sub8 << 1);
    assign ans_high[4] = (sub8[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub9 = x8 - fra2;
    wire [24:0] x9 = (sub9[24] == 1'b1) ? (x8 << 1) : (sub9 << 1);
    assign ans_high[3] = (sub9[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub10 = x9 - fra2;
    wire [24:0] x10 = (sub10[24] == 1'b1) ? (x9 << 1) : (sub10 << 1);
    assign ans_high[2] = (sub10[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub11 = x10 - fra2;
    wire [24:0] x11 = (sub11[24] == 1'b1) ? (x10 << 1) : (sub11 << 1);
    assign ans_high[1] = (sub11[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub12 = x11 - fra2;
    wire [24:0] x12 = (sub12[24] == 1'b1) ? (x11 << 1) : (sub12 << 1);
    assign ans_high[0] = (sub12[24] == 1'b1) ? 1'b0 : 1'b1;

    reg [11:0] ans_high_reg;
    reg [24:0] x_next;
    reg [23:0] fra2_next;

    wire [11:0] ans_low;
    wire [24:0] sub_next1 = x_next - fra2_next;
    wire [24:0] x_next1 = (sub_next1[24] == 1'b1) ? (x_next << 1) : (sub_next1 << 1);
    assign ans_low[11] = (sub_next1[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub_next2 = x_next1 - fra2_next;
    wire [24:0] x_next2 = (sub_next2[24] == 1'b1) ? (x_next1 << 1) : (sub_next2 << 1);
    assign ans_low[10] = (sub_next2[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub_next3 = x_next2 - fra2_next;
    wire [24:0] x_next3 = (sub_next3[24] == 1'b1) ? (x_next2 << 1) : (sub_next3 << 1);
    assign ans_low[9] = (sub_next3[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub_next4 = x_next3 - fra2_next;
    wire [24:0] x_next4 = (sub_next4[24] == 1'b1) ? (x_next3 << 1) : (sub_next4 << 1);
    assign ans_low[8] = (sub_next4[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub_next5 = x_next4 - fra2_next;
    wire [24:0] x_next5 = (sub_next5[24] == 1'b1) ? (x_next4 << 1) : (sub_next5 << 1);
    assign ans_low[7] = (sub_next5[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub_next6 = x_next5 - fra2_next;
    wire [24:0] x_next6 = (sub_next6[24] == 1'b1) ? (x_next5 << 1) : (sub_next6 << 1);
    assign ans_low[6] = (sub_next6[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub_next7 = x_next6 - fra2_next;
    wire [24:0] x_next7 = (sub_next7[24] == 1'b1) ? (x_next6 << 1) : (sub_next7 << 1);
    assign ans_low[5] = (sub_next7[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub_next8 = x_next7 - fra2_next;
    wire [24:0] x_next8 = (sub_next8[24] == 1'b1) ? (x_next7 << 1) : (sub_next8 << 1);
    assign ans_low[4] = (sub_next8[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub_next9 = x_next8 - fra2_next;
    wire [24:0] x_next9 = (sub_next9[24] == 1'b1) ? (x_next8 << 1) : (sub_next9 << 1);
    assign ans_low[3] = (sub_next9[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub_next10 = x_next9 - fra2_next;
    wire [24:0] x_next10 = (sub_next10[24] == 1'b1) ? (x_next9 << 1) : (sub_next10 << 1);
    assign ans_low[2] = (sub_next10[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub_next11 = x_next10 - fra2_next;
    wire [24:0] x_next11 = (sub_next11[24] == 1'b1) ? (x_next10 << 1) : (sub_next11 << 1);
    assign ans_low[1] = (sub_next11[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub_next12 = x_next11 - fra2_next;
    wire [24:0] x_next12 = (sub_next12[24] == 1'b1) ? (x_next11 << 1) : (sub_next12 << 1);
    assign ans_low[0] = (sub_next12[24] == 1'b1) ? 1'b0 : 1'b1;

    // wire [24:0] sub_p = x_p-1 - fra2;
    // wire [24:0] x_p = (sub_p[24] == 1'b1) ? (x_p-1 << 1) : (sub_p << 1);
    // assign ans_high[12-p] = (sub3[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [8:0] for_ans_exp;
    assign for_ans_exp = exp1_reg + 9'd127;
    wire [8:0] ans_exp;
    assign ans_exp = for_ans_exp - exp2_reg;
    wire [8:0] ans_exp_minus1;
    assign ans_exp_minus1 = ans_exp - 9'd1;

    always @(posedge clk) begin
        if (~reset) begin
            result <= 32'd0;
            ans_high_reg <= 12'd0;
            x_next <= 25'd0;
            fra2_next <= 24'd0;
            exp1_reg <= 9'd0;
            exp2_reg <= 9'd0;
            ans_sig_reg <= 1'b0;
        end else begin
            ans_high_reg <= ans_high;
            x_next <= x12;
            fra2_next <= fra2;
            exp1_reg <= {1'b0, exp1};
            exp2_reg <= {1'b0, exp2};
            ans_sig_reg <= sig1 ^ sig2;
            if (ans_high_reg[11] == 1'b1) begin
                if (ans_exp[8] == 1'b1) begin
                    result <= 32'd0;
                end else begin
                    result <= {ans_sig_reg,ans_exp[7:0], ans_high_reg[10:0], ans_low};
                end
            end else begin
                if (ans_exp_minus1[8] == 1'b1) begin
                    result <= 32'd0;
                end else begin
                    result <= {ans_sig_reg,ans_exp_minus1[7:0], ans_high_reg[9:0], ans_low, 1'b0};//最終ビットは速さのため計算せず
                end
            end
        end
    end
endmodule
`default_nettype wire