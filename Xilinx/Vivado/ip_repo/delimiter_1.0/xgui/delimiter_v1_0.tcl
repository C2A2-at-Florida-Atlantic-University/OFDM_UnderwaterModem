# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "IN0_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NUM_OUTPUTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUT0_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUT1_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUT2_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUT3_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUT4_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUT5_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUT6_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "OUT7_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.IN0_WIDTH { PARAM_VALUE.IN0_WIDTH } {
	# Procedure called to update IN0_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IN0_WIDTH { PARAM_VALUE.IN0_WIDTH } {
	# Procedure called to validate IN0_WIDTH
	return true
}

proc update_PARAM_VALUE.NUM_OUTPUTS { PARAM_VALUE.NUM_OUTPUTS } {
	# Procedure called to update NUM_OUTPUTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NUM_OUTPUTS { PARAM_VALUE.NUM_OUTPUTS } {
	# Procedure called to validate NUM_OUTPUTS
	return true
}

proc update_PARAM_VALUE.OUT0_WIDTH { PARAM_VALUE.OUT0_WIDTH } {
	# Procedure called to update OUT0_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT0_WIDTH { PARAM_VALUE.OUT0_WIDTH } {
	# Procedure called to validate OUT0_WIDTH
	return true
}

proc update_PARAM_VALUE.OUT1_WIDTH { PARAM_VALUE.OUT1_WIDTH } {
	# Procedure called to update OUT1_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT1_WIDTH { PARAM_VALUE.OUT1_WIDTH } {
	# Procedure called to validate OUT1_WIDTH
	return true
}

proc update_PARAM_VALUE.OUT2_WIDTH { PARAM_VALUE.OUT2_WIDTH } {
	# Procedure called to update OUT2_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT2_WIDTH { PARAM_VALUE.OUT2_WIDTH } {
	# Procedure called to validate OUT2_WIDTH
	return true
}

proc update_PARAM_VALUE.OUT3_WIDTH { PARAM_VALUE.OUT3_WIDTH } {
	# Procedure called to update OUT3_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT3_WIDTH { PARAM_VALUE.OUT3_WIDTH } {
	# Procedure called to validate OUT3_WIDTH
	return true
}

proc update_PARAM_VALUE.OUT4_WIDTH { PARAM_VALUE.OUT4_WIDTH } {
	# Procedure called to update OUT4_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT4_WIDTH { PARAM_VALUE.OUT4_WIDTH } {
	# Procedure called to validate OUT4_WIDTH
	return true
}

proc update_PARAM_VALUE.OUT5_WIDTH { PARAM_VALUE.OUT5_WIDTH } {
	# Procedure called to update OUT5_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT5_WIDTH { PARAM_VALUE.OUT5_WIDTH } {
	# Procedure called to validate OUT5_WIDTH
	return true
}

proc update_PARAM_VALUE.OUT6_WIDTH { PARAM_VALUE.OUT6_WIDTH } {
	# Procedure called to update OUT6_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT6_WIDTH { PARAM_VALUE.OUT6_WIDTH } {
	# Procedure called to validate OUT6_WIDTH
	return true
}

proc update_PARAM_VALUE.OUT7_WIDTH { PARAM_VALUE.OUT7_WIDTH } {
	# Procedure called to update OUT7_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.OUT7_WIDTH { PARAM_VALUE.OUT7_WIDTH } {
	# Procedure called to validate OUT7_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.IN0_WIDTH { MODELPARAM_VALUE.IN0_WIDTH PARAM_VALUE.IN0_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IN0_WIDTH}] ${MODELPARAM_VALUE.IN0_WIDTH}
}

proc update_MODELPARAM_VALUE.NUM_OUTPUTS { MODELPARAM_VALUE.NUM_OUTPUTS PARAM_VALUE.NUM_OUTPUTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NUM_OUTPUTS}] ${MODELPARAM_VALUE.NUM_OUTPUTS}
}

proc update_MODELPARAM_VALUE.OUT0_WIDTH { MODELPARAM_VALUE.OUT0_WIDTH PARAM_VALUE.OUT0_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT0_WIDTH}] ${MODELPARAM_VALUE.OUT0_WIDTH}
}

proc update_MODELPARAM_VALUE.OUT1_WIDTH { MODELPARAM_VALUE.OUT1_WIDTH PARAM_VALUE.OUT1_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT1_WIDTH}] ${MODELPARAM_VALUE.OUT1_WIDTH}
}

proc update_MODELPARAM_VALUE.OUT2_WIDTH { MODELPARAM_VALUE.OUT2_WIDTH PARAM_VALUE.OUT2_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT2_WIDTH}] ${MODELPARAM_VALUE.OUT2_WIDTH}
}

proc update_MODELPARAM_VALUE.OUT3_WIDTH { MODELPARAM_VALUE.OUT3_WIDTH PARAM_VALUE.OUT3_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT3_WIDTH}] ${MODELPARAM_VALUE.OUT3_WIDTH}
}

proc update_MODELPARAM_VALUE.OUT4_WIDTH { MODELPARAM_VALUE.OUT4_WIDTH PARAM_VALUE.OUT4_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT4_WIDTH}] ${MODELPARAM_VALUE.OUT4_WIDTH}
}

proc update_MODELPARAM_VALUE.OUT5_WIDTH { MODELPARAM_VALUE.OUT5_WIDTH PARAM_VALUE.OUT5_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT5_WIDTH}] ${MODELPARAM_VALUE.OUT5_WIDTH}
}

proc update_MODELPARAM_VALUE.OUT6_WIDTH { MODELPARAM_VALUE.OUT6_WIDTH PARAM_VALUE.OUT6_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT6_WIDTH}] ${MODELPARAM_VALUE.OUT6_WIDTH}
}

proc update_MODELPARAM_VALUE.OUT7_WIDTH { MODELPARAM_VALUE.OUT7_WIDTH PARAM_VALUE.OUT7_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.OUT7_WIDTH}] ${MODELPARAM_VALUE.OUT7_WIDTH}
}

