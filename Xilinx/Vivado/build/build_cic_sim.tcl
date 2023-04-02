#################################################################################################################################################
# Jared Hermans
#################################################################################################################################################

set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)
create_project -force cic_test cic_test -part xc7z010clg400-1
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/modules
source file_list.tcl
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd
source ./cic_compiler_test_bd.tcl
update_compile_order -fileset sources_1
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/cic_test
make_wrapper -files [get_files $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/cic_test/cic_test.srcs/sources_1/bd/cic/cic.bd] -top
add_files -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/cic_test/cic_test.gen/sources_1/bd/cic/hdl/cic_wrapper.v
update_compile_order -fileset sources_1
set_property top cic_wrapper [current_fileset]
update_compile_order -fileset sources_1
set_property -name {xsim.simulate.runtime} -value {} -objects [get_filesets sim_1]
set_property top cic_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
update_compile_order -fileset sim_1
add_files -fileset sim_1 -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/wcfg/cic_tb_behav.wcfg
set_property xsim.view $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/wcfg/cic_tb_behav.wcfg [get_filesets sim_1]
start_gui
