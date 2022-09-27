vlib work

vlog -reportprogress 300 -work work "../gpio_reg_array.v"
vlog -reportprogress 300 -work work "../gpio_reg_array_tb.v"

vsim -L work  gpio_reg_array_tb
add wave *

add wave -position insertpoint \
sim:/gpio_reg_array_tb/DUT/r_BRAM_Counter \
sim:/gpio_reg_array_tb/DUT/r_out \
sim:/gpio_reg_array_tb/DUT/r_Delay_Counter \
sim:/gpio_reg_array_tb/DUT/Flag

radix signal sim:/gpio_reg_array_tb/DUT/r_out hex

radix signal sim:/gpio_reg_array_tb/in00 hex
radix signal sim:/gpio_reg_array_tb/in01 hex
radix signal sim:/gpio_reg_array_tb/in02 hex
radix signal sim:/gpio_reg_array_tb/in03 hex
radix signal sim:/gpio_reg_array_tb/in04 hex
radix signal sim:/gpio_reg_array_tb/in05 hex
radix signal sim:/gpio_reg_array_tb/in06 hex
radix signal sim:/gpio_reg_array_tb/in07 hex
radix signal sim:/gpio_reg_array_tb/in08 hex
radix signal sim:/gpio_reg_array_tb/in09 hex
radix signal sim:/gpio_reg_array_tb/in10 hex
radix signal sim:/gpio_reg_array_tb/in11 hex
radix signal sim:/gpio_reg_array_tb/in12 hex
radix signal sim:/gpio_reg_array_tb/in13 hex
radix signal sim:/gpio_reg_array_tb/in14 hex
radix signal sim:/gpio_reg_array_tb/in15 hex
radix signal sim:/gpio_reg_array_tb/in16 hex
radix signal sim:/gpio_reg_array_tb/in17 hex
radix signal sim:/gpio_reg_array_tb/in18 hex
radix signal sim:/gpio_reg_array_tb/in19 hex

radix signal sim:/gpio_reg_array_tb/out00 hex
radix signal sim:/gpio_reg_array_tb/out01 hex
radix signal sim:/gpio_reg_array_tb/out02 hex
radix signal sim:/gpio_reg_array_tb/out03 hex
radix signal sim:/gpio_reg_array_tb/out04 hex
radix signal sim:/gpio_reg_array_tb/out05 hex
radix signal sim:/gpio_reg_array_tb/out06 hex
radix signal sim:/gpio_reg_array_tb/out07 hex
radix signal sim:/gpio_reg_array_tb/out08 hex
radix signal sim:/gpio_reg_array_tb/out09 hex
radix signal sim:/gpio_reg_array_tb/out10 hex
radix signal sim:/gpio_reg_array_tb/out11 hex
radix signal sim:/gpio_reg_array_tb/out12 hex
radix signal sim:/gpio_reg_array_tb/out13 hex
radix signal sim:/gpio_reg_array_tb/out14 hex
radix signal sim:/gpio_reg_array_tb/out15 hex
radix signal sim:/gpio_reg_array_tb/out16 hex
radix signal sim:/gpio_reg_array_tb/out17 hex
radix signal sim:/gpio_reg_array_tb/out18 hex
radix signal sim:/gpio_reg_array_tb/out19 hex

radix signal sim:/gpio_reg_array_tb/BRAM_addr hex
radix signal sim:/gpio_reg_array_tb/BRAM_wrdata hex
radix signal sim:/gpio_reg_array_tb/BRAM_rddata hex
radix signal sim:/gpio_reg_array_tb/BRAM_we hex
radix signal sim:/gpio_reg_array_tb/DUT/r_BRAM_Counter hex
view wave

view structure
view signals
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all
