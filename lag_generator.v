/**************************************************************************
***                     Lag Signal Generator (500ns/20ns)               ***     
***                  For testing. We create a lag signal                ***
***                            Author :   LAK                           ***  
**************************************************************************/

//we first look at 3 lag with parameter 1 2 1


`timescale 1us/1us
module lag_generator(signal, signal_lag);

input [15:0] signal;
output [15:0] signal_lag;

reg clk;
integer count;
reg [15:0] lag_0,lag_1,lag_2;
reg [15:0] signal_lag_sum;
//real tt;

initial begin
count = -1;
clk = 0;
forever #125 clk = ~clk;
end

always@(negedge clk) begin
count <= count + 1;
end

always@(count) begin
if (count == 0) lag_2 = signal;
if (count == 1) lag_1 = signal;
if (count == 2) lag_0 = signal;
if (count > 2) begin
lag_2 <= lag_1;
lag_1 <= lag_0;
lag_0 <= signal;
end
end
always@(lag_0 or lag_1 or lag_2) signal_lag_sum = $realtobits((lag_2 * 0.2 + lag_1 * 0.3 + lag_0 * 0.5)/ (0.2+0.3+0.5));
//always@(lag_1 or lag_2 or lag_3) tt = (lag_3 * 0.2 + lag_2 * 0.3 + lag_1 * 0.5) / (0.2+0.3+0.5);

assign signal_lag = signal_lag_sum;
endmodule // lag_generator  	



