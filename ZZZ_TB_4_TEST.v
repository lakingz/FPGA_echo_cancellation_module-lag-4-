`timescale 1us / 1us
module ZZZ_TB_4_TEST();

reg [15:0] sig,sigg;
reg clk,rst;
wire [63:0] double,doublee;
wire stop;

always #125 clk = ~clk;

initial begin
	clk = 1;
	rst = 1;
	sig = 16'b0000000000001001;
	sigg = 16'b0000000000000001;
end

sig16b_to_double MUT (
	.clk(clk),
	.rst(rst),
	.sig16b(sig),
	.double(double),
	.stop(stop)
);
sig16b_to_double MUTT (
	.clk(clk),
	.rst(rst),
	.sig16b(sigg),
	.double(doublee),
	.stop(stop)
);

always @(stop) rst <= 0;

endmodule //ZZZ_TB_4_TEST