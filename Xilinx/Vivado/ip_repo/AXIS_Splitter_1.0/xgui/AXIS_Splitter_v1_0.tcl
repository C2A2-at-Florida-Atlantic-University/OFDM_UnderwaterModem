# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  ipgui::add_page $IPINST -name "Page 0"

  ipgui::add_param $IPINST -name "AXIS_TDATA_WIDTH"
  ipgui::add_param $IPINST -name "M_TREADY_ANDED_TVALID"

}

proc update_PARAM_VALUE.AXIS_TDATA_WIDTH { PARAM_VALUE.AXIS_TDATA_WIDTH } {
	# Procedure called to update AXIS_TDATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AXIS_TDATA_WIDTH { PARAM_VALUE.AXIS_TDATA_WIDTH } {
	# Procedure called to validate AXIS_TDATA_WIDTH
	return true
}

proc update_PARAM_VALUE.M_TREADY_ANDED_TVALID { PARAM_VALUE.M_TREADY_ANDED_TVALID } {
	# Procedure called to update M_TREADY_ANDED_TVALID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.M_TREADY_ANDED_TVALID { PARAM_VALUE.M_TREADY_ANDED_TVALID } {
	# Procedure called to validate M_TREADY_ANDED_TVALID
	return true
}


proc update_MODELPARAM_VALUE.AXIS_TDATA_WIDTH { MODELPARAM_VALUE.AXIS_TDATA_WIDTH PARAM_VALUE.AXIS_TDATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AXIS_TDATA_WIDTH}] ${MODELPARAM_VALUE.AXIS_TDATA_WIDTH}
}

proc update_MODELPARAM_VALUE.M_TREADY_ANDED_TVALID { MODELPARAM_VALUE.M_TREADY_ANDED_TVALID PARAM_VALUE.M_TREADY_ANDED_TVALID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.M_TREADY_ANDED_TVALID}] ${MODELPARAM_VALUE.M_TREADY_ANDED_TVALID}
}

