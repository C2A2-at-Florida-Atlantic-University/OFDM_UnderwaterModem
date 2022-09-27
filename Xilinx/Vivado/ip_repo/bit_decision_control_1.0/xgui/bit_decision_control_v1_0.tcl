# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "C_S00_AXIS_TDATA_WIDTH" -parent ${Page_0}

  ipgui::add_param $IPINST -name "BRAM_addr_width"
  ipgui::add_param $IPINST -name "Passthrough_num"

}

proc update_PARAM_VALUE.BRAM_addr_width { PARAM_VALUE.BRAM_addr_width } {
	# Procedure called to update BRAM_addr_width when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BRAM_addr_width { PARAM_VALUE.BRAM_addr_width } {
	# Procedure called to validate BRAM_addr_width
	return true
}

proc update_PARAM_VALUE.Passthrough_num { PARAM_VALUE.Passthrough_num } {
	# Procedure called to update Passthrough_num when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Passthrough_num { PARAM_VALUE.Passthrough_num } {
	# Procedure called to validate Passthrough_num
	return true
}

proc update_PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to update C_S00_AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to validate C_S00_AXIS_TDATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH { MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.BRAM_addr_width { MODELPARAM_VALUE.BRAM_addr_width PARAM_VALUE.BRAM_addr_width } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BRAM_addr_width}] ${MODELPARAM_VALUE.BRAM_addr_width}
}

proc update_MODELPARAM_VALUE.Passthrough_num { MODELPARAM_VALUE.Passthrough_num PARAM_VALUE.Passthrough_num } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Passthrough_num}] ${MODELPARAM_VALUE.Passthrough_num}
}

