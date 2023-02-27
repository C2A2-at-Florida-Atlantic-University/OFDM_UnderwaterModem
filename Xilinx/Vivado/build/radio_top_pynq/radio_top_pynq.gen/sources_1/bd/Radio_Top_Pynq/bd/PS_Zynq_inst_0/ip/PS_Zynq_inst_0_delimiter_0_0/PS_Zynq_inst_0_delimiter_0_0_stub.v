// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Sun Feb 26 20:55:30 2023
// Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Projects/FAU-Modem/OFDM/Xilinx/Vivado/build/radio_top_pynq/radio_top_pynq.gen/sources_1/bd/Radio_Top_Pynq/bd/PS_Zynq_inst_0/ip/PS_Zynq_inst_0_delimiter_0_0/PS_Zynq_inst_0_delimiter_0_0_stub.v
// Design      : PS_Zynq_inst_0_delimiter_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "delimiter,Vivado 2022.1" *)
module PS_Zynq_inst_0_delimiter_0_0(IN0, OUT0, OUT1)
/* synthesis syn_black_box black_box_pad_pin="IN0[31:0],OUT0[26:0],OUT1[4:0]" */;
  input [31:0]IN0;
  output [26:0]OUT0;
  output [4:0]OUT1;
endmodule
