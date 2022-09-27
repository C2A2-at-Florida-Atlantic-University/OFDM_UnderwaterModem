create_clock -period 25.000 -name m00_axis_aclk -waveform {0.000 12.500} [get_ports m00_axis_aclk]
create_generated_clock -name ClockToADC -source [get_pins AD9244_to_AXIS_M_M00_AXIS_inst/clock_forward_inst/C] -divide_by 1 [get_ports ClockToADC]
set_input_delay -clock ClockToADC -min 3.600 [get_ports -prop_thru_buffers {ADCdata[*]}]
set_input_delay -clock ClockToADC -max 7.200 [get_ports -prop_thru_buffers {ADCdata[*]}]
