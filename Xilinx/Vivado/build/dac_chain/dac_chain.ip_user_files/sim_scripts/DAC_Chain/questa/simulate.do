onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib DAC_Chain_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {DAC_Chain.udo}

run -all

quit -force
