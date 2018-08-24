/**************************************************************************
***                        Random Signal Generator                      ***     
***For testing. For given integer n, it generate n random sample points.***
***                            Author :   LAK                           ***  
**************************************************************************/

`timescale 1us / 1us
module signal_generator (sampling_cycle_counter,clk_operation,signal);

input [12:0] sampling_cycle_counter;
input clk_operation;
output reg [15:0] signal;

always @(posedge clk_operation) begin
	if (sampling_cycle_counter == 0) begin
		signal <= $urandom;
	end
end

endmodule // signal_generator  	

