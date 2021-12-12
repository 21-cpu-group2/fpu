`timescale 1us / 100ns
`default_nettype none

module ftoi (
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

reg [32:0] flag_ans;
reg sig_reg;

wire [31:0] add;
assign add = {31'd0, flag_ans[32]};
wire [31:0] ans;
assign ans = flag_ans[31:0];

wire [31:0] add_ans;
assign add_ans = add + ans;


wire [31:0] add_ans_reverse;
assign add_ans_reverse = ~add_ans;
wire [31:0] minus_add_ans;
assign minus_add_ans = add_ans_reverse + 32'd1;

always @(posedge clk) begin
    if (~reset) begin
        result <= 32'd0;
        // valid <= 1'b0;
        sig_reg <= 1'b0;
    end else begin
        sig_reg <= sig;
        case (exp)
            8'd126 : flag_ans <= {1'b0, 32'd0};
            8'd127 : flag_ans <= {fra[22], 32'd1};
            8'd128 : flag_ans <= {fra[21], 31'd1, fra[22]};
            8'd129 : flag_ans <= {fra[20], 30'd1, fra[22:21]};
            8'd130 : flag_ans <= {fra[19], 29'd1, fra[22:20]};
            8'd131 : flag_ans <= {fra[18], 28'd1, fra[22:19]};
            8'd132 : flag_ans <= {fra[17], 27'd1, fra[22:18]};
            8'd133 : flag_ans <= {fra[16], 26'd1, fra[22:17]};
            8'd134 : flag_ans <= {fra[15], 25'd1, fra[22:16]};
            8'd135 : flag_ans <= {fra[14], 24'd1, fra[22:15]};
            8'd136 : flag_ans <= {fra[13], 23'd1, fra[22:14]};
            8'd137 : flag_ans <= {fra[12], 22'd1, fra[22:13]};
            8'd138 : flag_ans <= {fra[11], 21'd1, fra[22:12]};
            8'd139 : flag_ans <= {fra[10], 20'd1, fra[22:11]};
            8'd140 : flag_ans <= {fra[9], 19'd1, fra[22:10]};
            8'd141 : flag_ans <= {fra[8], 18'd1, fra[22:9]};
            8'd142 : flag_ans <= {fra[7], 17'd1, fra[22:8]};
            8'd143 : flag_ans <= {fra[6], 16'd1, fra[22:7]};
            8'd144 : flag_ans <= {fra[5], 15'd1, fra[22:6]};
            8'd145 : flag_ans <= {fra[4], 14'd1, fra[22:5]};
            8'd146 : flag_ans <= {fra[3], 13'd1, fra[22:4]};
            8'd147 : flag_ans <= {fra[2], 12'd1, fra[22:3]};
            8'd148 : flag_ans <= {fra[1], 11'd1, fra[22:2]};
            8'd149 : flag_ans <= {fra[0], 10'd1, fra[22:1]};
            8'd150 : flag_ans <= {10'd1, fra};
            8'd151 : flag_ans <= {9'd1, fra, 1'b0};
            8'd152 : flag_ans <= {8'd1, fra, 2'b0};
            8'd153 : flag_ans <= {7'd1, fra, 3'b0};
            8'd154 : flag_ans <= {6'd1, fra, 4'b0};
            8'd155 : flag_ans <= {5'd1, fra, 5'b0};
            8'd156 : flag_ans <= {4'd1, fra, 6'b0};
            8'd157 : flag_ans <= {3'd1, fra, 7'b0};
            default: flag_ans <= {1'b0, 32'd0};
        endcase
        // if (valid) begin
        //     valid <= 1'b0;
        // end
        if (sig_reg) begin
            result <= minus_add_ans;
            // valid <= 1'b1;
        end else begin
            result <= add_ans;
            // valid <= 1'b1;
        end
    end
end


    
endmodule
`default_nettype wire