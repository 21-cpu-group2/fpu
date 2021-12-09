`timescale 1us / 100ns
`default_nettype none

module floor (
    input wire [31:0] op,
    output reg [31:0] result,
    input wire clk,
    input wire reset
);

wire sig;
wire [7:0] exp;
wire [22:0] fra;
assign sig = op[31];
assign exp = op[30:23];
assign fra = op[22:0];

reg new_sig_reg;
reg [7:0] new_exp_reg;
reg [24:0] new_fra_reg;

reg [22:0] fra_desimal;//orをとるので整数部分は0埋め
reg [24:0] for_add;


wire [24:0] add_fra;
assign add_fra = new_fra_reg + for_add;
wire [7:0] exp_plus_1;
assign exp_plus_1 = new_exp_reg + 8'd1;

always @(posedge clk) begin
    if (~reset) begin
        result <= 32'd0;
        new_sig_reg <= 1'b0;
        new_exp_reg <= 8'd0;
        new_fra_reg <= 25'd0;
        fra_desimal <= 23'd0;
        for_add <= 23'd0;
    end else begin
        new_sig_reg <= sig;
        if ((exp[8] == 1'b0) & (~(&exp[6:0]))) begin//exp<=126
            fra_desimal <= 23'd0;
            for_add <= 25'd0;
            if (sig) begin
                new_exp_reg <= 8'd127;
                new_fra_reg <= {2'b01, 23'd0};
            end else begin
                new_exp_reg <= 8'd0;
                new_fra_reg <= 25'd0;
            end
        end else begin
            new_exp_reg <= exp;
            case (exp)
                8'd127 : begin
                    new_fra_reg <= {2'd1, 23'd0};
                    fra_desimal <= fra;
                    for_add <= {2'd1, 23'd0};
                end
                8'd128 : begin
                    new_fra_reg <= {2'd1, fra[22], 22'd0};
                    fra_desimal <= {1'b0, fra[21:0]};
                    for_add <= {3'd1, 22'd0};
                end
                8'd129 : begin
                    new_fra_reg <= {2'd1, fra[22:21], 21'd0};
                    fra_desimal <= {2'b0, fra[20:0]};
                    for_add <= {4'd1, 21'd0};
                end
                8'd130 : begin
                    new_fra_reg <= {2'd1, fra[22:20], 20'd0};
                    fra_desimal <= {3'b0, fra[19:0]};
                    for_add <= {5'd1, 20'd0};
                end
                8'd131 : begin
                    new_fra_reg <= {2'd1, fra[22:19], 19'd0};
                    fra_desimal <= {4'b0, fra[18:0]};
                    for_add <= {6'd1, 19'd0};
                end
                8'd132 : begin
                    new_fra_reg <= {2'd1, fra[22:18], 18'd0};
                    fra_desimal <= {5'b0, fra[17:0]};
                    for_add <= {7'd1, 18'd0};
                end
                8'd133 : begin
                    new_fra_reg <= {2'd1, fra[22:17], 17'd0};
                    fra_desimal <= {6'b0, fra[16:0]};
                    for_add <= {8'd1, 17'd0};
                end
                8'd134 : begin
                    new_fra_reg <= {2'd1, fra[22:16], 16'd0};
                    fra_desimal <= {7'b0, fra[15:0]};
                    for_add <= {9'd1, 16'd0};
                end
                8'd135 : begin
                    new_fra_reg <= {2'd1, fra[22:15], 15'd0};
                    fra_desimal <= {8'b0, fra[14:0]};
                    for_add <= {10'd1, 15'd0};
                end
                8'd136 : begin
                    new_fra_reg <= {2'd1, fra[22:14], 14'd0};
                    fra_desimal <= {9'b0, fra[13:0]};
                    for_add <= {11'd1, 14'd0};
                end
                8'd137 : begin
                    new_fra_reg <= {2'd1, fra[22:13], 13'd0};
                    fra_desimal <= {10'b0, fra[12:0]};
                    for_add <= {12'd1, 13'd0};
                end
                8'd138 : begin
                    new_fra_reg <= {2'd1, fra[22:12], 12'd0};
                    fra_desimal <= {11'b0, fra[11:0]};
                    for_add <= {13'd1, 12'd0};
                end
                8'd139 : begin
                    new_fra_reg <= {2'd1, fra[22:11], 11'd0};
                    fra_desimal <= {12'b0, fra[10:0]};
                    for_add <= {14'd1, 11'd0};
                end
                8'd140 : begin
                    new_fra_reg <= {2'd1, fra[22:10], 10'd0};
                    fra_desimal <= {13'b0, fra[9:0]};
                    for_add <= {15'd1, 10'd0};
                end
                8'd141 : begin
                    new_fra_reg <= {2'd1, fra[22:9], 9'd0};
                    fra_desimal <= {14'b0, fra[8:0]};
                    for_add <= {16'd1, 9'd0};
                end
                8'd142 : begin
                    new_fra_reg <= {2'd1, fra[22:8], 8'd0};
                    fra_desimal <= {15'b0, fra[7:0]};
                    for_add <= {17'd1, 8'd0};
                end
                8'd143 : begin
                    new_fra_reg <= {2'd1, fra[22:7], 7'd0};
                    fra_desimal <= {16'b0, fra[6:0]};
                    for_add <= {18'd1, 7'd0};
                end
                8'd144 : begin
                    new_fra_reg <= {2'd1, fra[22:6], 6'd0};
                    fra_desimal <= {17'b0, fra[5:0]};
                    for_add <= {19'd1, 6'd0};
                end
                8'd145 : begin
                    new_fra_reg <= {2'd1, fra[22:5], 5'd0};
                    fra_desimal <= {18'b0, fra[4:0]};
                    for_add <= {20'd1, 5'd0};
                end
                8'd146 : begin
                    new_fra_reg <= {2'd1, fra[22:4], 4'd0};
                    fra_desimal <= {19'b0, fra[3:0]};
                    for_add <= {21'd1, 4'd0};
                end
                8'd147 : begin
                    new_fra_reg <= {2'd1, fra[22:3], 3'd0};
                    fra_desimal <= {20'b0, fra[2:0]};
                    for_add <= {22'd1, 3'd0};
                end
                8'd148 : begin
                    new_fra_reg <= {2'd1, fra[22:2], 2'd0};
                    fra_desimal <= {21'b0, fra[1:0]};
                    for_add <= {23'd1, 2'd0};
                end
                8'd149 : begin
                    new_fra_reg <= {2'd1, fra[22:1], 1'd0};
                    fra_desimal <= {22'b0, fra[0]};
                    for_add <= {24'd1, 1'd0};
                end
                default : begin//exp>=150
                    new_fra_reg <= {2'd1, fra};
                    fra_desimal <= 23'b0;
                    for_add <= 25'd0;
                end
            endcase
        end
        if (~new_sig_reg | ~(|fra_desimal)) begin//正もしくは負だけど小数部分が0のときは切り捨て
            result <= {new_sig_reg, new_exp_reg, new_fra_reg[22:0]};
        end else if (add_fra[25]) begin//負で（絶対値として）切り上げたらexpを変える必要がある場合
            result <= {new_sig_reg, exp_plus_1, 23'd0};
        end else begin
            result <= {new_sig_reg, new_exp_reg, add_fra[22:0]};
        end
    end
end

endmodule
`default_nettype wire