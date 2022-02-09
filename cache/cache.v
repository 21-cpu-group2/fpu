//ddrとのやり取りは128bit=4wordで行うとする
//可変にする
module cache#(
    parameter tag_len = 13,
    parameter status_len = 3,
    parameter index_len = 10,
    parameter offset_len = 4,
    parameter data_len = 128,
    parameter tag_zero = 13'd0,
    parameter index_zero = 10'd0,
    parameter offset_zero = 4'd0,
    parameter data_init = 128'd0//(32 * 2 ** (offset_len - 2))'d0
)(
	(* mark_debug = "true" *) input wire clk,
	input wire rstn,

	//MAステージからキャッシュに読みたいデータを指定される
	(* mark_debug = "true" *) input wire [26:0] MA2cache_rd_addr,
	(* mark_debug = "true" *) input wire MA2cache_rd_en,
	//MAステージにキャッシュが要求されたデータを渡す
	(* mark_debug = "true" *) output reg cache2MA_rd_fin,
	(* mark_debug = "true" *) output reg [31:0] cache2MA_rd_data,
	//キャッシュミスの場合はキャッシュがDDRに読みたいデータを指定してキャッシュに持ってくる
	(* mark_debug = "true" *) output reg [26:0] cache2DDR_rd_addr,
	(* mark_debug = "true" *) output reg cache2DDR_rd_en,
	//DDRがキャッシュに要求されたデータを渡す
	(* mark_debug = "true" *) input wire DDR2cache_rd_fin,
	(* mark_debug = "true" *) input wire [data_len-1:0] DDR2cache_rd_data,//[31:0] to [127:0]

	//MAステージからキャッシュに書き込みたいデータを渡される
	(* mark_debug = "true" *) input wire [26:0] MA2cache_wr_addr,
	(* mark_debug = "true" *) input wire [31:0] MA2cache_wr_data,
	(* mark_debug = "true" *) input wire MA2cache_wr_en,
	//キャッシュからMAステージに書き込むように渡されたデータはいつかDDRに書き込むこと＆そのデータをMAステージが読み込みたいときはその新しく渡されたデータを返すことを宣言
	(* mark_debug = "true" *) output reg cache2MA_wr_fin,
	//適当なタイミングで書き込むべきデータをDDRに書き込む
	(* mark_debug = "true" *) output reg [26:0] cache2DDR_wr_addr,
	(* mark_debug = "true" *) output reg [data_len-1:0] cache2DDR_wr_data,//[31:0] to [127:0]
	(* mark_debug = "true" *) output reg cache2DDR_wr_en,
	//DDRにデータが書き込まれたことを知らせる
	(* mark_debug = "true" *) input wire DDR2cache_wr_fin
);

(* mark_debug = "true" *) reg [3:0] rd_status;
localparam rd_s_idle = 4'd0;
localparam rd_s_compare = 4'd1;
localparam rd_s_hit = 4'd2;
localparam rd_s_miss_ddrwait = 4'd3;
localparam rd_s_miss_end = 4'd4;

(* mark_debug = "true" *) reg [3:0] wr_status;
localparam wr_s_idle = 4'd0;
localparam wr_s_compare = 4'd1;
localparam wr_s_hit_ddrwait = 4'd2;
localparam wr_s_hit_end = 4'd3;
localparam wr_s_miss_ddrwait = 4'd4;
localparam wr_s_miss_ddr_wr_wait = 4'd5;
localparam wr_s_miss_ddrend = 4'd6;

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
wire [data_len-1:0] cache_rd_data;

wire [data_len-1:0] cache_rd_data_shift_rd_hit;
wire [offset_len + 2:0] shift_rd_hit = {MA2cache_rd_offset_2, 2'b00};
assign cache_rd_data_shift_rd_hit = (cache_rd_data >> shift_rd_hit);

wire [data_len-1:0] cache_rd_data_shift_rd_miss;
wire [offset_len + 2:0] shift_rd_miss = {MA2cache_rd_offset_3, 2'b00};
assign cache_rd_data_shift_rd_miss = (DDR2cache_rd_data >> shift_rd_miss);

wire [data_len-1:0] wr_data_hit = MA2cache_wr_data_2;//長さあってないけど0埋めしてくれるはず
wire [data_len-1:0] wr_data_hit_mask = 32'hfffffffff;//同上
wire [offset_len + 2:0] shift_wr_hit = {MA2cache_wr_offset_2, 2'b00};
wire [data_len-1:0] wr_data_hit_shift = (wr_data_hit << shift_wr_hit);
wire [data_len-1:0] wr_data_hit_mask_shift_not = ~(wr_data_hit_mask << shift_wr_hit);

wire [data_len-1:0] wr_data_miss = MA2cache_wr_data_3;//長さあってないけど0埋めしてくれるはず
wire [data_len-1:0] wr_data_miss_mask = 32'hfffffffff;//同上
wire [offset_len + 2:0] shift_wr_miss = {MA2cache_wr_offset_2, 2'b00};
wire [data_len-1:0] wr_data_miss_shift = (wr_data_miss << shift_wr_miss);
wire [data_len-1:0] wr_data_miss_mask_shift_not = ~(wr_data_miss_mask << shift_wr_miss);

reg cache_wr_en;
reg [tag_len-1:0] cache_wr_tag;
reg [2:0] cache_wr_status;
reg [data_len-1:0] cache_wr_data;

reg cache_rd_index_flag;
reg cache_wr_miss_index_flag;
reg cache_wr_hit_index_flag;
wire cache_rd_en;
wire [index_len-1:0] cache_index;
assign cache_index = (MA2cache_rd_en) ? MA2cache_rd_index ://MA2からのreadの際に直接読む時
                        cache_rd_index_flag ? MA2cache_rd_index_3 ://MA2からのread-missでddrからのdataをwriteするとき
                        (MA2cache_wr_en) ? MA2cache_wr_index ://MA2からのwriteの際に直接読む時
                        cache_wr_hit_index_flag ? MA2cache_wr_index_3 ://MA2からのwrite-hitでcacheのdataと一緒に書くとき
                        cache_wr_miss_index_flag ? MA2cache_wr_index_3 : index_zero;//MA2からのwrite-missでddrからのdataと一緒に書くとき
assign cache_rd_en = MA2cache_rd_en || MA2cache_wr_en;

Status_Tag_ram #(.index_len(index_len), .tag_len(tag_len)) Tag_ram1 (clk, cache_wr_en, cache_index,
                        cache_wr_tag, cache_wr_status, cache_rd_tag, cache_rd_status);

// Data_ram Data_ram1 (clk, cache_wr_en, cache_rd_en, rstn, cache_index, cache_wr_data, cache_rd_data);
bram #(.index_len(index_len), .data_size(data_len)) Data_ram1 (clk, cache_wr_en, cache_index, cache_wr_data, cache_rd_data);

always @(posedge clk) begin
    if (~rstn) begin
        cache2MA_rd_fin <= 1'b0;
        cache2MA_rd_data <= 32'd0;
        cache2DDR_rd_addr <= 27'd0;
        cache2DDR_rd_en <= 1'b0;
        cache2MA_wr_fin <= 1'b0;
        cache2DDR_wr_addr  <= 27'd0;
        cache2DDR_wr_data <= data_init;
        cache2DDR_wr_en  <= 1'b0;
        rd_status <= 4'd0;
        wr_status <= 4'd0;
        MA2cache_rd_tag_2 <= tag_zero;
        MA2cache_rd_index_2 <= index_zero;
        MA2cache_rd_offset_2 <= offset_zero;
        MA2cache_rd_tag_3 <= tag_zero;
        MA2cache_rd_index_3 <= index_zero;
        MA2cache_rd_offset_3 <= offset_zero;
        MA2cache_wr_tag_2 <= tag_zero;
        MA2cache_wr_index_2 <= index_zero;
        MA2cache_wr_offset_2 <= offset_zero;
        MA2cache_wr_tag_3 <= tag_zero;
        MA2cache_wr_index_3 <= index_zero;
        MA2cache_wr_offset_3 <= offset_zero;
        MA2cache_wr_data_2 <= 32'd0;
        MA2cache_wr_data_3 <= 32'd0;
        cache_wr_en <= 1'd0;
        cache_wr_tag <= tag_zero;
        cache_wr_status <= 3'd0;
        cache_wr_data <= data_init;
        cache_rd_index_flag <= 1'd0;
        cache_wr_miss_index_flag <= 1'd0;
        cache_wr_hit_index_flag <= 1'd0;
    end else if (MA2cache_rd_en) begin
        MA2cache_rd_tag_2 <= MA2cache_rd_tag;
        MA2cache_rd_index_2 <= MA2cache_rd_index;
        MA2cache_rd_offset_2 <= MA2cache_rd_offset;
        rd_status <= rd_s_compare;
    end else if (rd_status == rd_s_compare) begin
        if ((MA2cache_rd_tag_2 == cache_rd_tag) && cache_rd_status[0]) begin
            rd_status <= rd_s_hit;
            cache2MA_rd_fin <= 1'b1;
            cache2MA_rd_data <= cache_rd_data_shift_rd_hit[31:0];
            // case (MA2cache_rd_offset_2[3:2])
            //     2'b00 : cache2MA_rd_data <= cache_rd_data[31:0];
            //     2'b01 : cache2MA_rd_data <= cache_rd_data[63:32];
            //     2'b10 : cache2MA_rd_data <= cache_rd_data[95:64];
            //     2'b11 : cache2MA_rd_data <= cache_rd_data[127:96];
            // endcase
        end else begin
            rd_status <= rd_s_miss_ddrwait;
            cache2DDR_rd_en <= 1'b1;
            cache2DDR_rd_addr <= {MA2cache_rd_tag_2, MA2cache_rd_index_2, MA2cache_rd_offset_2};//offset不要かも？
            MA2cache_rd_tag_3 <= MA2cache_rd_tag_2;
            MA2cache_rd_index_3 <= MA2cache_rd_index_2;
            MA2cache_rd_offset_3 <= MA2cache_rd_offset_2;
        end
    end else if (rd_status == rd_s_hit) begin
        cache2MA_rd_fin <= 1'b0;
        rd_status <= rd_s_idle;
        cache2MA_rd_data <= 32'd0;
    end else if (rd_status == rd_s_miss_ddrwait) begin
        cache2DDR_rd_en <= 1'b0;
        if (DDR2cache_rd_fin) begin
            cache2MA_rd_data <= cache_rd_data_shift_rd_miss[31:0];
            // case (MA2cache_rd_offset_3[3:2])
            //     2'b00 : cache2MA_rd_data <= DDR2cache_rd_data[31:0];
            //     2'b01 : cache2MA_rd_data <= DDR2cache_rd_data[63:32];
            //     2'b10 : cache2MA_rd_data <= DDR2cache_rd_data[95:64];
            //     2'b11 : cache2MA_rd_data <= DDR2cache_rd_data[127:96];
            // endcase
            cache2MA_rd_fin <= 1'b1;
            cache_wr_en <= 1'b1;
            cache_wr_data <= DDR2cache_rd_data;//offset_lenを変えても変える必要なし
            cache_wr_tag <= MA2cache_rd_tag_3;
            cache_wr_status <= 3'b001;
            rd_status <= rd_s_miss_end;
            cache_rd_index_flag <= 1'b1;
            MA2cache_rd_index_3 <= MA2cache_rd_index_3;
        end else begin
            rd_status <= rd_s_miss_ddrwait;
            MA2cache_rd_tag_3 <= MA2cache_rd_tag_3;
            MA2cache_rd_index_3 <= MA2cache_rd_index_3;
            MA2cache_rd_offset_3 <= MA2cache_rd_offset_3;
        end
    end else if (rd_status == rd_s_miss_end) begin
        cache2MA_rd_fin <= 1'b0;
        cache2MA_rd_data <= 32'd0;
        cache_wr_en <= 1'b0;
        rd_status <= rd_s_idle;
        cache_wr_data <= data_init;
        cache_wr_tag <= tag_zero;
        cache_wr_status <= 3'b000;
        cache_rd_index_flag <= 1'b0;
        MA2cache_rd_index_3 <= index_zero;
    end else if (MA2cache_wr_en) begin///////////////////////////ここから書き込み
        MA2cache_wr_tag_2 <= MA2cache_wr_tag;
        MA2cache_wr_index_2 <= MA2cache_wr_index;
        MA2cache_wr_offset_2 <= MA2cache_wr_offset;
        MA2cache_wr_data_2 <= MA2cache_wr_data;
        wr_status <= wr_s_compare;
    end else if (wr_status == wr_s_compare) begin
        if ((MA2cache_wr_tag_2 == cache_rd_tag) && cache_rd_status[0]) begin
            //hit (not new)
            cache_wr_en <= 1'b1;
            cache_wr_tag <= MA2cache_wr_tag_2;
            cache_wr_data <= (cache_rd_data & wr_data_hit_mask_shift_not) | wr_data_hit_shift;
            cache2DDR_wr_data <= (cache_rd_data & wr_data_hit_mask_shift_not) | wr_data_hit_shift;
            // case (MA2cache_wr_offset_2[3:2])
            //     2'b00 : begin
            //         cache_wr_data <= {cache_rd_data[127:32], MA2cache_wr_data_2};
            //         cache2DDR_wr_data <= {cache_rd_data[127:32], MA2cache_wr_data_2};
            //     end 
            //     2'b01 : begin
            //         cache_wr_data <= {cache_rd_data[127:64], MA2cache_wr_data_2, cache_rd_data[31:0]};
            //         cache2DDR_wr_data <= {cache_rd_data[127:64], MA2cache_wr_data_2, cache_rd_data[31:0]};
            //     end
            //     2'b10 : begin
            //         cache_wr_data <= {cache_rd_data[127:96], MA2cache_wr_data_2, cache_rd_data[63:0]};
            //         cache2DDR_wr_data <= {cache_rd_data[127:96], MA2cache_wr_data_2, cache_rd_data[63:0]};
            //     end
            //     2'b11 : begin
            //         cache_wr_data <= {MA2cache_wr_data_2, cache_rd_data[95:0]};
            //         cache2DDR_wr_data <= {MA2cache_wr_data_2, cache_rd_data[95:0]};
            //     end
            // endcase
            cache_wr_status <= 3'b001;
            wr_status <= wr_s_hit_ddrwait;
            cache2DDR_wr_en <= 1'b1;
            cache2DDR_wr_addr <= {MA2cache_wr_tag_2, MA2cache_wr_index_2, MA2cache_wr_offset_2};//offset不要かも？
            cache_wr_hit_index_flag <= 1'd1;
            MA2cache_wr_index_3 <= MA2cache_wr_index_2;
        end else begin
            //miss
            wr_status <= wr_s_miss_ddrwait;
            cache2DDR_rd_addr <= {MA2cache_wr_tag_2, MA2cache_wr_index_2, MA2cache_wr_offset_2};
	        cache2DDR_rd_en <= 1'b1;
            MA2cache_wr_data_3 <= MA2cache_wr_data_2;
            MA2cache_wr_tag_3 <= MA2cache_wr_tag_2;
            MA2cache_wr_index_3 <= MA2cache_wr_index_2;
            MA2cache_wr_offset_3 <= MA2cache_wr_offset_2;
        end
    end else if (wr_status == wr_s_hit_ddrwait) begin
        cache_wr_en <= 1'b0;
        cache2DDR_wr_en <= 1'b0;
        cache_wr_data <= data_init;
        cache2DDR_wr_data <= data_init;
        cache_wr_status <= 3'b000;
        cache2DDR_wr_addr <= 27'd0;
        cache_wr_hit_index_flag <= 1'd0;
        MA2cache_wr_index_3 <= index_zero;
        cache_wr_tag <= tag_zero;
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
            wr_status <= wr_s_miss_ddr_wr_wait;
            cache_wr_en <= 1'b1;
            cache_wr_tag <= MA2cache_wr_tag_3;
            cache_wr_status <= 3'b001;
            cache_wr_data <= (cache_rd_data & wr_data_hit_mask_shift_not) | wr_data_hit_shift;
            cache2DDR_wr_data <= (cache_rd_data & wr_data_hit_mask_shift_not) | wr_data_hit_shift;
            // case (MA2cache_wr_offset_2[3:2])
            //     2'b00 : begin
            //         cache_wr_data <= {DDR2cache_rd_data[127:32], MA2cache_wr_data_3};
            //         cache2DDR_wr_data <= {DDR2cache_rd_data[127:32], MA2cache_wr_data_3};
            //     end 
            //     2'b01 : begin
            //         cache_wr_data <= {DDR2cache_rd_data[127:64], MA2cache_wr_data_3, DDR2cache_rd_data[31:0]};
            //         cache2DDR_wr_data <= {DDR2cache_rd_data[127:64], MA2cache_wr_data_3, DDR2cache_rd_data[31:0]};
            //     end
            //     2'b10 : begin
            //         cache_wr_data <= {DDR2cache_rd_data[127:96], MA2cache_wr_data_3, DDR2cache_rd_data[63:0]};
            //         cache2DDR_wr_data <= {DDR2cache_rd_data[127:96], MA2cache_wr_data_3, DDR2cache_rd_data[63:0]};
            //     end
            //     2'b11 : begin
            //         cache_wr_data <= {MA2cache_wr_data_3, DDR2cache_rd_data[95:0]};
            //         cache2DDR_wr_data <= {MA2cache_wr_data_3, DDR2cache_rd_data[95:0]};
            //     end
            // endcase
            cache2DDR_wr_en <= 1'b1;
            cache2DDR_wr_addr <= {MA2cache_wr_tag_3, MA2cache_wr_index_3, MA2cache_wr_offset_3};//offset不要かも？
            cache_wr_miss_index_flag <= 1'b1;
        end else begin
            wr_status <= wr_s_miss_ddrwait;
        end
    end else if (wr_status == wr_s_miss_ddr_wr_wait) begin
        cache_wr_en <= 1'b0;
        cache_wr_miss_index_flag <= 1'b0;
        cache2DDR_wr_en <= 1'b0;
        cache_wr_data <= data_init;
        cache2DDR_wr_data <= data_init;
        cache_wr_status <= 3'b000;
        cache2DDR_wr_addr <= 27'd0;
        if (DDR2cache_wr_fin) begin
            wr_status <= wr_s_miss_ddrend;
            cache2MA_wr_fin <= 1'b1;
        end else begin
            wr_status <= wr_s_miss_ddr_wr_wait;
        end
    end else if (wr_status == wr_s_miss_ddrend) begin
        wr_status <= wr_s_idle;
        cache2MA_wr_fin <= 1'b0;
    end
end

endmodule
