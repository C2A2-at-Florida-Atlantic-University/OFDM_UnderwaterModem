// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Sun Feb 26 20:55:29 2023
// Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top PS_Zynq_inst_0_delimiter_1_0 -prefix
//               PS_Zynq_inst_0_delimiter_1_0_ PS_Zynq_inst_0_delimiter_1_0_stub.v
// Design      : PS_Zynq_inst_0_delimiter_1_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "delimiter,Vivado 2022.1" *)
module PS_Zynq_inst_0_delimiter_1_0(IN0, OUT0, OUT1, OUT2)
/* synthesis syn_black_box black_box_pad_pin="IN0[31:0],OUT0[15:0],OUT1[11:0],OUT2[3:0]" */;
  input [31:0]IN0;
  output [15:0]OUT0;
  output [11:0]OUT1;
  output [3:0]OUT2;
endmodule
