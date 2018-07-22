module double_to_sig16b(
	clk,
	rst,
	sig16b,
	double
);

input clk,rst;
input [64-1:0] double;
output [16-1:0] sig16b;

reg sig16b_sign;
wire [14:0] sig16b_amp;
wire [52:0] double_amp_shift;
reg [52:0] double_amp_unshift;
reg [9:0] double_exponent;

always @(posedge clk) begin
   sig16b_sign <= double[63];
   if (double[62:52] < 1023) begin
      double_amp_unshift <= 0;   //negative exponent, rounding to 0.
      double_exponent <= 0;
   end 
   else begin
      double_exponent <= double[61:52] + 10'b0000000001;
      if (double_exponent > 14) begin
         double_amp_unshift[52:38] <= 15'b111111111111111;   // !!!!over 15 digit, rounding to 15'b1111111111111111.
	 double_exponent <= 14;
      end
      else begin 
         double_amp_unshift[52] <= 1;
	 double_amp_unshift[51:0] <= double[51:0];       
      end
   end
end

assign double_amp_shift = double_amp_unshift >> (14 - double_exponent);
assign sig16b_amp = double_amp_shift[52:38];
assign sig16b[15] = sig16b_sign;
assign sig16b[14:0] = sig16b_amp;

endmodule //double_to_sig16b
