
module STACKMODULE_TEST(clk, rst, a, b, c, mod, enable, ready);

input [2:0] a,b;
	output reg [2:0] c;
input clk,rst;
input mod,enable;
	output reg ready; //1 for ready, 0 for not;
reg [1:0] phase;


always @(posedge clk) begin
if (enable == 1) begin//enable == 1 (enable), enable == 0 (not enable)
	if (rst == 1) begin // 1 for rst, 0 for not rst.
		phase <= 0;
		ready <= 0;
	end
	else  if (phase == 0) begin
		phase <= 1;
		c <= a;	
		ready <= 0;
	end
	else  if (phase == 1) begin
		phase <= 2;
	end
	else  if (phase == 2) begin
		phase <= 3;
	end
	else if (phase == 3) begin
		if (mod == 0) c <= a+b;
		else c <= a-b;
		ready <= 1;
		phase <= 0;
	end
end
end

endmodule //STACKMODULE_TEST