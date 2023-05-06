#################################################################################################################################################
# Jared Hermans
#################################################################################################################################################

# Make sure to set environment variable $FAU_OFDM_REPO_PATH to root of this git repo
set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)
create_project -force ofdm_sync_reload_250 ofdm_sync_reload_250 -part xc7z010clg400-1
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]
update_ip_catalog
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/modules
source file_list.tcl
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd
source Ofdm_Sync_250k_reload_bd.tcl
update_compile_order -fileset sources_1
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/ofdm_sync_reload_250
start_gui
