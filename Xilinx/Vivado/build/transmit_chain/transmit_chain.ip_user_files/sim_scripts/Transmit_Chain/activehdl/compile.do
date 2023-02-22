vlib work
vlib activehdl

vlib activehdl/xpm
vlib activehdl/axi_bram_ctrl_v4_1_6
vlib activehdl/xil_defaultlib
vlib activehdl/axis_infrastructure_v1_1_0
vlib activehdl/axis_data_fifo_v2_0_8
vlib activehdl/xbip_utils_v3_0_10
vlib activehdl/axi_utils_v2_0_6
vlib activehdl/c_reg_fd_v12_0_6
vlib activehdl/xbip_dsp48_wrapper_v3_0_4
vlib activehdl/xbip_pipe_v3_0_6
vlib activehdl/xbip_dsp48_addsub_v3_0_6
vlib activehdl/xbip_addsub_v3_0_6
vlib activehdl/c_addsub_v12_0_14
vlib activehdl/c_mux_bit_v12_0_6
vlib activehdl/c_shift_ram_v12_0_14
vlib activehdl/xbip_bram18k_v3_0_6
vlib activehdl/mult_gen_v12_0_18
vlib activehdl/cmpy_v6_0_21
vlib activehdl/floating_point_v7_0_20
vlib activehdl/xfft_v9_1_8
vlib activehdl/blk_mem_gen_v8_4_5

vmap xpm activehdl/xpm
vmap axi_bram_ctrl_v4_1_6 activehdl/axi_bram_ctrl_v4_1_6
vmap xil_defaultlib activehdl/xil_defaultlib
vmap axis_infrastructure_v1_1_0 activehdl/axis_infrastructure_v1_1_0
vmap axis_data_fifo_v2_0_8 activehdl/axis_data_fifo_v2_0_8
vmap xbip_utils_v3_0_10 activehdl/xbip_utils_v3_0_10
vmap axi_utils_v2_0_6 activehdl/axi_utils_v2_0_6
vmap c_reg_fd_v12_0_6 activehdl/c_reg_fd_v12_0_6
vmap xbip_dsp48_wrapper_v3_0_4 activehdl/xbip_dsp48_wrapper_v3_0_4
vmap xbip_pipe_v3_0_6 activehdl/xbip_pipe_v3_0_6
vmap xbip_dsp48_addsub_v3_0_6 activehdl/xbip_dsp48_addsub_v3_0_6
vmap xbip_addsub_v3_0_6 activehdl/xbip_addsub_v3_0_6
vmap c_addsub_v12_0_14 activehdl/c_addsub_v12_0_14
vmap c_mux_bit_v12_0_6 activehdl/c_mux_bit_v12_0_6
vmap c_shift_ram_v12_0_14 activehdl/c_shift_ram_v12_0_14
vmap xbip_bram18k_v3_0_6 activehdl/xbip_bram18k_v3_0_6
vmap mult_gen_v12_0_18 activehdl/mult_gen_v12_0_18
vmap cmpy_v6_0_21 activehdl/cmpy_v6_0_21
vmap floating_point_v7_0_20 activehdl/floating_point_v7_0_20
vmap xfft_v9_1_8 activehdl/xfft_v9_1_8
vmap blk_mem_gen_v8_4_5 activehdl/blk_mem_gen_v8_4_5

vlog -work xpm  -sv2k12 "+incdir+../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/8713/hdl" \
"C:/Xilinx/Vivado/2022.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"C:/Xilinx/Vivado/2022.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
"C:/Xilinx/Vivado/2022.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"C:/Xilinx/Vivado/2022.1/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work axi_bram_ctrl_v4_1_6 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/3c31/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/Transmit_Chain/ip/Transmit_Chain_axi_bram_ctrl_0_1/sim/Transmit_Chain_axi_bram_ctrl_0_1.vhd" \

vlog -work axis_infrastructure_v1_1_0  -v2k5 "+incdir+../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/8713/hdl" \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/8713/hdl/axis_infrastructure_v1_1_vl_rfs.v" \

vlog -work axis_data_fifo_v2_0_8  -v2k5 "+incdir+../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/8713/hdl" \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/0bd2/hdl/axis_data_fifo_v2_0_vl_rfs.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/8713/hdl" \
"../../../bd/Transmit_Chain/ip/Transmit_Chain_axis_data_fifo_0_1/sim/Transmit_Chain_axis_data_fifo_0_1.v" \
"../../../bd/Transmit_Chain/ip/Transmit_Chain_axis_data_fifo_1_1/sim/Transmit_Chain_axis_data_fifo_1_1.v" \
"../../../bd/Transmit_Chain/ip/Transmit_Chain_fft_config_0_1/sim/Transmit_Chain_fft_config_0_1.v" \

vcom -work xbip_utils_v3_0_10 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/364f/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_6 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/1971/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work c_reg_fd_v12_0_6 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/edec/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_4 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/cdbf/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_6 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/7468/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_addsub_v3_0_6 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/910d/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \

vcom -work xbip_addsub_v3_0_6 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/cfdd/hdl/xbip_addsub_v3_0_vh_rfs.vhd" \

vcom -work c_addsub_v12_0_14 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/ebb8/hdl/c_addsub_v12_0_vh_rfs.vhd" \

vcom -work c_mux_bit_v12_0_6 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/ecb4/hdl/c_mux_bit_v12_0_vh_rfs.vhd" \

vcom -work c_shift_ram_v12_0_14 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/2598/hdl/c_shift_ram_v12_0_vh_rfs.vhd" \

vcom -work xbip_bram18k_v3_0_6 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/d367/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_18 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/ab19/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work cmpy_v6_0_21 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/b7d0/hdl/cmpy_v6_0_vh_rfs.vhd" \

vcom -work floating_point_v7_0_20 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/1b8e/hdl/floating_point_v7_0_vh_rfs.vhd" \

vcom -work xfft_v9_1_8 -93 \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/102e/hdl/xfft_v9_1_vh_rfs.vhd" \

vcom -work xil_defaultlib -93 \
"../../../bd/Transmit_Chain/ip/Transmit_Chain_ifft_1/sim/Transmit_Chain_ifft_1.vhd" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/8713/hdl" \
"../../../bd/Transmit_Chain/ip/Transmit_Chain_mux_0_1/sim/Transmit_Chain_mux_0_1.v" \
"../../../bd/Transmit_Chain/ip/Transmit_Chain_playback_ctrl_0_1/sim/Transmit_Chain_playback_ctrl_0_1.v" \

vlog -work blk_mem_gen_v8_4_5  -v2k5 "+incdir+../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/8713/hdl" \
"../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/25a8/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/8713/hdl" \
"../../../bd/Transmit_Chain/ip/Transmit_Chain_playback_mem_1/sim/Transmit_Chain_playback_mem_1.v" \
"../../../bd/Transmit_Chain/ip/Transmit_Chain_real_time_sampler_0_0/sim/Transmit_Chain_real_time_sampler_0_0.v" \
"../../../bd/Transmit_Chain/ip/Transmit_Chain_tlast_gen_0_1/sim/Transmit_Chain_tlast_gen_0_1.v" \
"../../../bd/Transmit_Chain/ip/Transmit_Chain_conj_0_1/sim/Transmit_Chain_conj_0_1.v" \
"../../../bd/Transmit_Chain/sim/Transmit_Chain.v" \

vlog -work xil_defaultlib \
"glbl.v"

