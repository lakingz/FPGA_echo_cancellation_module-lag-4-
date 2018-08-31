Echo Cancelation Module (lag-4) on (cyclone_4 FPGA)
Author: Anlai Liu (17al76@queens.ca)
Date: 2018-08-25

Main file:

	echo_cancelation.mpf (used to open project)

	double_16b_tb.v (test bunch for data conversion)
	double_to_sig16b.v
	sig16b_to_double.v

	signal_generator.v
	lag_generator.v
	para_approx.v
	echo_cancelation.v
	tb_all.v (test bunch for all sub level modules)
	ZZZ_TB_4_TEST.v

	echo_cancelation_full.v (Top level module)
	echo_cancelation_full_tb.v (Top level module test bunch)

fpu_package (doule precision floating point core):
author: David Lundgren

	fpu_double.v (main module)
	fpu_add.v
	fpu_div.v
	fpu_exception.v
	fpu_mul.v
	fpu_round.v
	fpu_sub.v
	fpu_TB.v
	Doulbe_FPU.PDF (instructor)

Document:
	
	LSM_algorithm_demo.Rmd 
	LSM_algorithm_demo.pdf (Testing LSM algorithm preformers)
	Description.pdf (More detailed description)
	
Usage:

	Open "echo_cancelation.mpf" to open the whole package. 
	tpye in transcript:
	vsim -gui work.echo_cancelation_full_tb	
	add wave -position insertpoint sim:/echo_cancelation_full_tb/*
	run {480 ms}
	
	"sig16b_without_echo" is the output we are looking at.

Note:
	time for task completion
	fpu package
	- 1. addition : 		(20 clock cycles/60 clks) 
	- 2. subtraction: 		(21 clock cycles/60 clks) 
	- 3. multiplication: 		(24 clock cycles/60 clks) 
	- 4. division: 			(71 clock cycles/160 clks)
	- 5. exception/ rounding        (1  clock cycles/2  clks)	

	main module
	- 1. echo_cancelation: 		(4 sampling cycles, 160 operation cycles/320 clks)
	- 2. lag_generator: 		(4 sampling cycles, 130 operation cycles/260 clks)
	- 3. para_approx: 		(4 sampling cycles, 310 operation cycles/620 clks)
	- 4. sig16b_to_double: 		(50 operation clock cycles)


LSM example:

	e = signal_lag - (lag_0 * parat_0 + lag_1 * parat_1 + lag_2 * parat_2);
	parat_0 <= parat_0 + mu / (gamma + lag_0**2 + lag_1**2 + lag_2**2) * lag_0 * e;
	parat_1 <= parat_1 + mu / (gamma + lag_0**2 + lag_1**2 + lag_2**2) * lag_1 * e;
	parat_2 <= parat_2 + mu / (gamma + lag_0**2 + lag_1**2 + lag_2**2) * lag_2 * e;
	parat_3 <= parat_3 + mu / (gamma + lag_0**2 + lag_1**2 + lag_2**2) * lag_3 * e;




