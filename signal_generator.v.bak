/**************************************************************************
***                        Random Signal Generator                      ***     
***For testing. For given integer n, it generate n random sample points.***
***                            Author :   LAK                           ***  
**************************************************************************/

`timescale 1us / 1us
module signal_generator (clk_samplying,signal);

input clk_samplying;
output reg [15:0] signal;

always@(posedge clk_samplying) begin
signal <= $urandom;
end

endmodule // signal_generator  	

