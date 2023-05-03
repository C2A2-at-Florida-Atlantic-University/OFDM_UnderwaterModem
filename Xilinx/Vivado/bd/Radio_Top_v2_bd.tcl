
################################################################
# This is a generated script based on design: Radio_Top_v2
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
# source Radio_Top_v2_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# dma_tlast_gen, mux, mux, mux

# Please add the sources of those modules before sourcing this Tcl script.


# The design that will be created by this Tcl script contains the following 
# block design container source references:
# ADC_Chain, DAC_Chain, Ofdm_Sync_250k, PS_Zynq

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
set design_name Radio_Top_v2

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
xilinx.com:ip:axi_dma:*\
user.org:user:AXIS_Splitter:*\
xilinx.com:ip:util_vector_logic:*\
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
dma_tlast_gen\
mux\
mux\
mux\
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

##################################################################
# CHECK Block Design Container Sources
##################################################################
set bCheckSources 1
set list_bdc_active "ADC_Chain, DAC_Chain, Ofdm_Sync_250k, PS_Zynq"

array set map_bdc_missing {}
set map_bdc_missing(ACTIVE) ""
set map_bdc_missing(BDC) ""

if { $bCheckSources == 1 } {
   set list_check_srcs "\ 
ADC_Chain \
DAC_Chain \
Ofdm_Sync_250k \
PS_Zynq \
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


# Hierarchical cell: Loopback
proc create_hier_cell_Loopback { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Loopback() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DAC_CHAIN

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DMA

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_SYNCHRONIZER

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_ADC_CHAIN

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DMA

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_SYNCHRONIZER


  # Create pins
  create_bd_pin -dir I -type clk axis_aclk
  create_bd_pin -dir I -type rst axis_aresetn
  create_bd_pin -dir I -from 0 -to 0 dma_loopback
  create_bd_pin -dir I duc_ddc_loopback
  create_bd_pin -dir I sync_loopback

  # Create instance: AXIS_Splitter_0, and set properties
  set AXIS_Splitter_0 [ create_bd_cell -type ip -vlnv user.org:user:AXIS_Splitter AXIS_Splitter_0 ]
  set_property -dict [ list \
   CONFIG.M_TREADY_ANDED_TVALID {true} \
 ] $AXIS_Splitter_0

  # Create instance: AXIS_Splitter_1, and set properties
  set AXIS_Splitter_1 [ create_bd_cell -type ip -vlnv user.org:user:AXIS_Splitter AXIS_Splitter_1 ]
  set_property -dict [ list \
   CONFIG.M_TREADY_ANDED_TVALID {true} \
 ] $AXIS_Splitter_1

  # Create instance: AXIS_Splitter_2, and set properties
  set AXIS_Splitter_2 [ create_bd_cell -type ip -vlnv user.org:user:AXIS_Splitter AXIS_Splitter_2 ]
  set_property -dict [ list \
   CONFIG.M_TREADY_ANDED_TVALID {true} \
 ] $AXIS_Splitter_2

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
  
  # Create instance: mux_1, and set properties
  set block_name mux
  set block_cell_name mux_1
  if { [catch {set mux_1 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mux_1 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: mux_2, and set properties
  set block_name mux
  set block_cell_name mux_2
  if { [catch {set mux_2 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $mux_2 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {or} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_orgate.png} \
 ] $util_vector_logic_0

  # Create interface connections
  connect_bd_intf_net -intf_net AXIS_Splitter_0_M01_AXIS [get_bd_intf_pins AXIS_Splitter_0/M01_AXIS] [get_bd_intf_pins AXIS_Splitter_1/S00_AXIS]
  connect_bd_intf_net -intf_net AXIS_Splitter_1_M00_AXIS [get_bd_intf_pins AXIS_Splitter_1/M00_AXIS] [get_bd_intf_pins mux_0/s_axis1]
  connect_bd_intf_net -intf_net AXIS_Splitter_1_M01_AXIS [get_bd_intf_pins AXIS_Splitter_1/M01_AXIS] [get_bd_intf_pins mux_2/s_axis1]
  connect_bd_intf_net -intf_net AXIS_Splitter_2_M00_AXIS [get_bd_intf_pins M_AXIS_SYNCHRONIZER] [get_bd_intf_pins AXIS_Splitter_2/M00_AXIS]
  connect_bd_intf_net -intf_net AXIS_Splitter_2_M01_AXIS [get_bd_intf_pins AXIS_Splitter_2/M01_AXIS] [get_bd_intf_pins mux_1/s_axis1]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins M_AXIS_DAC_CHAIN] [get_bd_intf_pins AXIS_Splitter_0/M00_AXIS]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins S_AXIS_DMA] [get_bd_intf_pins AXIS_Splitter_0/S00_AXIS]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins M_AXIS_DMA] [get_bd_intf_pins mux_0/m_axis]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins S_AXIS_ADC_CHAIN] [get_bd_intf_pins mux_2/s_axis0]
  connect_bd_intf_net -intf_net mux_1_m_axis [get_bd_intf_pins mux_0/s_axis0] [get_bd_intf_pins mux_1/m_axis]
  connect_bd_intf_net -intf_net mux_2_m_axis [get_bd_intf_pins AXIS_Splitter_2/S00_AXIS] [get_bd_intf_pins mux_2/m_axis]
  connect_bd_intf_net -intf_net s_axis0_1 [get_bd_intf_pins S_AXIS_SYNCHRONIZER] [get_bd_intf_pins mux_1/s_axis0]

  # Create port connections
  connect_bd_net -net PS_Zynq_0_aclk_100M [get_bd_pins axis_aclk] [get_bd_pins AXIS_Splitter_0/axis_aclk] [get_bd_pins AXIS_Splitter_1/axis_aclk] [get_bd_pins AXIS_Splitter_2/axis_aclk] [get_bd_pins mux_0/axis_aclk] [get_bd_pins mux_1/axis_aclk] [get_bd_pins mux_2/axis_aclk]
  connect_bd_net -net PS_Zynq_0_aresetn_100M [get_bd_pins axis_aresetn] [get_bd_pins mux_0/axis_aresetn] [get_bd_pins mux_1/axis_aresetn] [get_bd_pins mux_2/axis_aresetn]
  connect_bd_net -net PS_Zynq_0_dma_loopback [get_bd_pins dma_loopback] [get_bd_pins mux_0/i_select] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net PS_Zynq_0_sync_loopback [get_bd_pins sync_loopback] [get_bd_pins AXIS_Splitter_1/tready_select] [get_bd_pins mux_2/i_select] [get_bd_pins util_vector_logic_0/Op2]
  connect_bd_net -net tready_select1_1 [get_bd_pins duc_ddc_loopback] [get_bd_pins AXIS_Splitter_2/tready_select] [get_bd_pins mux_1/i_select]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins AXIS_Splitter_0/tready_select] [get_bd_pins util_vector_logic_0/Res]

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
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]


  # Create ports
  set ADCclock [ create_bd_port -dir O ADCclock ]
  set ADCdata [ create_bd_port -dir I -from 14 -to 0 ADCdata ]
  set DACclock [ create_bd_port -dir O DACclock ]
  set DACdata [ create_bd_port -dir O -from 13 -to 0 DACdata ]
  set DACsleep [ create_bd_port -dir O DACsleep ]
  set PowerAmpEnable [ create_bd_port -dir O PowerAmpEnable ]

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

  # Create instance: Loopback
  create_hier_cell_Loopback [current_bd_instance .] Loopback

  # Create instance: Ofdm_Sync_250k_0, and set properties
  set Ofdm_Sync_250k_0 [ create_bd_cell -type container -reference Ofdm_Sync_250k Ofdm_Sync_250k_0 ]
  set_property -dict [ list \
   CONFIG.ACTIVE_SIM_BD {Ofdm_Sync_250k.bd} \
   CONFIG.ACTIVE_SYNTH_BD {Ofdm_Sync_250k.bd} \
   CONFIG.ENABLE_DFX {0} \
   CONFIG.LIST_SIM_BD {Ofdm_Sync_250k.bd} \
   CONFIG.LIST_SYNTH_BD {Ofdm_Sync_250k.bd} \
   CONFIG.LOCK_PROPAGATE {0} \
 ] $Ofdm_Sync_250k_0

  # Create instance: PS_Zynq_0, and set properties
  set PS_Zynq_0 [ create_bd_cell -type container -reference PS_Zynq PS_Zynq_0 ]
  set_property -dict [ list \
   CONFIG.ACTIVE_SIM_BD {PS_Zynq.bd} \
   CONFIG.ACTIVE_SYNTH_BD {PS_Zynq.bd} \
   CONFIG.ENABLE_DFX {0} \
   CONFIG.LIST_SIM_BD {PS_Zynq.bd} \
   CONFIG.LIST_SYNTH_BD {PS_Zynq.bd} \
   CONFIG.LOCK_PROPAGATE {0} \
 ] $PS_Zynq_0

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_include_sg {0} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {26} \
 ] $axi_dma_0

  # Create instance: dma_tlast_gen_0, and set properties
  set block_name dma_tlast_gen
  set block_cell_name dma_tlast_gen_0
  if { [catch {set dma_tlast_gen_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dma_tlast_gen_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create interface connections
  connect_bd_intf_net -intf_net ADC_Chain_0_M_AXIS [get_bd_intf_pins ADC_Chain_0/M_AXIS] [get_bd_intf_pins Loopback/S_AXIS_ADC_CHAIN]
  connect_bd_intf_net -intf_net Loopback_M_AXIS_DAC_CHAIN [get_bd_intf_pins DAC_Chain_0/S_AXIS] [get_bd_intf_pins Loopback/M_AXIS_DAC_CHAIN]
  connect_bd_intf_net -intf_net Loopback_M_AXIS_DMA [get_bd_intf_pins Loopback/M_AXIS_DMA] [get_bd_intf_pins dma_tlast_gen_0/s_axis]
  connect_bd_intf_net -intf_net Loopback_M_AXIS_SYNCHRONIZER [get_bd_intf_pins Loopback/M_AXIS_SYNCHRONIZER] [get_bd_intf_pins Ofdm_Sync_250k_0/S_AXIS]
  connect_bd_intf_net -intf_net Ofdm_Sync_250k_0_M_AXIS [get_bd_intf_pins Loopback/S_AXIS_SYNCHRONIZER] [get_bd_intf_pins Ofdm_Sync_250k_0/M_AXIS]
  connect_bd_intf_net -intf_net PS_Zynq_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins PS_Zynq_0/DDR]
  connect_bd_intf_net -intf_net PS_Zynq_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins PS_Zynq_0/FIXED_IO]
  connect_bd_intf_net -intf_net PS_Zynq_0_M_AXI_DMA [get_bd_intf_pins PS_Zynq_0/M_AXI_DMA] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net S_AXI_DMA_HP0_1 [get_bd_intf_pins PS_Zynq_0/S_AXI_DMA_HP0] [get_bd_intf_pins axi_dma_0/M_AXI_MM2S]
  connect_bd_intf_net -intf_net S_AXI_DMA_HP1_1 [get_bd_intf_pins PS_Zynq_0/S_AXI_DMA_HP1] [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins Loopback/S_AXIS_DMA] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net dma_tlast_gen_0_m_axis [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins dma_tlast_gen_0/m_axis]

  # Create port connections
  connect_bd_net -net ADC_Chain_0_ClockToADC [get_bd_ports ADCclock] [get_bd_pins ADC_Chain_0/ClockToADC]
  connect_bd_net -net ADC_Chain_0_status [get_bd_pins ADC_Chain_0/status] [get_bd_pins PS_Zynq_0/ADCstatus]
  connect_bd_net -net ADC_control_1 [get_bd_pins ADC_Chain_0/ADC_control] [get_bd_pins PS_Zynq_0/ADCcontrol]
  connect_bd_net -net ADCdata_1 [get_bd_ports ADCdata] [get_bd_pins ADC_Chain_0/ADCdata]
  connect_bd_net -net DAC_Chain_0_ClockToDAC [get_bd_ports DACclock] [get_bd_pins DAC_Chain_0/ClockToDAC]
  connect_bd_net -net DAC_Chain_0_DAC_data [get_bd_ports DACdata] [get_bd_pins DAC_Chain_0/DAC_data]
  connect_bd_net -net DAC_Chain_0_DAC_sleep [get_bd_ports DACsleep] [get_bd_pins DAC_Chain_0/DAC_sleep]
  connect_bd_net -net DAC_Chain_0_PA_enable [get_bd_ports PowerAmpEnable] [get_bd_pins DAC_Chain_0/PA_enable]
  connect_bd_net -net DAC_control_1 [get_bd_pins DAC_Chain_0/DAC_control] [get_bd_pins PS_Zynq_0/DACcontrol]
  connect_bd_net -net Fc_scaled_1 [get_bd_pins ADC_Chain_0/Fc_scaled] [get_bd_pins PS_Zynq_0/ADC_Fc_scaled]
  connect_bd_net -net Interp_ratio_1 [get_bd_pins DAC_Chain_0/Interp_ratio] [get_bd_pins PS_Zynq_0/Interp_ratio]
  connect_bd_net -net PS_Zynq_0_DAC_Fc_scaled [get_bd_pins DAC_Chain_0/Fc_scaled] [get_bd_pins PS_Zynq_0/DAC_Fc_scaled]
  connect_bd_net -net PS_Zynq_0_aresetn_100M [get_bd_pins ADC_Chain_0/aresetn] [get_bd_pins DAC_Chain_0/aresetn] [get_bd_pins Loopback/axis_aresetn] [get_bd_pins Ofdm_Sync_250k_0/aresetn] [get_bd_pins PS_Zynq_0/aresetn_100M] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins dma_tlast_gen_0/axis_aresetn]
  connect_bd_net -net PS_Zynq_0_dma_loopback [get_bd_pins Loopback/dma_loopback] [get_bd_pins PS_Zynq_0/dma_loopback]
  connect_bd_net -net PS_Zynq_0_dma_tlast_count [get_bd_pins PS_Zynq_0/dma_tlast_count] [get_bd_pins dma_tlast_gen_0/i_dma_tlast_count]
  connect_bd_net -net aclk_10M_1 [get_bd_pins DAC_Chain_0/aclk_10M] [get_bd_pins PS_Zynq_0/aclk_10M]
  connect_bd_net -net aclk_40M_1 [get_bd_pins ADC_Chain_0/aclk_40M] [get_bd_pins PS_Zynq_0/aclk_40M]
  connect_bd_net -net aresetn_10M_1 [get_bd_pins DAC_Chain_0/aresetn_10M] [get_bd_pins PS_Zynq_0/aresetn_10M]
  connect_bd_net -net aresetn_40M_1 [get_bd_pins ADC_Chain_0/aresetn_40M] [get_bd_pins PS_Zynq_0/aresetn_40M]
  connect_bd_net -net axis_aclk_1 [get_bd_pins ADC_Chain_0/aclk] [get_bd_pins DAC_Chain_0/aclk] [get_bd_pins Loopback/axis_aclk] [get_bd_pins Ofdm_Sync_250k_0/aclk] [get_bd_pins PS_Zynq_0/aclk_100M] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins dma_tlast_gen_0/axis_aclk]
  connect_bd_net -net decimate_ratio_1 [get_bd_pins ADC_Chain_0/decimate_ratio] [get_bd_pins PS_Zynq_0/decimate_ratio]
  connect_bd_net -net duc_ddc_loopback_1 [get_bd_pins Loopback/duc_ddc_loopback] [get_bd_pins PS_Zynq_0/duc_ddc_loopback]
  connect_bd_net -net i_cp_len_1 [get_bd_pins Ofdm_Sync_250k_0/i_cp_len] [get_bd_pins PS_Zynq_0/cp_len]
  connect_bd_net -net i_nfft_1 [get_bd_pins Ofdm_Sync_250k_0/i_nfft] [get_bd_pins PS_Zynq_0/nfft]
  connect_bd_net -net i_symbols_1 [get_bd_pins Ofdm_Sync_250k_0/i_symbols] [get_bd_pins PS_Zynq_0/symbols]
  connect_bd_net -net i_sync_offset_1 [get_bd_pins Ofdm_Sync_250k_0/i_sync_offset] [get_bd_pins PS_Zynq_0/sync_offset]
  connect_bd_net -net i_threshold_1 [get_bd_pins Ofdm_Sync_250k_0/i_threshold] [get_bd_pins PS_Zynq_0/threshold]
  connect_bd_net -net sync_enable_1 [get_bd_pins Ofdm_Sync_250k_0/sync_enable] [get_bd_pins PS_Zynq_0/sync_enable]
  connect_bd_net -net sync_loopback_1 [get_bd_pins Loopback/sync_loopback] [get_bd_pins PS_Zynq_0/sync_loopback]

  # Create address segments
  assign_bd_address -offset 0x40000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces PS_Zynq_0/processing_system7_0/Data] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs PS_Zynq_0/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] -force
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs PS_Zynq_0/processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] -force


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


