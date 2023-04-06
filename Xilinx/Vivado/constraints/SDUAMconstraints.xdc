#ADC Interface - AD9244BST-40 14-bit ADC - all inputs
set_property -dict {PACKAGE_PIN A20 IOSTANDARD LVCMOS33} [get_ports ADCclock]
#ADCdata[14] is OTR signal
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVCMOS33} [get_ports {ADCdata[14]}]
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVCMOS33} [get_ports {ADCdata[13]}]
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports {ADCdata[12]}]
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports {ADCdata[11]}]
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS33} [get_ports {ADCdata[10]}]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33} [get_ports {ADCdata[9]}]
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS33} [get_ports {ADCdata[8]}]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33} [get_ports {ADCdata[7]}]
set_property -dict {PACKAGE_PIN F20 IOSTANDARD LVCMOS33} [get_ports {ADCdata[6]}]
set_property -dict {PACKAGE_PIN F19 IOSTANDARD LVCMOS33} [get_ports {ADCdata[5]}]
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports {ADCdata[4]}]
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports {ADCdata[3]}]
set_property -dict {PACKAGE_PIN C20 IOSTANDARD LVCMOS33} [get_ports {ADCdata[2]}]
set_property -dict {PACKAGE_PIN B20 IOSTANDARD LVCMOS33} [get_ports {ADCdata[1]}]
set_property -dict {PACKAGE_PIN B19 IOSTANDARD LVCMOS33} [get_ports {ADCdata[0]}]

#DAC Interface - AD9764A 14-bit DAC - all outputs
set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports DACclock]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports DACsleep]
set_property -dict {PACKAGE_PIN P19 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[13]}]
set_property -dict {PACKAGE_PIN P20 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[12]}]
set_property -dict {PACKAGE_PIN R19 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[11]}]
set_property -dict {PACKAGE_PIN T20 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[10]}]
set_property -dict {PACKAGE_PIN T19 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[9]}]
set_property -dict {PACKAGE_PIN U20 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[8]}]
set_property -dict {PACKAGE_PIN V20 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[7]}]
set_property -dict {PACKAGE_PIN W20 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[6]}]
set_property -dict {PACKAGE_PIN W19 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[5]}]
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[4]}]
set_property -dict {PACKAGE_PIN W18 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[3]}]
set_property -dict {PACKAGE_PIN Y18 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[2]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[1]}]
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports {DACdata[0]}]

# force DAC_data registers to be placed in OLOGIC block
# this places it close to ouput pad for low skew between DAC data & clock
# NOTE: DAC clock is routed through ODDR in design to ensure low skew to output pin
set_property IOB TRUE [get_ports {DACdata[*]}]


#Power Amp Enable - Output
set_property -dict {PACKAGE_PIN N18 IOSTANDARD LVCMOS33 DRIVE 4 SLEW SLOW} [get_ports PowerAmpEnable]
