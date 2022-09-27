vlib work

vlog -reportprogress 300 -work work "../delimiter.sv"
vlog -reportprogress 300 -work work "../delimiter_tb.sv"

vsim -L work  delimiter_tb
add wave *
radix signal sim:/delimiter_tb/IN0 hex
radix signal sim:/delimiter_tb/OUT0 hex
radix signal sim:/delimiter_tb/OUT1 hex
radix signal sim:/delimiter_tb/OUT2 hex
radix signal sim:/delimiter_tb/OUT3 hex
radix signal sim:/delimiter_tb/OUT4 hex
radix signal sim:/delimiter_tb/OUT5 hex
radix signal sim:/delimiter_tb/OUT6 hex
radix signal sim:/delimiter_tb/OUT7 hex

view wave

view structure
view signals
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
run -all