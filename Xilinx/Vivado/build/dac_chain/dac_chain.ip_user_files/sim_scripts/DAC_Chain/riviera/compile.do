vlib work
vlib riviera

vlib riviera/xil_defaultlib

vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"../../../bd/DAC_Chain/ip/DAC_Chain_dac_resampler_0_0/sim/DAC_Chain_dac_resampler_0_0.v" \
"../../../bd/DAC_Chain/sim/DAC_Chain.v" \


vlog -work xil_defaultlib \
"glbl.v"

