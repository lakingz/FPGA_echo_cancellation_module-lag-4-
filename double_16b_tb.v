`timescale 1us / 1us
module double_16b_tb();

reg [15:0] sig_in;
reg clk,rst;
wire [63:0] double;
wire stop;
wire [15:0] sig_out;

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
begin : STIMUL 
	#0			  
	count = 0;
	rst = 1'b1;
	#500;
	rst = 1'b0;	   // paste after this
//inputA:1.6999999999e-314
//inputB:4.0000000000e-300
enable = 1'b1;
opa = 64'b0000000000000000000000000000000011001101000101110000011010100010;
opb = 64'b0000000111000101011011100001111111000010111110001111001101011001;
fpu_op = 3'b011;//fpu_op (operation code, 3 bits, 000 = add, 001 = subtract,010 = multiply, 011 = divide, others are not used)
rmode = 2'b00;
#500;
enable = 1'b0;//enable (set high to start operation)
#20000;
//Output:4.249999999722977e-015
end

always #125 clk = ~clk;

initial begin
	clk = 0;
end

/*sig16b_to_double MUT (
	.clk(clk),
	.rst(rst),
	.sig16b(sig_in),
	.double(double),
	.stop(stop)
);

double_to_sig16b MUTT (
	.clk(clk),
	.rst(rst),
	.sig16b(sig_out),
	.double(double)
);
always @(stop) rst <= 0;*/

endmodule //double_16b_tb
