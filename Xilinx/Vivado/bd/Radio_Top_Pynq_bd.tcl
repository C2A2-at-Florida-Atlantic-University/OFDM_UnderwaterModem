
################################################################
# This is a generated script based on design: Radio_Top_Pynq
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
# source Radio_Top_Pynq_script.tcl


# The design that will be created by this Tcl script contains the following 
# block design container source references:
# PS_Zynq, Transmit_Chain

# Please add the sources before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z020clg400-1
   set_property BOARD_PART tul.com.tw:pynq-z2:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name Radio_Top_Pynq

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
xilinx.com:ip:axis_data_fifo:*\
xilinx.com:ip:system_ila:*\
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
# CHECK Block Design Container Sources
##################################################################
set bCheckSources 1
set list_bdc_active "PS_Zynq, Transmit_Chain"

array set map_bdc_missing {}
set map_bdc_missing(ACTIVE) ""
set map_bdc_missing(BDC) ""

if { $bCheckSources == 1 } {
   set list_check_srcs "\ 
PS_Zynq \
Transmit_Chain \
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
  set DDR [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddrx_rtl:1.0 DDR ]

  set FIXED_IO [ create_bd_intf_port -mode Master -vlnv xilinx.com:display_processing_system7:fixedio_rtl:1.0 FIXED_IO ]


  # Create ports

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

  # Create instance: Transmit_Chain_0, and set properties
  set Transmit_Chain_0 [ create_bd_cell -type container -reference Transmit_Chain Transmit_Chain_0 ]
  set_property -dict [ list \
   CONFIG.ACTIVE_SIM_BD {Transmit_Chain.bd} \
   CONFIG.ACTIVE_SYNTH_BD {Transmit_Chain.bd} \
   CONFIG.ENABLE_DFX {0} \
   CONFIG.LIST_SIM_BD {Transmit_Chain.bd} \
   CONFIG.LIST_SYNTH_BD {Transmit_Chain.bd} \
   CONFIG.LOCK_PROPAGATE {0} \
 ] $Transmit_Chain_0

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_include_mm2s_dre {1} \
   CONFIG.c_include_s2mm_dre {1} \
   CONFIG.c_include_sg {0} \
   CONFIG.c_mm2s_burst_size {256} \
   CONFIG.c_s2mm_burst_size {256} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
   CONFIG.c_sg_length_width {26} \
 ] $axi_dma_0

  # Create instance: axis_data_fifo_1, and set properties
  set axis_data_fifo_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo axis_data_fifo_1 ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {8192} \
 ] $axis_data_fifo_1

  # Create instance: system_ila_DMA, and set properties
  set system_ila_DMA [ create_bd_cell -type ip -vlnv xilinx.com:ip:system_ila system_ila_DMA ]
  set_property -dict [ list \
   CONFIG.C_DATA_DEPTH {2048} \
   CONFIG.C_NUM_MONITOR_SLOTS {2} \
   CONFIG.C_SLOT {1} \
   CONFIG.C_SLOT_0_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
   CONFIG.C_SLOT_1_INTF_TYPE {xilinx.com:interface:axis_rtl:1.0} \
 ] $system_ila_DMA

  # Create interface connections
  connect_bd_intf_net -intf_net PS_Zynq_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins PS_Zynq_0/DDR]
  connect_bd_intf_net -intf_net PS_Zynq_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins PS_Zynq_0/FIXED_IO]
  connect_bd_intf_net -intf_net PS_Zynq_0_M_AXI_BRAM [get_bd_intf_pins PS_Zynq_0/M_AXI_BRAM] [get_bd_intf_pins Transmit_Chain_0/S_BRAM_AXI]
  connect_bd_intf_net -intf_net PS_Zynq_0_M_AXI_DMA [get_bd_intf_pins PS_Zynq_0/M_AXI_DMA] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net S00_AXI_DMA_1 [get_bd_intf_pins PS_Zynq_0/S00_AXI_DMA] [get_bd_intf_pins axi_dma_0/M_AXI_MM2S]
  connect_bd_intf_net -intf_net S01_AXI_DMA_1 [get_bd_intf_pins PS_Zynq_0/S01_AXI_DMA] [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]
  connect_bd_intf_net -intf_net S_AXIS_1 [get_bd_intf_pins Transmit_Chain_0/S_AXIS] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
connect_bd_intf_net -intf_net [get_bd_intf_nets S_AXIS_1] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins system_ila_DMA/SLOT_0_AXIS]
  connect_bd_intf_net -intf_net Transmit_Chain_0_M_AXIS [get_bd_intf_pins Transmit_Chain_0/M_AXIS] [get_bd_intf_pins axis_data_fifo_1/S_AXIS]
connect_bd_intf_net -intf_net [get_bd_intf_nets Transmit_Chain_0_M_AXIS] [get_bd_intf_pins Transmit_Chain_0/M_AXIS] [get_bd_intf_pins system_ila_DMA/SLOT_1_AXIS]
  connect_bd_intf_net -intf_net axis_data_fifo_1_M_AXIS [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins axis_data_fifo_1/M_AXIS]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins PS_Zynq_0/aresetn_100M] [get_bd_pins Transmit_Chain_0/aresetn] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axis_data_fifo_1/s_axis_aresetn] [get_bd_pins system_ila_DMA/resetn]
  connect_bd_net -net config_start_0_1 [get_bd_pins PS_Zynq_0/fft_config_en] [get_bd_pins Transmit_Chain_0/config_start_0]
  connect_bd_net -net continuous_0_1 [get_bd_pins PS_Zynq_0/continuous] [get_bd_pins Transmit_Chain_0/continuous_0]
  connect_bd_net -net cp_len_0_1 [get_bd_pins PS_Zynq_0/cp_len] [get_bd_pins Transmit_Chain_0/cp_len_0]
  connect_bd_net -net dl_en_0_1 [get_bd_pins PS_Zynq_0/dl_en] [get_bd_pins Transmit_Chain_0/dl_en_0]
  connect_bd_net -net fs_cycles_0_1 [get_bd_pins PS_Zynq_0/fs_cycles] [get_bd_pins Transmit_Chain_0/fs_cycles_0]
  connect_bd_net -net i_negative_freq_0_1 [get_bd_pins PS_Zynq_0/negative_freq] [get_bd_pins Transmit_Chain_0/i_negative_freq_0]
  connect_bd_net -net inv_0_1 [get_bd_pins PS_Zynq_0/fft_inv] [get_bd_pins Transmit_Chain_0/inv_0]
  connect_bd_net -net nfft_0_1 [get_bd_pins PS_Zynq_0/nfft] [get_bd_pins Transmit_Chain_0/nfft_0]
  connect_bd_net -net nfft_scaled_0_1 [get_bd_pins PS_Zynq_0/nfft_scaled] [get_bd_pins Transmit_Chain_0/nfft_scaled_0]
  connect_bd_net -net playback_en_1 [get_bd_pins PS_Zynq_0/playback_en] [get_bd_pins Transmit_Chain_0/playback_en]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins PS_Zynq_0/aclk_100M] [get_bd_pins Transmit_Chain_0/aclk] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axis_data_fifo_1/s_axis_aclk] [get_bd_pins system_ila_DMA/clk]
  connect_bd_net -net symbols_0_1 [get_bd_pins PS_Zynq_0/symbols] [get_bd_pins Transmit_Chain_0/symbols_0]

  # Create address segments
  assign_bd_address -offset 0x40020000 -range 0x00004000 -target_address_space [get_bd_addr_spaces PS_Zynq_0/processing_system7_0/Data] [get_bd_addr_segs Transmit_Chain_0/axi_bram_ctrl_0/S_AXI/Mem0] -force
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


