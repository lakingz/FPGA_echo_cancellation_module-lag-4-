`timescale 1us / 1us
module ZZZ_TB_4_TEST();

reg clk_operation,rst,sampling_cycle_counter,enable_sampling_MUT3,enable_MUT3;
integer sampling_count;
reg [64:0] sig_double,sig_lag_double;

initial begin
rst <= 1;
#4;
rst <= 0;
clk_operation = 1;
sampling_cycle_counter <= 0;
enable_sampling_MUT3 <= 1;
enable_MUT3 <= 1;
sig_double <= 0;
sig_lag_double <= 0;
end

always #1 begin
clk_operation <= ~clk_operation;
end

always #620 begin
sampling_cycle_counter <= 1;
#1
sampling_cycle_counter <= 0;
end


para_approx MUT3(           //4 sampling #620 operation
	.rst(rst),
	.sampling_cycle_counter(sampling_cycle_counter),
	.clk_operation(clk_operation),
	.enable_sampling(enable_sampling_MUT3),
	.enable(enable_MUT3),
	.signal(sig_double), 
	.signal_lag(sig_lag_double),
	.gamma(64'b0011111111010000000000000000000000000000000000000000000000000000), 
//default      64'b0 01111111101 0000000000000000000000000000000000000000000000000000; //0.01
	.mu(64'b0011111111110000000000000000000000000000000000000000000000000000),	 
//default   64'b0 01111111111 0000000000000000000000000000000000000000000000000000; //1
		.para_0(para_approx_0), 
		.para_1(para_approx_1), 
		.para_2(para_approx_2),
		.para_3(para_approx_3),
		.e(e),
		.e_exp(e_exp),
		.normalize_amp_exp(normalize_amp_exp),
		.ready(ready_MUT3)
);
endmodule//TEST
