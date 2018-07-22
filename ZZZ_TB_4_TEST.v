`timescale 1us / 1us
module ZZZ_TB_4_TEST();

reg [15:0] sig,sig1,sig2;
reg clk;
wire [63:0] double;
reg stop,prestop;
reg [3:0] shift;

always #125 clk = ~clk;

initial begin
	clk = 1;
	sig = 16'b1010101010101010;
	shift = 4'b1111 + 5'b00001;
end

always @(posedge clk) begin
sig1 <= sig << (4'b0100 - 2);
sig2 <= sig << (shift);
stop <= 1;
prestop <= 0;
end

always @(stop == 1) prestop <= 1;
always @(prestop == 1) stop <= 0;


endmodule //ZZZ_TB_4_TEST