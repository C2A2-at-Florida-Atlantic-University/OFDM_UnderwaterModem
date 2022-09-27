//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
//Date        : Mon Sep 26 22:17:46 2022
//Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
//Command     : generate_target Transmit_Chain.bd
//Design      : Transmit_Chain
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "Transmit_Chain,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=Transmit_Chain,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=5,numReposBlks=5,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=2,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "Transmit_Chain.hwdef" *) 
module Transmit_Chain
   (M_AXIS_tdata,
    M_AXIS_tlast,
    M_AXIS_tready,
    M_AXIS_tvalid,
    S_AXIS_tdata,
    S_AXIS_tid,
    S_AXIS_tlast,
    S_AXIS_tready,
    S_AXIS_tuser,
    S_AXIS_tvalid,
    S_BRAM_AXI_araddr,
    S_BRAM_AXI_arburst,
    S_BRAM_AXI_arcache,
    S_BRAM_AXI_arlen,
    S_BRAM_AXI_arlock,
    S_BRAM_AXI_arprot,
    S_BRAM_AXI_arready,
    S_BRAM_AXI_arsize,
    S_BRAM_AXI_arvalid,
    S_BRAM_AXI_awaddr,
    S_BRAM_AXI_awburst,
    S_BRAM_AXI_awcache,
    S_BRAM_AXI_awlen,
    S_BRAM_AXI_awlock,
    S_BRAM_AXI_awprot,
    S_BRAM_AXI_awready,
    S_BRAM_AXI_awsize,
    S_BRAM_AXI_awvalid,
    S_BRAM_AXI_bready,
    S_BRAM_AXI_bresp,
    S_BRAM_AXI_bvalid,
    S_BRAM_AXI_rdata,
    S_BRAM_AXI_rlast,
    S_BRAM_AXI_rready,
    S_BRAM_AXI_rresp,
    S_BRAM_AXI_rvalid,
    S_BRAM_AXI_wdata,
    S_BRAM_AXI_wlast,
    S_BRAM_AXI_wready,
    S_BRAM_AXI_wstrb,
    S_BRAM_AXI_wvalid,
    aclk,
    aresetn,
    playback_en);
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS, CLK_DOMAIN Transmit_Chain_aclk, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 32768} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value chan} size {attribs {resolve_type generated dependency chan_size format long minimum {} maximum {}} value 1} stride {attribs {resolve_type generated dependency chan_stride format long minimum {} maximum {}} value 32} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 32768} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_xn_re {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value xn_re} enabled {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 32752} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} size {attribs {resolve_type generated dependency frame_size format long minimum {} maximum {}} value 1024} stride {attribs {resolve_type generated dependency frame_stride format long minimum {} maximum {}} value 32} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency xn_width format long minimum {} maximum {}} value 16} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency xn_fractwidth format long minimum {} maximum {}} value 15} signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}}}} field_xn_im {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value xn_im} enabled {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 32752} bitoffset {attribs {resolve_type generated dependency xn_im_offset format long minimum {} maximum {}} value 16} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} size {attribs {resolve_type generated dependency frame_size format long minimum {} maximum {}} value 1024} stride {attribs {resolve_type generated dependency frame_stride format long minimum {} maximum {}} value 32} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency xn_width format long minimum {} maximum {}} value 16} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {fixed {fractwidth {attribs {resolve_type generated dependency xn_fractwidth format long minimum {} maximum {}} value 15} signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value true}}}}}}}}}}}} TDATA_WIDTH 32 TUSER {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_xk_index {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value xk_index} enabled {attribs {resolve_type generated dependency xk_index_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency xk_index_width format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}} field_blk_exp {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value blk_exp} enabled {attribs {resolve_type generated dependency blk_exp_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 5} bitoffset {attribs {resolve_type generated dependency blk_exp_offset format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} size {attribs {resolve_type generated dependency chan_size format long minimum {} maximum {}} value 1} stride {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 8} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 5} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}}}} field_ovflo {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value ovflo} enabled {attribs {resolve_type generated dependency ovflo_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type generated dependency ovflo_offset format long minimum {} maximum {}} value 0} array_type {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} size {attribs {resolve_type generated dependency chan_size format long minimum {} maximum {}} value 1} stride {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 1} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} integer {signed {attribs {resolve_type immediate dependency {} format bool minimum {} maximum {}} value false}}}}}}}}} TUSER_WIDTH 0}, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) output [31:0]M_AXIS_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TLAST" *) output M_AXIS_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TREADY" *) input M_AXIS_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *) output M_AXIS_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS, CLK_DOMAIN Transmit_Chain_aclk, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 8, TUSER_WIDTH 8" *) input [31:0]S_AXIS_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TID" *) input [7:0]S_AXIS_tid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TLAST" *) input S_AXIS_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TREADY" *) output S_AXIS_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TUSER" *) input [7:0]S_AXIS_tuser;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *) input S_AXIS_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_BRAM_AXI, ADDR_WIDTH 15, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN Transmit_Chain_aclk, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 0, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 256, NUM_READ_OUTSTANDING 2, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 2, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 1, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [11:0]S_BRAM_AXI_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARBURST" *) input [1:0]S_BRAM_AXI_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARCACHE" *) input [3:0]S_BRAM_AXI_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARLEN" *) input [7:0]S_BRAM_AXI_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARLOCK" *) input S_BRAM_AXI_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARPROT" *) input [2:0]S_BRAM_AXI_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARREADY" *) output S_BRAM_AXI_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARSIZE" *) input [2:0]S_BRAM_AXI_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARVALID" *) input S_BRAM_AXI_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWADDR" *) input [11:0]S_BRAM_AXI_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWBURST" *) input [1:0]S_BRAM_AXI_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWCACHE" *) input [3:0]S_BRAM_AXI_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWLEN" *) input [7:0]S_BRAM_AXI_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWLOCK" *) input S_BRAM_AXI_awlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWPROT" *) input [2:0]S_BRAM_AXI_awprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWREADY" *) output S_BRAM_AXI_awready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWSIZE" *) input [2:0]S_BRAM_AXI_awsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWVALID" *) input S_BRAM_AXI_awvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI BREADY" *) input S_BRAM_AXI_bready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI BRESP" *) output [1:0]S_BRAM_AXI_bresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI BVALID" *) output S_BRAM_AXI_bvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI RDATA" *) output [31:0]S_BRAM_AXI_rdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI RLAST" *) output S_BRAM_AXI_rlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI RREADY" *) input S_BRAM_AXI_rready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI RRESP" *) output [1:0]S_BRAM_AXI_rresp;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI RVALID" *) output S_BRAM_AXI_rvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI WDATA" *) input [31:0]S_BRAM_AXI_wdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI WLAST" *) input S_BRAM_AXI_wlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI WREADY" *) output S_BRAM_AXI_wready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI WSTRB" *) input [3:0]S_BRAM_AXI_wstrb;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI WVALID" *) input S_BRAM_AXI_wvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, ASSOCIATED_BUSIF M_AXIS:S_AXIS:S_BRAM_AXI, ASSOCIATED_RESET aresetn, CLK_DOMAIN Transmit_Chain_aclk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input aresetn;
  input playback_en;

  wire [11:0]S_AXI_0_1_ARADDR;
  wire [1:0]S_AXI_0_1_ARBURST;
  wire [3:0]S_AXI_0_1_ARCACHE;
  wire [7:0]S_AXI_0_1_ARLEN;
  wire S_AXI_0_1_ARLOCK;
  wire [2:0]S_AXI_0_1_ARPROT;
  wire S_AXI_0_1_ARREADY;
  wire [2:0]S_AXI_0_1_ARSIZE;
  wire S_AXI_0_1_ARVALID;
  wire [11:0]S_AXI_0_1_AWADDR;
  wire [1:0]S_AXI_0_1_AWBURST;
  wire [3:0]S_AXI_0_1_AWCACHE;
  wire [7:0]S_AXI_0_1_AWLEN;
  wire S_AXI_0_1_AWLOCK;
  wire [2:0]S_AXI_0_1_AWPROT;
  wire S_AXI_0_1_AWREADY;
  wire [2:0]S_AXI_0_1_AWSIZE;
  wire S_AXI_0_1_AWVALID;
  wire S_AXI_0_1_BREADY;
  wire [1:0]S_AXI_0_1_BRESP;
  wire S_AXI_0_1_BVALID;
  wire [31:0]S_AXI_0_1_RDATA;
  wire S_AXI_0_1_RLAST;
  wire S_AXI_0_1_RREADY;
  wire [1:0]S_AXI_0_1_RRESP;
  wire S_AXI_0_1_RVALID;
  wire [31:0]S_AXI_0_1_WDATA;
  wire S_AXI_0_1_WLAST;
  wire S_AXI_0_1_WREADY;
  wire [3:0]S_AXI_0_1_WSTRB;
  wire S_AXI_0_1_WVALID;
  wire [11:0]axi_bram_ctrl_0_BRAM_PORTA_ADDR;
  wire axi_bram_ctrl_0_BRAM_PORTA_CLK;
  wire [31:0]axi_bram_ctrl_0_BRAM_PORTA_DIN;
  wire [31:0]axi_bram_ctrl_0_BRAM_PORTA_DOUT;
  wire axi_bram_ctrl_0_BRAM_PORTA_EN;
  wire axi_bram_ctrl_0_BRAM_PORTA_RST;
  wire [3:0]axi_bram_ctrl_0_BRAM_PORTA_WE;
  wire i_select_0_1;
  wire [31:0]mux_0_m_axis_TDATA;
  wire mux_0_m_axis_TLAST;
  wire mux_0_m_axis_TVALID;
  wire [31:0]playback_ctrl_0_BRAM_PORT_ADDR;
  wire playback_ctrl_0_BRAM_PORT_CLK;
  wire [31:0]playback_ctrl_0_BRAM_PORT_DIN;
  wire [31:0]playback_ctrl_0_BRAM_PORT_DOUT;
  wire playback_ctrl_0_BRAM_PORT_EN;
  wire playback_ctrl_0_BRAM_PORT_RST;
  wire playback_ctrl_0_BRAM_PORT_WE;
  wire [31:0]playback_ctrl_0_M_AXIS_TDATA;
  wire playback_ctrl_0_M_AXIS_TLAST;
  wire playback_ctrl_0_M_AXIS_TVALID;
  wire s_axi_aclk_0_1;
  wire s_axi_aresetn_0_1;
  wire [31:0]s_axis0_0_1_TDATA;
  wire [7:0]s_axis0_0_1_TID;
  wire s_axis0_0_1_TLAST;
  wire s_axis0_0_1_TREADY;
  wire [7:0]s_axis0_0_1_TUSER;
  wire s_axis0_0_1_TVALID;
  wire [31:0]xfft_0_M_AXIS_DATA_TDATA;
  wire xfft_0_M_AXIS_DATA_TLAST;
  wire xfft_0_M_AXIS_DATA_TREADY;
  wire xfft_0_M_AXIS_DATA_TVALID;

  assign M_AXIS_tdata[31:0] = xfft_0_M_AXIS_DATA_TDATA;
  assign M_AXIS_tlast = xfft_0_M_AXIS_DATA_TLAST;
  assign M_AXIS_tvalid = xfft_0_M_AXIS_DATA_TVALID;
  assign S_AXIS_tready = s_axis0_0_1_TREADY;
  assign S_AXI_0_1_ARADDR = S_BRAM_AXI_araddr[11:0];
  assign S_AXI_0_1_ARBURST = S_BRAM_AXI_arburst[1:0];
  assign S_AXI_0_1_ARCACHE = S_BRAM_AXI_arcache[3:0];
  assign S_AXI_0_1_ARLEN = S_BRAM_AXI_arlen[7:0];
  assign S_AXI_0_1_ARLOCK = S_BRAM_AXI_arlock;
  assign S_AXI_0_1_ARPROT = S_BRAM_AXI_arprot[2:0];
  assign S_AXI_0_1_ARSIZE = S_BRAM_AXI_arsize[2:0];
  assign S_AXI_0_1_ARVALID = S_BRAM_AXI_arvalid;
  assign S_AXI_0_1_AWADDR = S_BRAM_AXI_awaddr[11:0];
  assign S_AXI_0_1_AWBURST = S_BRAM_AXI_awburst[1:0];
  assign S_AXI_0_1_AWCACHE = S_BRAM_AXI_awcache[3:0];
  assign S_AXI_0_1_AWLEN = S_BRAM_AXI_awlen[7:0];
  assign S_AXI_0_1_AWLOCK = S_BRAM_AXI_awlock;
  assign S_AXI_0_1_AWPROT = S_BRAM_AXI_awprot[2:0];
  assign S_AXI_0_1_AWSIZE = S_BRAM_AXI_awsize[2:0];
  assign S_AXI_0_1_AWVALID = S_BRAM_AXI_awvalid;
  assign S_AXI_0_1_BREADY = S_BRAM_AXI_bready;
  assign S_AXI_0_1_RREADY = S_BRAM_AXI_rready;
  assign S_AXI_0_1_WDATA = S_BRAM_AXI_wdata[31:0];
  assign S_AXI_0_1_WLAST = S_BRAM_AXI_wlast;
  assign S_AXI_0_1_WSTRB = S_BRAM_AXI_wstrb[3:0];
  assign S_AXI_0_1_WVALID = S_BRAM_AXI_wvalid;
  assign S_BRAM_AXI_arready = S_AXI_0_1_ARREADY;
  assign S_BRAM_AXI_awready = S_AXI_0_1_AWREADY;
  assign S_BRAM_AXI_bresp[1:0] = S_AXI_0_1_BRESP;
  assign S_BRAM_AXI_bvalid = S_AXI_0_1_BVALID;
  assign S_BRAM_AXI_rdata[31:0] = S_AXI_0_1_RDATA;
  assign S_BRAM_AXI_rlast = S_AXI_0_1_RLAST;
  assign S_BRAM_AXI_rresp[1:0] = S_AXI_0_1_RRESP;
  assign S_BRAM_AXI_rvalid = S_AXI_0_1_RVALID;
  assign S_BRAM_AXI_wready = S_AXI_0_1_WREADY;
  assign i_select_0_1 = playback_en;
  assign s_axi_aclk_0_1 = aclk;
  assign s_axi_aresetn_0_1 = aresetn;
  assign s_axis0_0_1_TDATA = S_AXIS_tdata[31:0];
  assign s_axis0_0_1_TID = S_AXIS_tid[7:0];
  assign s_axis0_0_1_TLAST = S_AXIS_tlast;
  assign s_axis0_0_1_TUSER = S_AXIS_tuser[7:0];
  assign s_axis0_0_1_TVALID = S_AXIS_tvalid;
  assign xfft_0_M_AXIS_DATA_TREADY = M_AXIS_tready;
  Transmit_Chain_axi_bram_ctrl_0_0 axi_bram_ctrl_0
       (.bram_addr_a(axi_bram_ctrl_0_BRAM_PORTA_ADDR),
        .bram_clk_a(axi_bram_ctrl_0_BRAM_PORTA_CLK),
        .bram_en_a(axi_bram_ctrl_0_BRAM_PORTA_EN),
        .bram_rddata_a(axi_bram_ctrl_0_BRAM_PORTA_DOUT),
        .bram_rst_a(axi_bram_ctrl_0_BRAM_PORTA_RST),
        .bram_we_a(axi_bram_ctrl_0_BRAM_PORTA_WE),
        .bram_wrdata_a(axi_bram_ctrl_0_BRAM_PORTA_DIN),
        .s_axi_aclk(s_axi_aclk_0_1),
        .s_axi_araddr(S_AXI_0_1_ARADDR),
        .s_axi_arburst(S_AXI_0_1_ARBURST),
        .s_axi_arcache(S_AXI_0_1_ARCACHE),
        .s_axi_aresetn(s_axi_aresetn_0_1),
        .s_axi_arlen(S_AXI_0_1_ARLEN),
        .s_axi_arlock(S_AXI_0_1_ARLOCK),
        .s_axi_arprot(S_AXI_0_1_ARPROT),
        .s_axi_arready(S_AXI_0_1_ARREADY),
        .s_axi_arsize(S_AXI_0_1_ARSIZE),
        .s_axi_arvalid(S_AXI_0_1_ARVALID),
        .s_axi_awaddr(S_AXI_0_1_AWADDR),
        .s_axi_awburst(S_AXI_0_1_AWBURST),
        .s_axi_awcache(S_AXI_0_1_AWCACHE),
        .s_axi_awlen(S_AXI_0_1_AWLEN),
        .s_axi_awlock(S_AXI_0_1_AWLOCK),
        .s_axi_awprot(S_AXI_0_1_AWPROT),
        .s_axi_awready(S_AXI_0_1_AWREADY),
        .s_axi_awsize(S_AXI_0_1_AWSIZE),
        .s_axi_awvalid(S_AXI_0_1_AWVALID),
        .s_axi_bready(S_AXI_0_1_BREADY),
        .s_axi_bresp(S_AXI_0_1_BRESP),
        .s_axi_bvalid(S_AXI_0_1_BVALID),
        .s_axi_rdata(S_AXI_0_1_RDATA),
        .s_axi_rlast(S_AXI_0_1_RLAST),
        .s_axi_rready(S_AXI_0_1_RREADY),
        .s_axi_rresp(S_AXI_0_1_RRESP),
        .s_axi_rvalid(S_AXI_0_1_RVALID),
        .s_axi_wdata(S_AXI_0_1_WDATA),
        .s_axi_wlast(S_AXI_0_1_WLAST),
        .s_axi_wready(S_AXI_0_1_WREADY),
        .s_axi_wstrb(S_AXI_0_1_WSTRB),
        .s_axi_wvalid(S_AXI_0_1_WVALID));
  Transmit_Chain_ifft_0 ifft
       (.aclk(s_axi_aclk_0_1),
        .aresetn(s_axi_aresetn_0_1),
        .m_axis_data_tdata(xfft_0_M_AXIS_DATA_TDATA),
        .m_axis_data_tlast(xfft_0_M_AXIS_DATA_TLAST),
        .m_axis_data_tready(xfft_0_M_AXIS_DATA_TREADY),
        .m_axis_data_tvalid(xfft_0_M_AXIS_DATA_TVALID),
        .s_axis_config_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_config_tvalid(1'b0),
        .s_axis_data_tdata(mux_0_m_axis_TDATA),
        .s_axis_data_tlast(mux_0_m_axis_TLAST),
        .s_axis_data_tvalid(mux_0_m_axis_TVALID));
  Transmit_Chain_mux_0_0 mux_0
       (.axis_aclk(s_axi_aclk_0_1),
        .axis_aresetn(s_axi_aresetn_0_1),
        .i_select(i_select_0_1),
        .m_axis_tdata(mux_0_m_axis_TDATA),
        .m_axis_tlast(mux_0_m_axis_TLAST),
        .m_axis_tvalid(mux_0_m_axis_TVALID),
        .s_axis0_tdata(s_axis0_0_1_TDATA),
        .s_axis0_tid(s_axis0_0_1_TID),
        .s_axis0_tlast(s_axis0_0_1_TLAST),
        .s_axis0_tready(s_axis0_0_1_TREADY),
        .s_axis0_tuser(s_axis0_0_1_TUSER),
        .s_axis0_tvalid(s_axis0_0_1_TVALID),
        .s_axis1_tdata(playback_ctrl_0_M_AXIS_TDATA),
        .s_axis1_tid({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis1_tlast(playback_ctrl_0_M_AXIS_TLAST),
        .s_axis1_tuser({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis1_tvalid(playback_ctrl_0_M_AXIS_TVALID));
  Transmit_Chain_playback_ctrl_0_0 playback_ctrl_0
       (.BRAM_PORT_addr(playback_ctrl_0_BRAM_PORT_ADDR),
        .BRAM_PORT_clk(playback_ctrl_0_BRAM_PORT_CLK),
        .BRAM_PORT_din(playback_ctrl_0_BRAM_PORT_DIN),
        .BRAM_PORT_dout(playback_ctrl_0_BRAM_PORT_DOUT),
        .BRAM_PORT_en(playback_ctrl_0_BRAM_PORT_EN),
        .BRAM_PORT_rst(playback_ctrl_0_BRAM_PORT_RST),
        .BRAM_PORT_we(playback_ctrl_0_BRAM_PORT_WE),
        .M_AXIS_tdata(playback_ctrl_0_M_AXIS_TDATA),
        .M_AXIS_tlast(playback_ctrl_0_M_AXIS_TLAST),
        .M_AXIS_tvalid(playback_ctrl_0_M_AXIS_TVALID),
        .axis_aclk(s_axi_aclk_0_1),
        .axis_aresetn(s_axi_aresetn_0_1),
        .playback_en(i_select_0_1));
  Transmit_Chain_playback_mem_0 playback_mem
       (.addra({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,axi_bram_ctrl_0_BRAM_PORTA_ADDR}),
        .addrb(playback_ctrl_0_BRAM_PORT_ADDR),
        .clka(axi_bram_ctrl_0_BRAM_PORTA_CLK),
        .clkb(playback_ctrl_0_BRAM_PORT_CLK),
        .dina(axi_bram_ctrl_0_BRAM_PORTA_DIN),
        .dinb(playback_ctrl_0_BRAM_PORT_DIN),
        .douta(axi_bram_ctrl_0_BRAM_PORTA_DOUT),
        .doutb(playback_ctrl_0_BRAM_PORT_DOUT),
        .ena(axi_bram_ctrl_0_BRAM_PORTA_EN),
        .enb(playback_ctrl_0_BRAM_PORT_EN),
        .rsta(axi_bram_ctrl_0_BRAM_PORTA_RST),
        .rstb(playback_ctrl_0_BRAM_PORT_RST),
        .wea(axi_bram_ctrl_0_BRAM_PORTA_WE),
        .web({playback_ctrl_0_BRAM_PORT_WE,playback_ctrl_0_BRAM_PORT_WE,playback_ctrl_0_BRAM_PORT_WE,playback_ctrl_0_BRAM_PORT_WE}));
endmodule
