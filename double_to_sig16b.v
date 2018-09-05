

//produce one sampling lag. needs to do an align

module double_to_sig16b(
	sampling_cycle_counter,
	clk_operation,
	rst,
	enable,		
	double,
		sig16b
);

input [12:0] sampling_cycle_counter;
input clk_operation,rst,enable;
input [64-1:0] double;
output [16-1:0] sig16b;

wire [52:0] double_amp_shift;
reg [52:0] double_amp_unshift;
reg [10:0] double_exponent;
reg sig16b_sign;
wire [10:0] read_double_exp;

always @(posedge clk_operation) begin
		if (rst) begin
			double_amp_unshift <= 0;
	      		double_exponent <= 0;
		end
		else if (enable) begin 
			sig16b_sign <= double[63];
/*$display(
"  ##double_amp_shift: %b", double_amp_shift,
"  ##double_amp_unshift: %b", double_amp_unshift,
"  ##shift: %d", 15-double_exponent
);*/
			if (read_double_exp[10] == 1) begin              //verilog have problem reconizing negative number!!!!!!!!!!!!!!
				double_amp_unshift <= 0;   //negative exponent, rounding to 0.
				double_exponent <= 0;
			end 
			else begin
				if (read_double_exp > 15) begin
					double_amp_unshift[52:38] <= 15'b111111111111111;   // !!!!over 15 digit, rounding to 15'b1111111111111111.
					double_exponent <= 15;
				end
				else begin 
					double_amp_unshift[52] <= 1;
					double_amp_unshift[51:0] <= double[51:0];  
					double_exponent <= read_double_exp;     
				end
			end
		end
end

assign read_double_exp = double[62:52] - 1023;
assign double_amp_shift = double_amp_unshift >> (15 - double_exponent);
assign sig16b[14:0] = double_amp_shift[52:38];
assign sig16b[15] = sig16b_sign;
endmodule //double_to_sig16b


