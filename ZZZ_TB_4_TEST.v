`timescale 1us / 1us
module ZZZ_TB_4_TEST();

reg clk_samplying,clk_operation,rst;
reg enable;
reg [1:0]rmode;
reg [2:0]fpu_op;
reg [63:0]opa;
reg [63:0]opb;
wire [63:0]out;
wire ready;
wire underflow;
wire overflow;
wire inexact;
wire exception;
wire invalid;  

initial begin
clk_samplying = 0;
clk_operation = 0;
end
always #200 clk_samplying = ~clk_samplying;
always #1 clk_operation = ~clk_operation;

fpu UUT (
	.clk(clk_operation),
	.rst(rst),
	.enable(enable),
	.rmode(rmode),
	.fpu_op(fpu_op),
	.opa(opa),
	.opb(opb),
		.out(out),
		.ready(ready),
		.underflow(underflow),
		.overflow(overflow),
		.inexact(inexact),
		.exception(exception),
		.invalid(invalid));
initial
begin 
	#0;
	rst = 1'b1;
	#40;
	rst = 1'b0;
	enable = 1'b1;//enable (set high to start operation)
	   // paste after this
	opa = 64'b0000000000000000000000000000000011001101000101110000011010100010;
	opb = 64'b0000000111000101011011100001111111000010111110001111001101011001;
	fpu_op = 3'b011;//fpu_op (operation code, 3 bits, 000 = add, 001 = subtract,010 = multiply, 011 = divide, others are not used)
	rmode = 2'b00;
	#4;
	enable = 1'b0;
	#160;	
end

always @(posedge clk_samplying) begin
if (ready) begin
	opa <= $urandom;
	opb <= out;
	fpu_op <= $urandom;
	rmode = 2'b00;
	enable <= 1'b1;
	#4;
	enable <= 1'b0;
end
end
endmodule //ZZZ_TB_4_TEST


