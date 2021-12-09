`default_nettype none
module make_sig1 (
    input wire clk,
    input wire reset,
    output reg sig1
);

reg [5:0] count;

always @(posedge clk) begin
    if (~reset) begin
        sig1 <= 1'b0;
        count <= 6'd0;
    end else if (count != 6'd50) begin
        count <= count + 6'b1;
    end else begin
        count <= 6'd0;
        sig1 <= 1'b1;
    end
end
endmodule

module make_sig2 (
    input wire clk,
    input wire reset,
    output reg sig2
);

reg [5:0] count;

always @(posedge clk) begin
    if (~reset) begin
        sig2 <= 1'b0;
        count <= 6'd0;
    end else if (count != 6'd25) begin
        count <= count + 6'b1;
    end else begin
        count <= 6'd0;
        sig2 <= ~sig2;
    end
end
endmodule

module make_exp1 (
    input wire clk,
    input wire reset,
    output reg [7:0] exp1
);

reg [6:0] count;

always @(posedge clk) begin
    if (~reset) begin
        exp1 <= 8'd0;
        count <= 7'b0;
    end else if (count == 7'd25) begin
        exp1 <= 8'd100;
        count <= count + 7'd1;
    end else if (count == 7'd75) begin
        exp1 <= 8'b11111111;
        count <= count + 7'd1;
    end else if (count > 7'd75) begin
        count <= count + 7'd1;
        exp1 <= exp1 - 8'd1;
    end else begin
        count <= count + 7'd1;
        exp1 <= exp1 + 8'd1;
    end
end 
endmodule

module make_exp2 (
    input wire clk,
    input wire reset,
    output reg [7:0] exp2
);

reg [6:0] count;

always @(posedge clk) begin
    if (~reset) begin
        exp2 <= 8'd100;
        count <= 7'b0;
    end else if (count == 7'd30) begin
        exp2 <= 8'd0;
        count <= count + 7'd1;
    end else if (count == 7'd60) begin
        exp2 <= 8'b11111111;
        count <= count + 7'd1;
    end else if (count > 7'd60) begin
        count <= count + 7'd1;
        exp2 <= exp2 - 8'd1;
    end else begin
        count <= count + 7'd1;
        exp2 <= exp2 + 8'd1;
    end
end 
endmodule

module make_fra1 (
    input wire clk,
    input wire reset,
    output reg [22:0] fra1
);

reg [6:0] count;

always @(posedge clk) begin
    if (~reset) begin
        fra1 <= 23'd0;
        count <= 7'b0;
    end else if (count == 7'd40) begin
        fra1 <= 23'd1000000;
        count <= count + 7'd1;
    end else if (count == 7'd70) begin
        fra1 <= 23'h7fffff;
        count <= count + 7'd1;
    end else if (count > 7'd70) begin
        count <= count + 7'd1;
        fra1 <= fra1 - 23'd1;
    end else begin
        count <= count + 7'd1;
        fra1 <= fra1 + 23'd1;
    end
end 
endmodule

module make_fra2 (
    input wire clk,
    input wire reset,
    output reg [22:0] fra2
);

reg [6:0] count;

always @(posedge clk) begin
    if (~reset) begin
        fra2 <= 23'd1234567;
        count <= 7'b0;
    end else if (count == 7'd25) begin
        fra2 <= 23'h7fffff;
        count <= count + 7'd1;
    end else if (count == 7'd50) begin
        fra2 <= 23'd0;
        count <= count + 7'd1;
    end else if (count > 7'd25 && count < 7'd50) begin
        count <= count + 7'd1;
        fra2 <= fra2 - 23'd1;
    end else begin
        count <= count + 7'd1;
        fra2 <= fra2 + 23'd1;
    end
end 
endmodule
`default_nettype wire