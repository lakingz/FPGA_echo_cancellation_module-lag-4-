/**************************************************************************
***                          para approximation                         ***                       
***                            Author :   LAK                           ***  
**************************************************************************/
//4 sampling clks 500 operation clks(250 cycle)


`timescale 1us/1us
module para_approx(
rst,
sampling_cycle_counter,
clk_operation,
enable_sampling,
enable,
signal, 
signal_lag,
gamma,   //default 64'b0 01111111101 0000000000000000000000000000000000000000000000000000; //0.01
mu,	 //default 64'b0 01111111111 0000000000000000000000000000000000000000000000000000; //1
	para_0, 
	para_1, 
	para_2,
	para_3,
	e,
	e_exp,
	normalize_amp_exp,
	ready
);

input [63:0] signal,signal_lag;
input [12:0] sampling_cycle_counter;
input clk_operation,rst,enable,enable_sampling;
input [63:0] gamma;
input [63:0] mu;
output reg [63:0] para_0,para_1,para_2,para_3;
output reg ready;
output reg [10:0] e_exp,normalize_amp_exp;
output reg [63:0] e;

reg enable_internal;
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

reg [2:0] count_sampling;
reg [3:0] count_operation;
reg [63:0] lag_0,lag_1,lag_2,lag_3;
reg [63:0] signal_lag_align;

reg [63:0] lp_0,lp_1,lp_2,lp_3;						//count_operation == 0
reg [63:0] lp_01,lp_23,ll_0,ll_1;					//count_operation == 1
reg [63:0] lp_0123,ll_2,ll_3,ll_01;					//count_operation == 2
reg [63:0] ll_23,gamma_ll_01;						//count_operation == 3
reg [63:0] normalize_amp,e_mu;						//count_operation == 4
reg [63:0] e_mu_lag_0,e_mu_lag_1,e_mu_lag_2,e_mu_lag_3;			//count_operation == 5
reg [63:0] D_para_0,D_para_1,D_para_2,D_para_3;				//count_operation == 6




always @(posedge clk_operation) begin
	if (rst) begin 
		lag_3 <= 0;
		lag_2 <= 0;
		lag_1 <= 0;
		lag_0 <= 0;	
		signal_lag_align <= 0;
		para_0 <= 64'b0000000000010000000000000000000000000000000000000000000000000000;
		para_1 <= 64'b0000000000010000000000000000000000000000000000000000000000000000;
		para_2 <= 64'b0000000000010000000000000000000000000000000000000000000000000000;
		para_3 <= 64'b0000000000010000000000000000000000000000000000000000000000000000;
		count_sampling <= 0;
		enable_internal <= 0;
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
				lag_0 <= signal;
				count_sampling <= 1;
				signal_lag_align <= signal_lag; //signal_lag alignment;
			end
			1: begin
				lag_1 <= lag_0;
				lag_0 <= signal;
				count_sampling <= 2;
				signal_lag_align <= signal_lag;
			end
			2: begin
				lag_2 <= lag_1;
				lag_1 <= lag_0;
				lag_0 <= signal;
				count_sampling <= 3;
				signal_lag_align <= signal_lag;
			end
			3: begin
				lag_3 <= lag_2;
				lag_2 <= lag_1;
				lag_1 <= lag_0;
				lag_0 <= signal;
				count_operation <= 0;
				signal_lag_align <= signal_lag;
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

			opa_U2 <= lag_2;
			opb_U2 <= para_2;
			fpu_op_U2 <= 3'b010; //out = lag_2*para_2
			rmode_U2 = 2'b00;
			enable_U2 <= 1'b1;

			opa_U3 <= lag_3;
			opb_U3 <= para_3;
			fpu_op_U3 <= 3'b010; //out = lag_3*para_3
			rmode_U3 = 2'b00;
			enable_U3 <= 1'b1;			
			#4

			enable_U0 <= 1'b0;			
			enable_U1 <= 1'b0;
			enable_U2 <= 1'b0;
			enable_U3 <= 1'b0;
	
			#60

			if (ready_U0&ready_U1&ready_U2&ready_U3 == 1) 
			begin
				count_operation <= 1;
				lp_0 <= out_U0;
				lp_1 <= out_U1;
				lp_2 <= out_U2;
				lp_3 <= out_U3;
			
			end
		end

		1: begin
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

			opa_U2 <= lag_0;
			opb_U2 <= lag_0;
			fpu_op_U2 <= 3'b010; //out = lag_0*lag_0
			rmode_U2 = 2'b00;
			enable_U2 <= 1'b1;

			opa_U3 <= lag_1;
			opb_U3 <= lag_1;
			fpu_op_U3 <= 3'b010; //out = lag_1*lag_1
			rmode_U3 = 2'b00;
			enable_U3 <= 1'b1;			
			#4

			enable_U0 <= 1'b0;			
			enable_U1 <= 1'b0;
			enable_U2 <= 1'b0;
			enable_U3 <= 1'b0;
		
			#60

			if (ready_U0&ready_U1&ready_U2&ready_U3 == 1) begin
				count_operation <= 2;
				lp_01 <= out_U0;
				lp_23 <= out_U1;
				ll_0 <= out_U2;
				ll_1 <= out_U3;
			end
		end

		2: begin
/*$display(
" ##count_operation:", count_operation,
" ##lag_0: %b", lag_0[63:52],// - 12'b001111111111,
" ##para_0: %b", para_0[63:52],
" ##lag_0*para_0: %b", out_U0[63:52],
" ##lag_1: %b", lag_1[63:52],
" ##para_1: %b", para_1[63:52],
" ##lag_1*para_1: %b", out_U1[63:52],
" ##lag_2: %b", lag_2[63:52],
" ##para_2: %b", para_2[63:52],
" ##lag_2*para_2: %b", out_U2[63:52],
" ##lag_3: %b", lag_3[63:52],
" ##para_3: %b", para_3[63:52],
" ##lag_3*para_3: %b", out_U3[63:52]
);*/

			opa_U0 <= lp_01;
			opb_U0 <= lp_23;
			fpu_op_U0 <= 3'b000; //out = lag_0*para_0+lag_1*para_1+lag_2*para_2+lag_3*para_3
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;

			opa_U1 <= lag_2;
			opb_U1 <= lag_2;
			fpu_op_U1 <= 3'b010; //out = lag_2*lag_2
			rmode_U1 = 2'b00;
			enable_U1 <= 1'b1;

			opa_U2 <= lag_3;
			opb_U2 <= lag_3;
			fpu_op_U2 <= 3'b010; //out = lag_3*lag_3
			rmode_U2 = 2'b00;
			enable_U2 <= 1'b1;

			opa_U3 <= ll_0;
			opb_U3 <= ll_1;
			fpu_op_U3 <= 3'b000; //out = lag_0*lag_0+lag_1*lag_1
			rmode_U3 = 2'b00;
			enable_U3 <= 1'b1;			
			#4

			enable_U0 <= 1'b0;			
			enable_U1 <= 1'b0;
			enable_U2 <= 1'b0;
			enable_U3 <= 1'b0;
		
			#60

			if (ready_U0&ready_U1&ready_U2&ready_U3 == 1) begin
				count_operation <= 3;
				lp_0123 <= out_U0;
				ll_2 <= out_U1;
				ll_3 <= out_U2;
				ll_01 <= out_U3;
			end
		end


		3: begin
	
			opa_U0 <= ll_2;
			opb_U0 <= ll_3;
			fpu_op_U0 <= 3'b000; //out = lag_2*lag_2+lag_3*lag_3
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;

			opa_U1 <= gamma;
			opb_U1 <= ll_01;
			fpu_op_U1 <= 3'b000; //out = gamma + lag_0*lag_0+lag_1*lag_1
			rmode_U1 = 2'b00;
			enable_U1 <= 1'b1;

			opa_U2 <= signal_lag_align;
			opb_U2 <= lp_0123;
			fpu_op_U2 <= 3'b001; //out = e
			rmode_U2 = 2'b00;
			enable_U2 <= 1'b1;
			#4

			enable_U0 <= 1'b0;			
			enable_U1 <= 1'b0;
			enable_U2 <= 1'b0;
	
			#60

			if (ready_U0&ready_U1&ready_U2 == 1) begin
				count_operation <= 4;
				ll_23 <= out_U0;
				gamma_ll_01 <= out_U1;
				e <= out_U2;// unbais error of prediction	
				e_exp <= out_U2[62:52] - 1023;	
			end
		end

		4: begin
			
			opa_U0 <= e;
			opb_U0 <= mu;
			fpu_op_U0 <= 3'b010; //out = e_mu
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;

			opa_U1 <= gamma_ll_01;
			opb_U1 <= ll_23;
			fpu_op_U1 <= 3'b000; //out = normalize_amp = gamma + lag_0*lag_0+lag_1*lag_1+lag_2*lag_2+lag_3*lag_3
			rmode_U1 = 2'b00;
			enable_U1 <= 1'b1;

			#4

			enable_U0 <= 1'b0;			
			enable_U1 <= 1'b0;
		
			#60

			if (ready_U0&ready_U1 == 1) begin
/*$display(
"  ##signal_lag_align[sign]: %b", signal_lag_align[63],
"  ##lp_0123[sign]: %b", lp_0123[63],
"  ##signal_lag_align[exp]: %d", signal_lag_align[62:52] - 1023,
"  ##lp_0123[exp]: %d", lp_0123[62:52] - 1023,
"  ##signal_lag_align: %b", signal_lag_align[51:45],
"  ##lp_0123: %b", lp_0123[51:45]
);*/				count_operation <= 5;
				e_mu <= out_U0; 
				normalize_amp <= out_U1;		
				normalize_amp_exp <= out_U1[62:52] - 1023;
			end
		end

		5: begin
	
			opa_U0 <= e_mu;
			opb_U0 <= lag_0;
			fpu_op_U0 <= 3'b010; //out = e*mu*lag_0
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;

			opa_U1 <= e_mu;
			opb_U1 <= lag_1;
			fpu_op_U1 <= 3'b010; //out = e*mu*lag_1
			rmode_U1 = 2'b00;
			enable_U1 <= 1'b1;

			opa_U2 <= e_mu;
			opb_U2 <= lag_2;
			fpu_op_U2 <= 3'b010; //out = e*mu*lag_2
			rmode_U2 = 2'b00;
			enable_U2 <= 1'b1;

			opa_U3 <= e_mu;
			opb_U3 <= lag_3;
			fpu_op_U3 <= 3'b010; //out = e*mu*lag_3
			rmode_U3 = 2'b00;
			enable_U3 <= 1'b1;			
			#4

			enable_U0 <= 1'b0;			
			enable_U1 <= 1'b0;
			enable_U2 <= 1'b0;
			enable_U3 <= 1'b0;
		
			#60

			if (ready_U0&ready_U1&ready_U2&ready_U3 == 1) 
			begin
				count_operation <= 6;
				e_mu_lag_0 <= out_U0;
				e_mu_lag_1 <= out_U1;
				e_mu_lag_2 <= out_U2;
				e_mu_lag_3 <= out_U3;
			end
		end
		6: begin		
			opa_U0 <= e_mu_lag_0;
			opb_U0 <= normalize_amp;
			fpu_op_U0 <= 3'b011; //out = e*mu*lag_0/(gamma + lag_0*lag_0+lag_1*lag_1+lag_2*lag_2+lag_3*lag_3)
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;

			opa_U1 <= e_mu_lag_1;
			opb_U1 <= normalize_amp;
			fpu_op_U1 <= 3'b011; //out = e*mu*lag_1/(gamma + lag_0*lag_0+lag_1*lag_1+lag_2*lag_2+lag_3*lag_3)
			rmode_U1 = 2'b00;
			enable_U1 <= 1'b1;

			opa_U2 <= e_mu_lag_2;
			opb_U2 <= normalize_amp;
			fpu_op_U2 <= 3'b011; //out = e*mu*lag_2/(gamma + lag_0*lag_0+lag_1*lag_1+lag_2*lag_2+lag_3*lag_3)
			rmode_U2 = 2'b00;
			enable_U2 <= 1'b1;

			opa_U3 <= e_mu_lag_3;
			opb_U3 <= normalize_amp;
			fpu_op_U3 <= 3'b011; //out = e*mu*lag_3/(gamma + lag_0*lag_0+lag_1*lag_1+lag_2*lag_2+lag_3*lag_3)
			rmode_U3 = 2'b00;
			enable_U3 <= 1'b1;			
			#4

			enable_U0 <= 1'b0;			
			enable_U1 <= 1'b0;
			enable_U2 <= 1'b0;
			enable_U3 <= 1'b0;
		
			#160

			if (ready_U0&ready_U1&ready_U2&ready_U3 == 1) 
			begin
				count_operation <= 7;
				D_para_0 <= out_U0;
				D_para_1 <= out_U1;
				D_para_2 <= out_U2;
				D_para_3 <= out_U3;
			end
		end

		7: begin		
/*$display(
"##e: %b", e,
"##e_exp: %d", e_exp,
"##normalize_amp: %b", normalize_amp,
"##normalize_amp: %d", normalize_amp
);*/	
			opa_U0 <= para_0;
			opb_U0 <= D_para_0;
			fpu_op_U0 <= 3'b000; //out = para_0 + e*mu*lag_0/(gamma + lag_0*lag_0+lag_1*lag_1+lag_2*lag_2+lag_2*lag_2)
			rmode_U0 = 2'b00;
			enable_U0 <= 1'b1;

			opa_U1 <= para_1;
			opb_U1 <= D_para_1;
			fpu_op_U1 <= 3'b000; //out = para_1 + e*mu*lag_1/(gamma + lag_0*lag_0+lag_1*lag_1+lag_2*lag_2+lag_2*lag_2)
			rmode_U1 = 2'b00;
			enable_U1 <= 1'b1;

			opa_U2 <= para_2;
			opb_U2 <= D_para_2;
			fpu_op_U2 <= 3'b000; //out = para_2 + e*mu*lag_2/(gamma + lag_0*lag_0+lag_1*lag_1+lag_2*lag_2+lag_2*lag_2)
			rmode_U2 = 2'b00;
			enable_U2 <= 1'b1;

			opa_U3 <= para_3;
			opb_U3 <= D_para_3;
			fpu_op_U3 <= 3'b000; //out = para_3 + e*mu*lag_3/(gamma + lag_0*lag_0+lag_1*lag_1+lag_2*lag_2+lag_2*lag_2)
			rmode_U3 = 2'b00;
			enable_U3 <= 1'b1;			
			#4

			enable_U0 <= 1'b0;			
			enable_U1 <= 1'b0;
			enable_U2 <= 1'b0;
			enable_U3 <= 1'b0;
		
			#60

			if (ready_U0&ready_U1&ready_U2&ready_U3 == 1) begin
				para_0 <= out_U0;
				para_1 <= out_U1;
				para_2 <= out_U2;
				para_3 <= out_U3; 
				count_operation <= 8;	
				enable_internal <= 0;
				ready <= 1;
			end
		end
		8: begin
			enable_U0 <= 1'b0;
			enable_U1 <= 1'b0;
			enable_U2 <= 1'b0;
			enable_U3 <= 1'b0;
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
endmodule // para_approx

