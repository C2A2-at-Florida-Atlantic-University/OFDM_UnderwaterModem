set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)

# Add source files
add_files -fileset sources_1 [glob rtl/*.vhd]

# Add sim files
add_files -fileset sim_1 [glob sim/*.sv]

# Add instantiated IP
import_ip ip/mult_gen_0.xci
import_ip ip/ila_0.xci
import_ip ip/ila_1.xci
import_ip ip/dds_compiler_0.xci
import_ip ip/duc_fir_compiler.xci

upgrade_ip [get_ips {*}]
set_property generate_synth_checkpoint 0 [get_files mult_gen_0.xci]
set_property generate_synth_checkpoint 0 [get_files ila_0.xci]
set_property generate_synth_checkpoint 0 [get_files duc_fir_compiler.xci]

# Add ip repo
set_property  ip_repo_paths  $FAU_OFDM_REPO_PATH/Xilinx/Vivado/ip_repo [current_project]
update_ip_catalog
