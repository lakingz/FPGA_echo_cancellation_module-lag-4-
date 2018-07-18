/**************************************************************************
***                   Random Signal Generator Testbench                 ***     
***                            Author :   LAK                           ***  
**************************************************************************/

`timescale 1us / 1us
module signal_generator_tb ();

reg clk;
wire [15:0] signal_random;
wire [15:0] signal_lag;

signal_generator MUT(
.signal_random(signal_random)
);
lag_generator MUTT(
.signal(signal_random),
.signal_lag(signal_lag)
);

initial clk = 1;

always #125 clk = ~clk;


endmodule //signal_generator_tb