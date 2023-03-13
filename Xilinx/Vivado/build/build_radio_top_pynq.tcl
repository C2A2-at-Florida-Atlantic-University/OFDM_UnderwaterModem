#################################################################################################################################################
# Jared Hermans
#################################################################################################################################################

# Make sure to set environment variable $FAU_OFDM_REPO_PATH to root of this git repo
# This script will build the OFDM base project for the Pynq-Z2 board (without DAC/ADC interface)
# Run "vivado -mode batch -source build_radio_top_pynq.tcl"

# Download pynq-z2 from https://www.tulembedded.com/FPGA/ProductsPYNQ-Z2.html#:~:text=Z2%20Board%20File
# Copy pynq-z2 to <Xilinx_Install_Path>/Vivado/<vivado_version>/data/boards/board_files
# Open vivado and run TCL: "set_param board.repoPaths [list "<path_to_board_file>/pynq-z2/A.0"]

set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)
create_project -force radio_top_pynq radio_top_pynq -part xc7z020clg400-1
set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/modules
source file_list.tcl
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd
source Transmit_Chain_bd.tcl
source PS_Zynq_Pynq_bd.tcl
source Radio_Top_Pynq_bd.tcl
update_compile_order -fileset sources_1
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build
make_wrapper -files [get_files $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq/radio_top_pynq.srcs/sources_1/bd/Radio_Top_Pynq/Radio_Top_Pynq.bd] -top
add_files -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq/radio_top_pynq.gen/sources_1/bd/Radio_Top_Pynq/hdl/Radio_Top_Pynq_wrapper.v
update_compile_order -fileset sources_1
generate_target -force -verbose -quiet {synthesis} [get_ips]
update_compile_order -fileset sources_1
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/constraints
add_files -fileset constrs_1 -norecurse base_pynq_z2.xdc
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq

if (1) {
  launch_runs synth_1 -jobs 12
  wait_on_run synth_1
  launch_runs impl_1 -to_step write_bitstream
  wait_on_run impl_1
  write_hw_platform -fixed -include_bit -force -file Radio_Top_Pynq_wrapper.xsa
}

start_gui
