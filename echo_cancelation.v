/**************************************************************************
***                          Echo approximation                         ***                       
***                            Author :   LAK                           ***  
**************************************************************************/
//4 sampling clks 250 operation clks (125 cycles)


`timescale 1us/1us
module echo_cancelation(
rst,
sampling_cycle_counter,
clk_operation,
enable_sampling,
enable,
signal_receive,
signal_send, 
para_0, 
para_1, 
para_2,
para_3,
	signal_without_echo,
	signal_without_echo_exp,
	ready
);

input [63:0] signal_send,signal_receive;
input [12:0] sampling_cycle_counter;
input clk_operation,rst,enable,enable_sampling;
input [63:0] para_0,para_1,para_2,para_3;
output reg ready;
output reg [63:0] signal_without_echo;
output reg [10:0] signal_without_echo_exp;

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

reg [2:0] count_sampling;
reg [3:0] count_operation;
reg [63:0] lag_0,lag_1,lag_2,lag_3;
reg [63:0] signal_receive_align,signal_lag_approx;
reg [63:0] lp_0,lp_1,lp_2,lp_3;
reg [63:0] lp_01,lp_23;

always @(posedge clk_operation) begin
	if (rst) begin 
		//lag_3 <= 0;
		//lag_2 <= 0;
		//lag_1 <= 0;
		//lag_0 <= 0;	
		count_sampling <= 0;
		enable_internal <= 0;
		signal_without_echo <= 0;
	end

	if (enable) begin
		enable_internal <= 1;
		ready <= 0;
	end
end

//the sampling and alignment. 
always @(posedge clk_operation) begin
	if (sampling_cycle_counter == 0) begin
		if (~rst) begin	
		if (enable_sampling) begin
			case (count_sampling)
			0: begin
				lag_0 <= signal_send;
				signal_receive_align <= signal_receive; //signa alignment;
				count_sampling <= 1;				
			end
			1: begin
				lag_1 <= lag_0;
				lag_0 <= signal_send;
				signal_receive_align <= signal_receive;
				count_sampling <= 2;
			end
			2: begin
				lag_2 <= lag_1;
				lag_1 <= lag_0;
				lag_0 <= signal_send;
				signal_receive_align <= signal_receive;
				count_sampling <= 3;
			end
			3: begin
				lag_3 <= lag_2;
				lag_2 <= lag_1;
				lag_1 <= lag_0;
				lag_0 <= signal_send;
				signal_receive_align <= signal_receive;
				count_operation <= 0;
/*$display(
"##lag_3: %b", lag_3,
"##lag_2: %b", lag_2,
"##lag_1: %b", lag_1,
"##lag_0: %b", lag_0,
"##signal_lag_align: %b", signal_lag_align
);*/
			end		
			default:;
			endcase
		end
		end
	end
end

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

			#4

			enable_U0 <= 1'b0;			
			enable_U1 <= 1'b0;
	
			#60

			if (ready_U0&ready_U1 == 1) 
			begin
				count_operation <= 1;
				lp_0 <= out_U0;
				lp_1 <= out_U1;			
			end
		end
		1: begin
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

			#4

			enable_U0 <= 1'b0;			
			enable_U1 <= 1'b0;
	
			#60

			if (ready_U0&ready_U1 == 1) 
			begin
				count_operation <= 2;
				lp_2 <= out_U0;
				lp_3 <= out_U1;			
			end
		end
		2: begin
			opa_U0 <= lp_0;
			opb_U0 <= lp_1;
			fpu_op_U0 <= 3'b000; //out = lag_0*para_0+lag_1*para_1
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;

			opa_U1 <= lp_2;
			opb_U1 <= lp_3;
			fpu_op_U1 <= 3'b000; //out = lag_2*para_2+lag_3*para_3
			rmode_U1 = 2'b00;
			enable_U1 <= 1'b1;

			#4

			enable_U0 <= 1'b0;			
			enable_U1 <= 1'b0;
	
			#60

			if (ready_U0&ready_U1 == 1) 
			begin
				count_operation <= 3;
				lp_01 <= out_U0;
				lp_23 <= out_U1;			
			end
		end
		3: begin		
/*$display(
"##e: %b", e,
"##e_exp: %d", e_exp,
"##normalize_amp: %b", normalize_amp,
"##normalize_amp: %d", normalize_amp
);	*/
			opa_U0 <= lp_01;
			opb_U0 <= lp_23;
			fpu_op_U0 <= 3'b000; //out = lag_0*para_0+lag_1*para_1+lag_2*para_2+lag_3*para_3
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;
			#4

			enable_U0 <= 1'b0;	
		
			#60

			if (ready_U0 == 1) begin
				count_operation <= 4;	
				signal_lag_approx <= out_U0;
			end
		end	
		4: begin
			opa_U1 <= signal_receive_align;
			opb_U1 <= signal_lag_approx;
			fpu_op_U1 <= 3'b001; //out = signal without echo
			rmode_U1 = 2'b00;
			enable_U1 <= 1'b1;

			#4

			enable_U1 <= 1'b0;
	
			#60

			if (ready_U1 == 1) 
			begin
				count_operation <= 5;	
				signal_without_echo <= out_U1;
				signal_without_echo_exp <= out_U1[62:52] - 1023;
				enable_internal <= 0;
				ready <= 1;
			end
		end
		5: begin
			enable_U0 <= 1'b0;
			enable_U1 <= 1'b0;
		end
		default:;
		endcase
	end
	end
end	

// fpu modules *2
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
endmodule // echo_cancelation

