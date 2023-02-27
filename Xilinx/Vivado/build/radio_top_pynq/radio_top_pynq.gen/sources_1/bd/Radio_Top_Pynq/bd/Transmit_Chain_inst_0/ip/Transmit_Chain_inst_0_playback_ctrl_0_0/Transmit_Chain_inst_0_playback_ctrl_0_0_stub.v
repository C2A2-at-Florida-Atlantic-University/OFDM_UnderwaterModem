// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Sun Feb 26 20:54:37 2023
// Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top Transmit_Chain_inst_0_playback_ctrl_0_0 -prefix
//               Transmit_Chain_inst_0_playback_ctrl_0_0_ Transmit_Chain_inst_0_playback_ctrl_0_0_stub.v
// Design      : Transmit_Chain_inst_0_playback_ctrl_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "playback_ctrl,Vivado 2022.1" *)
module Transmit_Chain_inst_0_playback_ctrl_0_0(axis_aclk, axis_aresetn, playback_en, 
  fs_cycles, symbols, nfft_scaled, continuous, BRAM_PORT_addr, BRAM_PORT_clk, BRAM_PORT_din, 
  BRAM_PORT_dout, BRAM_PORT_en, BRAM_PORT_rst, BRAM_PORT_we, M_AXIS_tdata, M_AXIS_tvalid, 
  M_AXIS_tlast, M_AXIS_tready)
/* synthesis syn_black_box black_box_pad_pin="axis_aclk,axis_aresetn,playback_en,fs_cycles[26:0],symbols[3:0],nfft_scaled[11:0],continuous,BRAM_PORT_addr[31:0],BRAM_PORT_clk,BRAM_PORT_din[31:0],BRAM_PORT_dout[31:0],BRAM_PORT_en,BRAM_PORT_rst,BRAM_PORT_we[0:0],M_AXIS_tdata[31:0],M_AXIS_tvalid,M_AXIS_tlast,M_AXIS_tready" */;
  input axis_aclk;
  input axis_aresetn;
  input playback_en;
  input [26:0]fs_cycles;
  input [3:0]symbols;
  input [11:0]nfft_scaled;
  input continuous;
  output [31:0]BRAM_PORT_addr;
  output BRAM_PORT_clk;
  output [31:0]BRAM_PORT_din;
  input [31:0]BRAM_PORT_dout;
  output BRAM_PORT_en;
  output BRAM_PORT_rst;
  output [0:0]BRAM_PORT_we;
  output [31:0]M_AXIS_tdata;
  output M_AXIS_tvalid;
  output M_AXIS_tlast;
  input M_AXIS_tready;
endmodule
