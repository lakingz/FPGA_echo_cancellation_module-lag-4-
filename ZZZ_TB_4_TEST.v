`timescale 1us / 1us
module ZZZ_TB_4_TEST();

reg [15:0] sig;
reg clk,rst;
wire [63:0] double;
wire stop;

always #125 clk = ~clk;

initial begin
	clk = 1;
	rst = 1;
	sig = $urandom;
end

sig16b_to_double MUTTT (
	.clk(clk),
	.rst(rst),
	.sig16b(sig),
	.double(double),
	.stop(stop)
);

always @(negedge stop) rst <= 0;
always @(posedge stop) rst <= 1;

endmodule //ZZZ_TB_4_TEST