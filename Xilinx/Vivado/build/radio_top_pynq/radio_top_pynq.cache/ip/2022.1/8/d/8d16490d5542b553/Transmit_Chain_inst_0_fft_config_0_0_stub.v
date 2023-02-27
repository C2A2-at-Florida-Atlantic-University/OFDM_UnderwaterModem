// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Sun Feb 26 20:54:35 2023
// Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ Transmit_Chain_inst_0_fft_config_0_0_stub.v
// Design      : Transmit_Chain_inst_0_fft_config_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "fft_config,Vivado 2022.1" *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix(axis_aclk, axis_aresetn, config_start, nfft, 
  cp_len, inv, m_axis_tdata, m_axis_tvalid)
/* synthesis syn_black_box black_box_pad_pin="axis_aclk,axis_aresetn,config_start,nfft[4:0],cp_len[15:0],inv,m_axis_tdata[39:0],m_axis_tvalid" */;
  input axis_aclk;
  input axis_aresetn;
  input config_start;
  input [4:0]nfft;
  input [15:0]cp_len;
  input inv;
  output [39:0]m_axis_tdata;
  output m_axis_tvalid;
endmodule
