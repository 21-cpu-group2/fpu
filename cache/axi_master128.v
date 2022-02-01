`timescale 1ns / 1ps

module axi_master(

    input wire ACLK,
    input wire ARESETN,
    
    output wire M_AXI_AWID,
    output reg [26:0] M_AXI_AWADDR,
    output wire [7:0] M_AXI_AWLEN,
    output wire [2:0] M_AXI_AWSIZE,
    output wire [1:0] M_AXI_AWBURST,
    output wire M_AXI_AWLOCK,
    output wire [3:0] M_AXI_AWCACHE,
    output wire [2:0] M_AXI_AWPROT,
    output wire [3:0] M_AXI_AWQOS,
    output reg M_AXI_AWVALID,
    input wire M_AXI_AWREADY,
    
    output reg [127:0] M_AXI_WDATA,
    output wire [15:0] M_AXI_WSTRB,
    output wire M_AXI_WLAST,
    output reg M_AXI_WVALID,
    input wire M_AXI_WREADY,
    
    input wire M_AXI_BID,
    input wire [1:0] M_AXI_BRESP,
    input wire M_AXI_BVALID,
    output reg M_AXI_BREADY,
    
    output wire M_AXI_ARID,
    output reg [26:0] M_AXI_ARADDR,
    output wire [7:0] M_AXI_ARLEN,
    output wire [2:0] M_AXI_ARSIZE,
    output wire [1:0] M_AXI_ARBURST,
    output wire M_AXI_ARLOCK,
    output wire [3:0] M_AXI_ARCACHE,
    output wire [2:0] M_AXI_ARPROT,
    output wire [3:0] M_AXI_ARQOS,
    output reg M_AXI_ARVALID,
    input wire M_AXI_ARREADY,
    
    input wire M_AXI_RID,
    input wire [127:0] M_AXI_RDATA,
    input wire [1:0] M_AXI_RRESP,
    input wire M_AXI_RLAST,
    input wire M_AXI_RVALID,
    output reg M_AXI_RREADY,
 
    input wire wr_en,
    input wire rd_en,
    output reg wr_fin,
    output reg rd_fin,
    input wire [127:0] wr_data,
    input wire [26:0] wr_addr,
    input wire [26:0] rd_addr,
    output reg [127:0] rd_data,
    
    output wire slderr
);

    wire f_wr_en;
    wire [26:0] f_wr_addr;
    wire [127:0] f_wr_data;

    fifo fifo(
        .clk(ACLK),
        .rstn(ARESETN),

        .wr_busy(wr_busy),
        .wr_en(f_wr_en),
        .wr_addr(f_wr_addr),
        .wr_data(f_wr_data),

        .rd_addr(wr_addr),
        .rd_data(wr_data),
        .rd_en(wr_en),
        
        .slderr(slderr)
    );

    wire wr_busy;
    
    //M_AXI_AWADDR, M_AXI_AWVALID <- M_AXI_AWREADY
    assign M_AXI_AWID = 1'b0;
    assign M_AXI_AWLEN = 8'b0;
    assign M_AXI_AWSIZE = 3'b100;
    assign M_AXI_AWBURST = 2'b01;
    assign M_AXI_AWLOCK = 1'b0;
    assign M_AXI_AWCACHE = 4'b0011;
    assign M_AXI_AWPROT = 3'b0;
    assign M_AXI_AWQOS = 4'b0;

    //M_AXI_WDATA, M_AXI_WVALID <- M_AXI_WREADY
    assign M_AXI_WSTRB = 16'hffff;
    assign M_AXI_WLAST = 1'b1;
    
    reg [1:0] wstate;
    localparam ws_0 = 2'd0;
    localparam ws_1 = 2'd1;
    localparam ws_2 = 2'd2;

    assign wr_busy = 
        (((wstate == ws_0) & f_wr_en) || (wstate == ws_1) || ((wstate == ws_2) & ~M_AXI_WREADY))? 1'b1 : 1'b0;
    
    always@(posedge ACLK) begin
        if(~ARESETN) begin
            M_AXI_AWADDR <= 27'b0;
            M_AXI_AWVALID <= 1'b0;
            M_AXI_WDATA <= 128'b0; 
            M_AXI_WVALID <= 1'b0;
            wstate <= ws_0;
            wr_fin <= 1'b0;
        end else if(wstate == ws_0) begin
            wr_fin <= 1'b0;
            if(f_wr_en) begin
                M_AXI_AWADDR <= f_wr_addr;
                M_AXI_WDATA <= f_wr_data;
                M_AXI_AWVALID <= 1'b1;
                wstate <= ws_1;
            end
        end else if(wstate == ws_1) begin
            if(M_AXI_AWREADY) begin
                M_AXI_AWVALID <= 1'b0;
                M_AXI_WVALID <= 1'b1;
                wstate <= ws_2;
            end
        end else if(wstate == ws_2) begin
            if(M_AXI_WREADY) begin
                M_AXI_WVALID <= 1'b0;
                wstate <= ws_0;
                wr_fin <= 1'b1;
            end
        end
    end

    //M_AXI_ARADDR, M_AXI_ARVALID <- M_AXI_ARREADY
    assign M_AXI_ARID = 1'b0;   
    assign M_AXI_ARLEN = 8'b0;
    assign M_AXI_ARSIZE = 3'b100;
    assign M_AXI_ARBURST = 2'b01;
    assign M_AXI_ARLOCK = 1'b0;
    assign M_AXI_ARCACHE = 4'b0011;
    assign M_AXI_ARPROT = 3'b0;
    assign M_AXI_ARQOS = 4'b0;

    //M_AXI_RREADY <- M_AXI_RVALID, M_AXI_RLAST, M_AXI_RDATA, M_AXI_RID, M_AXI_RRESP

    reg [1:0] rstate;
    localparam rs_0 = 2'd0;
    localparam rs_1 = 2'd1;
    localparam rs_2 = 2'd2;
    
    always@(posedge ACLK) begin
        if(~ARESETN) begin
            M_AXI_ARADDR <= 27'b0;
            M_AXI_ARVALID <= 1'b0;
            M_AXI_RREADY <= 1'b0;
            rd_data <= 128'b0;
            rd_fin <= 1'b0;
            rstate <= rs_0;
        end else if(rstate == rs_0) begin
            rd_fin <= 1'b0;
            if(rd_en) begin
                M_AXI_ARADDR <= rd_addr;
                rstate <= rs_1;
                M_AXI_ARVALID <= 1'b1;
            end
        end else if(rstate == rs_1) begin
            if(M_AXI_ARREADY) begin
                M_AXI_ARVALID <= 1'b0;
                M_AXI_RREADY <= 1'b1;
                rstate <= rs_2;
            end
        end else if(rstate == rs_2) begin
            if(M_AXI_RVALID) begin
                M_AXI_RREADY <= 1'b0;
                rd_data <= M_AXI_RDATA;
                rstate <= rs_0;
                rd_fin <= 1'b1;
            end
        end
    end

    //M_AXI_BREADY <- M_AXI_BVALID, M_AXI_BID, M_AXI_BRESP
    always @(posedge ACLK) begin
        if (~ARESETN) begin
 	        M_AXI_BREADY <= 1'b0;
        end else begin
 	        M_AXI_BREADY <= 1'b1;
        end
    end

endmodule