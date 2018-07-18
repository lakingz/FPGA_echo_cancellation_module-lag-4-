/**************************************************************************
***                        Random Signal Generator                      ***     
***For testing. For given integer n, it generate n random sample points.***
***                            Author :   LAK                           ***  
**************************************************************************/

`timescale 1us / 1us
module signal_generator (signal_random);

reg clk;
output reg [15:0] signal_random;
integer count;

initial begin
count = -1;
clk = 1;
forever #125 clk = ~clk;
end	

always@(posedge clk) begin
count <= count + 1;
signal_random <= $urandom;
end

endmodule // signal_generator  	

