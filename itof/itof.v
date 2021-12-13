`timescale 1us / 100ns
`default_nettype none

module ZLC_exp(
    input wire [30:0] op,
    output wire [27:0] out
);
assign out =(op[30]) ? {3'd0, op[30:6]} :
            (op[29]) ? {3'd1, op[29:5]} : 
            (op[28]) ? {3'd2, op[28:4]} :
            (op[27]) ? {3'd3, op[27:3]} :
            (op[26]) ? {3'd4, op[26:2]} :
            (op[25]) ? {3'd5, op[25:1]} : {3'd6, op[24:0]};//|op[30:24] == 1が前提としてある

endmodule

module ZLC_fra(
    input wire [23:0] op,
    output wire [28:0] out
);
assign out =(op[23]) ? {5'd0, op[22:0], 1'd0} :
            (op[22]) ? {5'd1, op[21:0], 1'd0, 1'b0} :
            (op[21]) ? {5'd2, op[20:0], 2'd0, 1'b0} :
            (op[20]) ? {5'd3, op[19:0], 3'd0, 1'b0} :
            (op[19]) ? {5'd4, op[18:0], 4'd0, 1'b0} :
            (op[18]) ? {5'd5, op[17:0], 5'd0, 1'b0} :
            (op[17]) ? {5'd6, op[16:0], 6'd0, 1'b0} :
            (op[16]) ? {5'd7, op[15:0], 7'd0, 1'b0} :
            (op[15]) ? {5'd8, op[14:0], 8'd0, 1'b0} :
            (op[14]) ? {5'd9, op[13:0], 9'd0, 1'b0} :
            (op[13]) ? {5'd10, op[12:0], 10'd0, 1'b0} :
            (op[12]) ? {5'd11, op[11:0], 11'd0, 1'b0} :
            (op[11]) ? {5'd12, op[10:0], 12'd0, 1'b0} :
            (op[10]) ? {5'd13, op[9:0], 13'd0, 1'b0} :
            (op[9]) ? {5'd14, op[8:0], 14'd0, 1'b0} :
            (op[8]) ? {5'd15, op[7:0], 15'd0, 1'b0} :
            (op[7]) ? {5'd16, op[6:0], 16'd0, 1'b0} :
            (op[6]) ? {5'd17, op[5:0], 17'd0, 1'b0} :
            (op[5]) ? {5'd18, op[4:0], 18'd0, 1'b0} :
            (op[4]) ? {5'd19, op[3:0], 19'd0, 1'b0} :
            (op[3]) ? {5'd20, op[2:0], 20'd0, 1'b0} :
            (op[2]) ? {5'd21, op[1:0], 21'd0, 1'b0} :
            (op[1]) ? {5'd22, op[0], 22'd0, 1'b0} :
            (op[0]) ? {5'd23, 23'd0, 1'b0} : {5'd24, 23'd0, 1'b1};

endmodule

module itof (
    input wire [31:0] op,
    output reg [31:0] result,
    input wire clk,
    input wire reset
);

reg sig;
reg [30:0] abs_op;

wire [27:0] outpre;
ZLC_exp ZLC_exp_1(abs_op, outpre);
wire [2:0] exp_zero_count;
wire [23:0] fra;
wire kuriagari;
assign exp_zero_count = outpre[27:25];
assign fra = outpre[24:1];
assign kuriagari = outpre[0];
wire fra_all_one;
assign fra_all_one = &fra;

reg [2:0] exp_zero_count_reg;
wire [7:0] zero_exp_zero_count;
assign zero_exp_zero_count = {5'd0, exp_zero_count_reg};
reg [22:0] fra_result;
reg sig_result;
reg [7:0] sub_from;
reg use_fra_plus_1;
reg [23:0] for_fra_plus_1;

wire [28:0] outpre_2;
ZLC_fra ZLC_fra_1(abs_op[23:0], outpre_2);
wire [4:0] fra_zero_count;
wire [22:0] fra_2;
wire is_zero;
assign fra_zero_count = outpre_2[28:24];
assign fra_2 = outpre_2[23:1];
assign is_zero = outpre_2[0];

reg [4:0] fra_zero_count_reg;
wire [7:0] zero_fra_zero_count;
assign zero_fra_zero_count = {3'd0, fra_zero_count_reg};

reg is_zero_reg;
reg exact;

wire [23:0] fra_plus_1;
assign fra_plus_1 = for_fra_plus_1 + 24'd1;
wire [7:0] exp_exact;
assign exp_exact = sub_from - zero_fra_zero_count;
wire [7:0] exp_not_exact;
assign exp_not_exact = sub_from - zero_exp_zero_count;

wire [31:0] result_use_fra_plus_1;
assign result_use_fra_plus_1 = {sig_result, exp_not_exact, fra_plus_1[22:0]};
wire [31:0] result_not_exact;
assign result_not_exact = {sig_result, exp_not_exact, fra_result};
wire [31:0] result_exact;
assign result_exact = {sig_result, exp_exact, fra_result};

always @(posedge clk) begin
    if (~reset) begin
        result <= 32'd0;
        // valid <= 1'b0;
        exp_zero_count_reg <= 3'd0;
        fra_result <= 23'd0;
        sig_result <= 1'b0;
        sub_from <= 8'd0;
        use_fra_plus_1 <= 1'b0;
        for_fra_plus_1 <= 24'd0;
        fra_zero_count_reg <= 5'd0;
        is_zero_reg <= 1'b0;
        exact <= 1'b0;
    end else begin
        if (op[31]) begin
            sig <= 1'b1;
            abs_op <= ~op[30:0] + 31'd1;
        end else begin
            sig <= 1'b0;
            abs_op <= op[30:0];
        end
        sig_result <= sig;
        exp_zero_count_reg <= exp_zero_count;
        fra_zero_count_reg <= fra_zero_count;
        for_fra_plus_1 <= fra;
        if (|abs_op[30:24]) begin//対応するち�?�?どのfloatがな�?場�?
            exact <= 1'b0;
            is_zero_reg <= 1'b0;
            if (kuriagari & fra_all_one) begin
                fra_result <= 23'd0;
                sub_from <= 8'd158;
                use_fra_plus_1 <= 1'b0;
            end else if (kuriagari) begin
                fra_result <= 23'd0;//使わな�?
                use_fra_plus_1 <= 1'b1;
                sub_from <= 8'd157;
            end else begin
                fra_result <= fra[22:0];
                use_fra_plus_1 <= 1'b0;
                sub_from <= 8'd157;
            end
        end else begin //対応するち�?�?どのfloatがあ�?
            exact <= 1'b1;
            fra_result <= fra_2;
            sub_from <= 8'd150;
            use_fra_plus_1 <= 1'b0;
            is_zero_reg <= is_zero;
        end
        if (~exact) begin
            if(use_fra_plus_1) begin
                result <= result_use_fra_plus_1;
                // valid <= 1'b1;
            end else begin
                result <= result_not_exact;
                // valid <= 1'b1;
            end
        end else if (is_zero_reg) begin
            result <= 32'b0;
            // valid <= 1'b1;
        end else if (exact) begin
            result <= result_exact;
            // valid <= 1'b1;
        end
    end
end
    
endmodule
`default_nettype wire
