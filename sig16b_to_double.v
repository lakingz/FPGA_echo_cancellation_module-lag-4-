//takes at most 17??? operation clks

module sig16b_to_double(
	clk_operation,
	rst,
	sig16b,
	double,
	ready,
	enable
);

input clk_operation,rst;
input enable;
input [16-1:0] sig16b;
output [64-1:0] double;
output reg ready;

reg enable_internal;
reg double_sign;
reg [14:0] sig16b_amp;
reg [10:0] double_exponent;
reg [3:0] i;

always @(posedge clk_operation) begin
   if (rst) begin
      double_sign <= sig16b[15];
      sig16b_amp <= sig16b[14:0];
      double_exponent <= 0;
      ready <= 0;
   end
   else begin 
      if (enable) begin
         i <= 15;
         enable_internal <= 1;
	 ready <= 0;
      end
      if (enable_internal) begin   
         case (sig16b_amp[14])
         1: begin
            double_exponent <= i - 1;
            sig16b_amp <= sig16b_amp << 1;
	    enable_internal <= 0;
	    ready <= 1;
         end
   
         0: begin
   	    if (i > 0) begin
	       i <= i - 1;	
	       sig16b_amp <= sig16b_amp << 1;
	    end
	    else begin
	       double_exponent <= 0;
	       sig16b_amp <= 0;
	       enable_internal <= 0;
	       ready <= 1;
            end
         end
         endcase
      end
   end
end


assign double[63] = double_sign;
assign double[62:52] = double_exponent + 1023; //exponent is offset by 1023
assign double[51:37] = sig16b_amp;
assign double[36:0] = 0;

endmodule //sig16b_to_double




