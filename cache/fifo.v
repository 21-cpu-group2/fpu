`timescale 1ns / 1ps

module fifo(
    input wire clk,
    input wire rstn,

    //fifo writes, fifo reads...
    //if (wr_fin & exist) wr_en will be asserted
    input wire wr_busy,
    output reg wr_en,
    output reg [26:0] wr_addr,
    output reg [127:0] wr_data,

    input wire [26:0] rd_addr,
    input wire [127:0] rd_data,
    input wire rd_en,
    
    output reg slderr
);

    wire exist;
    assign exist = (count == 5'b0)? 1'b0 : 1'b1;

    reg [26:0] addr_ram [31:0];
    reg [127:0] data_ram [31:0];
    reg [4:0] count;
    reg [4:0] rd_num, wr_num;
    
    always @(posedge clk) begin
        if(~rstn) begin
            rd_num <= 5'b0;
        end else if(rd_en) begin
            addr_ram[rd_num] <= rd_addr;
            data_ram[rd_num] <= rd_data;
            rd_num <= rd_num + 1'b1;
        end
    end

    always @(posedge clk) begin
        if(~rstn) begin
            wr_num <= 5'b0;
            wr_en <= 1'b0;
        end else if(~wr_busy & exist) begin
            wr_addr <= addr_ram[wr_num];
            wr_data <= data_ram[wr_num];
            wr_en <= 1'b1;
            wr_num <= wr_num + 1'b1;
        end else begin
            wr_en <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if(~rstn) begin
            count <= 5'b0;
            slderr <= 1'b0;
        end else begin
            case({(~wr_busy & exist),rd_en})
                2'b01: count <= count + 1'b1;
                2'b10: count <= count - 5'b1;
                default: count <= count;
            endcase
            if(count == 5'd31) begin
                slderr <= 1'b1;
            end
        end
    end

endmodule