set FAUPath $::env(FAUPath)

create_project radio_top radio_top -part xc7z010clg400-1
#set_property board_part xilinx.com:zcu111:part0:1.4 [current_project]
# BD Wrapper has to be verilog or else simulation crashes
set_property target_language Verilog [current_project]

cd $FAUPath/modules
source file_list.tcl

cd $FAUPath/bd
source Transmit_Chain_bd.tcl
source radio_top_bd.tcl

update_compile_order -fileset sources_1

generate_target -force -verbose -quiet {synthesis} [get_ips]

update_compile_order -fileset sources_1


start_gui
