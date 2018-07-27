`timescale 1us / 1us
module ZZZ_TB_4_TEST();

reg [2:0] sig,sig1,sig2,a,b,c;
reg clk;
reg [2:0] double,double_2;
reg enable;
reg [1:0] phase;

always #125 clk = ~clk;

initial begin
	clk = 1;	
	enable = 0;
end

initial phase = 2'b00;

always @(posedge clk) begin
	sig <= $urandom;
	sig1 <= $urandom;
	sig2 <= $urandom;
end

STACKMODULE_TEST MUTT (      //<=
.clk(clk), 
.a(a), 
.b(b), 
.c(c), 
.mod(0),
.enable(enable)
);

always @(posedge clk) begin
if (phase == 2'b00) begin
a <= sig;
b <= sig1;
c <= double;
phase <= 2'b01;
end
else if (phase == 2'b01) begin
a <= sig2;
b <= double;
c <= double_2;
phase <= 2'b10;
end
else if (phase == 2'b10) begin
double <= double_2;
phase <= 2'b00;
end
end
endmodule //ZZZ_TB_4_TEST

/*
# vsim -gui work.ZZZ_TB_4_TEST 
# Start time: 20:23:15 on Jul 26,2018
# Loading work.ZZZ_TB_4_TEST
# Loading work.STACKMODULE_TEST
# ** Error (suppressible): (vsim-3053) D:/WORKING_FOLDER/echo_cancelation/A_code/ZZZ_TB_4_TEST.v(25): Illegal output or inout port connection for port 'c'.
#    Time: 0 us  Iteration: 0  Instance: /ZZZ_TB_4_TEST/MUTT File: D:/WORKING_FOLDER/echo_cancelation/A_code/STACKMODULE_TEST.v
# ** Warning: (vsim-3015) D:/WORKING_FOLDER/echo_cancelation/A_code/ZZZ_TB_4_TEST.v(25): [PCDPC] - Port size (1) does not match connection size (32) for port 'mod'. The port definition is at: D:/WORKING_FOLDER/echo_cancelation/A_code/STACKMODULE_TEST.v(2).
#    Time: 0 us  Iteration: 0  Instance: /ZZZ_TB_4_TEST/MUTT File: D:/WORKING_FOLDER/echo_cancelation/A_code/STACKMODULE_TEST.v
# Error loading design
# End time: 20:23:15 on Jul 26,2018, Elapsed time: 0:00:00
# Errors: 1, Warnings: 1
*/