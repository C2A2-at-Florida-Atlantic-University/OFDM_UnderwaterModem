set FAUPath $::env(FAUPath)

create_project radio_top_pynq radio_top_pynq -part xc7z020clg400-1
set_property board_part tul.com.tw:pynq-z2:part0:1.0 [current_project]
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]

cd $FAUPath/modules
source file_list.tcl

cd $FAUPath/bd
source Transmit_Chain_bd.tcl
source PS_Zynq_Pynq_bd.tcl
source Radio_Top_Pynq_bd.tcl

update_compile_order -fileset sources_1
cd $FAUPath/build
make_wrapper -files [get_files radio_top_pynq/radio_top_pynq.srcs/sources_1/bd/Radio_Top_Pynq/Radio_Top_Pynq.bd] -top
add_files -norecurse radio_top_pynq/radio_top_pynq.gen/sources_1/bd/Radio_Top_Pynq/hdl/Radio_Top_Pynq_wrapper.v
update_compile_order -fileset sources_1
generate_target -force -verbose -quiet {synthesis} [get_ips]

update_compile_order -fileset sources_1

cd $FAUPath/constraints
add_files -fileset constrs_1 -norecurse base_pynq_z2.xdc

start_gui
