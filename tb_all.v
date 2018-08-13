/**************************************************************************
***                            Testbench ALL                            ***     
***                            Author :   LAK                           ***  
**************************************************************************/

`timescale 1us / 1us
module tb_all ();

reg clk_sampling,clk_operation;
reg rst,enable_MUT1,enable_MUT2,enable_MUT3;
wire [15:0] sig16b;
wire [63:0] sig_double;
wire ready_MUT1,ready_MUT2,ready_MUT3;
wire [63:0] signal_lag,signal_align;
reg [63:0] para_in_0,para_in_1,para_in_2,para_in_3;
wire [63:0] para_0,para_1,para_2,para_3;
wire [10:0] e_exp,normalize_amp_exp;
integer iteration;
reg enable_sampling_MUT2, enable_sampling_MUT3;

initial begin
clk_sampling = 1;
clk_operation = 1;
rst = 1;
#200
rst = 0;
para_in_0[63] = 0;
para_in_0[62:52] = 11'b01111111110;
para_in_0[51:0] = $urandom;

para_in_1[63] = 0;
para_in_1[62:52] = 11'b01111111110;
para_in_1[51:0] = $urandom;

para_in_2[63] = 0;
para_in_2[62:52] = 11'b01111111110;
para_in_2[51:0] = $urandom;

para_in_3[63] = 0;
para_in_3[62:52] = 11'b01111111110;
para_in_3[51:0] = $urandom;

iteration = 0;
end

always #4000 clk_sampling = ~clk_sampling; //sampling clk must be large enough!!!
always #1 clk_operation = ~clk_operation;


signal_generator MUT0(
	.clk_sampling(clk_sampling),
		.signal(sig16b)
);

sig16b_to_double MUT1(
	.clk_operation(clk_operation),
	.rst(rst),
	.sig16b(sig16b),
	.enable(enable_MUT1),
		.double(sig_double),
		.ready(ready_MUT1)
);

lag_generator MUT2(
	.rst(rst),
	.enable_sampling(enable_sampling_MUT2),
	.enable(enable_MUT2),
	.clk_sampling(clk_sampling),
	.clk_operation(clk_operation),
	.signal(sig_double), 
	.para_0(para_in_0), 
	.para_1(para_in_1), 
	.para_2(para_in_2), 
	.para_3(para_in_3),
		.signal_lag(signal_lag),
		.signal_align(signal_align),
		.ready(ready_MUT2)
);

echo_approx MUT3(
	.rst(rst),
	.clk_sampling(clk_sampling),
	.clk_operation(clk_operation),
	.enable_sampling(enable_sampling_MUT3),
	.enable(enable_MUT3),
	.signal(signal_align), 
	.signal_lag(signal_lag),
	.gamma(64'b0011111111010000000000000000000000000000000000000000000000000000), 
//default      64'b0 01111111101 0000000000000000000000000000000000000000000000000000; //0.01
	.mu(64'b0011111111110000000000000000000000000000000000000000000000000000),	 
//default   64'b0 01111111111 0000000000000000000000000000000000000000000000000000; //1
		.para_0(para_0), 
		.para_1(para_1), 
		.para_2(para_2),
		.para_3(para_3),
		.e_exp(e_exp),
		.normalize_amp_exp(normalize_amp_exp),
		.ready(ready_MUT3)
);

initial begin
	enable_sampling_MUT2 <= 0;
	enable_sampling_MUT3 <= 0;
	#8000;	
	enable_sampling_MUT2 <= 1;
	enable_sampling_MUT3 <= 0;
	#8000;
	enable_sampling_MUT2 <= 1;
	enable_sampling_MUT3 <= 1;
end
always @(posedge clk_sampling) begin
	enable_MUT1 <= 1;
	#2            //double operation clk       
	enable_MUT1 <= 0;
	#16
	if (ready_MUT1) begin
		enable_MUT2 <= 1;
		#4 
		enable_MUT2 <= 0;
$display(
"##iteration: %d", iteration
);
	end
	#1200
	if (ready_MUT2) begin
		enable_MUT3 <= 1;
		#4 
		enable_MUT3 <= 0;
	end
	#2500
	if (ready_MUT3) begin
	iteration <= iteration + 1;
	end
end
endmodule //tb_all
