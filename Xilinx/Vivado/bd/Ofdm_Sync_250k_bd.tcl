
################################################################
# This is a generated script based on design: Ofdm_Sync_250k
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
# source Ofdm_Sync_250k_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# iq_concat, iq_split, max_thresh, synchronizer

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
set design_name Ofdm_Sync_250k

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
user.org:user:AXIS_Splitter:*\
xilinx.com:ip:cordic:*\
xilinx.com:ip:fir_compiler:*\
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
iq_concat\
iq_split\
max_thresh\
synchronizer\
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
   CONFIG.HAS_TLAST {0} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S_AXIS


  # Create ports
  set aclk [ create_bd_port -dir I -type clk aclk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S_AXIS:M_AXIS} \
   CONFIG.ASSOCIATED_RESET {aresetn} \
 ] $aclk
  set aresetn [ create_bd_port -dir I -type rst aresetn ]
  set i_cp_len [ create_bd_port -dir I -from 11 -to 0 i_cp_len ]
  set i_nfft [ create_bd_port -dir I -from 11 -to 0 i_nfft ]
  set i_symbols [ create_bd_port -dir I -from 3 -to 0 i_symbols ]
  set i_sync_offset [ create_bd_port -dir I -from 9 -to 0 i_sync_offset ]
  set i_threshold [ create_bd_port -dir I -from 31 -to 0 i_threshold ]

  # Create instance: AXIS_Splitter_0, and set properties
  set AXIS_Splitter_0 [ create_bd_cell -type ip -vlnv user.org:user:AXIS_Splitter AXIS_Splitter_0 ]
  set_property -dict [ list \
   CONFIG.M_TREADY_ANDED_TVALID {true} \
 ] $AXIS_Splitter_0

  # Create instance: AXIS_Splitter_1, and set properties
  set AXIS_Splitter_1 [ create_bd_cell -type ip -vlnv user.org:user:AXIS_Splitter AXIS_Splitter_1 ]
  set_property -dict [ list \
   CONFIG.AXIS_TDATA_WIDTH {64} \
 ] $AXIS_Splitter_1

  # Create instance: cordic_0, and set properties
  set cordic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:cordic cordic_0 ]
  set_property -dict [ list \
   CONFIG.Compensation_Scaling {Embedded_Multiplier} \
   CONFIG.Data_Format {SignedFraction} \
   CONFIG.Functional_Selection {Translate} \
   CONFIG.Input_Width {32} \
   CONFIG.Output_Width {32} \
 ] $cordic_0

  # Create instance: fir_compiler_imag, and set properties
  set fir_compiler_imag [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler fir_compiler_imag ]
  set_property -dict [ list \
   CONFIG.Clock_Frequency {100.0} \
   CONFIG.CoefficientSource {COE_File} \
   CONFIG.Coefficient_File {/home/jared/Projects/OFDM_UnderwaterModem/Xilinx/Vivado/modules/data/zc_4096_nfft_2048_ZC_13_root_q.coe} \
   CONFIG.Coefficient_Fractional_Bits {0} \
   CONFIG.Coefficient_Sets {1} \
   CONFIG.Coefficient_Sign {Signed} \
   CONFIG.Coefficient_Structure {Inferred} \
   CONFIG.Coefficient_Width {16} \
   CONFIG.ColumnConfig {11} \
   CONFIG.Data_Fractional_Bits {0} \
   CONFIG.Data_Width {16} \
   CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
   CONFIG.Has_ARESETn {true} \
   CONFIG.M_DATA_Has_TREADY {true} \
   CONFIG.Output_Rounding_Mode {Truncate_LSBs} \
   CONFIG.Output_Width {32} \
   CONFIG.Quantization {Integer_Coefficients} \
   CONFIG.Sample_Frequency {0.25} \
 ] $fir_compiler_imag

  # Create instance: fir_compiler_real, and set properties
  set fir_compiler_real [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler fir_compiler_real ]
  set_property -dict [ list \
   CONFIG.Clock_Frequency {100.0} \
   CONFIG.CoefficientSource {COE_File} \
   CONFIG.Coefficient_File {/home/jared/Projects/OFDM_UnderwaterModem/Xilinx/Vivado/modules/data/zc_4096_nfft_2048_ZC_13_root_i.coe} \
   CONFIG.Coefficient_Fractional_Bits {0} \
   CONFIG.Coefficient_Sets {1} \
   CONFIG.Coefficient_Sign {Signed} \
   CONFIG.Coefficient_Structure {Inferred} \
   CONFIG.Coefficient_Width {16} \
   CONFIG.ColumnConfig {11} \
   CONFIG.Data_Fractional_Bits {0} \
   CONFIG.Data_Width {16} \
   CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
   CONFIG.Has_ARESETn {true} \
   CONFIG.M_DATA_Has_TREADY {true} \
   CONFIG.Output_Rounding_Mode {Truncate_LSBs} \
   CONFIG.Output_Width {32} \
   CONFIG.Quantization {Integer_Coefficients} \
   CONFIG.Sample_Frequency {0.25} \
 ] $fir_compiler_real

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
  
  # Create instance: iq_split_0, and set properties
  set block_name iq_split
  set block_cell_name iq_split_0
  if { [catch {set iq_split_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $iq_split_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: max_thresh_0, and set properties
  set block_name max_thresh
  set block_cell_name max_thresh_0
  if { [catch {set max_thresh_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $max_thresh_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
  
  # Create instance: synchronizer_0, and set properties
  set block_name synchronizer
  set block_cell_name synchronizer_0
  if { [catch {set synchronizer_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $synchronizer_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [ list \
   CONFIG.g_ILA {false} \
 ] $synchronizer_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant xlconstant_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net AXIS_Splitter_0_M00_AXIS [get_bd_intf_pins AXIS_Splitter_0/M00_AXIS] [get_bd_intf_pins synchronizer_0/s_axis]
  connect_bd_intf_net -intf_net AXIS_Splitter_0_M01_AXIS [get_bd_intf_pins AXIS_Splitter_0/M01_AXIS] [get_bd_intf_pins iq_split_0/s_axis]
  connect_bd_intf_net -intf_net AXIS_Splitter_1_M00_AXIS [get_bd_intf_pins AXIS_Splitter_1/M00_AXIS] [get_bd_intf_pins max_thresh_0/s_axis]
  connect_bd_intf_net -intf_net AXIS_Splitter_1_M01_AXIS [get_bd_intf_pins AXIS_Splitter_1/M01_AXIS] [get_bd_intf_pins synchronizer_0/s_axis_abs_ila]
  connect_bd_intf_net -intf_net S_AXIS_1 [get_bd_intf_ports S_AXIS] [get_bd_intf_pins AXIS_Splitter_0/S00_AXIS]
  connect_bd_intf_net -intf_net cordic_0_M_AXIS_DOUT [get_bd_intf_pins AXIS_Splitter_1/S00_AXIS] [get_bd_intf_pins cordic_0/M_AXIS_DOUT]
  connect_bd_intf_net -intf_net fir_compiler_imag_M_AXIS_DATA [get_bd_intf_pins fir_compiler_imag/M_AXIS_DATA] [get_bd_intf_pins iq_concat_0/s_axis_imag]
  connect_bd_intf_net -intf_net fir_compiler_real_M_AXIS_DATA [get_bd_intf_pins fir_compiler_real/M_AXIS_DATA] [get_bd_intf_pins iq_concat_0/s_axis_real]
  connect_bd_intf_net -intf_net iq_concat_0_m_axis [get_bd_intf_pins cordic_0/S_AXIS_CARTESIAN] [get_bd_intf_pins iq_concat_0/m_axis]
  connect_bd_intf_net -intf_net iq_split_0_m_axis_imag [get_bd_intf_pins fir_compiler_imag/S_AXIS_DATA] [get_bd_intf_pins iq_split_0/m_axis_imag]
  connect_bd_intf_net -intf_net iq_split_0_m_axis_real [get_bd_intf_pins fir_compiler_real/S_AXIS_DATA] [get_bd_intf_pins iq_split_0/m_axis_real]
  connect_bd_intf_net -intf_net synchronizer_0_m_axis [get_bd_intf_ports M_AXIS] [get_bd_intf_pins synchronizer_0/m_axis]

  # Create port connections
  connect_bd_net -net aclk_0_1 [get_bd_ports aclk] [get_bd_pins AXIS_Splitter_0/axis_aclk] [get_bd_pins AXIS_Splitter_1/axis_aclk] [get_bd_pins cordic_0/aclk] [get_bd_pins fir_compiler_imag/aclk] [get_bd_pins fir_compiler_real/aclk] [get_bd_pins iq_concat_0/axis_aclk] [get_bd_pins iq_split_0/axis_aclk] [get_bd_pins max_thresh_0/axis_aclk] [get_bd_pins synchronizer_0/axis_aclk]
  connect_bd_net -net i_cp_len_0_1 [get_bd_ports i_cp_len] [get_bd_pins synchronizer_0/i_cp_len]
  connect_bd_net -net i_nfft_0_1 [get_bd_ports i_nfft] [get_bd_pins synchronizer_0/i_nfft]
  connect_bd_net -net i_symbols_0_1 [get_bd_ports i_symbols] [get_bd_pins synchronizer_0/i_symbols]
  connect_bd_net -net i_threshold_0_1 [get_bd_ports i_threshold] [get_bd_pins max_thresh_0/i_threshold]
  connect_bd_net -net i_trig_offset_0_1 [get_bd_ports i_sync_offset] [get_bd_pins synchronizer_0/i_trig_offset]
  connect_bd_net -net max_thresh_0_o_max_detected [get_bd_pins max_thresh_0/o_max_detected] [get_bd_pins synchronizer_0/i_max_sync]
  connect_bd_net -net resetn_0_1 [get_bd_ports aresetn] [get_bd_pins fir_compiler_imag/aresetn] [get_bd_pins fir_compiler_real/aresetn]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins AXIS_Splitter_0/tready_select] [get_bd_pins AXIS_Splitter_1/tready_select] [get_bd_pins xlconstant_0/dout]

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


