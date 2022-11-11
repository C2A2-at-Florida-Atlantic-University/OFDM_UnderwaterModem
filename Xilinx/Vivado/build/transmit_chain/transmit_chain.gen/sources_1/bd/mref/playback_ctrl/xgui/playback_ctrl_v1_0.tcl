# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "g_CLOCK_CYCLES" -parent ${Page_0}
  ipgui::add_param $IPINST -name "g_NUM_SYMBOLS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "g_SYMBOL_LENGTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.g_CLOCK_CYCLES { PARAM_VALUE.g_CLOCK_CYCLES } {
	# Procedure called to update g_CLOCK_CYCLES when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.g_CLOCK_CYCLES { PARAM_VALUE.g_CLOCK_CYCLES } {
	# Procedure called to validate g_CLOCK_CYCLES
	return true
}

proc update_PARAM_VALUE.g_NUM_SYMBOLS { PARAM_VALUE.g_NUM_SYMBOLS } {
	# Procedure called to update g_NUM_SYMBOLS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.g_NUM_SYMBOLS { PARAM_VALUE.g_NUM_SYMBOLS } {
	# Procedure called to validate g_NUM_SYMBOLS
	return true
}

proc update_PARAM_VALUE.g_SYMBOL_LENGTH { PARAM_VALUE.g_SYMBOL_LENGTH } {
	# Procedure called to update g_SYMBOL_LENGTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.g_SYMBOL_LENGTH { PARAM_VALUE.g_SYMBOL_LENGTH } {
	# Procedure called to validate g_SYMBOL_LENGTH
	return true
}


proc update_MODELPARAM_VALUE.g_CLOCK_CYCLES { MODELPARAM_VALUE.g_CLOCK_CYCLES PARAM_VALUE.g_CLOCK_CYCLES } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.g_CLOCK_CYCLES}] ${MODELPARAM_VALUE.g_CLOCK_CYCLES}
}

proc update_MODELPARAM_VALUE.g_SYMBOL_LENGTH { MODELPARAM_VALUE.g_SYMBOL_LENGTH PARAM_VALUE.g_SYMBOL_LENGTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.g_SYMBOL_LENGTH}] ${MODELPARAM_VALUE.g_SYMBOL_LENGTH}
}

proc update_MODELPARAM_VALUE.g_NUM_SYMBOLS { MODELPARAM_VALUE.g_NUM_SYMBOLS PARAM_VALUE.g_NUM_SYMBOLS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.g_NUM_SYMBOLS}] ${MODELPARAM_VALUE.g_NUM_SYMBOLS}
}

