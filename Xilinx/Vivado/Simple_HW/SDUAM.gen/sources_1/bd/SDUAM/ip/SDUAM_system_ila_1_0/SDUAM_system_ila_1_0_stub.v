// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.2 (lin64) Build 3367213 Tue Oct 19 02:47:39 MDT 2021
// Date        : Mon Nov 15 10:13:01 2021
// Host        : saad-17Z90N-R-AAC8U1 running 64-bit Linux Mint 20.1
// Command     : write_verilog -force -mode synth_stub
//               /home/saad/Xilinx/UnderwaterModem/Updated_MyXilinx/3Vivado_HW/SDUAM.gen/sources_1/bd/SDUAM/ip/SDUAM_system_ila_1_0/SDUAM_system_ila_1_0_stub.v
// Design      : SDUAM_system_ila_1_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z010clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "bd_485c,Vivado 2021.2" *)
module SDUAM_system_ila_1_0(clk, SLOT_0_AXIS_tdata, SLOT_0_AXIS_tstrb, 
  SLOT_0_AXIS_tlast, SLOT_0_AXIS_tvalid, SLOT_0_AXIS_tready, resetn)
/* synthesis syn_black_box black_box_pad_pin="clk,SLOT_0_AXIS_tdata[31:0],SLOT_0_AXIS_tstrb[3:0],SLOT_0_AXIS_tlast,SLOT_0_AXIS_tvalid,SLOT_0_AXIS_tready,resetn" */;
  input clk;
  input [31:0]SLOT_0_AXIS_tdata;
  input [3:0]SLOT_0_AXIS_tstrb;
  input SLOT_0_AXIS_tlast;
  input SLOT_0_AXIS_tvalid;
  input SLOT_0_AXIS_tready;
  input resetn;
endmodule
