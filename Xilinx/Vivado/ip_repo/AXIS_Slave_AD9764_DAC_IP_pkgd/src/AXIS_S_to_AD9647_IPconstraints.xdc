create_clock -period 20.000 -name s00_axis_aclk -waveform {0.000 10.000} [get_ports s00_axis_aclk]
create_generated_clock -name ClockToDAC -source [get_pins AXIS_S_to_AD9764_S00_AXIS_inst/clock_forward_inst/C] -divide_by 1 -invert [get_ports ClockToDAC]
set_input_delay -clock [get_clocks s00_axis_aclk] -min -add_delay 2.500 [get_ports {control[*]}]
set_input_delay -clock [get_clocks s00_axis_aclk] -max -add_delay 4.000 [get_ports {control[*]}]
set_input_delay -clock [get_clocks s00_axis_aclk] -min -add_delay 2.500 [get_ports {s00_axis_tdata[*]}]
set_input_delay -clock [get_clocks s00_axis_aclk] -max -add_delay 4.000 [get_ports {s00_axis_tdata[*]}]
set_input_delay -clock [get_clocks s00_axis_aclk] -min -add_delay 2.500 [get_ports s00_axis_aresetn]
set_input_delay -clock [get_clocks s00_axis_aclk] -max -add_delay 4.000 [get_ports s00_axis_aresetn]
set_input_delay -clock [get_clocks s00_axis_aclk] -min -add_delay 2.500 [get_ports s00_axis_tvalid]
set_input_delay -clock [get_clocks s00_axis_aclk] -max -add_delay 4.000 [get_ports s00_axis_tvalid]

set_output_delay -clock [get_clocks ClockToDAC] -min -add_delay -1.000 [get_ports {DAC_data[*]}]
set_output_delay -clock [get_clocks ClockToDAC] -max -add_delay 2.750 [get_ports {DAC_data[*]}]
set_output_delay -clock [get_clocks s00_axis_aclk] -max 5 [get_ports s00_axis_tready]
set_output_delay -clock [get_clocks s00_axis_aclk] -min -1 [get_ports s00_axis_tready]

# force DAC_data registers to be placed in OLOGIC block
# this places it close to ouput pad for low skew between DAC data & clock
# NOTE: DAC clock is routed through ODDR in design to ensure low skew to output pin
set_property IOB TRUE [get_ports {DAC_data[*]}]
