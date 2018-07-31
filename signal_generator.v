/**************************************************************************
***                        Random Signal Generator                      ***     
***For testing. For given integer n, it generate n random sample points.***
***                            Author :   LAK                           ***  
**************************************************************************/

`timescale 1us / 1us
module signal_generator (signal_random);

reg clk;
output reg [15:0] signal_random;

initial begin
clk = 1;
forever #125 clk = ~clk;
end	

always@(posedge clk) begin
signal_random <= $urandom;
end

endmodule // signal_generator  	

