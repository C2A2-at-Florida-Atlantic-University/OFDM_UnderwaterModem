onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+DAC_Chain -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.DAC_Chain xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {DAC_Chain.udo}

run -all

endsim

quit -force
