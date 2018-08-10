echo cancelation package on (cyclone 4 FPGA)
auther:anlai liu

file:
in progess..


Run echi_cancelation.mpf to open the package.
open tb_all.v in modelsim/simulate for simulation. 


//always@(count) 
if (count >= 2) e = signal_lag - (lag_0 * parat_0 + lag_1 * parat_1 + lag_2 * parat_2);
always@(count or e!= 0)
if (count >= 2) begin
parat_0 <= parat_0 + mu / (gamma + lag_0**2 + lag_1**2 + lag_2**2) * lag_0 * e;
parat_1 <= parat_1 + mu / (gamma + lag_0**2 + lag_1**2 + lag_2**2) * lag_1 * e;
parat_2 <= parat_2 + mu / (gamma + lag_0**2 + lag_1**2 + lag_2**2) * lag_2 * e;
end


