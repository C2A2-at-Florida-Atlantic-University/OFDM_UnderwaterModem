-makelib xcelium_lib/xilinx_vip -sv \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/xilinx_vip/hdl/axi_vip_if.sv" \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/xilinx_vip/hdl/clk_vip_if.sv" \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/xilinx_vip/hdl/rst_vip_if.sv" \
-endlib
-makelib xcelium_lib/xpm -sv \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "C:/Xilinx_2022.1/Vivado/2022.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/axi_infrastructure_v1_1_0 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_vip_v1_1_12 -sv \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/1033/hdl/axi_vip_v1_1_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/processing_system7_vip_v1_0_14 -sv \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/5765/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/SDUAM/ip/SDUAM_processing_system7_0_0/sim/SDUAM_processing_system7_0_0.v" \
-endlib
-makelib xcelium_lib/lib_cdc_v1_0_2 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/ef1e/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/proc_sys_reset_v5_0_13 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/8842/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/SDUAM/ip/SDUAM_rst_ps7_0_100M_0/sim/SDUAM_rst_ps7_0_100M_0.vhd" \
-endlib
-makelib xcelium_lib/axi_lite_ipif_v3_0_4 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/66ea/hdl/axi_lite_ipif_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/interrupt_control_v3_1_4 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/a040/hdl/interrupt_control_v3_1_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/axi_gpio_v2_0_28 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/3ed9/hdl/axi_gpio_v2_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/SDUAM/ip/SDUAM_axi_gpio_0_0/sim/SDUAM_axi_gpio_0_0.vhd" \
-endlib
-makelib xcelium_lib/generic_baseblocks_v2_1_0 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/b752/hdl/generic_baseblocks_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_7 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/83df/simulation/fifo_generator_vlog_beh.v" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_7 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/83df/hdl/fifo_generator_v13_2_rfs.vhd" \
-endlib
-makelib xcelium_lib/fifo_generator_v13_2_7 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/83df/hdl/fifo_generator_v13_2_rfs.v" \
-endlib
-makelib xcelium_lib/axi_data_fifo_v2_1_25 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/5390/hdl/axi_data_fifo_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_register_slice_v2_1_26 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/0a3f/hdl/axi_register_slice_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/axi_protocol_converter_v2_1_26 \
  "../../../../SDUAM.gen/sources_1/bd/SDUAM/ipshared/90c8/hdl/axi_protocol_converter_v2_1_vl_rfs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/SDUAM/ip/SDUAM_auto_pc_0/sim/SDUAM_auto_pc_0.v" \
  "../../../bd/SDUAM/sim/SDUAM.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

