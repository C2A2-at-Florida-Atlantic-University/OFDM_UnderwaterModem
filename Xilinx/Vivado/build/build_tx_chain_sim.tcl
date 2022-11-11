set FAUPath $::env(FAUPath)

create_project transmit_chain transmit_chain -part xc7z010clg400-1
#set_property board_part xilinx.com:zcu111:part0:1.4 [current_project]
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]

cd $FAUPath/modules
source file_list.tcl

cd $FAUPath/bd
source Transmit_Chain_bd.tcl

update_compile_order -fileset sources_1
cd $FAUPath/build
make_wrapper -files [get_files transmit_chain/transmit_chain.srcs/sources_1/bd/Transmit_Chain/Transmit_Chain.bd] -top
add_files -norecurse transmit_chain/transmit_chain.gen/sources_1/bd/Transmit_Chain/hdl/Transmit_Chain_wrapper.v
update_compile_order -fileset sources_1
set_property top Transmit_Chain_wrapper [current_fileset]

generate_target -force -verbose -quiet {synthesis} [get_ips]

update_compile_order -fileset sources_1


start_gui
