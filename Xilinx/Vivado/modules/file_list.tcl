set FAU_OFDM_REPO_PATH $::env(FAU_OFDM_REPO_PATH)

# Add source files
add_files -fileset sources_1 [glob rtl/*.vhd]

# Add sim files
add_files -fileset sim_1 sim/transmit_chain_tb.sv
add_files -fileset sim_1 sim/dac_chain_tb.sv
add_files -fileset sim_1 sim/cic_tb.sv
add_files -fileset sim_1 sim/cic_tx_tb.sv
add_files -fileset sim_1 sim/adc_chain_tb.sv
add_files -fileset sim_1 sim/synchronizer_tb.sv

# Add instantiated IQ
import_ip ip/mult_gen_0.xci
import_ip ip/ila_0.xci
upgrade_ip [get_ips {*}]
set_property generate_synth_checkpoint 0 [get_files mult_gen_0.xci]
set_property generate_synth_checkpoint 0 [get_files ila_0.xci]

# Add ip repo
set_property  ip_repo_paths  $FAU_OFDM_REPO_PATH/Xilinx/Vivado/ip_repo [current_project]
update_ip_catalog
