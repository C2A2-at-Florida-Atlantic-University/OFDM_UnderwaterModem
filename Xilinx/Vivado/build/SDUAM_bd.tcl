
################################################################
# This is a generated script based on design: SDUAM
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
# source SDUAM_script.tcl


# The design that will be created by this Tcl script contains the following 
# block design container source references:
# Transmit_Chain

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
set design_name SDUAM

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
xilinx.com:ip:axi_gpio:*\
xilinx.com:ip:processing_system7:*\
xilinx.com:ip:proc_sys_reset:*\
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
set list_bdc_active "Transmit_Chain"

array set map_bdc_missing {}
set map_bdc_missing(ACTIVE) ""
set map_bdc_missing(BDC) ""

if { $bCheckSources == 1 } {
   set list_check_srcs "\ 
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
   CONFIG.c_include_mm2s {1} \
   CONFIG.c_include_s2mm {0} \
   CONFIG.c_include_sg {0} \
   CONFIG.c_mm2s_burst_size {256} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
 ] $axi_dma_0

  # Create instance: axi_dma_1, and set properties
  set axi_dma_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma axi_dma_1 ]
  set_property -dict [ list \
   CONFIG.c_include_mm2s {0} \
   CONFIG.c_include_sg {0} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
 ] $axi_dma_1

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_ALL_OUTPUTS_2 {1} \
   CONFIG.C_IS_DUAL {1} \
 ] $axi_gpio_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_SI {2} \
 ] $axi_interconnect_0

  # Create instance: axi_interconnect_1, and set properties
  set axi_interconnect_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect axi_interconnect_1 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {4} \
 ] $axi_interconnect_1

  # Create instance: processing_system7_0, and set properties
  set processing_system7_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7 processing_system7_0 ]
  set_property -dict [ list \
   CONFIG.PCW_ACT_APU_PERIPHERAL_FREQMHZ {666.666687} \
   CONFIG.PCW_ACT_CAN_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_DCI_PERIPHERAL_FREQMHZ {10.158730} \
   CONFIG.PCW_ACT_ENET0_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_ENET1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_FPGA1_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA2_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_FPGA3_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_PCAP_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_QSPI_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SDIO_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_SMC_PERIPHERAL_FREQMHZ {10.000000} \
   CONFIG.PCW_ACT_SPI_PERIPHERAL_FREQMHZ {160.000000} \
   CONFIG.PCW_ACT_TPIU_PERIPHERAL_FREQMHZ {200.000000} \
   CONFIG.PCW_ACT_TTC0_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC0_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK0_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK1_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_TTC1_CLK2_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ACT_UART_PERIPHERAL_FREQMHZ {100.000000} \
   CONFIG.PCW_ACT_WDT_PERIPHERAL_FREQMHZ {111.111115} \
   CONFIG.PCW_ARMPLL_CTRL_FBDIV {40} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_CAN_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_CLK0_FREQ {100000000} \
   CONFIG.PCW_CLK1_FREQ {10000000} \
   CONFIG.PCW_CLK2_FREQ {10000000} \
   CONFIG.PCW_CLK3_FREQ {10000000} \
   CONFIG.PCW_CPU_CPU_PLL_FREQMHZ {1333.333} \
   CONFIG.PCW_CPU_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR0 {15} \
   CONFIG.PCW_DCI_PERIPHERAL_DIVISOR1 {7} \
   CONFIG.PCW_DDRPLL_CTRL_FBDIV {32} \
   CONFIG.PCW_DDR_DDR_PLL_FREQMHZ {1066.667} \
   CONFIG.PCW_DDR_PERIPHERAL_DIVISOR0 {2} \
   CONFIG.PCW_DDR_RAM_HIGHADDR {0x1FFFFFFF} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET0_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET0_RESET_ENABLE {0} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_ENET1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_ENET1_RESET_ENABLE {0} \
   CONFIG.PCW_ENET_RESET_ENABLE {0} \
   CONFIG.PCW_EN_CLK1_PORT {0} \
   CONFIG.PCW_EN_EMIO_SPI1 {0} \
   CONFIG.PCW_EN_EMIO_UART0 {0} \
   CONFIG.PCW_EN_GPIO {1} \
   CONFIG.PCW_EN_SDIO0 {1} \
   CONFIG.PCW_EN_SPI1 {1} \
   CONFIG.PCW_EN_UART0 {1} \
   CONFIG.PCW_EN_UART1 {1} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR0 {4} \
   CONFIG.PCW_FCLK0_PERIPHERAL_DIVISOR1 {4} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK1_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK2_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_FCLK3_PERIPHERAL_DIVISOR1 {1} \
   CONFIG.PCW_FCLK_CLK1_BUF {FALSE} \
   CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_FPGA1_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_FPGA_FCLK0_ENABLE {1} \
   CONFIG.PCW_FPGA_FCLK1_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK2_ENABLE {0} \
   CONFIG.PCW_FPGA_FCLK3_ENABLE {0} \
   CONFIG.PCW_GPIO_MIO_GPIO_ENABLE {1} \
   CONFIG.PCW_GPIO_MIO_GPIO_IO {MIO} \
   CONFIG.PCW_I2C0_RESET_ENABLE {0} \
   CONFIG.PCW_I2C1_RESET_ENABLE {0} \
   CONFIG.PCW_I2C_PERIPHERAL_FREQMHZ {25} \
   CONFIG.PCW_I2C_RESET_ENABLE {1} \
   CONFIG.PCW_IOPLL_CTRL_FBDIV {48} \
   CONFIG.PCW_IO_IO_PLL_FREQMHZ {1600.000} \
   CONFIG.PCW_IRQ_F2P_INTR {1} \
   CONFIG.PCW_MIO_0_DIRECTION {inout} \
   CONFIG.PCW_MIO_0_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_0_PULLUP {enabled} \
   CONFIG.PCW_MIO_0_SLEW {slow} \
   CONFIG.PCW_MIO_10_DIRECTION {inout} \
   CONFIG.PCW_MIO_10_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_10_PULLUP {enabled} \
   CONFIG.PCW_MIO_10_SLEW {slow} \
   CONFIG.PCW_MIO_11_DIRECTION {inout} \
   CONFIG.PCW_MIO_11_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_11_PULLUP {enabled} \
   CONFIG.PCW_MIO_11_SLEW {slow} \
   CONFIG.PCW_MIO_12_DIRECTION {inout} \
   CONFIG.PCW_MIO_12_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_12_PULLUP {enabled} \
   CONFIG.PCW_MIO_12_SLEW {slow} \
   CONFIG.PCW_MIO_13_DIRECTION {inout} \
   CONFIG.PCW_MIO_13_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_13_PULLUP {enabled} \
   CONFIG.PCW_MIO_13_SLEW {slow} \
   CONFIG.PCW_MIO_14_DIRECTION {in} \
   CONFIG.PCW_MIO_14_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_14_PULLUP {enabled} \
   CONFIG.PCW_MIO_14_SLEW {slow} \
   CONFIG.PCW_MIO_15_DIRECTION {out} \
   CONFIG.PCW_MIO_15_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_15_PULLUP {enabled} \
   CONFIG.PCW_MIO_15_SLEW {slow} \
   CONFIG.PCW_MIO_16_DIRECTION {inout} \
   CONFIG.PCW_MIO_16_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_16_PULLUP {enabled} \
   CONFIG.PCW_MIO_16_SLEW {slow} \
   CONFIG.PCW_MIO_17_DIRECTION {inout} \
   CONFIG.PCW_MIO_17_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_17_PULLUP {enabled} \
   CONFIG.PCW_MIO_17_SLEW {slow} \
   CONFIG.PCW_MIO_18_DIRECTION {inout} \
   CONFIG.PCW_MIO_18_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_18_PULLUP {enabled} \
   CONFIG.PCW_MIO_18_SLEW {slow} \
   CONFIG.PCW_MIO_19_DIRECTION {inout} \
   CONFIG.PCW_MIO_19_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_19_PULLUP {enabled} \
   CONFIG.PCW_MIO_19_SLEW {slow} \
   CONFIG.PCW_MIO_1_DIRECTION {inout} \
   CONFIG.PCW_MIO_1_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_1_PULLUP {enabled} \
   CONFIG.PCW_MIO_1_SLEW {slow} \
   CONFIG.PCW_MIO_20_DIRECTION {inout} \
   CONFIG.PCW_MIO_20_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_20_PULLUP {enabled} \
   CONFIG.PCW_MIO_20_SLEW {slow} \
   CONFIG.PCW_MIO_21_DIRECTION {inout} \
   CONFIG.PCW_MIO_21_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_21_PULLUP {enabled} \
   CONFIG.PCW_MIO_21_SLEW {slow} \
   CONFIG.PCW_MIO_22_DIRECTION {inout} \
   CONFIG.PCW_MIO_22_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_22_PULLUP {enabled} \
   CONFIG.PCW_MIO_22_SLEW {slow} \
   CONFIG.PCW_MIO_23_DIRECTION {inout} \
   CONFIG.PCW_MIO_23_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_23_PULLUP {enabled} \
   CONFIG.PCW_MIO_23_SLEW {slow} \
   CONFIG.PCW_MIO_24_DIRECTION {inout} \
   CONFIG.PCW_MIO_24_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_24_PULLUP {enabled} \
   CONFIG.PCW_MIO_24_SLEW {slow} \
   CONFIG.PCW_MIO_25_DIRECTION {inout} \
   CONFIG.PCW_MIO_25_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_25_PULLUP {enabled} \
   CONFIG.PCW_MIO_25_SLEW {slow} \
   CONFIG.PCW_MIO_26_DIRECTION {out} \
   CONFIG.PCW_MIO_26_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_26_PULLUP {enabled} \
   CONFIG.PCW_MIO_26_SLEW {slow} \
   CONFIG.PCW_MIO_27_DIRECTION {inout} \
   CONFIG.PCW_MIO_27_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_27_PULLUP {enabled} \
   CONFIG.PCW_MIO_27_SLEW {slow} \
   CONFIG.PCW_MIO_28_DIRECTION {inout} \
   CONFIG.PCW_MIO_28_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_28_PULLUP {enabled} \
   CONFIG.PCW_MIO_28_SLEW {slow} \
   CONFIG.PCW_MIO_29_DIRECTION {inout} \
   CONFIG.PCW_MIO_29_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_29_PULLUP {enabled} \
   CONFIG.PCW_MIO_29_SLEW {slow} \
   CONFIG.PCW_MIO_2_DIRECTION {inout} \
   CONFIG.PCW_MIO_2_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_2_PULLUP {disabled} \
   CONFIG.PCW_MIO_2_SLEW {slow} \
   CONFIG.PCW_MIO_30_DIRECTION {inout} \
   CONFIG.PCW_MIO_30_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_30_PULLUP {enabled} \
   CONFIG.PCW_MIO_30_SLEW {slow} \
   CONFIG.PCW_MIO_31_DIRECTION {inout} \
   CONFIG.PCW_MIO_31_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_31_PULLUP {enabled} \
   CONFIG.PCW_MIO_31_SLEW {slow} \
   CONFIG.PCW_MIO_32_DIRECTION {inout} \
   CONFIG.PCW_MIO_32_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_32_PULLUP {enabled} \
   CONFIG.PCW_MIO_32_SLEW {slow} \
   CONFIG.PCW_MIO_33_DIRECTION {inout} \
   CONFIG.PCW_MIO_33_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_33_PULLUP {enabled} \
   CONFIG.PCW_MIO_33_SLEW {slow} \
   CONFIG.PCW_MIO_34_DIRECTION {inout} \
   CONFIG.PCW_MIO_34_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_34_PULLUP {enabled} \
   CONFIG.PCW_MIO_34_SLEW {slow} \
   CONFIG.PCW_MIO_35_DIRECTION {inout} \
   CONFIG.PCW_MIO_35_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_35_PULLUP {enabled} \
   CONFIG.PCW_MIO_35_SLEW {slow} \
   CONFIG.PCW_MIO_36_DIRECTION {inout} \
   CONFIG.PCW_MIO_36_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_36_PULLUP {enabled} \
   CONFIG.PCW_MIO_36_SLEW {slow} \
   CONFIG.PCW_MIO_37_DIRECTION {inout} \
   CONFIG.PCW_MIO_37_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_37_PULLUP {enabled} \
   CONFIG.PCW_MIO_37_SLEW {slow} \
   CONFIG.PCW_MIO_38_DIRECTION {inout} \
   CONFIG.PCW_MIO_38_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_38_PULLUP {enabled} \
   CONFIG.PCW_MIO_38_SLEW {slow} \
   CONFIG.PCW_MIO_39_DIRECTION {inout} \
   CONFIG.PCW_MIO_39_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_39_PULLUP {enabled} \
   CONFIG.PCW_MIO_39_SLEW {slow} \
   CONFIG.PCW_MIO_3_DIRECTION {inout} \
   CONFIG.PCW_MIO_3_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_3_PULLUP {disabled} \
   CONFIG.PCW_MIO_3_SLEW {slow} \
   CONFIG.PCW_MIO_40_DIRECTION {inout} \
   CONFIG.PCW_MIO_40_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_40_PULLUP {enabled} \
   CONFIG.PCW_MIO_40_SLEW {slow} \
   CONFIG.PCW_MIO_41_DIRECTION {inout} \
   CONFIG.PCW_MIO_41_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_41_PULLUP {enabled} \
   CONFIG.PCW_MIO_41_SLEW {slow} \
   CONFIG.PCW_MIO_42_DIRECTION {inout} \
   CONFIG.PCW_MIO_42_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_42_PULLUP {enabled} \
   CONFIG.PCW_MIO_42_SLEW {slow} \
   CONFIG.PCW_MIO_43_DIRECTION {inout} \
   CONFIG.PCW_MIO_43_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_43_PULLUP {enabled} \
   CONFIG.PCW_MIO_43_SLEW {slow} \
   CONFIG.PCW_MIO_44_DIRECTION {inout} \
   CONFIG.PCW_MIO_44_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_44_PULLUP {enabled} \
   CONFIG.PCW_MIO_44_SLEW {slow} \
   CONFIG.PCW_MIO_45_DIRECTION {inout} \
   CONFIG.PCW_MIO_45_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_45_PULLUP {enabled} \
   CONFIG.PCW_MIO_45_SLEW {slow} \
   CONFIG.PCW_MIO_46_DIRECTION {inout} \
   CONFIG.PCW_MIO_46_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_46_PULLUP {enabled} \
   CONFIG.PCW_MIO_46_SLEW {slow} \
   CONFIG.PCW_MIO_47_DIRECTION {inout} \
   CONFIG.PCW_MIO_47_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_47_PULLUP {enabled} \
   CONFIG.PCW_MIO_47_SLEW {slow} \
   CONFIG.PCW_MIO_48_DIRECTION {out} \
   CONFIG.PCW_MIO_48_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_48_PULLUP {enabled} \
   CONFIG.PCW_MIO_48_SLEW {slow} \
   CONFIG.PCW_MIO_49_DIRECTION {in} \
   CONFIG.PCW_MIO_49_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_49_PULLUP {enabled} \
   CONFIG.PCW_MIO_49_SLEW {slow} \
   CONFIG.PCW_MIO_4_DIRECTION {inout} \
   CONFIG.PCW_MIO_4_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_4_PULLUP {disabled} \
   CONFIG.PCW_MIO_4_SLEW {slow} \
   CONFIG.PCW_MIO_50_DIRECTION {inout} \
   CONFIG.PCW_MIO_50_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_50_PULLUP {enabled} \
   CONFIG.PCW_MIO_50_SLEW {slow} \
   CONFIG.PCW_MIO_51_DIRECTION {inout} \
   CONFIG.PCW_MIO_51_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_51_PULLUP {enabled} \
   CONFIG.PCW_MIO_51_SLEW {slow} \
   CONFIG.PCW_MIO_52_DIRECTION {inout} \
   CONFIG.PCW_MIO_52_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_52_PULLUP {enabled} \
   CONFIG.PCW_MIO_52_SLEW {slow} \
   CONFIG.PCW_MIO_53_DIRECTION {inout} \
   CONFIG.PCW_MIO_53_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_53_PULLUP {enabled} \
   CONFIG.PCW_MIO_53_SLEW {slow} \
   CONFIG.PCW_MIO_5_DIRECTION {inout} \
   CONFIG.PCW_MIO_5_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_5_PULLUP {disabled} \
   CONFIG.PCW_MIO_5_SLEW {slow} \
   CONFIG.PCW_MIO_6_DIRECTION {inout} \
   CONFIG.PCW_MIO_6_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_6_PULLUP {disabled} \
   CONFIG.PCW_MIO_6_SLEW {slow} \
   CONFIG.PCW_MIO_7_DIRECTION {out} \
   CONFIG.PCW_MIO_7_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_7_PULLUP {disabled} \
   CONFIG.PCW_MIO_7_SLEW {slow} \
   CONFIG.PCW_MIO_8_DIRECTION {out} \
   CONFIG.PCW_MIO_8_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_8_PULLUP {disabled} \
   CONFIG.PCW_MIO_8_SLEW {slow} \
   CONFIG.PCW_MIO_9_DIRECTION {inout} \
   CONFIG.PCW_MIO_9_IOTYPE {LVCMOS 3.3V} \
   CONFIG.PCW_MIO_9_PULLUP {enabled} \
   CONFIG.PCW_MIO_9_SLEW {slow} \
   CONFIG.PCW_MIO_TREE_PERIPHERALS {\
GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#UART\
0#UART 0#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#SPI 1#SPI 1#SPI 1#SPI 1#SPI\
1#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#GPIO#SD 0#SD 0#SD\
0#SD 0#SD 0#SD 0#GPIO#GPIO#UART 1#UART 1#GPIO#GPIO#GPIO#GPIO} \
   CONFIG.PCW_MIO_TREE_SIGNALS {\
gpio[0]#gpio[1]#gpio[2]#gpio[3]#gpio[4]#gpio[5]#gpio[6]#gpio[7]#gpio[8]#gpio[9]#gpio[10]#gpio[11]#gpio[12]#gpio[13]#rx#tx#gpio[16]#gpio[17]#gpio[18]#gpio[19]#gpio[20]#gpio[21]#mosi#miso#sclk#ss[0]#ss[1]#gpio[27]#gpio[28]#gpio[29]#gpio[30]#gpio[31]#gpio[32]#gpio[33]#gpio[34]#gpio[35]#gpio[36]#gpio[37]#gpio[38]#gpio[39]#clk#cmd#data[0]#data[1]#data[2]#data[3]#gpio[46]#gpio[47]#tx#rx#gpio[50]#gpio[51]#gpio[52]#gpio[53]} \
   CONFIG.PCW_PCAP_PERIPHERAL_DIVISOR0 {8} \
   CONFIG.PCW_QSPI_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SD0_GRP_CD_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_POW_ENABLE {0} \
   CONFIG.PCW_SD0_GRP_WP_ENABLE {0} \
   CONFIG.PCW_SD0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SD0_SD0_IO {MIO 40 .. 45} \
   CONFIG.PCW_SDIO_PERIPHERAL_DIVISOR0 {16} \
   CONFIG.PCW_SDIO_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_SDIO_PERIPHERAL_VALID {1} \
   CONFIG.PCW_SMC_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_SPI1_GRP_SS0_ENABLE {1} \
   CONFIG.PCW_SPI1_GRP_SS0_IO {MIO 25} \
   CONFIG.PCW_SPI1_GRP_SS1_ENABLE {1} \
   CONFIG.PCW_SPI1_GRP_SS1_IO {MIO 26} \
   CONFIG.PCW_SPI1_GRP_SS2_ENABLE {0} \
   CONFIG.PCW_SPI1_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_SPI1_SPI1_IO {MIO 22 .. 27} \
   CONFIG.PCW_SPI_PERIPHERAL_DIVISOR0 {10} \
   CONFIG.PCW_SPI_PERIPHERAL_FREQMHZ {160} \
   CONFIG.PCW_SPI_PERIPHERAL_VALID {1} \
   CONFIG.PCW_TPIU_PERIPHERAL_DIVISOR0 {1} \
   CONFIG.PCW_UART0_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART0_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_UART0_UART0_IO {MIO 14 .. 15} \
   CONFIG.PCW_UART1_GRP_FULL_ENABLE {0} \
   CONFIG.PCW_UART1_PERIPHERAL_ENABLE {1} \
   CONFIG.PCW_UART1_UART1_IO {MIO 48 .. 49} \
   CONFIG.PCW_UART_PERIPHERAL_DIVISOR0 {16} \
   CONFIG.PCW_UART_PERIPHERAL_FREQMHZ {100} \
   CONFIG.PCW_UART_PERIPHERAL_VALID {1} \
   CONFIG.PCW_UIPARAM_ACT_DDR_FREQ_MHZ {533.333374} \
   CONFIG.PCW_UIPARAM_DDR_BANK_ADDR_COUNT {3} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY0 {0.24} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY1 {0.223} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY2 {0.1} \
   CONFIG.PCW_UIPARAM_DDR_BOARD_DELAY3 {0.1} \
   CONFIG.PCW_UIPARAM_DDR_BUS_WIDTH {16 Bit} \
   CONFIG.PCW_UIPARAM_DDR_CL {7} \
   CONFIG.PCW_UIPARAM_DDR_COL_ADDR_COUNT {10} \
   CONFIG.PCW_UIPARAM_DDR_CWL {6} \
   CONFIG.PCW_UIPARAM_DDR_DEVICE_CAPACITY {4096 MBits} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_0 {0.017} \
   CONFIG.PCW_UIPARAM_DDR_DQS_TO_CLK_DELAY_1 {0.040} \
   CONFIG.PCW_UIPARAM_DDR_DRAM_WIDTH {16 Bits} \
   CONFIG.PCW_UIPARAM_DDR_ECC {Disabled} \
   CONFIG.PCW_UIPARAM_DDR_PARTNO {Custom} \
   CONFIG.PCW_UIPARAM_DDR_ROW_ADDR_COUNT {15} \
   CONFIG.PCW_UIPARAM_DDR_SPEED_BIN {DDR3_1600J} \
   CONFIG.PCW_UIPARAM_DDR_T_FAW {50} \
   CONFIG.PCW_UIPARAM_DDR_T_RAS_MIN {35} \
   CONFIG.PCW_UIPARAM_DDR_T_RC {48.75} \
   CONFIG.PCW_UIPARAM_DDR_T_RCD {7} \
   CONFIG.PCW_UIPARAM_DDR_T_RP {7} \
   CONFIG.PCW_USB0_RESET_ENABLE {0} \
   CONFIG.PCW_USB1_RESET_ENABLE {0} \
   CONFIG.PCW_USB_RESET_ENABLE {1} \
   CONFIG.PCW_USE_FABRIC_INTERRUPT {1} \
   CONFIG.PCW_USE_S_AXI_HP0 {1} \
   CONFIG.PCW_USE_S_AXI_HP1 {0} \
 ] $processing_system7_0

  # Create instance: rst_ps7_0_100M, and set properties
  set rst_ps7_0_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset rst_ps7_0_100M ]

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net S00_AXI_2 [get_bd_intf_pins axi_interconnect_1/S00_AXI] [get_bd_intf_pins processing_system7_0/M_AXI_GP0]
  connect_bd_intf_net -intf_net S_AXIS_1 [get_bd_intf_pins Transmit_Chain_0/S_AXIS] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net S_BRAM_AXI_1 [get_bd_intf_pins Transmit_Chain_0/S_BRAM_AXI] [get_bd_intf_pins axi_interconnect_1/M03_AXI]
  connect_bd_intf_net -intf_net Transmit_Chain_0_M_AXIS [get_bd_intf_pins Transmit_Chain_0/M_AXIS] [get_bd_intf_pins axi_dma_1/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net axi_dma_1_M_AXI_S2MM [get_bd_intf_pins axi_dma_1/M_AXI_S2MM] [get_bd_intf_pins axi_interconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_pins processing_system7_0/S_AXI_HP0]
  connect_bd_intf_net -intf_net axi_interconnect_1_M00_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins axi_interconnect_1/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M01_AXI [get_bd_intf_pins axi_dma_1/S_AXI_LITE] [get_bd_intf_pins axi_interconnect_1/M01_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_1_M02_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins axi_interconnect_1/M02_AXI]
  connect_bd_intf_net -intf_net processing_system7_0_DDR [get_bd_intf_ports DDR] [get_bd_intf_pins processing_system7_0/DDR]
  connect_bd_intf_net -intf_net processing_system7_0_FIXED_IO [get_bd_intf_ports FIXED_IO] [get_bd_intf_pins processing_system7_0/FIXED_IO]

  # Create port connections
  connect_bd_net -net playback_en_1 [get_bd_pins Transmit_Chain_0/playback_en] [get_bd_pins axi_gpio_0/gpio_io_o]
  connect_bd_net -net processing_system7_0_FCLK_CLK0 [get_bd_pins Transmit_Chain_0/aclk] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axi_dma_1/m_axi_s2mm_aclk] [get_bd_pins axi_dma_1/s_axi_lite_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_interconnect_1/ACLK] [get_bd_pins axi_interconnect_1/M00_ACLK] [get_bd_pins axi_interconnect_1/M01_ACLK] [get_bd_pins axi_interconnect_1/M02_ACLK] [get_bd_pins axi_interconnect_1/M03_ACLK] [get_bd_pins axi_interconnect_1/S00_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0] [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/S_AXI_HP0_ACLK] [get_bd_pins rst_ps7_0_100M/slowest_sync_clk]
  connect_bd_net -net processing_system7_0_FCLK_RESET0_N [get_bd_pins processing_system7_0/FCLK_RESET0_N] [get_bd_pins rst_ps7_0_100M/ext_reset_in]
  connect_bd_net -net rst_ps7_0_100M_peripheral_aresetn [get_bd_pins Transmit_Chain_0/aresetn] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins axi_dma_1/axi_resetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_interconnect_1/ARESETN] [get_bd_pins axi_interconnect_1/M00_ARESETN] [get_bd_pins axi_interconnect_1/M01_ARESETN] [get_bd_pins axi_interconnect_1/M02_ARESETN] [get_bd_pins axi_interconnect_1/M03_ARESETN] [get_bd_pins axi_interconnect_1/S00_ARESETN] [get_bd_pins rst_ps7_0_100M/peripheral_aresetn]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] -force
  assign_bd_address -offset 0x00000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces axi_dma_1/Data_S2MM] [get_bd_addr_segs processing_system7_0/S_AXI_HP0/HP0_DDR_LOWOCM] -force
  assign_bd_address -offset 0x40000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs Transmit_Chain_0/axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x40400000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x40410000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_dma_1/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x41200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces processing_system7_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] -force


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


