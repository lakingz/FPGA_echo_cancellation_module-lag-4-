`timescale 1us / 1us
module double_16b_tb();

reg [15:0] sig_in;
reg clk,rst;
wire [63:0] double;
wire stop;
wire [15:0] sig_out;

always #125 clk = ~clk;

initial begin
	clk = 1;
	rst = 1;
	sig_in = 16'b0000000000001001;
end

sig16b_to_double MUT (
	.clk(clk),
	.rst(rst),
	.sig16b(sig_in),
	.double(double),
	.stop(stop)
);

double_to_sig16b MUTT (
	.clk(clk),
	.rst(rst),
	.sig16b(sig_out),
	.double(double)
);

always @(stop) rst <= 0;

endmodule //double_16b_tb
