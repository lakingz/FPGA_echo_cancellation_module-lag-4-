/**************************************************************************
***                          Echo approximation                         ***                       
***                            Author :   LAK                           ***  
**************************************************************************/



`timescale 1us/1us
module echo_approx(signal, signal_lag, para_0, para_1, para_2);

input [15:0] signal, signal_lag;
output para_0,para_1,para_2;

reg clk;
integer count;
real gamma, mu;
reg [15:0] lag_0,lag_1,lag_2;
real parat_0, parat_1,parat_2;
real e;

initial begin
count = -1;
clk = 0;
gamma <= 0.01;
mu <= 1;
parat_0 <= 0;
parat_1 <= 0;
parat_2 <= 0;
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

always@(count) 
if (count >= 2) e = signal_lag - (lag_0 * parat_0 + lag_1 * parat_1 + lag_2 * parat_2);

always@(count or e!= 0)
if (count >= 2) begin
parat_0 <= parat_0 + mu / (gamma + lag_0**2 + lag_1**2 + lag_2**2) * lag_0 * e;
parat_1 <= parat_1 + mu / (gamma + lag_0**2 + lag_1**2 + lag_2**2) * lag_1 * e;
parat_2 <= parat_2 + mu / (gamma + lag_0**2 + lag_1**2 + lag_2**2) * lag_2 * e;
end

assign para_0 = parat_0;
assign para_1 = parat_1;
assign para_2 = parat_2;

endmodule // echo_approx

