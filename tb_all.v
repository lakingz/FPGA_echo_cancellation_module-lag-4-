/**************************************************************************
***                            Testbench ALL                            ***     
***                            Author :   LAK                           ***  
**************************************************************************/

`timescale 1us / 1us
module tb_all ();

reg clk_samplying,clk_operation;
reg rst,enable_MUTT,enable_MUTTT;
wire [15:0] sig16b;
wire [63:0] sig_double;
wire ready_MUTT;
wire [63:0] signal_lag;

initial begin
clk_samplying = 1;
clk_operation = 1;
rst = 1;
#200
rst = 0;
end

always #1000 clk_samplying = ~clk_samplying; //looks like we want # to be odd number.
always #1 clk_operation = ~clk_operation;


signal_generator MUT(
	.clk_samplying(clk_samplying),
		.signal(sig16b)
);

sig16b_to_double MUTT(
	.clk_operation(clk_operation),
	.rst(rst),
	.sig16b(sig16b),
	.enable(enable_MUTT),
		.double(sig_double),
		.ready(ready_MUTT)
);

lag_generator MUTTT(
	.rst(rst),
	.enable(enable_MUTTT),
	.clk_samplying(clk_samplying),
	.clk_operation(clk_operation),
	.signal(sig_double), 
		.signal_lag(signal_lag)
);

always @(posedge clk_samplying) begin
	enable_MUTT <= 1;
	enable_MUTTT <= 0;
	#2            //double operation clk       
	enable_MUTT <= 0;
end

always @(posedge clk_samplying) begin
	if (ready_MUTT) begin
		enable_MUTTT <= 1;
	end
end
/*echo_approx MUTTT(
.signal(signal_random), 
.signal_lag(signal_lag), 
.para_0(parat_0), 
.para_1(parat_1),
.para_2(parat_2)
);

assign para_0 = parat_0;
assign para_1 = parat_1;
assign para_2 = parat_2;
*/


endmodule //tb_all
