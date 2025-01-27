#################################################################################################################################################
# Jared Hermans
#################################################################################################################################################

# Make sure to set environment variable $FAU_OFDM_REPO_PATH to root of this git repo
# This script will build the DAC chain block design container for simulation
# Run "vivado -mode batch -source build_dac_chain_sim.tcl"

set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)
create_project -force dac_chain dac_chain -part xc7z010clg400-1
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/modules
source file_list.tcl
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd
source DAC_Chain_bd.tcl
update_compile_order -fileset sources_1
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/dac_chain
make_wrapper -files [get_files dac_chain.srcs/sources_1/bd/DAC_Chain/DAC_Chain.bd] -top
add_files -norecurse dac_chain.gen/sources_1/bd/DAC_Chain/hdl/DAC_Chain_wrapper.v
update_compile_order -fileset sources_1
set_property top DAC_Chain_wrapper [current_fileset]
generate_target -force -verbose -quiet {synthesis} [get_ips]
update_compile_order -fileset sources_1
set_property top dac_chain_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {} -objects [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/wcfg/dac_chain_tb_behav.wcfg
set_property xsim.view $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/wcfg/dac_chain_tb_behav.wcfg [get_filesets sim_1]
update_compile_order -fileset sim_1
start_gui
