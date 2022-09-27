//Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Command: generate_target bd_485c_wrapper.bd
//Design : bd_485c_wrapper
//Purpose: IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module bd_485c_wrapper
   (SLOT_0_AXIS_tdata,
    SLOT_0_AXIS_tlast,
    SLOT_0_AXIS_tready,
    SLOT_0_AXIS_tstrb,
    SLOT_0_AXIS_tvalid,
    clk,
    resetn);
  input [31:0]SLOT_0_AXIS_tdata;
  input SLOT_0_AXIS_tlast;
  input SLOT_0_AXIS_tready;
  input [3:0]SLOT_0_AXIS_tstrb;
  input SLOT_0_AXIS_tvalid;
  input clk;
  input resetn;

  wire [31:0]SLOT_0_AXIS_tdata;
  wire SLOT_0_AXIS_tlast;
  wire SLOT_0_AXIS_tready;
  wire [3:0]SLOT_0_AXIS_tstrb;
  wire SLOT_0_AXIS_tvalid;
  wire clk;
  wire resetn;

  bd_485c bd_485c_i
       (.SLOT_0_AXIS_tdata(SLOT_0_AXIS_tdata),
        .SLOT_0_AXIS_tlast(SLOT_0_AXIS_tlast),
        .SLOT_0_AXIS_tready(SLOT_0_AXIS_tready),
        .SLOT_0_AXIS_tstrb(SLOT_0_AXIS_tstrb),
        .SLOT_0_AXIS_tvalid(SLOT_0_AXIS_tvalid),
        .clk(clk),
        .resetn(resetn));
endmodule
