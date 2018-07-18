
/**************************************************************************
***                               Testing                               ***   
***                            Author :   LAK                           ***  
**************************************************************************/

`timescale 1us / 1us
module tb_test ();

integer count;
reg clk;
real a,b,d;
reg [4:0] c;

initial begin
count = -1;
clk = 0;
a = 0.4;
c = 5'b10011;
forever #125 clk = ~clk;
end

always @ (posedge clk) begin
b <= a * c;
d <= $bi
end


endmodule // tb_test