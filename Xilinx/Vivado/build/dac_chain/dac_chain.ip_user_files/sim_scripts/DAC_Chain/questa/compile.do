vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xil_defaultlib  -incr -mfcu \
"../../../bd/DAC_Chain/ip/DAC_Chain_dac_resampler_0_0/sim/DAC_Chain_dac_resampler_0_0.v" \
"../../../bd/DAC_Chain/sim/DAC_Chain.v" \


vlog -work xil_defaultlib \
"glbl.v"

