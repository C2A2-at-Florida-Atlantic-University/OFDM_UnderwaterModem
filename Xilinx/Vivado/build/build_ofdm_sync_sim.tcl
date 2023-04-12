#################################################################################################################################################
# Jared Hermans
#################################################################################################################################################

# Make sure to set environment variable $FAU_OFDM_REPO_PATH to root of this git repo
set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)
create_project -force ofdm_sync ofdm_sync -part xc7z010clg400-1
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]
update_ip_catalog
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/modules
source file_list.tcl
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd
source Ofdm_Sync_250k_bd.tcl
update_compile_order -fileset sources_1
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/ofdm_sync
make_wrapper -files [get_files $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/ofdm_sync/ofdm_sync.srcs/sources_1/bd/Ofdm_Sync_250k/Ofdm_Sync_250k.bd] -top
add_files -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/ofdm_sync/ofdm_sync.gen/sources_1/bd/Ofdm_Sync_250k/hdl/Ofdm_Sync_250k_wrapper.v
update_compile_order -fileset sources_1
set_property top Ofdm_Sync_250k_wrapper [current_fileset]
generate_target -force -verbose -quiet {synthesis} [get_ips]
update_compile_order -fileset sources_1
set_property -name {xsim.simulate.runtime} -value {} -objects [get_filesets sim_1]
set_property top synchronizer_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
add_files -fileset sim_1 -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/wcfg/synchronizer_tb_behav.wcfg
set_property xsim.view $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/wcfg/synchronizer_tb_behav.wcfg [get_filesets sim_1]
start_gui
