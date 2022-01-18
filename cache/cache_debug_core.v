`timescale 1ns / 1ps
`default_nettype wire

module cache_debug_core (
    input clk, rstn,
    input wire cache2core_wr_fin,
    input wire cache2core_rd_fin,
    input wire [31:0] cache2core_rd_data,
    output wire [26:0] core2cache_rd_addr,
    output wire [26:0] core2cache_wr_addr,
    output reg [31:0] core2cache_wr_data,
    output reg core2cache_rd_en,
    output reg core2cache_wr_en
);

reg wr_wait;
reg rd_wait;

reg [12:0] core2cache_rd_addr_tag;
reg [9:0] core2cache_rd_addr_index;
reg [3:0] core2cache_rd_addr_offset;
assign core2cache_rd_addr = {core2cache_rd_addr_tag, core2cache_rd_addr_index, core2cache_rd_addr_offset};

reg [12:0] core2cache_wr_addr_tag;
reg [9:0] core2cache_wr_addr_index;
reg [3:0] core2cache_wr_addr_offset;
assign core2cache_wr_addr = {core2cache_wr_addr_tag, core2cache_wr_addr_index, core2cache_wr_addr_offset};

reg [9:0] counter;

always @(posedge clk) begin
    if (~rstn) begin
        core2cache_wr_data <= 32'd0;
        core2cache_rd_en <= 1'b0;
        core2cache_wr_en <= 1'b0;
        wr_wait <= 1'b0;
        rd_wait <= 1'b0;
        core2cache_rd_addr_tag <= 13'd0;
        core2cache_rd_addr_index <= 10'd0;
        core2cache_rd_addr_offset <= 4'd0;
        core2cache_wr_addr_tag <= 13'd0;
        core2cache_wr_addr_index <= 10'd0;
        core2cache_wr_addr_offset <= 4'd0;
        counter <= 10'd0;
    end else if (wr_wait) begin
        core2cache_wr_en <= 1'b0;
        if (cache2core_wr_fin) begin
            wr_wait <= 1'b0;
        end else begin
            wr_wait <= 1'b1;
        end
    end else if (rd_wait) begin
        core2cache_rd_en <= 1'b0;
        if (cache2core_rd_fin) begin
            rd_wait <= 1'b0;
        end else begin
            rd_wait <= 1'b1;
        end
    end else if (counter < 10'd100) begin
        counter <= counter + 10'd1;
        core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0001000000000;
        core2cache_wr_addr_index <= core2cache_wr_addr_index + 10'b0101000000;
        core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b1100;
        core2cache_wr_en <= 1'b1;
        core2cache_wr_data <= core2cache_wr_data + 32'd1;
        wr_wait <= 1'b1;
    end else if (counter < 10'd200) begin
        counter <= counter + 10'd1;
        core2cache_rd_addr_tag <= core2cache_rd_addr_tag + 13'b0001000000000;
        core2cache_rd_addr_index <= core2cache_rd_addr_index + 10'b0101000000;
        core2cache_rd_addr_offset <= core2cache_rd_addr_offset + 4'b1100;
        core2cache_rd_en <= 1'b1;
        rd_wait <= 1'b1;
    end else if (counter < 10'd400) begin
        counter <= counter + 10'd1;
        if (counter[0]) begin
            core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0101000000000;
            core2cache_wr_addr_index <= core2cache_wr_addr_index + 10'b0001000000;
            core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b1100;
            core2cache_wr_en <= 1'b1;
            core2cache_wr_data <= core2cache_wr_data + 32'd1;
            wr_wait <= 1'b1;
        end else begin
            core2cache_rd_addr_tag <= core2cache_rd_addr_tag + 13'b0101000000000;
            core2cache_rd_addr_index <= core2cache_rd_addr_index + 10'b0001000000;
            core2cache_rd_addr_offset <= core2cache_rd_addr_offset + 4'b1100;
            core2cache_rd_en <= 1'b1;
            rd_wait <= 1'b1;
        end
    end
end
    
endmodule