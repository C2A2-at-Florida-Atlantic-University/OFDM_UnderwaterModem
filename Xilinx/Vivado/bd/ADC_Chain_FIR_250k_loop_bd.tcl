
################################################################
# This is a generated script based on design: ADC_Chain
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2022.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   common::send_gid_msg -ssname BD::TCL -id 2040 -severity "WARNING" "This script was generated using Vivado <$scripts_vivado_version> without IP versions in the create_bd_cell commands, but is now being run in <$current_vivado_version> of Vivado. There may have been major IP version changes between Vivado <$scripts_vivado_version> and <$current_vivado_version>, which could impact the parameter settings of the IPs."

}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source ADC_Chain_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# peak_sample_100M, decimator_config2, iq_concat, iq_mixer_rx_100M, iq_tdm_concat, peak_sample_duc, tdm_reformat_rx

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name ADC_Chain

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:cic_compiler:*\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
peak_sample_100M\
decimator_config2\
iq_concat\
iq_mixer_rx_100M\
iq_tdm_concat\
peak_sample_duc\
tdm_reformat_rx\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: DDC_Mixer
proc create_hier_cell_DDC_Mixer { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_DDC_Mixer() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_cic

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_dds_0


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst axis_aresetn
  create_bd_pin -dir I -from 15 -to 0 decimate_ratio
  create_bd_pin -dir I -from 1 -to 0 i_gain_shift_ddc
  create_bd_pin -dir I -from 2 -to 0 i_gain_shift_mixer
  create_bd_pin -dir I i_trigger
  create_bd_pin -dir O -from 31 -to 0 o_iq_square_sum_ddc

  # Create instance: cic_compiler, and set properties
  set cic_compiler [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler cic_compiler ]
  set_property -dict [ list \
   CONFIG.Clock_Frequency {100.0000000} \
   CONFIG.Filter_Type {Decimation} \
   CONFIG.Fixed_Or_Initial_Rate {160} \
   CONFIG.Input_Data_Width {16} \
   CONFIG.Input_Sample_Frequency {40} \
   CONFIG.Maximum_Rate {1600} \
   CONFIG.Minimum_Rate {4} \
   CONFIG.Number_Of_Channels {2} \
   CONFIG.Number_Of_Stages {2} \
   CONFIG.Output_Data_Width {16} \
   CONFIG.Quantization {Truncation} \
   CONFIG.SamplePeriod {1} \
   CONFIG.Sample_Rate_Changes {Programmable} \
 ] $cic_compiler

  # Create instance: decimator_config2_0, and set properties
  set block_name decimator_config2
  set block_cell_name decimator_config2_0
  if { [catch {set decimator_config2_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $decimator_config2_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.g_DEFAULT_RATE {0x00A0} \
 ] $decimator_config2_0

  # Create instance: iq_concat_0, and set properties
  set block_name iq_concat
  set block_cell_name iq_concat_0
  if { [catch {set iq_concat_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $iq_concat_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.g_TDATA_WIDTH {16} \
 ] $iq_concat_0

  # Create instance: iq_mixer_rx_100M_0, and set properties
  set block_name iq_mixer_rx_100M
  set block_cell_name iq_mixer_rx_100M_0
  if { [catch {set iq_mixer_rx_100M_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $iq_mixer_rx_100M_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.g_ILA {false} \
 ] $iq_mixer_rx_100M_0

  # Create instance: iq_tdm_concat_0, and set properties
  set block_name iq_tdm_concat
  set block_cell_name iq_tdm_concat_0
  if { [catch {set iq_tdm_concat_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $iq_tdm_concat_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.g_ILA {false} \
 ] $iq_tdm_concat_0

  # Create instance: peak_sample_duc_0, and set properties
  set block_name peak_sample_duc
  set block_cell_name peak_sample_duc_0
  if { [catch {set peak_sample_duc_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $peak_sample_duc_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: tdm_reformat_rx_0, and set properties
  set block_name tdm_reformat_rx
  set block_cell_name tdm_reformat_rx_0
  if { [catch {set tdm_reformat_rx_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $tdm_reformat_rx_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.g_ILA {false} \
 ] $tdm_reformat_rx_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins s_axis_dds_0] [get_bd_intf_pins iq_mixer_rx_100M_0/s_axis_dds]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins s_axis_cic] [get_bd_intf_pins peak_sample_duc_0/s_axis]
  connect_bd_intf_net -intf_net cic_compiler_M_AXIS_DATA [get_bd_intf_pins cic_compiler/M_AXIS_DATA] [get_bd_intf_pins iq_tdm_concat_0/s_axis]
  connect_bd_intf_net -intf_net decimator_config2_0_m_axis [get_bd_intf_pins cic_compiler/S_AXIS_CONFIG] [get_bd_intf_pins decimator_config2_0/m_axis]
  connect_bd_intf_net -intf_net iq_concat_0_m_axis [get_bd_intf_pins iq_concat_0/m_axis] [get_bd_intf_pins tdm_reformat_rx_0/s_axis]
  connect_bd_intf_net -intf_net iq_mixer_rx_100M_0_m_axis_imag [get_bd_intf_pins iq_concat_0/s_axis_imag] [get_bd_intf_pins iq_mixer_rx_100M_0/m_axis_imag]
  connect_bd_intf_net -intf_net iq_mixer_rx_100M_0_m_axis_real [get_bd_intf_pins iq_concat_0/s_axis_real] [get_bd_intf_pins iq_mixer_rx_100M_0/m_axis_real]
  connect_bd_intf_net -intf_net iq_tdm_concat_0_m_axis [get_bd_intf_pins M_AXIS] [get_bd_intf_pins iq_tdm_concat_0/m_axis]
  connect_bd_intf_net -intf_net peak_sample_duc_0_m_axis [get_bd_intf_pins cic_compiler/S_AXIS_DATA] [get_bd_intf_pins peak_sample_duc_0/m_axis]
  connect_bd_intf_net -intf_net s_axis_1 [get_bd_intf_pins s_axis] [get_bd_intf_pins iq_mixer_rx_100M_0/s_axis]

  # Create port connections
  connect_bd_net -net aclk_1 [get_bd_pins aclk] [get_bd_pins cic_compiler/aclk] [get_bd_pins decimator_config2_0/axis_aclk] [get_bd_pins iq_concat_0/axis_aclk] [get_bd_pins iq_mixer_rx_100M_0/axis_aclk] [get_bd_pins iq_tdm_concat_0/aclk] [get_bd_pins peak_sample_duc_0/aclk] [get_bd_pins tdm_reformat_rx_0/aclk]
  connect_bd_net -net axis_aresetn_0_1 [get_bd_pins axis_aresetn] [get_bd_pins iq_mixer_rx_100M_0/axis_aresetn]
  connect_bd_net -net decimate_ratio_1 [get_bd_pins decimate_ratio] [get_bd_pins decimator_config2_0/i_decimate_ratio]
  connect_bd_net -net i_gain_shift_0_2 [get_bd_pins i_gain_shift_ddc] [get_bd_pins iq_tdm_concat_0/i_gain_shift]
  connect_bd_net -net i_gain_shift_mixer_1 [get_bd_pins i_gain_shift_mixer] [get_bd_pins iq_mixer_rx_100M_0/i_gain_shift]
  connect_bd_net -net i_trigger_1 [get_bd_pins i_trigger] [get_bd_pins peak_sample_duc_0/i_trigger]
  connect_bd_net -net peak_sample_duc_0_o_iq_square [get_bd_pins o_iq_square_sum_ddc] [get_bd_pins peak_sample_duc_0/o_iq_square]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set M_AXIS [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS ]

  set s_axis [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {0} \
   CONFIG.HAS_TREADY {0} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {2} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $s_axis

  set s_axis_cic [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_cic ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {0} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {2} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $s_axis_cic

  set s_axis_dds_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_dds_0 ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {0} \
   CONFIG.HAS_TREADY {0} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chan} size {attribs {resolve_type generated dependency chan_size format long minimum {} maximum {}} value 1} stride {attribs {resolve_type generated dependency chan_stride format long minimum {} maximum {}} value 32} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_cosine {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value cosine} enabled {attribs {resolve_type generated dependency cosine_enabled format bool minimum {} maximum {}} value true} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency cosine_width format long minimum {} maximum {}} value 16} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency cosine_fractwidth format long minimum {} maximum {}} value 14} signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}} field_sine {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value sine} enabled {attribs {resolve_type generated dependency sine_enabled format bool minimum {} maximum {}} value true} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency sine_width format long minimum {} maximum {}} value 16} bitoffset {attribs {resolve_type generated dependency sine_offset format long minimum {} maximum {}} value 16} real {fixed {fractwidth {attribs {resolve_type generated dependency sine_fractwidth format long minimum {} maximum {}} value 14} signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}}}}}}} TDATA_WIDTH 32 TUSER {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_chanid {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chanid} enabled {attribs {resolve_type generated dependency chanid_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency chanid_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} field_user {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value user} enabled {attribs {resolve_type generated dependency user_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency user_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency user_offset format long minimum {} maximum {}} value 0}}}}}} TUSER_WIDTH 0}} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $s_axis_dds_0


  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M_AXIS:s_axis:s_axis_dds_0:s_axis_cic} \
   CONFIG.ASSOCIATED_RESET {resetn_0:axis_aresetn_0} \
 ] $aclk
  set axis_aresetn_0 [ create_bd_port -dir I -type rst axis_aresetn_0 ]
  set decimate_ratio [ create_bd_port -dir I -from 15 -to 0 decimate_ratio ]
  set i_gain_shift_ddc [ create_bd_port -dir I -from 1 -to 0 i_gain_shift_ddc ]
  set i_gain_shift_mixer [ create_bd_port -dir I -from 2 -to 0 i_gain_shift_mixer ]
  set i_trigger [ create_bd_port -dir I i_trigger ]
  set o_iq_square_sum_ddc [ create_bd_port -dir O -from 31 -to 0 o_iq_square_sum_ddc ]
  set o_peak_sample_adc [ create_bd_port -dir O -from 15 -to 0 o_peak_sample_adc ]

  # Create instance: DDC_Mixer
  create_hier_cell_DDC_Mixer [current_bd_instance .] DDC_Mixer

  # Create instance: peak_sample_100M_0, and set properties
  set block_name peak_sample_100M
  set block_cell_name peak_sample_100M_0
  if { [catch {set peak_sample_100M_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $peak_sample_100M_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net DDC_Mixer_M_AXIS [get_bd_intf_ports M_AXIS] [get_bd_intf_pins DDC_Mixer/M_AXIS]
  connect_bd_intf_net -intf_net peak_sample_100M_0_m_axis [get_bd_intf_pins DDC_Mixer/s_axis] [get_bd_intf_pins peak_sample_100M_0/m_axis]
  connect_bd_intf_net -intf_net s_axis_0_1 [get_bd_intf_ports s_axis_cic] [get_bd_intf_pins DDC_Mixer/s_axis_cic]
  connect_bd_intf_net -intf_net s_axis_1 [get_bd_intf_ports s_axis] [get_bd_intf_pins peak_sample_100M_0/s_axis]
  connect_bd_intf_net -intf_net s_axis_dds_0_1 [get_bd_intf_ports s_axis_dds_0] [get_bd_intf_pins DDC_Mixer/s_axis_dds_0]

  # Create port connections
  connect_bd_net -net DDC_Mixer_o_iq_square_0 [get_bd_ports o_iq_square_sum_ddc] [get_bd_pins DDC_Mixer/o_iq_square_sum_ddc]
  connect_bd_net -net aclk_1 [get_bd_ports aclk] [get_bd_pins DDC_Mixer/aclk] [get_bd_pins peak_sample_100M_0/aclk]
  connect_bd_net -net axis_aresetn_0_1 [get_bd_ports axis_aresetn_0] [get_bd_pins DDC_Mixer/axis_aresetn]
  connect_bd_net -net decimate_ratio_1 [get_bd_ports decimate_ratio] [get_bd_pins DDC_Mixer/decimate_ratio]
  connect_bd_net -net i_gain_shift_0_1 [get_bd_ports i_gain_shift_mixer] [get_bd_pins DDC_Mixer/i_gain_shift_mixer]
  connect_bd_net -net i_gain_shift_0_3 [get_bd_ports i_gain_shift_ddc] [get_bd_pins DDC_Mixer/i_gain_shift_ddc]
  connect_bd_net -net i_trigger_1 [get_bd_ports i_trigger] [get_bd_pins DDC_Mixer/i_trigger] [get_bd_pins peak_sample_100M_0/i_trigger]
  connect_bd_net -net peak_sample_100M_0_o_peak_sample [get_bd_ports o_peak_sample_adc] [get_bd_pins peak_sample_100M_0/o_peak_sample]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


