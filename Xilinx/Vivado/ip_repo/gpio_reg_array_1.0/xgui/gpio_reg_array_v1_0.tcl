# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NUM_REGS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUT00_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT01_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT02_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT03_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT04_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT05_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT06_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT07_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT08_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT09_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT10_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT11_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT12_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT13_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT14_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT15_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT16_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT17_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT18_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "OUT19_INPUT" -parent ${Page_0} -widget checkBox
  ipgui::add_param $IPINST -name "WIDTH_00" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_01" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_02" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_03" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_04" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_05" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_06" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_07" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_08" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_09" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_10" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_11" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_12" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_13" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_14" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_15" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_16" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_17" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_18" -parent ${Page_0}
  ipgui::add_param $IPINST -name "WIDTH_19" -parent ${Page_0}

  ipgui::add_param $IPINST -name "BRAM_WIDTH"

}

proc update_PARAM_VALUE.BRAM_WIDTH { PARAM_VALUE.BRAM_WIDTH } {
	# Procedure called to update BRAM_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BRAM_WIDTH { PARAM_VALUE.BRAM_WIDTH } {
	# Procedure called to validate BRAM_WIDTH
	return true
}

proc update_PARAM_VALUE.NUM_REGS { PARAM_VALUE.NUM_REGS } {
	# Procedure called to update NUM_REGS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_REGS { PARAM_VALUE.NUM_REGS } {
	# Procedure called to validate NUM_REGS
	return true
}

proc update_PARAM_VALUE.OUT00_INPUT { PARAM_VALUE.OUT00_INPUT } {
	# Procedure called to update OUT00_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT00_INPUT { PARAM_VALUE.OUT00_INPUT } {
	# Procedure called to validate OUT00_INPUT
	return true
}

proc update_PARAM_VALUE.OUT01_INPUT { PARAM_VALUE.OUT01_INPUT } {
	# Procedure called to update OUT01_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT01_INPUT { PARAM_VALUE.OUT01_INPUT } {
	# Procedure called to validate OUT01_INPUT
	return true
}

proc update_PARAM_VALUE.OUT02_INPUT { PARAM_VALUE.OUT02_INPUT } {
	# Procedure called to update OUT02_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT02_INPUT { PARAM_VALUE.OUT02_INPUT } {
	# Procedure called to validate OUT02_INPUT
	return true
}

proc update_PARAM_VALUE.OUT03_INPUT { PARAM_VALUE.OUT03_INPUT } {
	# Procedure called to update OUT03_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT03_INPUT { PARAM_VALUE.OUT03_INPUT } {
	# Procedure called to validate OUT03_INPUT
	return true
}

proc update_PARAM_VALUE.OUT04_INPUT { PARAM_VALUE.OUT04_INPUT } {
	# Procedure called to update OUT04_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT04_INPUT { PARAM_VALUE.OUT04_INPUT } {
	# Procedure called to validate OUT04_INPUT
	return true
}

proc update_PARAM_VALUE.OUT05_INPUT { PARAM_VALUE.OUT05_INPUT } {
	# Procedure called to update OUT05_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT05_INPUT { PARAM_VALUE.OUT05_INPUT } {
	# Procedure called to validate OUT05_INPUT
	return true
}

proc update_PARAM_VALUE.OUT06_INPUT { PARAM_VALUE.OUT06_INPUT } {
	# Procedure called to update OUT06_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT06_INPUT { PARAM_VALUE.OUT06_INPUT } {
	# Procedure called to validate OUT06_INPUT
	return true
}

proc update_PARAM_VALUE.OUT07_INPUT { PARAM_VALUE.OUT07_INPUT } {
	# Procedure called to update OUT07_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT07_INPUT { PARAM_VALUE.OUT07_INPUT } {
	# Procedure called to validate OUT07_INPUT
	return true
}

proc update_PARAM_VALUE.OUT08_INPUT { PARAM_VALUE.OUT08_INPUT } {
	# Procedure called to update OUT08_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT08_INPUT { PARAM_VALUE.OUT08_INPUT } {
	# Procedure called to validate OUT08_INPUT
	return true
}

proc update_PARAM_VALUE.OUT09_INPUT { PARAM_VALUE.OUT09_INPUT } {
	# Procedure called to update OUT09_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT09_INPUT { PARAM_VALUE.OUT09_INPUT } {
	# Procedure called to validate OUT09_INPUT
	return true
}

proc update_PARAM_VALUE.OUT10_INPUT { PARAM_VALUE.OUT10_INPUT } {
	# Procedure called to update OUT10_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT10_INPUT { PARAM_VALUE.OUT10_INPUT } {
	# Procedure called to validate OUT10_INPUT
	return true
}

proc update_PARAM_VALUE.OUT11_INPUT { PARAM_VALUE.OUT11_INPUT } {
	# Procedure called to update OUT11_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT11_INPUT { PARAM_VALUE.OUT11_INPUT } {
	# Procedure called to validate OUT11_INPUT
	return true
}

proc update_PARAM_VALUE.OUT12_INPUT { PARAM_VALUE.OUT12_INPUT } {
	# Procedure called to update OUT12_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT12_INPUT { PARAM_VALUE.OUT12_INPUT } {
	# Procedure called to validate OUT12_INPUT
	return true
}

proc update_PARAM_VALUE.OUT13_INPUT { PARAM_VALUE.OUT13_INPUT } {
	# Procedure called to update OUT13_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT13_INPUT { PARAM_VALUE.OUT13_INPUT } {
	# Procedure called to validate OUT13_INPUT
	return true
}

proc update_PARAM_VALUE.OUT14_INPUT { PARAM_VALUE.OUT14_INPUT } {
	# Procedure called to update OUT14_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT14_INPUT { PARAM_VALUE.OUT14_INPUT } {
	# Procedure called to validate OUT14_INPUT
	return true
}

proc update_PARAM_VALUE.OUT15_INPUT { PARAM_VALUE.OUT15_INPUT } {
	# Procedure called to update OUT15_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT15_INPUT { PARAM_VALUE.OUT15_INPUT } {
	# Procedure called to validate OUT15_INPUT
	return true
}

proc update_PARAM_VALUE.OUT16_INPUT { PARAM_VALUE.OUT16_INPUT } {
	# Procedure called to update OUT16_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT16_INPUT { PARAM_VALUE.OUT16_INPUT } {
	# Procedure called to validate OUT16_INPUT
	return true
}

proc update_PARAM_VALUE.OUT17_INPUT { PARAM_VALUE.OUT17_INPUT } {
	# Procedure called to update OUT17_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT17_INPUT { PARAM_VALUE.OUT17_INPUT } {
	# Procedure called to validate OUT17_INPUT
	return true
}

proc update_PARAM_VALUE.OUT18_INPUT { PARAM_VALUE.OUT18_INPUT } {
	# Procedure called to update OUT18_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT18_INPUT { PARAM_VALUE.OUT18_INPUT } {
	# Procedure called to validate OUT18_INPUT
	return true
}

proc update_PARAM_VALUE.OUT19_INPUT { PARAM_VALUE.OUT19_INPUT } {
	# Procedure called to update OUT19_INPUT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT19_INPUT { PARAM_VALUE.OUT19_INPUT } {
	# Procedure called to validate OUT19_INPUT
	return true
}

proc update_PARAM_VALUE.WIDTH_00 { PARAM_VALUE.WIDTH_00 } {
	# Procedure called to update WIDTH_00 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_00 { PARAM_VALUE.WIDTH_00 } {
	# Procedure called to validate WIDTH_00
	return true
}

proc update_PARAM_VALUE.WIDTH_01 { PARAM_VALUE.WIDTH_01 } {
	# Procedure called to update WIDTH_01 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_01 { PARAM_VALUE.WIDTH_01 } {
	# Procedure called to validate WIDTH_01
	return true
}

proc update_PARAM_VALUE.WIDTH_02 { PARAM_VALUE.WIDTH_02 } {
	# Procedure called to update WIDTH_02 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_02 { PARAM_VALUE.WIDTH_02 } {
	# Procedure called to validate WIDTH_02
	return true
}

proc update_PARAM_VALUE.WIDTH_03 { PARAM_VALUE.WIDTH_03 } {
	# Procedure called to update WIDTH_03 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_03 { PARAM_VALUE.WIDTH_03 } {
	# Procedure called to validate WIDTH_03
	return true
}

proc update_PARAM_VALUE.WIDTH_04 { PARAM_VALUE.WIDTH_04 } {
	# Procedure called to update WIDTH_04 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_04 { PARAM_VALUE.WIDTH_04 } {
	# Procedure called to validate WIDTH_04
	return true
}

proc update_PARAM_VALUE.WIDTH_05 { PARAM_VALUE.WIDTH_05 } {
	# Procedure called to update WIDTH_05 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_05 { PARAM_VALUE.WIDTH_05 } {
	# Procedure called to validate WIDTH_05
	return true
}

proc update_PARAM_VALUE.WIDTH_06 { PARAM_VALUE.WIDTH_06 } {
	# Procedure called to update WIDTH_06 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_06 { PARAM_VALUE.WIDTH_06 } {
	# Procedure called to validate WIDTH_06
	return true
}

proc update_PARAM_VALUE.WIDTH_07 { PARAM_VALUE.WIDTH_07 } {
	# Procedure called to update WIDTH_07 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_07 { PARAM_VALUE.WIDTH_07 } {
	# Procedure called to validate WIDTH_07
	return true
}

proc update_PARAM_VALUE.WIDTH_08 { PARAM_VALUE.WIDTH_08 } {
	# Procedure called to update WIDTH_08 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_08 { PARAM_VALUE.WIDTH_08 } {
	# Procedure called to validate WIDTH_08
	return true
}

proc update_PARAM_VALUE.WIDTH_09 { PARAM_VALUE.WIDTH_09 } {
	# Procedure called to update WIDTH_09 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_09 { PARAM_VALUE.WIDTH_09 } {
	# Procedure called to validate WIDTH_09
	return true
}

proc update_PARAM_VALUE.WIDTH_10 { PARAM_VALUE.WIDTH_10 } {
	# Procedure called to update WIDTH_10 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_10 { PARAM_VALUE.WIDTH_10 } {
	# Procedure called to validate WIDTH_10
	return true
}

proc update_PARAM_VALUE.WIDTH_11 { PARAM_VALUE.WIDTH_11 } {
	# Procedure called to update WIDTH_11 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_11 { PARAM_VALUE.WIDTH_11 } {
	# Procedure called to validate WIDTH_11
	return true
}

proc update_PARAM_VALUE.WIDTH_12 { PARAM_VALUE.WIDTH_12 } {
	# Procedure called to update WIDTH_12 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_12 { PARAM_VALUE.WIDTH_12 } {
	# Procedure called to validate WIDTH_12
	return true
}

proc update_PARAM_VALUE.WIDTH_13 { PARAM_VALUE.WIDTH_13 } {
	# Procedure called to update WIDTH_13 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_13 { PARAM_VALUE.WIDTH_13 } {
	# Procedure called to validate WIDTH_13
	return true
}

proc update_PARAM_VALUE.WIDTH_14 { PARAM_VALUE.WIDTH_14 } {
	# Procedure called to update WIDTH_14 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_14 { PARAM_VALUE.WIDTH_14 } {
	# Procedure called to validate WIDTH_14
	return true
}

proc update_PARAM_VALUE.WIDTH_15 { PARAM_VALUE.WIDTH_15 } {
	# Procedure called to update WIDTH_15 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_15 { PARAM_VALUE.WIDTH_15 } {
	# Procedure called to validate WIDTH_15
	return true
}

proc update_PARAM_VALUE.WIDTH_16 { PARAM_VALUE.WIDTH_16 } {
	# Procedure called to update WIDTH_16 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_16 { PARAM_VALUE.WIDTH_16 } {
	# Procedure called to validate WIDTH_16
	return true
}

proc update_PARAM_VALUE.WIDTH_17 { PARAM_VALUE.WIDTH_17 } {
	# Procedure called to update WIDTH_17 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_17 { PARAM_VALUE.WIDTH_17 } {
	# Procedure called to validate WIDTH_17
	return true
}

proc update_PARAM_VALUE.WIDTH_18 { PARAM_VALUE.WIDTH_18 } {
	# Procedure called to update WIDTH_18 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_18 { PARAM_VALUE.WIDTH_18 } {
	# Procedure called to validate WIDTH_18
	return true
}

proc update_PARAM_VALUE.WIDTH_19 { PARAM_VALUE.WIDTH_19 } {
	# Procedure called to update WIDTH_19 when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WIDTH_19 { PARAM_VALUE.WIDTH_19 } {
	# Procedure called to validate WIDTH_19
	return true
}


proc update_MODELPARAM_VALUE.NUM_REGS { MODELPARAM_VALUE.NUM_REGS PARAM_VALUE.NUM_REGS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_REGS}] ${MODELPARAM_VALUE.NUM_REGS}
}

proc update_MODELPARAM_VALUE.OUT00_INPUT { MODELPARAM_VALUE.OUT00_INPUT PARAM_VALUE.OUT00_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT00_INPUT}] ${MODELPARAM_VALUE.OUT00_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_00 { MODELPARAM_VALUE.WIDTH_00 PARAM_VALUE.WIDTH_00 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_00}] ${MODELPARAM_VALUE.WIDTH_00}
}

proc update_MODELPARAM_VALUE.OUT01_INPUT { MODELPARAM_VALUE.OUT01_INPUT PARAM_VALUE.OUT01_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT01_INPUT}] ${MODELPARAM_VALUE.OUT01_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_01 { MODELPARAM_VALUE.WIDTH_01 PARAM_VALUE.WIDTH_01 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_01}] ${MODELPARAM_VALUE.WIDTH_01}
}

proc update_MODELPARAM_VALUE.OUT02_INPUT { MODELPARAM_VALUE.OUT02_INPUT PARAM_VALUE.OUT02_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT02_INPUT}] ${MODELPARAM_VALUE.OUT02_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_02 { MODELPARAM_VALUE.WIDTH_02 PARAM_VALUE.WIDTH_02 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_02}] ${MODELPARAM_VALUE.WIDTH_02}
}

proc update_MODELPARAM_VALUE.OUT03_INPUT { MODELPARAM_VALUE.OUT03_INPUT PARAM_VALUE.OUT03_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT03_INPUT}] ${MODELPARAM_VALUE.OUT03_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_03 { MODELPARAM_VALUE.WIDTH_03 PARAM_VALUE.WIDTH_03 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_03}] ${MODELPARAM_VALUE.WIDTH_03}
}

proc update_MODELPARAM_VALUE.OUT04_INPUT { MODELPARAM_VALUE.OUT04_INPUT PARAM_VALUE.OUT04_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT04_INPUT}] ${MODELPARAM_VALUE.OUT04_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_04 { MODELPARAM_VALUE.WIDTH_04 PARAM_VALUE.WIDTH_04 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_04}] ${MODELPARAM_VALUE.WIDTH_04}
}

proc update_MODELPARAM_VALUE.OUT05_INPUT { MODELPARAM_VALUE.OUT05_INPUT PARAM_VALUE.OUT05_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT05_INPUT}] ${MODELPARAM_VALUE.OUT05_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_05 { MODELPARAM_VALUE.WIDTH_05 PARAM_VALUE.WIDTH_05 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_05}] ${MODELPARAM_VALUE.WIDTH_05}
}

proc update_MODELPARAM_VALUE.OUT06_INPUT { MODELPARAM_VALUE.OUT06_INPUT PARAM_VALUE.OUT06_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT06_INPUT}] ${MODELPARAM_VALUE.OUT06_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_06 { MODELPARAM_VALUE.WIDTH_06 PARAM_VALUE.WIDTH_06 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_06}] ${MODELPARAM_VALUE.WIDTH_06}
}

proc update_MODELPARAM_VALUE.OUT07_INPUT { MODELPARAM_VALUE.OUT07_INPUT PARAM_VALUE.OUT07_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT07_INPUT}] ${MODELPARAM_VALUE.OUT07_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_07 { MODELPARAM_VALUE.WIDTH_07 PARAM_VALUE.WIDTH_07 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_07}] ${MODELPARAM_VALUE.WIDTH_07}
}

proc update_MODELPARAM_VALUE.OUT08_INPUT { MODELPARAM_VALUE.OUT08_INPUT PARAM_VALUE.OUT08_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT08_INPUT}] ${MODELPARAM_VALUE.OUT08_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_08 { MODELPARAM_VALUE.WIDTH_08 PARAM_VALUE.WIDTH_08 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_08}] ${MODELPARAM_VALUE.WIDTH_08}
}

proc update_MODELPARAM_VALUE.OUT09_INPUT { MODELPARAM_VALUE.OUT09_INPUT PARAM_VALUE.OUT09_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT09_INPUT}] ${MODELPARAM_VALUE.OUT09_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_09 { MODELPARAM_VALUE.WIDTH_09 PARAM_VALUE.WIDTH_09 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_09}] ${MODELPARAM_VALUE.WIDTH_09}
}

proc update_MODELPARAM_VALUE.OUT10_INPUT { MODELPARAM_VALUE.OUT10_INPUT PARAM_VALUE.OUT10_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT10_INPUT}] ${MODELPARAM_VALUE.OUT10_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_10 { MODELPARAM_VALUE.WIDTH_10 PARAM_VALUE.WIDTH_10 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_10}] ${MODELPARAM_VALUE.WIDTH_10}
}

proc update_MODELPARAM_VALUE.OUT11_INPUT { MODELPARAM_VALUE.OUT11_INPUT PARAM_VALUE.OUT11_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT11_INPUT}] ${MODELPARAM_VALUE.OUT11_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_11 { MODELPARAM_VALUE.WIDTH_11 PARAM_VALUE.WIDTH_11 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_11}] ${MODELPARAM_VALUE.WIDTH_11}
}

proc update_MODELPARAM_VALUE.OUT12_INPUT { MODELPARAM_VALUE.OUT12_INPUT PARAM_VALUE.OUT12_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT12_INPUT}] ${MODELPARAM_VALUE.OUT12_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_12 { MODELPARAM_VALUE.WIDTH_12 PARAM_VALUE.WIDTH_12 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_12}] ${MODELPARAM_VALUE.WIDTH_12}
}

proc update_MODELPARAM_VALUE.OUT13_INPUT { MODELPARAM_VALUE.OUT13_INPUT PARAM_VALUE.OUT13_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT13_INPUT}] ${MODELPARAM_VALUE.OUT13_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_13 { MODELPARAM_VALUE.WIDTH_13 PARAM_VALUE.WIDTH_13 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_13}] ${MODELPARAM_VALUE.WIDTH_13}
}

proc update_MODELPARAM_VALUE.OUT14_INPUT { MODELPARAM_VALUE.OUT14_INPUT PARAM_VALUE.OUT14_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT14_INPUT}] ${MODELPARAM_VALUE.OUT14_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_14 { MODELPARAM_VALUE.WIDTH_14 PARAM_VALUE.WIDTH_14 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_14}] ${MODELPARAM_VALUE.WIDTH_14}
}

proc update_MODELPARAM_VALUE.OUT15_INPUT { MODELPARAM_VALUE.OUT15_INPUT PARAM_VALUE.OUT15_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT15_INPUT}] ${MODELPARAM_VALUE.OUT15_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_15 { MODELPARAM_VALUE.WIDTH_15 PARAM_VALUE.WIDTH_15 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_15}] ${MODELPARAM_VALUE.WIDTH_15}
}

proc update_MODELPARAM_VALUE.OUT16_INPUT { MODELPARAM_VALUE.OUT16_INPUT PARAM_VALUE.OUT16_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT16_INPUT}] ${MODELPARAM_VALUE.OUT16_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_16 { MODELPARAM_VALUE.WIDTH_16 PARAM_VALUE.WIDTH_16 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_16}] ${MODELPARAM_VALUE.WIDTH_16}
}

proc update_MODELPARAM_VALUE.OUT17_INPUT { MODELPARAM_VALUE.OUT17_INPUT PARAM_VALUE.OUT17_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT17_INPUT}] ${MODELPARAM_VALUE.OUT17_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_17 { MODELPARAM_VALUE.WIDTH_17 PARAM_VALUE.WIDTH_17 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_17}] ${MODELPARAM_VALUE.WIDTH_17}
}

proc update_MODELPARAM_VALUE.OUT18_INPUT { MODELPARAM_VALUE.OUT18_INPUT PARAM_VALUE.OUT18_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT18_INPUT}] ${MODELPARAM_VALUE.OUT18_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_18 { MODELPARAM_VALUE.WIDTH_18 PARAM_VALUE.WIDTH_18 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_18}] ${MODELPARAM_VALUE.WIDTH_18}
}

proc update_MODELPARAM_VALUE.OUT19_INPUT { MODELPARAM_VALUE.OUT19_INPUT PARAM_VALUE.OUT19_INPUT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT19_INPUT}] ${MODELPARAM_VALUE.OUT19_INPUT}
}

proc update_MODELPARAM_VALUE.WIDTH_19 { MODELPARAM_VALUE.WIDTH_19 PARAM_VALUE.WIDTH_19 } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WIDTH_19}] ${MODELPARAM_VALUE.WIDTH_19}
}

proc update_MODELPARAM_VALUE.BRAM_WIDTH { MODELPARAM_VALUE.BRAM_WIDTH PARAM_VALUE.BRAM_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BRAM_WIDTH}] ${MODELPARAM_VALUE.BRAM_WIDTH}
}

