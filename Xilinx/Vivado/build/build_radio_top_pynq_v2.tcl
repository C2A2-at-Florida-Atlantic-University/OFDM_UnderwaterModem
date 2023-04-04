#################################################################################################################################################
# Jared Hermans
#################################################################################################################################################

set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)
create_project -force radio_top_pynq_v2 radio_top_pynq_v2 -part xc7z020clg400-1
set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/modules
source file_list.tcl
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/bd
source ADC_Chain_bd.tcl
set_property generate_synth_checkpoint false [get_files  $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq_v2/radio_top_pynq_v2.srcs/sources_1/ip/mult_gen_0/mult_gen_0.xci]
generate_target all [get_files  $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq_v2/radio_top_pynq_v2.srcs/sources_1/ip/mult_gen_0/mult_gen_0.xci]
source DAC_Chain_bd.tcl
source PS_Zynq_Pynq_v2_bd.tcl
source Radio_Top_Pynq_v2_bd.tcl
update_compile_order -fileset sources_1
make_wrapper -files [get_files $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq_v2/radio_top_pynq_v2.srcs/sources_1/bd/Radio_Top_Pynq_v2/Radio_Top_Pynq_v2.bd] -top
add_files -norecurse $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq_v2/radio_top_pynq_v2.gen/sources_1/bd/Radio_Top_Pynq_v2/hdl/Radio_Top_Pynq_v2_wrapper.v
update_compile_order -fileset sources_1
set_property top Radio_Top_Pynq_v2_wrapper [current_fileset]
update_compile_order -fileset sources_1
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/constraints
add_files -fileset constrs_1 -norecurse base_pynq_z2.xdc
cd $FAU_OFDM_REPO_PATH/Xilinx/Vivado/build/radio_top_pynq_v2

if (1) {
  launch_runs synth_1 -jobs 24
  wait_on_run synth_1
  launch_runs impl_1 -to_step write_bitstream
  wait_on_run impl_1
  write_hw_platform -fixed -include_bit -force -file Radio_Top_Pynq_v2_wrapper.xsa
}

start_gui
