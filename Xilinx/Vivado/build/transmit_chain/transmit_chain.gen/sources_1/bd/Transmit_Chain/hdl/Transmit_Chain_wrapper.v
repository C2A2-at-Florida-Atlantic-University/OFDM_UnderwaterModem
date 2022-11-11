//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
//Date        : Sun Nov  6 11:11:40 2022
//Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
//Command     : generate_target Transmit_Chain_wrapper.bd
//Design      : Transmit_Chain_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module Transmit_Chain_wrapper
   (M_AXIS_tdata,
    M_AXIS_tlast,
    M_AXIS_tvalid,
    S_AXIS_tdata,
    S_AXIS_tlast,
    S_AXIS_tready,
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
    config_start_0,
    continuous_0,
    cp_len_0,
    dl_en_0,
    fs_cycles_0,
    i_negative_freq_0,
    inv_0,
    nfft_0,
    nfft_scaled_0,
    playback_en,
    symbols_0);
  output [31:0]M_AXIS_tdata;
  output M_AXIS_tlast;
  output M_AXIS_tvalid;
  input [31:0]S_AXIS_tdata;
  input S_AXIS_tlast;
  output S_AXIS_tready;
  input S_AXIS_tvalid;
  input [11:0]S_BRAM_AXI_araddr;
  input [1:0]S_BRAM_AXI_arburst;
  input [3:0]S_BRAM_AXI_arcache;
  input [7:0]S_BRAM_AXI_arlen;
  input S_BRAM_AXI_arlock;
  input [2:0]S_BRAM_AXI_arprot;
  output S_BRAM_AXI_arready;
  input [2:0]S_BRAM_AXI_arsize;
  input S_BRAM_AXI_arvalid;
  input [11:0]S_BRAM_AXI_awaddr;
  input [1:0]S_BRAM_AXI_awburst;
  input [3:0]S_BRAM_AXI_awcache;
  input [7:0]S_BRAM_AXI_awlen;
  input S_BRAM_AXI_awlock;
  input [2:0]S_BRAM_AXI_awprot;
  output S_BRAM_AXI_awready;
  input [2:0]S_BRAM_AXI_awsize;
  input S_BRAM_AXI_awvalid;
  input S_BRAM_AXI_bready;
  output [1:0]S_BRAM_AXI_bresp;
  output S_BRAM_AXI_bvalid;
  output [31:0]S_BRAM_AXI_rdata;
  output S_BRAM_AXI_rlast;
  input S_BRAM_AXI_rready;
  output [1:0]S_BRAM_AXI_rresp;
  output S_BRAM_AXI_rvalid;
  input [31:0]S_BRAM_AXI_wdata;
  input S_BRAM_AXI_wlast;
  output S_BRAM_AXI_wready;
  input [3:0]S_BRAM_AXI_wstrb;
  input S_BRAM_AXI_wvalid;
  input aclk;
  input aresetn;
  input config_start_0;
  input continuous_0;
  input [15:0]cp_len_0;
  input dl_en_0;
  input [26:0]fs_cycles_0;
  input i_negative_freq_0;
  input inv_0;
  input [4:0]nfft_0;
  input [11:0]nfft_scaled_0;
  input playback_en;
  input [3:0]symbols_0;

  wire [31:0]M_AXIS_tdata;
  wire M_AXIS_tlast;
  wire M_AXIS_tvalid;
  wire [31:0]S_AXIS_tdata;
  wire S_AXIS_tlast;
  wire S_AXIS_tready;
  wire S_AXIS_tvalid;
  wire [11:0]S_BRAM_AXI_araddr;
  wire [1:0]S_BRAM_AXI_arburst;
  wire [3:0]S_BRAM_AXI_arcache;
  wire [7:0]S_BRAM_AXI_arlen;
  wire S_BRAM_AXI_arlock;
  wire [2:0]S_BRAM_AXI_arprot;
  wire S_BRAM_AXI_arready;
  wire [2:0]S_BRAM_AXI_arsize;
  wire S_BRAM_AXI_arvalid;
  wire [11:0]S_BRAM_AXI_awaddr;
  wire [1:0]S_BRAM_AXI_awburst;
  wire [3:0]S_BRAM_AXI_awcache;
  wire [7:0]S_BRAM_AXI_awlen;
  wire S_BRAM_AXI_awlock;
  wire [2:0]S_BRAM_AXI_awprot;
  wire S_BRAM_AXI_awready;
  wire [2:0]S_BRAM_AXI_awsize;
  wire S_BRAM_AXI_awvalid;
  wire S_BRAM_AXI_bready;
  wire [1:0]S_BRAM_AXI_bresp;
  wire S_BRAM_AXI_bvalid;
  wire [31:0]S_BRAM_AXI_rdata;
  wire S_BRAM_AXI_rlast;
  wire S_BRAM_AXI_rready;
  wire [1:0]S_BRAM_AXI_rresp;
  wire S_BRAM_AXI_rvalid;
  wire [31:0]S_BRAM_AXI_wdata;
  wire S_BRAM_AXI_wlast;
  wire S_BRAM_AXI_wready;
  wire [3:0]S_BRAM_AXI_wstrb;
  wire S_BRAM_AXI_wvalid;
  wire aclk;
  wire aresetn;
  wire config_start_0;
  wire continuous_0;
  wire [15:0]cp_len_0;
  wire dl_en_0;
  wire [26:0]fs_cycles_0;
  wire i_negative_freq_0;
  wire inv_0;
  wire [4:0]nfft_0;
  wire [11:0]nfft_scaled_0;
  wire playback_en;
  wire [3:0]symbols_0;

  Transmit_Chain Transmit_Chain_i
       (.M_AXIS_tdata(M_AXIS_tdata),
        .M_AXIS_tlast(M_AXIS_tlast),
        .M_AXIS_tvalid(M_AXIS_tvalid),
        .S_AXIS_tdata(S_AXIS_tdata),
        .S_AXIS_tlast(S_AXIS_tlast),
        .S_AXIS_tready(S_AXIS_tready),
        .S_AXIS_tvalid(S_AXIS_tvalid),
        .S_BRAM_AXI_araddr(S_BRAM_AXI_araddr),
        .S_BRAM_AXI_arburst(S_BRAM_AXI_arburst),
        .S_BRAM_AXI_arcache(S_BRAM_AXI_arcache),
        .S_BRAM_AXI_arlen(S_BRAM_AXI_arlen),
        .S_BRAM_AXI_arlock(S_BRAM_AXI_arlock),
        .S_BRAM_AXI_arprot(S_BRAM_AXI_arprot),
        .S_BRAM_AXI_arready(S_BRAM_AXI_arready),
        .S_BRAM_AXI_arsize(S_BRAM_AXI_arsize),
        .S_BRAM_AXI_arvalid(S_BRAM_AXI_arvalid),
        .S_BRAM_AXI_awaddr(S_BRAM_AXI_awaddr),
        .S_BRAM_AXI_awburst(S_BRAM_AXI_awburst),
        .S_BRAM_AXI_awcache(S_BRAM_AXI_awcache),
        .S_BRAM_AXI_awlen(S_BRAM_AXI_awlen),
        .S_BRAM_AXI_awlock(S_BRAM_AXI_awlock),
        .S_BRAM_AXI_awprot(S_BRAM_AXI_awprot),
        .S_BRAM_AXI_awready(S_BRAM_AXI_awready),
        .S_BRAM_AXI_awsize(S_BRAM_AXI_awsize),
        .S_BRAM_AXI_awvalid(S_BRAM_AXI_awvalid),
        .S_BRAM_AXI_bready(S_BRAM_AXI_bready),
        .S_BRAM_AXI_bresp(S_BRAM_AXI_bresp),
        .S_BRAM_AXI_bvalid(S_BRAM_AXI_bvalid),
        .S_BRAM_AXI_rdata(S_BRAM_AXI_rdata),
        .S_BRAM_AXI_rlast(S_BRAM_AXI_rlast),
        .S_BRAM_AXI_rready(S_BRAM_AXI_rready),
        .S_BRAM_AXI_rresp(S_BRAM_AXI_rresp),
        .S_BRAM_AXI_rvalid(S_BRAM_AXI_rvalid),
        .S_BRAM_AXI_wdata(S_BRAM_AXI_wdata),
        .S_BRAM_AXI_wlast(S_BRAM_AXI_wlast),
        .S_BRAM_AXI_wready(S_BRAM_AXI_wready),
        .S_BRAM_AXI_wstrb(S_BRAM_AXI_wstrb),
        .S_BRAM_AXI_wvalid(S_BRAM_AXI_wvalid),
        .aclk(aclk),
        .aresetn(aresetn),
        .config_start_0(config_start_0),
        .continuous_0(continuous_0),
        .cp_len_0(cp_len_0),
        .dl_en_0(dl_en_0),
        .fs_cycles_0(fs_cycles_0),
        .i_negative_freq_0(i_negative_freq_0),
        .inv_0(inv_0),
        .nfft_0(nfft_0),
        .nfft_scaled_0(nfft_scaled_0),
        .playback_en(playback_en),
        .symbols_0(symbols_0));
endmodule
