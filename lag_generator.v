/**************************************************************************
***                     Lag Signal Generator (500ns/20ns)               ***     
***                  For testing. We create a lag signal                ***
***                            Author :   LAK                           ***  
**************************************************************************/

//we first look at 3 lag with parameter 1 2 1


`timescale 1us/1us
module lag_generator(
rst,
clk_samplying,
clk_operation,
signal, 
signal_lag);

input [63:0] signal;
output reg [63:0] signal_lag;
input clk_samplying,clk_operation,rst;
reg enable_U0,enable_U1,enable_U2,enable_U3;
reg [1:0]rmode_U0,rmode_U1,rmode_U2,rmode_U3;
reg [2:0]fpu_op_U0,fpu_op_U1,fpu_op_U2,fpu_op_U3;
reg [63:0]opa_U0,opa_U1,opa_U2,opa_U3;
reg [63:0]opb_U0,opb_U1,opb_U2,opb_U3;
wire [63:0]out_U0,out_U1,out_U2,out_U3;
wire ready_U0,ready_U1,ready_U2,ready_U3;
wire underflow;
wire overflow;
wire inexact;
wire exception;
wire invalid;  

reg [2:0] count_samplying, count_operation;
reg [63:0] lag_0,lag_1,lag_2,lag_3;
reg [63:0] para_0,para_1,para_2,para_3;
//real tt;

always @(posedge clk_samplying) begin
	if (rst) begin 
		count_samplying <= 0;
		count_operation <= 4;
		lag_3 <= signal;
		lag_2 <= 0;
		lag_1 <= 0;
		lag_0 <= 0;	
		para_0 <= $urandom;
		para_1 <= $urandom;
		para_2 <= $urandom;
		para_3 <= $urandom;
	end
	case (count_samplying)
	0: begin
		lag_2 <= signal;
		count_samplying <= 1;
	end
	1: begin
		lag_1 <= signal;
		count_samplying <= 2;
	end	
	2: begin
		lag_0 <= signal;
		count_samplying <= 3;
	end
	3: begin
		lag_3 <= lag_2;
		lag_2 <= lag_1;
		lag_1 <= lag_0;
		lag_0 <= signal;
	end
	endcase
	count_operation <= 0; ////!!!!operation must must be finished before new sample.
end

fpu U0 (
	.clk(clk_operation),
	.rst(rst),
	.enable(enable_U0),
	.rmode(rmode_U0),
	.fpu_op(fpu_op_U0),
	.opa(opa_U0),
	.opb(opb_U0),
		.out(out_U0),
		.ready(ready_U0),
		.underflow(underflow),
		.overflow(overflow),
		.inexact(inexact),
		.exception(exception),
		.invalid(invalid));

fpu U1 (
	.clk(clk_operation),
	.rst(rst),
	.enable(enable_U1),
	.rmode(rmode_U1),
	.fpu_op(fpu_op_U1),
	.opa(opa_U1),
	.opb(opb_U1),
		.out(out_U1),
		.ready(ready_U1),
		.underflow(underflow),
		.overflow(overflow),
		.inexact(inexact),
		.exception(exception),
		.invalid(invalid));

fpu U2 (
	.clk(clk_operation),
	.rst(rst),
	.enable(enable_U2),
	.rmode(rmode_U2),
	.fpu_op(fpu_op_U2),
	.opa(opa_U2),
	.opb(opb_U2),
		.out(out_U2),
		.ready(ready_U2),
		.underflow(underflow),
		.overflow(overflow),
		.inexact(inexact),
		.exception(exception),
		.invalid(invalid));
fpu U3 (
	.clk(clk_operation),
	.rst(rst),
	.enable(enable_U3),
	.rmode(rmode_U3),
	.fpu_op(fpu_op_U3),
	.opa(opa_U3),
	.opb(opb_U3),
		.out(out_U3),
		.ready(ready_U3),
		.underflow(underflow),
		.overflow(overflow),
		.inexact(inexact),
		.exception(exception),
		.invalid(invalid));
//fpu_op (operation code, 3 bits, 000 = add, 001 = subtract,010 = multiply, 011 = divide, others are not used)

always @(posedge clk_operation) begin
	case (count_operation)
	0: begin
		opa_U0 <= lag_0;
		opb_U0 <= para_0;
		fpu_op_U0 <= 3'b010; //lag_0*para_0
		rmode_U0 = 2'b00;
		enable_U0 <= 1'b1;
		#4;
		enable_U0 <= 1'b0;

		opa_U1 <= lag_1;
		opb_U1 <= para_1;
		fpu_op_U1 <= 3'b010; //lag_1*para_1
		rmode_U1 = 2'b00;
		enable_U1 <= 1'b1;
		#4;

		enable_U2 <= 1'b0;
		opa_U2 <= lag_2;
		opb_U2 <= para_2;
		fpu_op_U2 <= 3'b010; //lag_2*para_2
		rmode_U2 = 2'b00;
		enable_U2 <= 1'b1;
		#4;
		enable_U2 <= 1'b0;

		opa_U3 <= lag_3;
		opb_U3 <= para_3;
		fpu_op_U3 <= 3'b010; //lag_3*para_3
		rmode_U3 = 2'b00;
		enable_U3 <= 1'b1;
		#4;
		enable_U3 <= 1'b0;
		
		if (ready_U0&ready_U1&ready_U2&ready_U3 == 1) count_operation <= 1;
	end
	1: begin
		opa_U0 <= out_U0;
		opb_U0 <= out_U1;
		fpu_op_U0 <= 3'b000; //lag_0*para_0 + lag_1*para_1
		rmode_U0 = 2'b00;
		enable_U0 <= 1'b1;
		#4;
		enable_U0 <= 1'b0;

		opa_U1 <= out_U2;
		opb_U1 <= out_U3;
		fpu_op_U1 <= 3'b000; //lag_2*para_2 + lag_3*para_3
		rmode_U1 = 2'b00;
		enable_U1 <= 1'b1;
		#4;
		enable_U1 <= 1'b0;

		opa_U2 <= para_0;
		opb_U2 <= para_1;
		fpu_op_U2 <= 3'b000; //para_0+para+1
		rmode_U2 = 2'b00;
		enable_U2 <= 1'b1;
		#4;
		enable_U2 <= 1'b0;

		opa_U3 <= para_2;
		opb_U3 <= para_3;
		fpu_op_U3 <= 3'b000; //para_2+para+3
		rmode_U3 = 2'b00;
		enable_U3 <= 1'b1;
		#4;
		enable_U3 <= 1'b0;
	
		if (ready_U0&ready_U1&ready_U2&ready_U3 == 1) count_operation <= 2;
	end	
	2: begin
		opa_U0 <= out_U0;
		opb_U0 <= out_U1;
		fpu_op_U0 <= 3'b000; //lag_0*para_0 + lag_1*para_1+lag_2*para_2 + lag_3*para_3
		rmode_U0 = 2'b00;
		enable_U0 <= 1'b1;
		#4;
		enable_U0 <= 1'b0;

		opa_U1 <= out_U2;
		opb_U1 <= out_U3; 
		fpu_op_U1 <= 3'b000; //para_0+para_1+para_2+para+3
		rmode_U1 = 2'b00;
		enable_U1 <= 1'b1;
		#4;
		enable_U1 <= 1'b0;
	
		if (ready_U0&ready_U1 == 1) count_operation <= 3;
	end
	3: begin
		opa_U3 <= out_U0;
		opb_U3 <= out_U1;
		fpu_op_U3 <= 3'b011; //lag_0*para_0 + lag_1*para_1+lag_2*para_2 + lag_3*para_3
		rmode_U3 = 2'b00;
		enable_U3 <= 1'b1;
		#4;
		enable_U3 <= 1'b0;
		
		if (ready_U3 == 1) begin
			signal_lag <= out_U0; 
			count_operation <= 4;
		end
	end
	endcase
end

//always@(lag_0 or lag_1 or lag_2) signal_lag_sum = ((lag_3 * 0.1 + lag_2 * 0.2 + lag_1 * 0.3 + lag_0 * 0.5)/ (0.1+0.2+0.3+0.5));

endmodule // lag_generator  	



