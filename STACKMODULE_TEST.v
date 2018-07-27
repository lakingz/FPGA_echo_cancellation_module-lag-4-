
module STACKMODULE_TEST(clk, a, b, c, mod, enable);

input [2:0] a,b;
output reg [2:0] c;
input clk;
input mod,enable;

always @(posedge clk) begin
if (enable == 1) begin //enable == 1 (enable), enable == 0 (not enable)
	if (mod == 0) c <= a+b;
	else c <= a-b;
end
else c <= 0;
end

endmodule //STACKMODULE_TEST