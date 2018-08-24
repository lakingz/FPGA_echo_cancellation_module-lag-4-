`timescale 1us / 1us
module ZZZ_TB_4_TEST();

reg [4:0] count,cycle;
reg clk;
integer sampling_count;
reg [3:0] random;

initial begin
clk = 1;
count = 0;
cycle = 4;
sampling_count = 0;
end

always #1 begin
clk <= ~clk;
count <= count + 1;
	if (count == cycle - 1) count <= 0;
end

always @(posedge clk) begin
	if (count == 0) begin
		sampling_count = sampling_count + 1;	
		random <= $random;
	end
end
endmodule//TEST
