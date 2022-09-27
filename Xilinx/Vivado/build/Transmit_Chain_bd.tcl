
################################################################
# This is a generated script based on design: Transmit_Chain
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
# source Transmit_Chain_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# mux, playback_ctrl

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
set design_name Transmit_Chain

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
xilinx.com:ip:axi_bram_ctrl:*\
xilinx.com:ip:xfft:*\
xilinx.com:ip:blk_mem_gen:*\
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
mux\
playback_ctrl\
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

  set S_AXIS [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS ]
  set_property -dict [ list \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {8} \
   CONFIG.TUSER_WIDTH {8} \
   ] $S_AXIS

  set S_BRAM_AXI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_BRAM_AXI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {12} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {0} \
   CONFIG.MAX_BURST_LENGTH {1} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {0} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_BRAM_AXI


  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S_AXIS:M_AXIS:S_BRAM_AXI} \
 ] $aclk
  set aresetn [ create_bd_port -dir I -type rst aresetn ]
  set playback_en [ create_bd_port -dir I playback_en ]

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl axi_bram_ctrl_0 ]
  set_property -dict [ list \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_0

  # Create instance: ifft, and set properties
  set ifft [ create_bd_cell -type ip -vlnv xilinx.com:ip:xfft ifft ]
  set_property -dict [ list \
   CONFIG.aresetn {true} \
   CONFIG.data_format {fixed_point} \
   CONFIG.implementation_options {automatically_select} \
   CONFIG.number_of_stages_using_block_ram_for_data_and_phase_factors {3} \
   CONFIG.run_time_configurable_transform_length {false} \
   CONFIG.target_clock_frequency {100} \
 ] $ifft

  # Create instance: mux_0, and set properties
  set block_name mux
  set block_cell_name mux_0
  if { [catch {set mux_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mux_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: playback_ctrl_0, and set properties
  set block_name playback_ctrl
  set block_cell_name playback_ctrl_0
  if { [catch {set playback_ctrl_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $playback_ctrl_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: playback_mem, and set properties
  set playback_mem [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen playback_mem ]
  set_property -dict [ list \
   CONFIG.Assume_Synchronous_Clk {false} \
   CONFIG.Enable_B {Use_ENB_Pin} \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.Port_B_Clock {100} \
   CONFIG.Port_B_Enable_Rate {100} \
   CONFIG.Port_B_Write_Rate {50} \
   CONFIG.Use_RSTB_Pin {true} \
 ] $playback_mem

  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_0_1 [get_bd_intf_ports S_BRAM_AXI] [get_bd_intf_pins axi_bram_ctrl_0/S_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins playback_mem/BRAM_PORTA]
  connect_bd_intf_net -intf_net mux_0_m_axis [get_bd_intf_pins ifft/S_AXIS_DATA] [get_bd_intf_pins mux_0/m_axis]
  connect_bd_intf_net -intf_net playback_ctrl_0_BRAM_PORT [get_bd_intf_pins playback_ctrl_0/BRAM_PORT] [get_bd_intf_pins playback_mem/BRAM_PORTB]
  connect_bd_intf_net -intf_net playback_ctrl_0_M_AXIS [get_bd_intf_pins mux_0/s_axis1] [get_bd_intf_pins playback_ctrl_0/M_AXIS]
  connect_bd_intf_net -intf_net s_axis0_0_1 [get_bd_intf_ports S_AXIS] [get_bd_intf_pins mux_0/s_axis0]
  connect_bd_intf_net -intf_net xfft_0_M_AXIS_DATA [get_bd_intf_ports M_AXIS] [get_bd_intf_pins ifft/M_AXIS_DATA]

  # Create port connections
  connect_bd_net -net i_select_0_1 [get_bd_ports playback_en] [get_bd_pins mux_0/i_select] [get_bd_pins playback_ctrl_0/playback_en]
  connect_bd_net -net s_axi_aclk_0_1 [get_bd_ports aclk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins ifft/aclk] [get_bd_pins mux_0/axis_aclk] [get_bd_pins playback_ctrl_0/axis_aclk]
  connect_bd_net -net s_axi_aresetn_0_1 [get_bd_ports aresetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins ifft/aresetn] [get_bd_pins mux_0/axis_aresetn] [get_bd_pins playback_ctrl_0/axis_aresetn]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces S_BRAM_AXI] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force


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


