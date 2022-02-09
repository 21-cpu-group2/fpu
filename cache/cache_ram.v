// `default_nettype none
//仕様：we/reのどちらかが1clkだけ上がって、そのときにadd,tag,statusを指定
//　　　その次のclkで書き込みが完了している/読み出しが成功している
//(validは次の読み出し命令が来なければ1clkのみ立っている)
//（この仕様はどちらも共通）
//cachelineは128bit=4wordがデフォルト
module Status_Tag_ram #(
    parameter index_len = 10,
    parameter data_size = 16,// = tag(13) + 3
    parameter tag_len = 13
)(
    input wire clk, we,
    input wire [index_len - 1:0] addr,
    input wire [tag_len - 1:0] tag_in,
    input wire [2:0] status_in,
    output wire [tag_len - 1:0] tag_out,
    output wire [2:0] status_out
);
(* ram_style = "block" *)
reg [data_size-1:0] ram [0:2**index_len-1];

reg [tag_len + 2:0] status_tag_out;
assign status_out = status_tag_out[tag_len+2:tag_len];
assign tag_out = status_tag_out[tag_len-1:0];
wire [data_size-1:0] status_tag_in;
assign status_tag_in = {status_in, tag_in};

always @(posedge clk) begin
    if (we) begin
        ram[addr] <= status_tag_in;
    end else status_tag_out <= ram[addr];
end
endmodule

module Data_ram #(
    parameter index_len = 10,
    parameter data_size = 128// = 32 * 2 * (offset - 2)
)(
    input wire clk, we,
    input wire [index_len - 1:0] addr,
    input wire [data_size - 1:0] Data_in,
    output reg [data_size - 1:0] Data_out
);
(* ram_style = "block" *)
reg [data_size-1:0] ram [0:2**index_len-1];

always @(posedge clk) begin
    if (we) begin
        ram[addr] <= Data_in;
    end else Data_out <= ram[addr];
end
endmodule
////////////////////////////////////////////////////////////////////////does not use below this line
module bram 
    #(
        parameter addr_size = 10,
        parameter data_size = 128
    )
    (
        input wire ACLK,
        input wire we,
        input wire [addr_size-1:0] addr,
        input wire [data_size-1:0] din,
        output reg [data_size-1:0] dout
    );
    (* ram_style = "block" *) reg [data_size-1:0] ram [2**addr_size-1:0];
    // int i;
    // initial begin
    //     for(i = 0; i < 2**addr_size;++i)begin
    //         ram[i] = 0;
    //     end
    // end
    always @( posedge ACLK ) begin
        if (we) begin
            ram[addr] <= din;
        end
        
        dout <= ram[addr];
    end
endmodule

module BRAM_inst

  #(parameter DATA_WIDTH=32,     
  parameter ADDR_WIDTH=10)     
  (      
    input [(DATA_WIDTH-1):0] data_in,      
    input [(ADDR_WIDTH-1):0] read_addr, write_addr,      
    input wr_en, clk,      
    output [(DATA_WIDTH-1):0] data_out      
);

   (* ram_style = "block" *) reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];    
   reg [ADDR_WIDTH-1:0] read_addr_reg;        
   always @ (posedge clk) begin       
       read_addr_reg <= read_addr;               
       if (wr_en) begin        
           ram[write_addr] <= data_in;      
        end    
    end

   assign data_out = ram[read_addr_reg];   

endmodule

module BRAM_top   
#(parameter DATA_WIDTH=32,     
parameter ADDR_WIDTH=10)     
(      
    input [(DATA_WIDTH-1):0] data_in,      
    input [(ADDR_WIDTH-1):0] addr,      
    input wr_en, clk,      
    output reg [(DATA_WIDTH-1):0] data_out      
    );

   wire [DATA_WIDTH-1:0] data_out_tmp;

   Data_ram #(.data_size(DATA_WIDTH),.index_len(ADDR_WIDTH)) 
   chaitanya_ram_inst (        
       .Data_out   (data_out_tmp),        
       .Data_in    (data_in),        
       .addr  (addr),            
       .clk        (clk),        
       .we      (wr_en));        
       always @ (posedge clk)      
       begin        
           data_out <= data_out_tmp;      
        end

endmodule

module status_BRAM_top   
#(parameter DATA_WIDTH=16,     
parameter ADDR_WIDTH=10)     
(      
    input [(DATA_WIDTH-4):0] tag_in,
    input [2:0] status_in, 
    input [(ADDR_WIDTH-1):0] addr,      
    input wr_en, clk,      
    output reg [(DATA_WIDTH-4):0] tag_out,
    output reg [2:0] status_out      
    );

   wire [DATA_WIDTH-4:0] tag_out_tmp;
   wire [2:0] status_out_tmp;

   Status_Tag_ram #(.data_size(DATA_WIDTH),.index_len(ADDR_WIDTH)) 
   chaitanya_ram_inst (        
       .tag_out   (tag_out_tmp),
       .status_out  (status_out_tmp),
       .tag_in    (tag_in),
       .status_in   (status_in),        
       .addr  (addr),            
       .clk        (clk),        
       .we      (wr_en));        
       always @ (posedge clk)      
       begin        
           tag_out <= tag_out_tmp;
           status_out <= status_out_tmp;      
        end

endmodule
`default_nettype wire
