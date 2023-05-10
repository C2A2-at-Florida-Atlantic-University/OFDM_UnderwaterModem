#################################################################################################################################################
# Jared Hermans
#################################################################################################################################################

# Make sure to set environment variable $FAU_OFDM_REPO_PATH to root of this git repo
# This script will build the DAC chain block design container for simulation
# Run "vivado -mode batch -source build_dac_chain_sim.tcl"
# If BD is edited run "write_bd_tcl -force -no_ip_version $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd/ADC_Chain_bd.tcl"

set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)
create_project -force duc_ddc_loopback_sim_v2 duc_ddc_loopback_sim_v2 -part xc7z010clg400-1
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]
update_ip_catalog
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/modules
source file_list.tcl
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd
source DAC_Chain_loop_bd.tcl
#source ADC_Chain_loop_bd.tcl
source ADC_Chain_v2_loop_bd.tcl
source DUC_DDC_Loopback_Sim_bd.tcl
update_compile_order -fileset sources_1
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/duc_ddc_loopback_sim_v2
make_wrapper -files [get_files $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/duc_ddc_loopback_sim_v2/duc_ddc_loopback_sim_v2.srcs/sources_1/bd/DUC_DDC_Loopback_Sim/DUC_DDC_Loopback_Sim.bd] -top
add_files -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/duc_ddc_loopback_sim_v2/duc_ddc_loopback_sim_v2.gen/sources_1/bd/DUC_DDC_Loopback_Sim/hdl/DUC_DDC_Loopback_Sim_wrapper.v
update_compile_order -fileset sources_1
set_property top DUC_DDC_Loopback_Sim_wrapper [current_fileset]
generate_target -force -verbose -quiet {synthesis} [get_ips]
update_compile_order -fileset sources_1
set_property -name {xsim.simulate.runtime} -value {} -objects [get_filesets sim_1]
set_property top duc_ddc_loopback_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/wcfg/duc_ddc_loopback_v2_tb_behav.wcfg
set_property xsim.view $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/wcfg/duc_ddc_loopback_v2_tb_behav.wcfg [get_filesets sim_1]
start_gui
