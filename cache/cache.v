//ddrとのやり取りは128bit=4wordで行うとする
module cache#(
    parameter tag_len = 13,
    parameter index_len = 10,
    parameter offset_len = 4,
    parameter tag_zero = 13'd0,
    parameter index_zero = 10'd0,
    parameter offset_zero = 4'd0,
    parameter data_init = 128'd0//(32 * 2 ** (offset_len - 2))'d0
)(
	input wire clk,
	input wire rstn,

	//MAステージからキャッシュに読みたいデータを指定される
	input wire [26:0] MA2cache_rd_addr,
	input wire MA2cache_rd_en,
	//MAステージにキャッシュが要求されたデータを渡す
	output reg cache2MA_rd_fin,
	output reg [31:0] cache2MA_rd_data,
	//キャッシュミスの場合はキャッシュがDDRに読みたいデータを指定してキャッシュに持ってくる
	output reg [26:0] cache2DDR_rd_addr,
	output reg cache2DDR_rd_en,
	//DDRがキャッシュに要求されたデータを渡す
	input wire DDR2cache_rd_fin,
	input wire [127:0] DDR2cache_rd_data,//[31:0] to [127:0]

	//MAステージからキャッシュに書き込みたいデータを渡される
	input wire [26:0] MA2cache_wr_addr,
	input wire [31:0] MA2cache_wr_data,
	input wire MA2cache_wr_en,
	//キャッシュからMAステージに書き込むように渡されたデータはいつかDDRに書き込むこと＆そのデータをMAステージが読み込みたいときはその新しく渡されたデータを返すことを宣言
	output reg cache2MA_wr_fin,
	//適当なタイミングで書き込むべきデータをDDRに書き込む
	output reg [26:0] cache2DDR_wr_addr,
	output reg [127:0] cache2DDR_wr_data,//[31:0] to [127:0]
	output reg cache2DDR_wr_en,
	//DDRにデータが書き込まれたことを知らせる
	input wire DDR2cache_wr_fin
);

reg [3:0] rd_status;
localparam rd_s_idle = 4'd0;
localparam rd_s_compare = 4'd1;
localparam rd_s_hit = 4'd2;
localparam rd_s_miss_ddrwait = 4'd3;
localparam rd_s_miss_end = 4'd4;

reg [3:0] wr_status;
localparam wr_s_idle = 4'd0;
localparam wr_s_compare = 4'd1;
localparam wr_s_hit_ddrwait = 4'd2;
localparam wr_s_hit_end = 4'd3;
localparam wr_s_miss_ddrwait = 4'd4;
localparam wr_s_miss_ddrend = 4'd5;

wire [tag_len-1:0] MA2cache_rd_tag;
wire [index_len-1:0] MA2cache_rd_index;
wire [offset_len-1:0] MA2cache_rd_offset;
assign {MA2cache_rd_tag, MA2cache_rd_index, MA2cache_rd_offset} = MA2cache_rd_addr;
reg [tag_len-1:0] MA2cache_rd_tag_2;
reg [index_len-1:0] MA2cache_rd_index_2;
reg [offset_len-1:0] MA2cache_rd_offset_2;
reg [tag_len-1:0] MA2cache_rd_tag_3;
reg [index_len-1:0] MA2cache_rd_index_3;
reg [offset_len-1:0] MA2cache_rd_offset_3;

wire [tag_len-1:0] MA2cache_wr_tag;
wire [index_len-1:0] MA2cache_wr_index;
wire [offset_len-1:0] MA2cache_wr_offset;
assign {MA2cache_wr_tag, MA2cache_wr_index, MA2cache_wr_offset} = MA2cache_wr_addr;
reg [tag_len-1:0] MA2cache_wr_tag_2;
reg [index_len-1:0] MA2cache_wr_index_2;
reg [offset_len-1:0] MA2cache_wr_offset_2;
reg [tag_len-1:0] MA2cache_wr_tag_3;
reg [index_len-1:0] MA2cache_wr_index_3;
reg [offset_len-1:0] MA2cache_wr_offset_3;

reg [31:0] MA2cache_wr_data_2;
reg [31:0] MA2cache_wr_data_3;

wire [tag_len-1:0] cache_rd_tag;
wire [2:0] cache_rd_status;
wire [32 * 2 ** (offset_len - 2) - 1:0] cache_rd_data;

reg cache_wr_en;
reg [tag_len-1:0] cache_wr_tag;
reg [2:0] cache_wr_status;
reg [32 * 2 ** (offset_len - 2) - 1:0] cache_wr_data;

reg cache_rd_index_flag;
reg cache_wr_index_flag;
wire cache_rd_en;
wire [index_len-1:0] cache_index;
assign cache_index = (MA2cache_rd_en) ? MA2cache_rd_index :
                        (DDR2cache_rd_fin && cache_rd_index_flag) ? MA2cache_rd_index_3 :
                        (MA2cache_wr_en) ? MA2cache_wr_index :
                        (DDR2cache_rd_fin && cache_wr_index_flag) ? MA2cache_wr_index_3 : index_zero;
assign cache_rd_en = MA2cache_rd_en || MA2cache_wr_en;

Status_Tag_ram Tag_ram1 (clk, cache_wr_en, cache_rd_en, rstn, cache_index,
                        cache_wr_tag, cache_wr_status, cache_rd_tag, cache_rd_status);

Data_ram Data_ram1 (clk, cache_wr_en, cache_rd_en, rstn, cache_index, cache_wr_data, cache_rd_data);

always @(posedge clk) begin
    if (~rstn) begin
	cache2MA_rd_fin = 1'b0;
	cache2MA_rd_data = 32'd0;
	cache2DDR_rd_addr = 27'd0;
	cache2DDR_rd_en = 1'b0;
	cache2MA_wr_fin = 1'b0;
	cache2DDR_wr_addr  = 27'd0;
	cache2DDR_wr_data = 128'd0;
	cache2DDR_wr_en  = 1'b0;
    rd_status = 4'd0;
    wr_status = 4'd0;
    MA2cache_rd_tag_2 = tag_zero;
    MA2cache_rd_index_2 = index_zero;
    MA2cache_rd_offset_2 = offset_zero;
    MA2cache_rd_tag_3 = tag_zero;
    MA2cache_rd_index_3 = index_zero;
    MA2cache_rd_offset_3 = offset_zero;
    MA2cache_wr_tag_2 = tag_zero;
    MA2cache_wr_index_2 = index_zero;
    MA2cache_wr_offset_2 = offset_zero;
    MA2cache_wr_tag_3 = tag_zero;
    MA2cache_wr_index_3 = index_zero;
    MA2cache_wr_offset_3 = offset_zero;
    MA2cache_wr_data_2 = 32'd0;
    MA2cache_wr_data_3 = 32'd0;
    cache_wr_en = 1'd0;
    cache_wr_tag = tag_zero;
    cache_wr_status = 3'd0;
    cache_wr_data = data_init;
    cache_rd_index_flag = 1'd0;
    cache_wr_index_flag = 1'd0;
    end else if (MA2cache_rd_en) begin
        MA2cache_rd_tag_2 <= MA2cache_rd_tag;
        MA2cache_rd_index_2 <= MA2cache_rd_index;
        MA2cache_rd_offset_2 <= MA2cache_rd_offset;
        rd_status <= rd_s_compare;
    end else if (rd_status == rd_s_compare) begin
        if ((MA2cache_rd_tag_2 == cache_rd_tag) && cache_rd_status[0]) begin
            rd_status <= rd_s_hit;
            cache2MA_rd_fin <= 1'b1;
            case (MA2cache_rd_offset_3[3:2])
                2'b00 : cache2MA_rd_data <= cache_rd_data[31:0];
                2'b01 : cache2MA_rd_data <= cache_rd_data[63:32];
                2'b10 : cache2MA_rd_data <= cache_rd_data[95:64];
                2'b11 : cache2MA_rd_data <= cache_rd_data[127:96];
            endcase
        end else begin
            rd_status <= rd_s_miss_ddrwait;
            cache2DDR_rd_en <= 1'b1;
            cache2DDR_rd_addr <= {MA2cache_rd_tag_2, MA2cache_rd_index_2, MA2cache_rd_offset_2};//offset不要かも？
            MA2cache_rd_tag_3 <= MA2cache_rd_tag_2;
            MA2cache_rd_index_3 <= MA2cache_rd_index_2;
            MA2cache_rd_offset_3 <= MA2cache_rd_offset_2;
            cache_rd_index_flag <= 1'b1;
        end
    end else if (rd_status == rd_s_hit) begin
        cache2MA_rd_fin <= 1'b0;
        rd_status <= rd_s_idle;
    end else if (rd_status == rd_s_miss_ddrwait) begin
        if (DDR2cache_rd_fin) begin
            case (MA2cache_rd_offset_3[3:2])
                2'b00 : cache2MA_rd_data <= DDR2cache_rd_data[31:0];
                2'b01 : cache2MA_rd_data <= DDR2cache_rd_data[63:32];
                2'b10 : cache2MA_rd_data <= DDR2cache_rd_data[95:64];
                2'b11 : cache2MA_rd_data <= DDR2cache_rd_data[127:96];
            endcase
            cache2MA_rd_fin <= 1'b1;
            cache_wr_en <= 1'b1;
            cache_wr_data <= DDR2cache_rd_data;//offset_lenを変えても変える必要なし
            cache_wr_tag <= MA2cache_rd_tag_3;
            cache_wr_status <= 3'b100;
            rd_status <= rd_s_miss_end;
            cache_rd_index_flag <= 1'b0;
        end else begin
            rd_status <= rd_s_miss_ddrwait;
            MA2cache_rd_tag_3 <= MA2cache_rd_tag_3;
            MA2cache_rd_index_3 <= MA2cache_rd_index_3;
            MA2cache_rd_offset_3 <= MA2cache_rd_offset_3;
            cache_rd_index_flag <= 1'b1;
        end
    end else if (rd_status == rd_s_miss_end) begin
        cache2MA_rd_fin <= 1'b0;
        cache_wr_en <= 1'b0;
        rd_status <= rd_s_idle;
    end else if (MA2cache_wr_en) begin///////////////////////////ここから書き込み
        MA2cache_wr_tag_2 <= MA2cache_wr_tag;
        MA2cache_wr_index_2 <= MA2cache_wr_index;
        MA2cache_wr_offset_2 <= MA2cache_wr_offset;
        MA2cache_wr_data_2 <= MA2cache_wr_data;
        wr_status <= wr_s_compare;
    end else if (wr_status == wr_s_compare) begin
        if ((MA2cache_rd_tag_2 == cache_rd_tag) || (cache_rd_status[0] == 1'b0)) begin
            //hit or new
            cache_wr_en <= 1'b1;
            cache_wr_tag <= MA2cache_wr_tag_2;
            case (MA2cache_wr_offset_2[3:2])
                2'b00 : begin
                    cache_wr_data <= {cache_rd_data[127:32], MA2cache_wr_data_2};
                    cache2DDR_wr_data <= {cache_rd_data[127:32], MA2cache_wr_data_2};
                end 
                2'b01 : begin
                    cache_wr_data <= {cache_rd_data[127:64], MA2cache_wr_data_2, cache_rd_data[31:0]};
                    cache2DDR_wr_data <= {cache_rd_data[127:64], MA2cache_wr_data_2, cache_rd_data[31:0]};
                end
                2'b10 : begin
                    cache_wr_data <= {cache_rd_data[127:96], MA2cache_wr_data_2, cache_rd_data[63:0]};
                    cache2DDR_wr_data <= {cache_rd_data[127:96], MA2cache_wr_data_2, cache_rd_data[63:0]};
                end
                2'b11 : begin
                    cache_wr_data <= {MA2cache_wr_data_2, cache_rd_data[95:0]};
                    cache2DDR_wr_data <= {MA2cache_wr_data_2, cache_rd_data[95:0]};
                end
            endcase
            cache_wr_status <= 3'b100;
            wr_status <= wr_s_hit_ddrwait;
            cache2DDR_wr_en <= 1'b1;
            cache2DDR_wr_addr <= {MA2cache_wr_tag_2, MA2cache_wr_index_2, MA2cache_wr_offset_2};//offset不要かも？
            end else begin
            //miss
            wr_status <= wr_s_miss_ddrwait;
            cache2DDR_rd_addr <= {MA2cache_wr_tag_2, MA2cache_wr_index_2, MA2cache_wr_offset_2};
	        cache2DDR_rd_en <= 1'b1;
            MA2cache_wr_data_3 <= MA2cache_wr_data_2;
            MA2cache_wr_tag_3 <= MA2cache_wr_tag_2;
            MA2cache_wr_index_3 <= MA2cache_wr_index_2;
            MA2cache_wr_offset_3 <= MA2cache_wr_offset_2;
            cache_wr_index_flag <= 1'b1;
        end
    end else if (wr_status == wr_s_hit_ddrwait) begin
        cache_wr_en <= 1'b0;
        cache2DDR_wr_en <= 1'b0;
        if (DDR2cache_wr_fin) begin
            wr_status <= wr_s_hit_end;
            cache2MA_wr_fin <= 1'b1;
        end else begin
            wr_status <= wr_s_hit_ddrwait;
        end
    end else if (wr_status == wr_s_hit_end) begin
        wr_status <= wr_s_idle;
        cache2MA_wr_fin <= 1'b0;
    end else if (wr_status == wr_s_miss_ddrwait) begin
        cache2DDR_rd_en <= 1'b0;
        MA2cache_wr_data_3 <= MA2cache_wr_data_3;
        MA2cache_wr_tag_3 <= MA2cache_wr_tag_3;
        MA2cache_wr_index_3 <= MA2cache_wr_index_3;
        MA2cache_wr_offset_3 <= MA2cache_wr_offset_3;
        if (DDR2cache_rd_fin) begin
            wr_status <= wr_s_miss_ddrend;
            cache_wr_en <= 1'b1;
            cache_wr_tag <= MA2cache_wr_tag_3;
            cache_wr_status <= 3'b100;
            case (MA2cache_wr_offset_3[3:2])
                2'b00 : cache_wr_data <= {DDR2cache_rd_data[127:32], MA2cache_wr_data_3};
                2'b01 : cache_wr_data <= {DDR2cache_rd_data[127:64], MA2cache_wr_data_3, DDR2cache_rd_data[31:0]};
                2'b10 : cache_wr_data <= {DDR2cache_rd_data[127:96], MA2cache_wr_data_3, DDR2cache_rd_data[63:0]};
                2'b11 : cache_wr_data <= {MA2cache_wr_data_3, DDR2cache_rd_data[95:0]};
            endcase
            cache2MA_wr_fin <= 1'b1;
            cache_wr_index_flag <= 1'b0;
        end else begin
            wr_status <= wr_s_miss_ddrwait;
            cache_wr_index_flag <= 1'b1;
        end
    end else if (wr_status == wr_s_miss_ddrend) begin
        cache_wr_en <= 1'b0;
        cache2MA_wr_fin <= 1'b0;
        wr_status <= wr_s_idle;
    end
end

endmodule
