`timescale 1ms / 100us
`default_nettype none

module test_cache();

	logic clk;
	logic rstn;

	//MAステージからキャッシュに読みたいデータを指定される
	logic [26:0] MA2cache_rd_addr;
	logic MA2cache_rd_en;
	//MAステージにキャッシュが要求されたデータを渡す
	logic cache2MA_rd_fin;
	logic [31:0] cache2MA_rd_data;
	//キャッシュミスの場合はキャッシュがDDRに読みたいデータを指定してキャッシュに持ってくる
	logic [26:0] cache2DDR_rd_addr;
	logic cache2DDR_rd_en;
	//DDRがキャッシュに要求されたデータを渡す
	logic DDR2cache_rd_fin;
	logic [127:0] DDR2cache_rd_data;//[31:0] to [127:0]

	//MAステージからキャッシュに書き込みたいデータを渡される
	logic [26:0] MA2cache_wr_addr;
	logic [31:0] MA2cache_wr_data;
	logic MA2cache_wr_en;
	//キャッシュからMAステージに書き込むように渡されたデータはいつかDDRに書き込むこと＆そのデータをMAステージが読み込みたいときはその新しく渡されたデータを返すことを宣言
	logic cache2MA_wr_fin;
	//適当なタイミングで書き込むべきデータをDDRに書き込む
	logic [26:0] cache2DDR_wr_addr;
	logic [127:0] cache2DDR_wr_data;//[31:0] to [127:0]
	logic cache2DDR_wr_en;
	//DDRにデータが書き込まれたことを知らせる
	logic DDR2cache_wr_fin;

    cache cache1(clk,rstn,MA2cache_rd_addr,MA2cache_rd_en,cache2MA_rd_fin,cache2MA_rd_data,cache2DDR_rd_addr,cache2DDR_rd_en,DDR2cache_rd_fin,DDR2cache_rd_data,MA2cache_wr_addr,MA2cache_wr_data,MA2cache_wr_en,cache2MA_wr_fin,cache2DDR_wr_addr,cache2DDR_wr_data,cache2DDR_wr_en,DDR2cache_wr_fin);

    ddr_demo ddr_demo1(cache2DDR_rd_addr,cache2DDR_rd_en,DDR2cache_rd_fin,DDR2cache_rd_data,cache2DDR_wr_addr,cache2DDR_wr_data,cache2DDR_wr_en,DDR2cache_wr_fin,clk,rstn);


    always begin
        #1 clk <= ~clk;
    end
    initial begin
        clk = 1'b0;
        rstn = 1'b0;
        MA2cache_rd_addr = 27'd0;
	    MA2cache_rd_en = 1'd0;
	    cache2MA_rd_fin = 1'd0;
	    cache2MA_rd_data = 32'd0;
	    cache2DDR_rd_addr = 27'd0;
	    cache2DDR_rd_en = 1'd0;
	    DDR2cache_rd_fin = 1'd0;
	    DDR2cache_rd_data = 128'd0;
	    MA2cache_wr_addr = 27'd0;
	    MA2cache_wr_data = 32'd0;
	    MA2cache_wr_en = 1'd0;
	    cache2MA_wr_fin = 1'd0;
	    cache2DDR_wr_addr = 27'd0;
	    cache2DDR_wr_data = 128'd0;
	    cache2DDR_wr_en = 1'd0;
	    DDR2cache_wr_fin = 1'd0;
        #2;
        rstn = 1'b1;
        #2;

        MA2cache_wr_en = 1'b1;
        MA2cache_wr_addr = {3'd0, 4'd0, 12'd0, 4'd0, 2'b00, 2'd0};
        MA2cache_wr_data = 32'h0000ffff;
        #2;
        MA2cache_wr_en = 1'b0;
        MA2cache_wr_addr = 27'd0;
        MA2cache_wr_data = 32'h00000000;//write
        #12;

        MA2cache_wr_en = 1'b1;
        MA2cache_wr_addr = {3'd0, 4'd0, 12'd0, 4'd4, 2'b01, 2'd0};
        MA2cache_wr_data = 32'h0000ff00;
        #2;
        MA2cache_wr_en = 1'b0;
        MA2cache_wr_addr = 27'd0;
        MA2cache_wr_data = 32'h00000000;//write
        #12;

        MA2cache_wr_en = 1'b1;
        MA2cache_wr_addr = {3'd0, 4'd0, 12'd0, 4'd4, 2'b11, 2'd0};
        MA2cache_wr_data = 32'h00003333;
        #2;
        MA2cache_wr_en = 1'b0;
        MA2cache_wr_addr = 27'd0;
        MA2cache_wr_data = 32'h00000000;//write
        #12;

        MA2cache_wr_en = 1'b1;
        MA2cache_wr_addr = {3'd0, 4'd0, 12'd0, 4'd8, 2'b11, 2'd0};
        MA2cache_wr_data = 32'h0000f80f;
        #2;
        MA2cache_wr_en = 1'b0;
        MA2cache_wr_addr = 27'd0;
        MA2cache_wr_data = 32'h00000000;//write
        #12;

        MA2cache_wr_en = 1'b1;
        MA2cache_wr_addr = {3'd0, 4'd0, 12'd0, 4'd8, 2'b10, 2'd0};
        MA2cache_wr_data = 32'h00001234;
        #2;
        MA2cache_wr_en = 1'b0;
        MA2cache_wr_addr = 27'd0;
        MA2cache_wr_data = 32'h00000000;//write
        #12;

        MA2cache_wr_en = 1'b1;
        MA2cache_wr_addr = {3'd0, 4'd0, 12'd0, 4'd0, 2'b11, 2'd0};
        MA2cache_wr_data = 32'h0000aaaa;
        #2;
        MA2cache_wr_en = 1'b0;
        MA2cache_wr_addr = 27'd0;
        MA2cache_wr_data = 32'h00000000;//write
        #12;

        MA2cache_rd_en = 1'b1;
        MA2cache_rd_addr = {3'd0, 4'd0, 12'd0, 4'd0, 2'b00, 2'd0};
        #2;
        MA2cache_rd_en = 1'b0;
        MA2cache_rd_addr = 27'd0;//read
        #12;

        MA2cache_rd_en = 1'b1;
        MA2cache_rd_addr = {3'd0, 4'd0, 12'd0, 4'd4, 2'b11, 2'd0};
        #2;
        MA2cache_rd_en = 1'b0;
        MA2cache_rd_addr = 27'd0;//read
        #12;

        MA2cache_wr_en = 1'b1;
        MA2cache_wr_addr = {3'd0, 4'd4, 12'd0, 4'd4, 2'b00, 2'd0};
        MA2cache_wr_data = 32'h00009999;
        #2;
        MA2cache_wr_en = 1'b0;
        MA2cache_wr_addr = 27'd0;
        MA2cache_wr_data = 32'h00000000;//write
        #12;

        MA2cache_rd_en = 1'b1;
        MA2cache_rd_addr = {3'd0, 4'd0, 12'd0, 4'd4, 2'b01, 2'd0};
        #2;
        MA2cache_rd_en = 1'b0;
        MA2cache_rd_addr = 27'd0;//read
        #12;

        $finish;
    end
    endmodule

