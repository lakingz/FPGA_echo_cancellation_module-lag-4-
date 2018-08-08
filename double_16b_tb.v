`timescale 1us / 1us
module double_16b_tb();

reg [15:0] sig16b_in;
reg clk_samplying,rst,clk_operation;
reg enable_MUT,enable_MUTT;
wire [63:0] double;
wire [15:0] sig16b_out;


always #200 clk_samplying = ~clk_samplying;
always #1 clk_operation = ~clk_operation;

initial begin
	rst = 1;
	#200
	rst = 0;
	clk_samplying = 1;
	clk_operation = 1;
	enable_MUTT = 1;
end

sig16b_to_double MUT (
	.clk_operation(clk_operation),
	.rst(rst),
	.sig16b(sig16b_in),
	.double(double),
	.ready(ready),
	.enable(enable_MUT)
);

double_to_sig16b MUTT(
	.clk_samplying(clk_operation),
	.rst(rst),
	.sig16b(sig16b_out),
	.double(double),
	.enable(enable_MUTT)
);

always @(posedge clk_samplying) begin
	sig16b_in <= $urandom;
	enable_MUT <= 1;
	#10
	enable_MUT <= 0;
end



endmodule //double_16b_tb
