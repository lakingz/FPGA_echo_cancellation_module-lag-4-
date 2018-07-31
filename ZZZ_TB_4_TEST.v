`timescale 1us / 1us
module ZZZ_TB_4_TEST();

reg clk,rst;
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
reg [6:0] count;

initial clk = 0;
always #125 clk = ~clk;

fpu UUT (
	.clk(clk),
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
	count = 0;
	rst = 1'b1;
	#5000;
	rst = 1'b0;
	enable = 1'b1;//enable (set high to start operation)
	   // paste after this
	#500;
	enable = 1'b0;
	opa = 64'b0000000000000000000000000000000011001101000101110000011010100010;
	opb = 64'b0000000111000101011011100001111111000010111110001111001101011001;
	fpu_op = 3'b011;//fpu_op (operation code, 3 bits, 000 = add, 001 = subtract,010 = multiply, 011 = divide, others are not used)
	rmode = 2'b00;
end

always @(posedge clk) begin
if (ready) begin
	opa <= $urandom;
	opb <= out;
	enable <= 1'b1;
	#500;
	enable <= 1'b0;
end
end
endmodule //ZZZ_TB_4_TEST





