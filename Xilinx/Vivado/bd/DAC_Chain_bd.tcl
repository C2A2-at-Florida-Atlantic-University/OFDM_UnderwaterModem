
################################################################
# This is a generated script based on design: DAC_Chain
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
# source DAC_Chain_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# sign_conversion, tdm_reformat_tx, decimator_config, iq_mixer_tx

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
set design_name DAC_Chain

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
xilinx.com:user:AXIS_S_to_AD9764:*\
xilinx.com:ip:axis_data_fifo:*\
xilinx.com:ip:cic_compiler:*\
xilinx.com:ip:dds_compiler:*\
xilinx.com:ip:xlconstant:*\
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
sign_conversion\
tdm_reformat_tx\
decimator_config\
iq_mixer_tx\
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


# Hierarchical cell: DUC_Mixer
proc create_hier_cell_DUC_Mixer { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_DUC_Mixer() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DATA

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DATA


  # Create pins
  create_bd_pin -dir I -from 31 -to 0 Fc_scaled
  create_bd_pin -dir I -from 15 -to 0 Interp_ratio
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: cic_compiler, and set properties
  set cic_compiler [ create_bd_cell -type ip -vlnv xilinx.com:ip:cic_compiler cic_compiler ]
  set_property -dict [ list \
   CONFIG.Clock_Frequency {100} \
   CONFIG.Fixed_Or_Initial_Rate {40} \
   CONFIG.Input_Data_Width {16} \
   CONFIG.Input_Sample_Frequency {1} \
   CONFIG.Maximum_Rate {400} \
   CONFIG.Minimum_Rate {10} \
   CONFIG.Number_Of_Channels {2} \
   CONFIG.Number_Of_Stages {2} \
   CONFIG.Output_Data_Width {16} \
   CONFIG.Quantization {Truncation} \
   CONFIG.Sample_Rate_Changes {Programmable} \
 ] $cic_compiler

  # Create instance: dds_compiler_0, and set properties
  set dds_compiler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler dds_compiler_0 ]
  set_property -dict [ list \
   CONFIG.Amplitude_Mode {Unit_Circle} \
   CONFIG.DATA_Has_TLAST {Not_Required} \
   CONFIG.Has_Phase_Out {false} \
   CONFIG.Latency {7} \
   CONFIG.M_DATA_Has_TUSER {Not_Required} \
   CONFIG.Negative_Sine {true} \
   CONFIG.Noise_Shaping {None} \
   CONFIG.Output_Frequency1 {0} \
   CONFIG.Output_Width {16} \
   CONFIG.PINC1 {0} \
   CONFIG.Parameter_Entry {Hardware_Parameters} \
   CONFIG.Phase_Increment {Streaming} \
   CONFIG.Phase_Width {32} \
   CONFIG.S_PHASE_Has_TUSER {Not_Required} \
 ] $dds_compiler_0

  # Create instance: interpolator_config, and set properties
  set block_name decimator_config
  set block_cell_name interpolator_config
  if { [catch {set interpolator_config [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $interpolator_config eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: iq_mixer_tx, and set properties
  set block_name iq_mixer_tx
  set block_cell_name iq_mixer_tx
  if { [catch {set iq_mixer_tx [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $iq_mixer_tx eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant xlconstant_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net cic_compiler_0_M_AXIS_DATA [get_bd_intf_pins cic_compiler/M_AXIS_DATA] [get_bd_intf_pins iq_mixer_tx/s_axis]
  connect_bd_intf_net -intf_net dds_compiler_0_M_AXIS_DATA [get_bd_intf_pins dds_compiler_0/M_AXIS_DATA] [get_bd_intf_pins iq_mixer_tx/s_axis_dds]
  connect_bd_intf_net -intf_net decimator_config_0_m_axis [get_bd_intf_pins cic_compiler/S_AXIS_CONFIG] [get_bd_intf_pins interpolator_config/m_axis]
  connect_bd_intf_net -intf_net iq_mixer_tx_0_m_axis [get_bd_intf_pins M_AXIS_DATA] [get_bd_intf_pins iq_mixer_tx/m_axis]
  connect_bd_intf_net -intf_net tdm_reformat_tx_0_m_axis [get_bd_intf_pins S_AXIS_DATA] [get_bd_intf_pins cic_compiler/S_AXIS_DATA]

  # Create port connections
  connect_bd_net -net aclk_1 [get_bd_pins aclk] [get_bd_pins cic_compiler/aclk] [get_bd_pins dds_compiler_0/aclk] [get_bd_pins interpolator_config/axis_aclk] [get_bd_pins iq_mixer_tx/axis_aclk]
  connect_bd_net -net aresetn_1 [get_bd_pins aresetn] [get_bd_pins iq_mixer_tx/axis_aresetn]
  connect_bd_net -net i_decimate_ratio_0_1 [get_bd_pins Interp_ratio] [get_bd_pins interpolator_config/i_decimate_ratio]
  connect_bd_net -net s_axis_phase_tdata_0_1 [get_bd_pins Fc_scaled] [get_bd_pins dds_compiler_0/s_axis_phase_tdata]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins dds_compiler_0/s_axis_phase_tvalid] [get_bd_pins xlconstant_0/dout]

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
  set S_AXIS [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S_AXIS


  # Create ports
  set ClockToDAC [ create_bd_port -dir O ClockToDAC ]
  set DAC_control [ create_bd_port -dir I -from 3 -to 0 DAC_control ]
  set DAC_data [ create_bd_port -dir O -from 13 -to 0 DAC_data ]
  set DAC_sleep [ create_bd_port -dir O DAC_sleep ]
  set Fc_scaled [ create_bd_port -dir I -from 31 -to 0 Fc_scaled ]
  set Interp_ratio [ create_bd_port -dir I -from 15 -to 0 Interp_ratio ]
  set PA_enable [ create_bd_port -dir O PA_enable ]
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S_AXIS} \
 ] $aclk
  set aclk_10M [ create_bd_port -dir I -type clk -freq_hz 10000000 aclk_10M ]
  set aresetn [ create_bd_port -dir I -type rst aresetn ]
  set aresetn_10M [ create_bd_port -dir I -type rst aresetn_10M ]

  # Create instance: AXIS_S_to_AD9764, and set properties
  set AXIS_S_to_AD9764 [ create_bd_cell -type ip -vlnv xilinx.com:user:AXIS_S_to_AD9764 AXIS_S_to_AD9764 ]
  set_property -dict [ list \
   CONFIG.C_S00_AXIS_TDATA_WIDTH {16} \
 ] $AXIS_S_to_AD9764

  # Create instance: DUC_Mixer
  create_hier_cell_DUC_Mixer [current_bd_instance .] DUC_Mixer

  # Create instance: axis_data_fifo, and set properties
  set axis_data_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo ]
  set_property -dict [ list \
   CONFIG.IS_ACLK_ASYNC {1} \
 ] $axis_data_fifo

  # Create instance: sign_conversion_0, and set properties
  set block_name sign_conversion
  set block_cell_name sign_conversion_0
  if { [catch {set sign_conversion_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $sign_conversion_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: tdm_reformat_tx, and set properties
  set block_name tdm_reformat_tx
  set block_cell_name tdm_reformat_tx
  if { [catch {set tdm_reformat_tx [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $tdm_reformat_tx eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net axis_data_fifo_M_AXIS [get_bd_intf_pins axis_data_fifo/M_AXIS] [get_bd_intf_pins sign_conversion_0/s_axis]
  connect_bd_intf_net -intf_net iq_mixer_tx_0_m_axis [get_bd_intf_pins DUC_Mixer/M_AXIS_DATA] [get_bd_intf_pins axis_data_fifo/S_AXIS]
  connect_bd_intf_net -intf_net s_axis_0_1 [get_bd_intf_ports S_AXIS] [get_bd_intf_pins tdm_reformat_tx/s_axis]
  connect_bd_intf_net -intf_net sign_conversion_0_m_axis [get_bd_intf_pins AXIS_S_to_AD9764/s00_axis] [get_bd_intf_pins sign_conversion_0/m_axis]
  connect_bd_intf_net -intf_net tdm_reformat_tx_0_m_axis [get_bd_intf_pins DUC_Mixer/S_AXIS_DATA] [get_bd_intf_pins tdm_reformat_tx/m_axis]

  # Create port connections
  connect_bd_net -net AXIS_S_to_AD9764_0_ClockToDAC [get_bd_ports ClockToDAC] [get_bd_pins AXIS_S_to_AD9764/ClockToDAC]
  connect_bd_net -net AXIS_S_to_AD9764_0_DAC_data [get_bd_ports DAC_data] [get_bd_pins AXIS_S_to_AD9764/DAC_data]
  connect_bd_net -net AXIS_S_to_AD9764_0_DAC_sleep [get_bd_ports DAC_sleep] [get_bd_pins AXIS_S_to_AD9764/DAC_sleep]
  connect_bd_net -net AXIS_S_to_AD9764_0_PA_enable [get_bd_ports PA_enable] [get_bd_pins AXIS_S_to_AD9764/PA_enable]
  connect_bd_net -net aclk_1 [get_bd_ports aclk] [get_bd_pins DUC_Mixer/aclk] [get_bd_pins axis_data_fifo/s_axis_aclk] [get_bd_pins tdm_reformat_tx/axis_aclk]
  connect_bd_net -net aclk_10M_1 [get_bd_ports aclk_10M] [get_bd_pins AXIS_S_to_AD9764/s00_axis_aclk] [get_bd_pins axis_data_fifo/m_axis_aclk] [get_bd_pins sign_conversion_0/axis_aclk]
  connect_bd_net -net aresetn_1 [get_bd_ports aresetn] [get_bd_pins DUC_Mixer/aresetn] [get_bd_pins axis_data_fifo/s_axis_aresetn]
  connect_bd_net -net aresetn_10M_1 [get_bd_ports aresetn_10M] [get_bd_pins AXIS_S_to_AD9764/s00_axis_aresetn]
  connect_bd_net -net control_0_1 [get_bd_ports DAC_control] [get_bd_pins AXIS_S_to_AD9764/control]
  connect_bd_net -net i_decimate_ratio_0_1 [get_bd_ports Interp_ratio] [get_bd_pins DUC_Mixer/Interp_ratio]
  connect_bd_net -net s_axis_phase_tdata_0_1 [get_bd_ports Fc_scaled] [get_bd_pins DUC_Mixer/Fc_scaled]

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


