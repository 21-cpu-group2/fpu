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
    output reg core2cache_wr_en,
    (* mark_debug = "true" *) input wire swich,
    output reg end_flag,
    (* mark_debug = "true" *) output reg [9:0] counter
);

reg wr_wait;
reg rd_wait;

(* mark_debug = "true" *) reg [31:0] clk_counter;

reg [12:0] core2cache_rd_addr_tag;
reg [9:0] core2cache_rd_addr_index;
reg [3:0] core2cache_rd_addr_offset;
assign core2cache_rd_addr = {core2cache_rd_addr_tag, core2cache_rd_addr_index, core2cache_rd_addr_offset};

reg [12:0] core2cache_wr_addr_tag;
reg [9:0] core2cache_wr_addr_index;
reg [3:0] core2cache_wr_addr_offset;
assign core2cache_wr_addr = {core2cache_wr_addr_tag, core2cache_wr_addr_index, core2cache_wr_addr_offset};

// (* mark_debug = "true" *) reg [9:0] counter;

reg swich_flag;

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
        swich_flag <= 1'b0;
        end_flag <= 1'b0;
        clk_counter <= 32'd0;
    end else if (swich) begin
        clk_counter <= clk_counter + 32'd1;
        if (wr_wait) begin
            core2cache_wr_en <= 1'b0;
            core2cache_wr_data <= core2cache_wr_data;
            core2cache_rd_addr_tag <= core2cache_rd_addr_tag;
            core2cache_rd_addr_index <= core2cache_rd_addr_index;
            core2cache_rd_addr_offset <= core2cache_rd_addr_offset;
            core2cache_wr_addr_tag <= core2cache_wr_addr_tag;
            core2cache_wr_addr_index <= core2cache_wr_addr_index;
            core2cache_wr_addr_offset <= core2cache_wr_addr_offset;
            if (cache2core_wr_fin) begin
                wr_wait <= 1'b0;
            end else begin
                wr_wait <= 1'b1;
            end
        end else if (rd_wait) begin
            core2cache_rd_en <= 1'b0;
            core2cache_wr_data <= core2cache_wr_data;
            core2cache_rd_addr_tag <= core2cache_rd_addr_tag;
            core2cache_rd_addr_index <= core2cache_rd_addr_index;
            core2cache_rd_addr_offset <= core2cache_rd_addr_offset;
            core2cache_wr_addr_tag <= core2cache_wr_addr_tag;
            core2cache_wr_addr_index <= core2cache_wr_addr_index;
            core2cache_wr_addr_offset <= core2cache_wr_addr_offset;
            if (cache2core_rd_fin) begin
                rd_wait <= 1'b0;
            end else begin
                rd_wait <= 1'b1;
            end
        // end else if (counter == 10'd0) begin
        //     counter <= counter + 10'd1;
        //     core2cache_wr_addr_tag <= {3'd0, 4'h0, 6'd0};
        //     core2cache_wr_addr_index <= {6'd0, 4'h0};
        //     core2cache_wr_addr_offset <= {2'b00, 2'd0};
        //     core2cache_wr_en <= 1'b1;
        //     core2cache_wr_data <= 32'h0000ffff;
        //     wr_wait <= 1'b1;
        // end else if (counter == 10'd1) begin
        //     counter <= counter + 10'd1;
        //     core2cache_wr_addr_tag <= {3'd0, 4'h0, 6'd0};
        //     core2cache_wr_addr_index <= {6'd0, 4'h4};
        //     core2cache_wr_addr_offset <= {2'b01, 2'd0};
        //     core2cache_wr_en <= 1'b1;
        //     core2cache_wr_data <= 32'h0000ff00;
        //     wr_wait <= 1'b1;
        // end else if (counter == 10'd2) begin
        //     counter <= counter + 10'd1;
        //     core2cache_wr_addr_tag <= {3'd0, 4'h0, 6'd0};
        //     core2cache_wr_addr_index <= {6'd0, 4'h4};
        //     core2cache_wr_addr_offset <= {2'b11, 2'd0};
        //     core2cache_wr_en <= 1'b1;
        //     core2cache_wr_data <= 32'h00003333;
        //     wr_wait <= 1'b1;
        // end else if (counter == 10'd3) begin
        //     counter <= counter + 10'd1;
        //     core2cache_wr_addr_tag <= {3'd0, 4'h0, 6'd0};
        //     core2cache_wr_addr_index <= {6'd0, 4'h8};
        //     core2cache_wr_addr_offset <= {2'b11, 2'd0};
        //     core2cache_wr_en <= 1'b1;
        //     core2cache_wr_data <= 32'h0000f80f;
        //     wr_wait <= 1'b1;
        // end else if (counter == 10'd4) begin
        //     counter <= counter + 10'd1;
        //     core2cache_wr_addr_tag <= {3'd0, 4'h0, 6'd0};
        //     core2cache_wr_addr_index <= {6'd0, 4'h8};
        //     core2cache_wr_addr_offset <= {2'b10, 2'd0};
        //     core2cache_wr_en <= 1'b1;
        //     core2cache_wr_data <= 32'h00001234;
        //     wr_wait <= 1'b1;
        // end else if (counter == 10'd5) begin
        //     counter <= counter + 10'd1;
        //     core2cache_wr_addr_tag <= {3'd0, 4'h0, 6'd0};
        //     core2cache_wr_addr_index <= {6'd0, 4'h0};
        //     core2cache_wr_addr_offset <= {2'b11, 2'd0};
        //     core2cache_wr_en <= 1'b1;
        //     core2cache_wr_data <= 32'h0000aaaa;
        //     wr_wait <= 1'b1;
        // end else if (counter == 10'd6) begin
        //     counter <= counter + 10'd1;
        //     core2cache_rd_addr_tag <= {3'd0, 4'h0, 6'd0};
        //     core2cache_rd_addr_index <= {6'd0, 4'h0};
        //     core2cache_rd_addr_offset <= {2'b00, 2'd0};
        //     core2cache_rd_en <= 1'b1;
        //     rd_wait <= 1'b1;
        // end else if (counter == 10'd7) begin
        //     counter <= counter + 10'd1;
        //     core2cache_rd_addr_tag <= {3'd0, 4'h0, 6'd0};
        //     core2cache_rd_addr_index <= {6'd0, 4'h4};
        //     core2cache_rd_addr_offset <= {2'b11, 2'd0};
        //     core2cache_rd_en <= 1'b1;
        //     rd_wait <= 1'b1;
        // end else if (counter == 10'd8) begin
        //     counter <= counter + 10'd1;
        //     core2cache_wr_addr_tag <= {3'd0, 4'h4, 6'd0};
        //     core2cache_wr_addr_index <= {6'd0, 4'h4};
        //     core2cache_wr_addr_offset <= {2'b00, 2'd0};
        //     core2cache_wr_en <= 1'b1;
        //     core2cache_wr_data <= 32'h00009999;
        //     wr_wait <= 1'b1;
        // end else if (counter == 10'd9) begin
        //     counter <= counter + 10'd1;
        //     core2cache_rd_addr_tag <= {3'd0, 4'h0, 6'd0};
        //     core2cache_rd_addr_index <= {6'd0, 4'h4};
        //     core2cache_rd_addr_offset <= {2'b01, 2'd0};
        //     core2cache_rd_en <= 1'b1;
        //     rd_wait <= 1'b1;
        // end else if (counter > 10'd100) begin
        //     counter <= 10'd0;
        // end else begin
        //     end_flag <= 1'b1;
        //     counter <= counter +10'd1;
        // end
        // end else if (counter < 10'd100) begin
        //     counter <= counter + 10'd1;
        //     core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0000100000000;
        //     core2cache_wr_addr_index <= core2cache_wr_addr_index + 10'b0101000000;
        //     core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b1100;
        //     core2cache_wr_en <= 1'b1;
        //     core2cache_wr_data <= core2cache_wr_data + 32'd1;
        //     wr_wait <= 1'b1;
        // end else if (counter < 10'd200) begin
        //     counter <= counter + 10'd1;
        //     core2cache_rd_addr_tag <= core2cache_rd_addr_tag + 13'b0000100000000;
        //     core2cache_rd_addr_index <= core2cache_rd_addr_index + 10'b0101000000;
        //     core2cache_rd_addr_offset <= core2cache_rd_addr_offset + 4'b1100;
        //     core2cache_rd_en <= 1'b1;
        //     rd_wait <= 1'b1;
        // end else if (counter < 10'd400) begin
        //     counter <= counter + 10'd1;
        //     if (counter[0]) begin
        //         core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0000100000000;
        //         core2cache_wr_addr_index <= core2cache_wr_addr_index + 10'b01010000000;
        //         core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b1100;
        //         core2cache_wr_en <= 1'b1;
        //         core2cache_wr_data <= core2cache_wr_data + 32'd1;
        //         wr_wait <= 1'b1;
        //     end else begin
        //         core2cache_rd_addr_tag <= core2cache_rd_addr_tag + 13'b0000100000000;
        //         core2cache_rd_addr_index <= core2cache_rd_addr_index + 10'b0101000000;
        //         core2cache_rd_addr_offset <= core2cache_rd_addr_offset + 4'b1100;
        //         core2cache_rd_en <= 1'b1;
        //         rd_wait <= 1'b1;
        //     end
        end else if (counter < 10'd100) begin
            counter <= counter + 10'd1;
            if (counter[2:0] == 3'b000) core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0100000000000;
            else core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0010000000000;
            core2cache_wr_addr_index <= core2cache_wr_addr_index + 10'b0010000000;
            if (counter[2:0] == 3'b000) core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b1000;
            else core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b0100;
            core2cache_wr_en <= 1'b1;
            core2cache_wr_data <= core2cache_wr_data + 32'd1;
            wr_wait <= 1'b1;
        end else if (counter < 10'd200) begin
            counter <= counter + 10'd1;
            if (counter[2:0] == 3'b000) core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0100000000000;
            else core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0010000000000;
            core2cache_rd_addr_index <= core2cache_rd_addr_index + 10'b0010000000;
            if (counter[2:0] == 3'b000) core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b1000;
            else core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b0100;
            core2cache_rd_en <= 1'b1;
            rd_wait <= 1'b1;
        end else if (counter < 10'd400) begin
            counter <= counter + 10'd1;
            if (counter[0]) begin
                if (counter[3:1] == 3'b000) core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0100000000000;
                else core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0010000000000;
                core2cache_wr_addr_index <= core2cache_wr_addr_index + 10'b00100000000;
                if (counter[3:1] == 3'b000) core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b1000;
                else core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b0100;
                core2cache_wr_en <= 1'b1;
                core2cache_wr_data <= core2cache_wr_data + 32'd1;
                wr_wait <= 1'b1;
            end else begin
                if (counter[3:1] == 3'b000) core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0100000000000;
                else core2cache_wr_addr_tag <= core2cache_wr_addr_tag + 13'b0010000000000;
                core2cache_rd_addr_index <= core2cache_rd_addr_index + 10'b0010000000;
                if (counter[3:1] == 3'b000) core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b1000;
                else core2cache_wr_addr_offset <= core2cache_wr_addr_offset + 4'b0100;
                core2cache_rd_en <= 1'b1;
                rd_wait <= 1'b1;
            end
        // end else begin
        //     counter <= 10'd0;
        // end
        // if (swich_flag ^ swich) begin
        //     counter <= counter + 10'd1;
        //     swich_flag <= ~swich_flag;
        end
    end
end
    
endmodule