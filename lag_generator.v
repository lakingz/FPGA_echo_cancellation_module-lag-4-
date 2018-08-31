/**************************************************************************
***                     Lag Signal Generator (500ns/20ns)               ***     
***                  For testing. We create a lag signal                ***
***                            Author :   LAK                           ***  
**************************************************************************/
//take 4 sampling clks + 260 operation clks (130 cycle) to complete


`timescale 1us/1us
module lag_generator(
rst,
enable_sampling,
enable,
sampling_cycle_counter,
clk_operation,
signal, 
para_0, 
para_1, 
para_2, 
para_3,
	signal_lag,
	signal_align,
	ready
);

input [63:0] signal;
output reg [63:0] signal_lag,signal_align;
output reg ready;
input [12:0] sampling_cycle_counter;
input clk_operation,rst,enable,enable_sampling;
input [63:0] para_0,para_1,para_2,para_3;

reg enable_internal;
reg enable_U0,enable_U1;
reg [1:0]rmode_U0,rmode_U1;
reg [2:0]fpu_op_U0,fpu_op_U1;
reg [63:0]opa_U0,opa_U1;
reg [63:0]opb_U0,opb_U1;
wire [63:0]out_U0,out_U1;
wire ready_U0,ready_U1;
wire underflow;
wire overflow;
wire inexact;
wire exception;
wire invalid;  

reg [2:0] count_sampling,count_operation;
reg [63:0] lag_0,lag_1,lag_2,lag_3;
reg [63:0] lp0,lp1,lp2,lp3;
reg [63:0] lp0_1,lp2_3;

always @(posedge clk_operation) begin
	if (rst) begin 
		//lag_3 <= 0;
		//lag_2 <= 0;
		//lag_1 <= 0;
		//lag_0 <= 0;	
		//para_0 <= $urandom;
		//para_1 <= $urandom;
		//para_2 <= $urandom;
		//para_3 <= $urandom;
		count_sampling <= 0;
		enable_internal <= 0;
	end

	if (enable) begin
		enable_internal <= 1;
		ready <= 0;
	end
end

//the sampling is enabled even the module is not.
always @(posedge clk_operation) begin
	if (sampling_cycle_counter == 0) begin
		if (~rst) begin	
		if (enable_sampling) begin
			case (count_sampling)
			0: begin
				lag_0 <= signal;
				count_sampling <= 1;
				signal_align <= signal; 
			end
			1: begin
				lag_1 <= lag_0;
				lag_0 <= signal;
				count_sampling <= 2;
				signal_align <= signal; 
			end
			2: begin
				lag_2 <= lag_1;
				lag_1 <= lag_0;
				lag_0 <= signal;
				count_sampling <= 3;
				signal_align <= signal; 
			end
			3: begin
				lag_3 <= lag_2;
				lag_2 <= lag_1;
				lag_1 <= lag_0;
				lag_0 <= signal;
				count_operation <= 0;
				signal_align <= signal; //we delay samply to align with the lag.
/*$display(
"##lag_3: %b", lag_3,
"##lag_2: %b", lag_2,
"##lag_1: %b", lag_1,
"##lag_0: %b", lag_0,
"##signal_align: %b", signal_align
);*/
			end	
			default:;	
			endcase
		end
		end
	end
end

//always@(*) signal_lag_sum = ((lag_3 * para_3 + lag_2 * para_2 + lag_1 * para_1 + lag_0 * para_0);
always @(posedge clk_operation) begin
	if (~rst) begin	
	if (enable_internal) begin 

		case (count_operation)
		0: begin
			opa_U0 <= lag_0;
			opb_U0 <= para_0;
			fpu_op_U0 <= 3'b010; //out = lag_0*para_0
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;
	
			opa_U1 <= lag_1;
			opb_U1 <= para_1;
			fpu_op_U1 <= 3'b010; //out = lag_1*para_1
			rmode_U1 = 2'b00;
			enable_U1 <= 1'b1;

			#4;
			enable_U0 <= 1'b0;
			enable_U1 <= 1'b0;
			
			#60;

			if (ready_U0&ready_U1 == 1) begin
				lp0 <= out_U0;
				lp1 <= out_U1;
				count_operation <= 1;
			end
		end
		1:begin
			opa_U0 <= lag_2;
			opb_U0 <= para_2;
			fpu_op_U0 <= 3'b010; //out = lag_2*para_2
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;
	
			opa_U1 <= lag_3;
			opb_U1 <= para_3;
			fpu_op_U1 <= 3'b010; //out = lag_3*para_3
			rmode_U1 = 2'b00;
			enable_U1 <= 1'b1;
			
			#4;
			enable_U0 <= 1'b0;
			enable_U1 <= 1'b0;
			
			#60;

			if (ready_U0&ready_U1 == 1) begin
				lp2 <= out_U0;
				lp3 <= out_U1;
				count_operation <= 2;
			end

		end
		2: begin
			opa_U0 <= lp0;
			opb_U0 <= lp1;
			fpu_op_U0 <= 3'b000; //out = lag_0*para_0 + lag_1*para_1
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;
	
			opa_U1 <= lp2;
			opb_U1 <= lp3;
			fpu_op_U1 <= 3'b000; //out = lag_2*para_2 + lag_3*para_3
			rmode_U1 = 2'b00;
			enable_U1 <= 1'b1;						
			#4;

			enable_U0 <= 1'b0;
			enable_U1 <= 1'b0;
			
			#60;
		
			if (ready_U0&ready_U1 == 1) begin
				lp0_1 <= out_U0;
				lp2_3 <= out_U1;
				count_operation <= 3;			
			end
		end	
		3: begin
			opa_U0 <= lp0_1;
			opb_U0 <= lp2_3;
			fpu_op_U0 <= 3'b000; //out = lag_0*para_0 + lag_1*para_1+lag_2*para_2 + lag_3*para_3
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;

			#4;
			enable_U0 <= 1'b0;
			
			#60;
		
			if (ready_U0== 1) 
			begin
				count_operation <= 4;
				signal_lag <= out_U0; 
				enable_internal <= 0;
				ready <= 1;
			end
		end
		
/*$display(
//" ##count_sampling:",count_sampling,
" ##count_operation:",count_operation,
" ##lag_0: %b", lag_0[63:52],
" ##lag_1: %b", lag_1[63:52],
" ##lag_2: %b", lag_2[63:52],
" ##lag_3: %b", lag_3[63:52],
" ##top: %b", out_U0[63:52],
" ##down: %b", out_U1[63:52]
);*/
		4: begin
			enable_U0 <= 1'b0;
			enable_U1 <= 1'b0;
		end
		default:;
		endcase
	end
	end
end	

// fpu modules *4
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


//fpu_op (operation code, 3 bits, 000 = add, 001 = subtract,010 = multiply, 011 = divide, others are not used)
endmodule // lag_generator  	



