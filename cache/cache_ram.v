`default_nettype none
//仕様：we/reのどちらかが1clkだけ上がって、そのときにadd,tag,statusを指定
//　　　その次のclkで書き込みが完了している/読み出しが成功している
//(validは次の読み出し命令が来なければ1clkのみ立っている)
//（この仕様はどちらも共通）
//cachelineは128bit=4wordがデフォルト
module Status_Tag_ram #(
    parameter tag_len = 13,
    parameter index_len = 10,
    parameter offset_len = 4,
    parameter ram_width = 16,
    parameter tag_3_zero = 16'd0
)(
    input wire clk, we, re, rstn, 
    input wire [index_len - 1:0] addr,
    input wire [tag_len - 1:0] tag_in,
    input wire [2:0] status_in,
    output wire [tag_len - 1:0] tag_out,
    output wire [2:0] status_out
);
(* ram_style = "block" *)
reg [ram_width-1:0] ram [0:2**index_len-1];

reg [tag_len + 2:0] status_tag_out;
assign {status_out, tag_out} = status_tag_out;
wire [tag_len + 2:0] status_tag_in;
assign status_tag_in = {status_in, tag_in};
integer i;

initial begin
    for (i=0; i < 2**index_len; i = i + 1) begin
        ram[i] = tag_3_zero;
    end
end

always @(posedge clk) begin
    if (~rstn) begin
        status_tag_out <= tag_3_zero;
    end
    if (we) begin
        ram[addr] <= status_tag_in;
    end
    begin
        status_tag_out <= ram[addr];
    end
end
endmodule

module Data_ram #(
    parameter tag_len = 13,
    parameter index_len = 10,
    parameter offset_len = 4,
    parameter data_init = 128'd0//(32 * 2 ** (offset_len - 2))'d0
)(
    input wire clk, we,
    // input wire re, rstn, 
    input wire [index_len - 1:0] addr,
    input wire [32 * 2 ** (offset_len - 2) - 1:0] Data_in,
    output reg [32 * 2 ** (offset_len - 2) - 1:0] Data_out
);
(* ram_style = "block" *)
reg [32 * 2 ** (offset_len - 2) - 1:0] ram [0:2**index_len-1];
// integer i;

// initial begin
//     for (i=0;i < 2**index_len; i = i + 1) begin
//         ram[i] = data_init;
//     end
// end

always @(posedge clk) begin
    // if (~rstn) begin
    //     Data_out <= data_init;
    // end
    if (we) begin
        ram[addr] <= Data_in;
    end
    begin
        Data_out <= ram[addr];
    end
end
endmodule
`default_nettype wire
