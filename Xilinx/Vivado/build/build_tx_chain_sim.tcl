#################################################################################################################################################
# Jared Hermans
#################################################################################################################################################

# Make sure to set environment variable $FAU_OFDM_REPO_PATH to root of this git repo
# This script will build the transmit_chain block design container for simulation
# Run "vivado -mode batch -source build_tx_chain_sim.tcl"

set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)
create_project -force transmit_chain transmit_chain -part xc7z010clg400-1
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/modules
source file_list.tcl
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd
source Transmit_Chain_bd.tcl
update_compile_order -fileset sources_1
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build
make_wrapper -files [get_files $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/transmit_chain/transmit_chain.srcs/sources_1/bd/Transmit_Chain/Transmit_Chain.bd] -top
add_files -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/transmit_chain/transmit_chain.gen/sources_1/bd/Transmit_Chain/hdl/Transmit_Chain_wrapper.v
update_compile_order -fileset sources_1
set_property top Transmit_Chain_wrapper [current_fileset]
set_property -name {xsim.simulate.runtime} -value {} -objects [get_filesets sim_1]
generate_target -force -verbose -quiet {synthesis} [get_ips]
update_compile_order -fileset sources_1
set_property top transmit_chain_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/transmit_chain
add_files -fileset sim_1 -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/transmit_chain/transmit_chain_tb_behav.wcfg
set_property xsim.view $FAU_OFDM_REPO_PATH/Xilinx/Vivado/builds/transmit_chain/transmit_chain_tb_behav.wcfg [get_filesets sim_1]

start_gui
