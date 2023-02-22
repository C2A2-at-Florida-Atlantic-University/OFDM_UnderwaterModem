-makelib xcelium_lib/xpm -sv \
  "C:/Xilinx/Vivado/2022.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx/Vivado/2022.1/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "C:/Xilinx/Vivado/2022.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx/Vivado/2022.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/axi_bram_ctrl_v4_1_6 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/3c31/hdl/axi_bram_ctrl_v4_1_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/Transmit_Chain/ip/Transmit_Chain_axi_bram_ctrl_0_1/sim/Transmit_Chain_axi_bram_ctrl_0_1.vhd" \
-endlib
-makelib xcelium_lib/axis_infrastructure_v1_1_0 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/8713/hdl/axis_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axis_data_fifo_v2_0_8 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/0bd2/hdl/axis_data_fifo_v2_0_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/Transmit_Chain/ip/Transmit_Chain_axis_data_fifo_0_1/sim/Transmit_Chain_axis_data_fifo_0_1.v" \
  "../../../bd/Transmit_Chain/ip/Transmit_Chain_axis_data_fifo_1_1/sim/Transmit_Chain_axis_data_fifo_1_1.v" \
  "../../../bd/Transmit_Chain/ip/Transmit_Chain_fft_config_0_1/sim/Transmit_Chain_fft_config_0_1.v" \
-endlib
-makelib xcelium_lib/xbip_utils_v3_0_10 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/364f/hdl/xbip_utils_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_utils_v2_0_6 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/1971/hdl/axi_utils_v2_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/c_reg_fd_v12_0_6 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/edec/hdl/c_reg_fd_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_dsp48_wrapper_v3_0_4 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/cdbf/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_pipe_v3_0_6 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/7468/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_dsp48_addsub_v3_0_6 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/910d/hdl/xbip_dsp48_addsub_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_addsub_v3_0_6 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/cfdd/hdl/xbip_addsub_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/c_addsub_v12_0_14 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/ebb8/hdl/c_addsub_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/c_mux_bit_v12_0_6 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/ecb4/hdl/c_mux_bit_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/c_shift_ram_v12_0_14 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/2598/hdl/c_shift_ram_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xbip_bram18k_v3_0_6 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/d367/hdl/xbip_bram18k_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/mult_gen_v12_0_18 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/ab19/hdl/mult_gen_v12_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/cmpy_v6_0_21 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/b7d0/hdl/cmpy_v6_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/floating_point_v7_0_20 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/1b8e/hdl/floating_point_v7_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xfft_v9_1_8 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/102e/hdl/xfft_v9_1_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/Transmit_Chain/ip/Transmit_Chain_ifft_1/sim/Transmit_Chain_ifft_1.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/Transmit_Chain/ip/Transmit_Chain_mux_0_1/sim/Transmit_Chain_mux_0_1.v" \
  "../../../bd/Transmit_Chain/ip/Transmit_Chain_playback_ctrl_0_1/sim/Transmit_Chain_playback_ctrl_0_1.v" \
-endlib
-makelib xcelium_lib/blk_mem_gen_v8_4_5 \
  "../../../../transmit_chain.gen/sources_1/bd/Transmit_Chain/ipshared/25a8/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/Transmit_Chain/ip/Transmit_Chain_playback_mem_1/sim/Transmit_Chain_playback_mem_1.v" \
  "../../../bd/Transmit_Chain/ip/Transmit_Chain_real_time_sampler_0_0/sim/Transmit_Chain_real_time_sampler_0_0.v" \
  "../../../bd/Transmit_Chain/ip/Transmit_Chain_tlast_gen_0_1/sim/Transmit_Chain_tlast_gen_0_1.v" \
  "../../../bd/Transmit_Chain/ip/Transmit_Chain_conj_0_1/sim/Transmit_Chain_conj_0_1.v" \
  "../../../bd/Transmit_Chain/sim/Transmit_Chain.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

