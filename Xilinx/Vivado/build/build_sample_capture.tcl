#################################################################################################################################################
# Jared Hermans
#################################################################################################################################################

# Make sure to set environment variable $FAU_OFDM_REPO_PATH to root of this git repo
# This script will build the OFDM base project for the Modem board
# Run "vivado -mode batch -source build_sample_capture.tcl"

set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)
create_project -force sample_capture sample_capture -part xc7z010clg400-1
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/modules
source file_list.tcl
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd
source ADC_Chain_bd.tcl
source DAC_Chain_bd.tcl
source PS_Zynq_v2_bd.tcl
source Ofdm_Sync_250k_reload_bd.tcl
#source Sample_Capture_reload_bd.tcl
source Radio_Top_v2_reload_bd.tcl
update_compile_order -fileset sources_1
make_wrapper -files [get_files $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/sample_capture/sample_capture.srcs/sources_1/bd/Sample_Capture/Sample_Capture.bd] -top
add_files -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/sample_capture/sample_capture.gen/sources_1/bd/Sample_Capture/hdl/Sample_Capture_wrapper.v
update_compile_order -fileset sources_1
set_property top Sample_Capture_wrapper [current_fileset]
update_compile_order -fileset sources_1
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/constraints
add_files -fileset constrs_1 -norecurse SDUAMconstraints.xdc
set_property -name {xsim.simulate.runtime} -value {} -objects [get_filesets sim_1]

if (0) {
  launch_runs synth_1 -jobs 24
  wait_on_run synth_1
  launch_runs impl_1 -to_step write_bitstream
  wait_on_run impl_1
  write_hw_platform -fixed -include_bit -force -file Sample_Capture_wrapper.xsa
}

start_gui
