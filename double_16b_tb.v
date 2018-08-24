`timescale 1us / 1us
module double_16b_tb();

reg [15:0] sig16b_in,sig16b_align;
reg rst,clk_operation;
reg enable_MUT,enable_MUTT;
wire [63:0] double;
wire [15:0] sig16b_out;
reg [12:0] sampling_cycle, sampling_cycle_counter;
reg sampling_light;

always #1 begin
	clk_operation <= ~clk_operation;
	sampling_cycle_counter <= sampling_cycle_counter + 1;
		if (sampling_cycle_counter >= sampling_cycle - 1) begin
			sampling_cycle_counter <= 0;
			sampling_light <= 1;
		end
		else sampling_light <= 0;
end

initial begin
	clk_operation = 1;
	sampling_cycle = 40;
	sampling_cycle_counter = 0;
	rst = 1;
	#200
	rst = 0;
	enable_MUTT = 1;
end


sig16b_to_double MUT(
	.clk_operation(clk_operation),
	.rst(rst),
	.sig16b(sig16b_in),
	.enable(enable_MUT),
		.double(double),
		.ready(ready)
);

double_to_sig16b MUTT(
	.sampling_cycle_counter(sampling_cycle_counter),
	.clk_operation(clk_operation),
	.rst(rst),
	.enable(enable_MUTT),		
	.double(double),
		.sig16b(sig16b_out)
);
always @(posedge clk_operation) begin
	if (sampling_cycle_counter == 0) begin
		sig16b_in <= $urandom;
		sig16b_align <= sig16b_in;
		enable_MUT <= 1;
		#4 
		enable_MUT <= 0;
		#16
		if (ready) begin
			enable_MUTT <= 1;
		end
		else enable_MUTT <= 0;
	end
end



endmodule //double_16b_tb
