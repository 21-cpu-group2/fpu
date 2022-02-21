`timescale 1us / 100ns
`default_nettype none
module fdiv2
    (input wire [31:0] op1,
    input wire [31:0] op2,
    output reg [31:0] result,
    input wire clk,
    input wire reset
    );

    wire [24:0] fra1;
    wire [24:0] fra2;
    wire [8:0] exp1;
    wire [8:0] exp2;
    wire sig1;
    wire sig2;


    // assign fra1 = (op1[30:23] == 8'b0) ? {2'b00, op1[22:0]} : {2'b01, op1[22:0]};
    assign fra1 = (op1[30:23] == 8'b0) ? 25'd0 : {2'b01, op1[22:0]}; //exp = 0なら0
    assign fra2 = (op2[30:23] == 8'b0) ? {2'b00, op2[22:0]} : {2'b01, op2[22:0]};
    assign exp1 = {1'b0, op1[30:23]};
    assign exp2 = {1'b0, op2[30:23]};
    assign sig1 = op1[31];
    assign sig2 = op2[31];

    reg [24:0] fra2_2;
    reg [24:0] fra2_3;
    reg [24:0] fra2_4;
    reg [24:0] fra2_5;
    reg [24:0] fra2_6;
    reg [24:0] fra2_7;
    reg [24:0] fra2_8;
    reg [24:0] fra2_9;
    reg [24:0] fra2_10;
    reg [24:0] fra2_11;
    reg [24:0] fra2_12;

    reg ans_sig_reg_2;
    reg ans_sig_reg_3;
    reg ans_sig_reg_4;
    reg ans_sig_reg_5;
    reg ans_sig_reg_6;
    reg ans_sig_reg_7;
    reg ans_sig_reg_8;
    reg ans_sig_reg_9;
    reg ans_sig_reg_10;
    reg ans_sig_reg_11;
    reg ans_sig_reg_12;

    wire [1:0] ans1_12;
    wire [1:0] ans2_12;
    wire [1:0] ans3_12;
    wire [1:0] ans4_12;
    wire [1:0] ans5_12;
    wire [1:0] ans6_12;
    wire [1:0] ans7_12;
    wire [1:0] ans8_12;
    wire [1:0] ans9_12;
    wire [1:0] ans10_12;
    wire [1:0] ans11_12;
    wire [1:0] ans12_12;

    reg [24:0] x2_reg;
    reg [24:0] x4_reg;
    reg [24:0] x6_reg;
    reg [24:0] x8_reg;
    reg [24:0] x10_reg;
    reg [24:0] x12_reg;
    reg [24:0] x14_reg;
    reg [24:0] x16_reg;
    reg [24:0] x18_reg;
    reg [24:0] x20_reg;
    reg [24:0] x22_reg;
    
    reg [1:0] ans1to1;
    reg [3:0] ans1to2;
    reg [5:0] ans1to3;
    reg [7:0] ans1to4;
    reg [9:0] ans1to5;
    reg [11:0] ans1to6;
    reg [13:0] ans1to7;
    reg [15:0] ans1to8;
    reg [17:0] ans1to9;
    reg [19:0] ans1to10;
    reg [21:0] ans1to11;

//x / fra2 = ans ... amari
    wire [24:0] sub1 = fra1 - fra2;
    wire [24:0] x1 = (sub1[24] == 1'b1) ? (fra1 << 1) : (sub1 << 1);
    assign ans1_12[1] = (sub1[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub2 = x1 - fra2;
    wire [24:0] x2 = (sub2[24] == 1'b1) ? (x1 << 1) : (sub2 << 1);
    assign ans1_12[0] = (sub2[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub3 = x2_reg - fra2_2;
    wire [24:0] x3 = (sub3[24] == 1'b1) ? (x2_reg << 1) : (sub3 << 1);
    assign ans2_12[1] = (sub3[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub4 = x3 - fra2_2;
    wire [24:0] x4 = (sub4[24] == 1'b1) ? (x3 << 1) : (sub4 << 1);
    assign ans2_12[0] = (sub4[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub5 = x4_reg - fra2_3;
    wire [24:0] x5 = (sub5[24] == 1'b1) ? (x4_reg << 1) : (sub5 << 1);
    assign ans3_12[1] = (sub5[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub6 = x5 - fra2_3;
    wire [24:0] x6 = (sub6[24] == 1'b1) ? (x5 << 1) : (sub6 << 1);
    assign ans3_12[0] = (sub6[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub7 = x6_reg - fra2_4;
    wire [24:0] x7 = (sub7[24] == 1'b1) ? (x6_reg << 1) : (sub7 << 1);
    assign ans4_12[1] = (sub7[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub8 = x7 - fra2_4;
    wire [24:0] x8 = (sub8[24] == 1'b1) ? (x7 << 1) : (sub8 << 1);
    assign ans4_12[0] = (sub8[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub9 = x8_reg - fra2_5;
    wire [24:0] x9 = (sub9[24] == 1'b1) ? (x8_reg << 1) : (sub9 << 1);
    assign ans5_12[1] = (sub9[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub10 = x9 - fra2_5;
    wire [24:0] x10 = (sub10[24] == 1'b1) ? (x9 << 1) : (sub10 << 1);
    assign ans5_12[0] = (sub10[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub11 = x10_reg - fra2_6;
    wire [24:0] x11 = (sub11[24] == 1'b1) ? (x10_reg << 1) : (sub11 << 1);
    assign ans6_12[1] = (sub11[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub12 = x11 - fra2_6;
    wire [24:0] x12 = (sub12[24] == 1'b1) ? (x11 << 1) : (sub12 << 1);
    assign ans6_12[0] = (sub12[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub13 = x12_reg - fra2_7;
    wire [24:0] x13 = (sub13[24] == 1'b1) ? (x12_reg << 1) : (sub13 << 1);
    assign ans7_12[1] = (sub13[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub14 = x13 - fra2_7;
    wire [24:0] x14 = (sub14[24] == 1'b1) ? (x13 << 1) : (sub14 << 1);
    assign ans7_12[0] = (sub14[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub15 = x14_reg - fra2_8;
    wire [24:0] x15 = (sub15[24] == 1'b1) ? (x14_reg << 1) : (sub15 << 1);
    assign ans8_12[1] = (sub15[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub16 = x15 - fra2_8;
    wire [24:0] x16 = (sub16[24] == 1'b1) ? (x15 << 1) : (sub16 << 1);
    assign ans8_12[0] = (sub16[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub17 = x16_reg - fra2_9;
    wire [24:0] x17 = (sub17[24] == 1'b1) ? (x16_reg << 1) : (sub17 << 1);
    assign ans9_12[1] = (sub17[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub18 = x17 - fra2_9;
    wire [24:0] x18 = (sub18[24] == 1'b1) ? (x17 << 1) : (sub18 << 1);
    assign ans9_12[0] = (sub18[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub19 = x18_reg - fra2_10;
    wire [24:0] x19 = (sub19[24] == 1'b1) ? (x18_reg << 1) : (sub19 << 1);
    assign ans10_12[1] = (sub19[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub20 = x19 - fra2_10;
    wire [24:0] x20 = (sub20[24] == 1'b1) ? (x19 << 1) : (sub20 << 1);
    assign ans10_12[0] = (sub20[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub21 = x20_reg - fra2_11;
    wire [24:0] x21 = (sub21[24] == 1'b1) ? (x20_reg << 1) : (sub21 << 1);
    assign ans11_12[1] = (sub21[24] == 1'b1) ? 1'b0 : 1'b1;
    wire [24:0] sub22 = x21 - fra2_11;
    wire [24:0] x22 = (sub22[24] == 1'b1) ? (x21 << 1) : (sub22 << 1);
    assign ans11_12[0] = (sub22[24] == 1'b1) ? 1'b0 : 1'b1;

    wire [24:0] sub23 = x22_reg - fra2_12;
    wire [24:0] x23 = (sub23[24] == 1'b1) ? (x22_reg << 1) : (sub23 << 1);
    assign ans12_12[1] = (sub23[24] == 1'b1) ? 1'b0 : 1'b1;
    wire sub24 = (x23 < fra2_12);
    assign ans12_12[0] = (sub24 == 1'b1) ? 1'b0 : 1'b1;

    reg [8:0] ans_exp_2;
    reg [8:0] ans_exp_3;
    reg [8:0] ans_exp_4;
    reg [8:0] ans_exp_5;
    reg [8:0] ans_exp_6;
    reg [8:0] ans_exp_7;
    reg [8:0] ans_exp_8;
    reg [8:0] ans_exp_9;
    reg [8:0] ans_exp_10;
    reg [8:0] ans_exp_11;
    reg [8:0] ans_exp_12;

    wire [8:0] for_ans_exp;
    assign for_ans_exp = exp1 + 9'd127;
    wire [8:0] ans_exp;
    assign ans_exp = (exp1 == 9'd0) ? 9'b100000000 : (for_ans_exp - exp2);

    wire [8:0] ans_exp_12_minus1;
    assign ans_exp_12_minus1 = (exp1 == 9'd0) ? 9'b100000000 : (ans_exp_12 - 9'd1);

    always @(posedge clk) begin
        if (~reset) begin
            result <= 32'd0;
            x2_reg <= 25'd0;
            x4_reg <= 25'd0;
            x6_reg <= 25'd0;
            x8_reg <= 25'd0;
            x10_reg <= 25'd0;
            x12_reg <= 25'd0;
            x14_reg <= 25'd0;
            x16_reg <= 25'd0;
            x18_reg <= 25'd0;
            x20_reg <= 25'd0;
            x22_reg <= 25'd0;

            ans1to1 <= 2'd0;
            ans1to2 <= 4'd0;
            ans1to3 <= 6'd0;
            ans1to4 <= 8'd0;
            ans1to5 <= 10'd0;
            ans1to6 <= 12'd0;
            ans1to7 <= 14'd0;
            ans1to8 <= 16'd0;
            ans1to9 <= 18'd0;
            ans1to10 <= 20'd0;
            ans1to11 <= 22'd0;

            fra2_2 <= 25'd0;
            fra2_3 <= 25'd0;
            fra2_4 <= 25'd0;
            fra2_5 <= 25'd0;
            fra2_6 <= 25'd0;
            fra2_7 <= 25'd0;
            fra2_8 <= 25'd0;
            fra2_9 <= 25'd0;
            fra2_10 <= 25'd0;
            fra2_11 <= 25'd0;
            fra2_12 <= 25'd0;
            ans_exp_2 <= 9'd0;
            ans_exp_3 <= 9'd0;
            ans_exp_4 <= 9'd0;
            ans_exp_5 <= 9'd0;
            ans_exp_6 <= 9'd0;
            ans_exp_7 <= 9'd0;
            ans_exp_8 <= 9'd0;
            ans_exp_9 <= 9'd0;
            ans_exp_10 <= 9'd0;
            ans_exp_11 <= 9'd0;
            ans_exp_12 <= 9'd0;

            ans_sig_reg_2 <= 1'b0;
            ans_sig_reg_3 <= 1'b0;
            ans_sig_reg_4 <= 1'b0;
            ans_sig_reg_5 <= 1'b0;
            ans_sig_reg_6 <= 1'b0;
            ans_sig_reg_7 <= 1'b0;
            ans_sig_reg_8 <= 1'b0;
            ans_sig_reg_9 <= 1'b0;
            ans_sig_reg_10 <= 1'b0;
            ans_sig_reg_11 <= 1'b0;
            ans_sig_reg_12 <= 1'b0;
        end else begin

            x2_reg <= x2;
            ans1to1 <= ans1_12;
            x4_reg <= x4;
            ans1to2 <= {ans1to1, ans2_12};
            x6_reg <= x6;
            ans1to3 <= {ans1to2, ans3_12};
            x8_reg <= x8;
            ans1to4 <= {ans1to3, ans4_12};
            x10_reg <= x10;
            ans1to5 <= {ans1to4, ans5_12};
            x12_reg <= x12;
            ans1to6 <= {ans1to5, ans6_12};
            x14_reg <= x14;
            ans1to7 <= {ans1to6, ans7_12};
            x16_reg <= x16;
            ans1to8 <= {ans1to7, ans8_12};
            x18_reg <= x18;
            ans1to9 <= {ans1to8, ans9_12};
            x20_reg <= x20;
            ans1to10 <= {ans1to9, ans10_12};
            x22_reg <= x22;
            ans1to11 <= {ans1to10, ans11_12};

            fra2_2 <= fra2;
            fra2_3 <= fra2_2;
            fra2_4 <= fra2_3;
            fra2_5 <= fra2_4;
            fra2_6 <= fra2_5;
            fra2_7 <= fra2_6;
            fra2_8 <= fra2_7;
            fra2_9 <= fra2_8;
            fra2_10 <= fra2_9;
            fra2_11 <= fra2_10;
            fra2_12 <= fra2_11;
            ans_exp_2 <= ans_exp;
            ans_exp_3 <= ans_exp_2;
            ans_exp_4 <= ans_exp_3;
            ans_exp_5 <= ans_exp_4;
            ans_exp_6 <= ans_exp_5;
            ans_exp_7 <= ans_exp_6;
            ans_exp_8 <= ans_exp_7;
            ans_exp_9 <= ans_exp_8;
            ans_exp_10 <= ans_exp_9;
            ans_exp_11 <= ans_exp_10;
            ans_exp_12 <= ans_exp_11;
            ans_sig_reg_2 <= sig1 ^ sig2;
            ans_sig_reg_3 <= ans_sig_reg_2;
            ans_sig_reg_4 <= ans_sig_reg_3;
            ans_sig_reg_5 <= ans_sig_reg_4;
            ans_sig_reg_6 <= ans_sig_reg_5;
            ans_sig_reg_7 <= ans_sig_reg_6;
            ans_sig_reg_8 <= ans_sig_reg_7;
            ans_sig_reg_9 <= ans_sig_reg_8;
            ans_sig_reg_10 <= ans_sig_reg_9;
            ans_sig_reg_11 <= ans_sig_reg_10;
            ans_sig_reg_12 <= ans_sig_reg_11;
            if (ans1to11[21] == 1'b1) begin//
                if (ans_exp_12[8] == 1'b1) begin
                    result <= 32'd0;
                end else begin
                    result <= {ans_sig_reg_12, ans_exp_12[7:0], ans1to11[20:0], ans12_12};
                end
            end else begin
                if (ans_exp_12_minus1[8] == 1'b1) begin
                    result <= 32'd0;
                end else begin
                    result <= {ans_sig_reg_12, ans_exp_12_minus1[7:0], ans1to11[19:0], ans12_12, 1'b0};//最終ビットは速さのため計算せず
                end
            end
        end
    end
endmodule
`default_nettype wire
