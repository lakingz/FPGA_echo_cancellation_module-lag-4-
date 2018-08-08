/**************************************************************************
***                        Random Signal Generator                      ***     
***For testing. For given integer n, it generate n random sample points.***
***                            Author :   LAK                           ***  
**************************************************************************/

`timescale 1us / 1us
module signal_generator (clk_sampling,signal);

input clk_sampling;
output reg [15:0] signal;

always@(posedge clk_sampling) begin
signal <= $urandom;
end

endmodule // signal_generator  	

