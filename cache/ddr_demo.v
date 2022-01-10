`default_nettype wire
module ddr_demo(
    //キャッシュミスの場合はキャッシュがDDRに読みたいデータを指定してキャッシュに持ってくる
    input wire [26:0] cache2DDR_rd_addr,
	input wire cache2DDR_rd_en,
	//DDRがキャッシュに要求されたデータを渡す
	output reg DDR2cache_rd_fin,
	output reg [127:0] DDR2cache_rd_data,//[31:0] to [127:0]
    //適当なタイミングで書き込むべきデータをDDRに書き込む
	input wire [26:0] cache2DDR_wr_addr,
	input wire [127:0] cache2DDR_wr_data,//[31:0] to [127:0]
	input wire cache2DDR_wr_en,
	//DDRにデータが書き込まれたことを知らせる
	output reg DDR2cache_wr_fin,

    input clk,
    input rstn
);

(* ram_style = "block" *)
reg [127:0] ram [0:127];
wire [7:0] add;
assign add = cache2DDR_rd_en ? {cache2DDR_rd_addr[23:20], cache2DDR_rd_addr[7:4]} :
            cache2DDR_wr_en ? {cache2DDR_wr_addr[23:20], cache2DDR_wr_addr[7:4]} : 8'd0;

integer i;

always @(posedge clk) begin
    if (~rstn) begin
        DDR2cache_rd_fin = 1'd0;
    	DDR2cache_rd_data = 128'd0;
        DDR2cache_wr_fin = 1'd0;
        for (i=0; i < 128; i = i + 1) begin
            ram[i] = 128'd0;
        end
    end else if (cache2DDR_rd_en) begin
        DDR2cache_rd_data <= ram[add];
        DDR2cache_rd_fin <= 1'b1;
    end else if (DDR2cache_rd_fin) begin
        DDR2cache_rd_fin <= 1'b0;
    end else if (cache2DDR_wr_en) begin
        ram[add] <= cache2DDR_wr_data;
        DDR2cache_wr_fin <= 1'b1;
    end else if (DDR2cache_wr_fin) begin
        DDR2cache_wr_fin <= 1'd0;
    end
end

endmodule
