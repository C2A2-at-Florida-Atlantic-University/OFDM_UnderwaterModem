#################################################################################################################################################
# Jared Hermans
#################################################################################################################################################

# Make sure to set environment variable $FAU_OFDM_REPO_PATH to root of this git repo
# This script will build the OFDM base project for the Modem board
# Run "vivado -mode batch -source build_radio_top_v2_reload.tcl"

set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)
create_project -force radio_top_v2_reload_fir_loop radio_top_v2_reload_fir_loop -part xc7z010clg400-1
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/modules
source file_list.tcl
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd
source ADC_Chain_FIR_250k_loop_bd.tcl
source DAC_Chain_FIR_250k_loop_bd.tcl
source PS_Zynq_v2_bd.tcl
source Ofdm_Sync_250k_reload_bd.tcl
source Radio_Top_v2_FIR_loop_bd.tcl
update_compile_order -fileset sources_1
make_wrapper -files [get_files $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_v2_reload_fir_loop/radio_top_v2_reload_fir_loop.srcs/sources_1/bd/Radio_Top_v2/Radio_Top_v2.bd] -top
add_files -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_v2_reload_fir_loop/radio_top_v2_reload_fir_loop.gen/sources_1/bd/Radio_Top_v2/hdl/Radio_Top_v2_wrapper.v
update_compile_order -fileset sources_1
set_property top Radio_Top_v2_wrapper [current_fileset]
update_compile_order -fileset sources_1
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/constraints
add_files -fileset constrs_1 -norecurse SDUAMconstraints.xdc
set_property -name {xsim.simulate.runtime} -value {} -objects [get_filesets sim_1]

if (1) {
  launch_runs synth_1 -jobs 24
  wait_on_run synth_1
  launch_runs impl_1 -to_step write_bitstream
  wait_on_run impl_1
  write_hw_platform -fixed -include_bit -force -file Radio_Top_v2_wrapper.xsa
}

start_gui
