module sig16b_to_double(
	clk,
	rst,
	sig16b,
	double,
	stop
);

input clk,rst;
input [16-1:0] sig16b;
output [64-1:0] double;
output reg stop;

reg double_sign;
reg [14:0] sig_amp;
reg [10:0] double_exponent;
integer i;

always @(posedge clk) begin
   if (rst == 1) begin
      double_sign <= sig16b[15];
      sig_amp <= sig16b[14:0];
      double_exponent <= 0;
      i <= 15;
      stop <= 0;
   end
   else if (stop == 0) begin
      case (sig_amp[14])
      1: begin
         double_exponent <= i - 1;
         sig_amp <= sig_amp << 1;
         stop <= 1;
      end

      0: begin
	 if (i > 0) begin
	    i <= i - 1;	
	    sig_amp <= sig_amp << 1;
	 end
	 else begin
	    double_exponent <= 0;
	    sig_amp <= 0;
	    stop <= 1;
         end
      end
      endcase
   end
end


assign double[63] = double_sign;
assign double[62:52] = double_exponent + 1023; //exponent is offset by 1023
assign double[51:36] = sig_amp;
assign double[35:0] = 0;

endmodule //sig16b_to_double




