
################################################################
# This is a generated script based on design: DUC_DDC_Loopback_Sim
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
# source DUC_DDC_Loopback_Sim_script.tcl


# The design that will be created by this Tcl script contains the following 
# block design container source references:
# ADC_Chain, DAC_Chain

# Please add the sources before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z010clg400-1
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name DUC_DDC_Loopback_Sim

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
# CHECK Block Design Container Sources
##################################################################
set bCheckSources 1
set list_bdc_active "ADC_Chain, DAC_Chain"

array set map_bdc_missing {}
set map_bdc_missing(ACTIVE) ""
set map_bdc_missing(BDC) ""

if { $bCheckSources == 1 } {
   set list_check_srcs "\ 
ADC_Chain \
DAC_Chain \
"

   common::send_gid_msg -ssname BD::TCL -id 2056 -severity "INFO" "Checking if the following sources for block design container exist in the project: $list_check_srcs .\n\n"

   foreach src $list_check_srcs {
      if { [can_resolve_reference $src] == 0 } {
         if { [lsearch $list_bdc_active $src] != -1 } {
            set map_bdc_missing(ACTIVE) "$map_bdc_missing(ACTIVE) $src"
         } else {
            set map_bdc_missing(BDC) "$map_bdc_missing(BDC) $src"
         }
      }
   }

   if { [llength $map_bdc_missing(ACTIVE)] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2057 -severity "ERROR" "The following source(s) of Active variants are not found in the project: $map_bdc_missing(ACTIVE)" }
      common::send_gid_msg -ssname BD::TCL -id 2060 -severity "INFO" "Please add source files for the missing source(s) above."
      set bCheckIPsPassed 0
   }
   if { [llength $map_bdc_missing(BDC)] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2059 -severity "WARNING" "The following source(s) of variants are not found in the project: $map_bdc_missing(BDC)" }
      common::send_gid_msg -ssname BD::TCL -id 2060 -severity "INFO" "Please add source files for the missing source(s) above."
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
  set Fc_scaled [ create_bd_port -dir I -from 31 -to 0 Fc_scaled ]
  set Interp_ratio [ create_bd_port -dir I -from 15 -to 0 Interp_ratio ]
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set aclk_10M [ create_bd_port -dir I -type clk -freq_hz 40000000 aclk_10M ]
  set aresetn [ create_bd_port -dir I -type rst aresetn ]
  set aresetn_10M [ create_bd_port -dir I -type rst aresetn_10M ]
  set decimate_ratio [ create_bd_port -dir I -from 15 -to 0 decimate_ratio ]
  set i_select_40M_10M [ create_bd_port -dir I i_select_40M_10M ]
  set i_shift_reg [ create_bd_port -dir I -from 2 -to 0 i_shift_reg ]

  # Create instance: ADC_Chain_0, and set properties
  set ADC_Chain_0 [ create_bd_cell -type container -reference ADC_Chain ADC_Chain_0 ]
  set_property -dict [ list \
   CONFIG.ACTIVE_SIM_BD {ADC_Chain.bd} \
   CONFIG.ACTIVE_SYNTH_BD {ADC_Chain.bd} \
   CONFIG.ENABLE_DFX {0} \
   CONFIG.LIST_SIM_BD {ADC_Chain.bd} \
   CONFIG.LIST_SYNTH_BD {ADC_Chain.bd} \
   CONFIG.LOCK_PROPAGATE {0} \
 ] $ADC_Chain_0

  # Create instance: DAC_Chain_0, and set properties
  set DAC_Chain_0 [ create_bd_cell -type container -reference DAC_Chain DAC_Chain_0 ]
  set_property -dict [ list \
   CONFIG.ACTIVE_SIM_BD {DAC_Chain.bd} \
   CONFIG.ACTIVE_SYNTH_BD {DAC_Chain.bd} \
   CONFIG.ENABLE_DFX {0} \
   CONFIG.LIST_SIM_BD {DAC_Chain.bd} \
   CONFIG.LIST_SYNTH_BD {DAC_Chain.bd} \
   CONFIG.LOCK_PROPAGATE {0} \
 ] $DAC_Chain_0

  # Create interface connections
  connect_bd_intf_net -intf_net ADC_Chain_0_M_AXIS [get_bd_intf_ports M_AXIS] [get_bd_intf_pins ADC_Chain_0/M_AXIS]
  connect_bd_intf_net -intf_net DAC_Chain_0_M_AXIS [get_bd_intf_pins ADC_Chain_0/S_AXIS] [get_bd_intf_pins DAC_Chain_0/M_AXIS]
  connect_bd_intf_net -intf_net S_AXIS_0_1 [get_bd_intf_ports S_AXIS] [get_bd_intf_pins DAC_Chain_0/S_AXIS]
  connect_bd_intf_net -intf_net S_AXIS_DDS_1 [get_bd_intf_pins ADC_Chain_0/M_AXIS_DDS] [get_bd_intf_pins DAC_Chain_0/S_AXIS_DDS]

  # Create port connections
  connect_bd_net -net Fc_scaled_0_1 [get_bd_ports Fc_scaled] [get_bd_pins ADC_Chain_0/Fc_scaled]
  connect_bd_net -net Interp_ratio_0_1 [get_bd_ports Interp_ratio] [get_bd_pins DAC_Chain_0/Interp_ratio]
  connect_bd_net -net aclk_0_1 [get_bd_ports aclk] [get_bd_pins ADC_Chain_0/aclk] [get_bd_pins DAC_Chain_0/aclk]
  connect_bd_net -net aclk_10M_0_1 [get_bd_ports aclk_10M] [get_bd_pins ADC_Chain_0/aclk_10M] [get_bd_pins DAC_Chain_0/aclk_10M]
  connect_bd_net -net aresetn_0_1 [get_bd_ports aresetn] [get_bd_pins ADC_Chain_0/aresetn] [get_bd_pins DAC_Chain_0/aresetn]
  connect_bd_net -net aresetn_10M_0_1 [get_bd_ports aresetn_10M] [get_bd_pins ADC_Chain_0/aresetn_10M] [get_bd_pins DAC_Chain_0/aresetn_10M]
  connect_bd_net -net decimate_ratio_0_1 [get_bd_ports decimate_ratio] [get_bd_pins ADC_Chain_0/decimate_ratio]
  connect_bd_net -net i_select_40M_10M_0_1 [get_bd_ports i_select_40M_10M] [get_bd_pins ADC_Chain_0/i_select_40M_10M]
  connect_bd_net -net i_shift_reg_0_1 [get_bd_ports i_shift_reg] [get_bd_pins ADC_Chain_0/i_shift_reg]

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


