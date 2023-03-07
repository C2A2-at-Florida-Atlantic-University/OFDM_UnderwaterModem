#################################################################################################################################################
# Jared Hermans
#################################################################################################################################################

# Make sure to set environment variable $FAU_OFDM_REPO_PATH to root of this git repo
# This script will build the OFDM base project for the Pynq-Z2 board (without DAC/ADC interface)
# Run "vivado -mode batch -source build_radio_top.tcl"

set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)
create_project radio_top radio_top -part xc7z010clg400-1
#set_property board_part xilinx.com:zcu111:part0:1.4 [current_project]
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/modules
source file_list.tcl
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd
source Transmit_Chain_bd.tcl
source radio_top_bd.tcl
update_compile_order -fileset sources_1
generate_target -force -verbose -quiet {synthesis} [get_ips]
update_compile_order -fileset sources_1
start_gui
