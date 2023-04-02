add_files -fileset sources_1 [glob rtl/*.vhd]
add_files -fileset sim_1 sim/transmit_chain_tb.sv
add_files -fileset sim_1 sim/dac_chain_tb.sv
add_files -fileset sim_1 sim/cic_tb.sv

import_ip ip/mult_gen_0.xci
upgrade_ip [get_ips {*}]

set_property  ip_repo_paths  ../ip_repo [current_project]
