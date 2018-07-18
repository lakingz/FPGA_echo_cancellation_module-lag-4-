/**************************************************************************
***                            Testbench ALL                            ***     
***                            Author :   LAK                           ***  
**************************************************************************/

`timescale 1us / 1us
module tb_all ();

reg clk;
wire [15:0] signal_random;
wire [19:0] signal_lag;
wire para_0,para_1,para_2;

real parat_0,parat_1,parat_2;

signal_generator MUT(
.signal_random(signal_random)
);
lag_generator MUTT(
.signal(signal_random),
.signal_lag(signal_lag)
);

echo_approx MUTTT(
.signal(signal_random), 
.signal_lag(signal_lag), 
.para_0(parat_0), 
.para_1(parat_1),
.para_2(parat_2)
);

assign para_0 = parat_0;
assign para_1 = parat_1;
assign para_2 = parat_2;

initial clk = 1;

always #125 clk = ~clk;


endmodule //tb_all
