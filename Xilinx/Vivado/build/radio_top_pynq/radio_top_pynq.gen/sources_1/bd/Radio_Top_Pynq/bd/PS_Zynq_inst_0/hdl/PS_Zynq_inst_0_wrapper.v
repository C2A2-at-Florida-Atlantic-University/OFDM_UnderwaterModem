//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
//Date        : Tue Feb 28 17:49:07 2023
//Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
//Command     : generate_target PS_Zynq_inst_0_wrapper.bd
//Design      : PS_Zynq_inst_0_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module PS_Zynq_inst_0_wrapper
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    M_AXI_BRAM_araddr,
    M_AXI_BRAM_arburst,
    M_AXI_BRAM_arcache,
    M_AXI_BRAM_arlen,
    M_AXI_BRAM_arlock,
    M_AXI_BRAM_arprot,
    M_AXI_BRAM_arready,
    M_AXI_BRAM_arsize,
    M_AXI_BRAM_arvalid,
    M_AXI_BRAM_awaddr,
    M_AXI_BRAM_awburst,
    M_AXI_BRAM_awcache,
    M_AXI_BRAM_awlen,
    M_AXI_BRAM_awlock,
    M_AXI_BRAM_awprot,
    M_AXI_BRAM_awready,
    M_AXI_BRAM_awsize,
    M_AXI_BRAM_awvalid,
    M_AXI_BRAM_bready,
    M_AXI_BRAM_bresp,
    M_AXI_BRAM_bvalid,
    M_AXI_BRAM_rdata,
    M_AXI_BRAM_rlast,
    M_AXI_BRAM_rready,
    M_AXI_BRAM_rresp,
    M_AXI_BRAM_rvalid,
    M_AXI_BRAM_wdata,
    M_AXI_BRAM_wlast,
    M_AXI_BRAM_wready,
    M_AXI_BRAM_wstrb,
    M_AXI_BRAM_wvalid,
    M_AXI_DMA_araddr,
    M_AXI_DMA_arready,
    M_AXI_DMA_arvalid,
    M_AXI_DMA_awaddr,
    M_AXI_DMA_awready,
    M_AXI_DMA_awvalid,
    M_AXI_DMA_bready,
    M_AXI_DMA_bresp,
    M_AXI_DMA_bvalid,
    M_AXI_DMA_rdata,
    M_AXI_DMA_rready,
    M_AXI_DMA_rresp,
    M_AXI_DMA_rvalid,
    M_AXI_DMA_wdata,
    M_AXI_DMA_wready,
    M_AXI_DMA_wvalid,
    S00_AXI_DMA_araddr,
    S00_AXI_DMA_arburst,
    S00_AXI_DMA_arcache,
    S00_AXI_DMA_arlen,
    S00_AXI_DMA_arprot,
    S00_AXI_DMA_arready,
    S00_AXI_DMA_arsize,
    S00_AXI_DMA_arvalid,
    S00_AXI_DMA_rdata,
    S00_AXI_DMA_rlast,
    S00_AXI_DMA_rready,
    S00_AXI_DMA_rresp,
    S00_AXI_DMA_rvalid,
    S01_AXI_DMA_awaddr,
    S01_AXI_DMA_awburst,
    S01_AXI_DMA_awcache,
    S01_AXI_DMA_awlen,
    S01_AXI_DMA_awprot,
    S01_AXI_DMA_awready,
    S01_AXI_DMA_awsize,
    S01_AXI_DMA_awvalid,
    S01_AXI_DMA_bready,
    S01_AXI_DMA_bresp,
    S01_AXI_DMA_bvalid,
    S01_AXI_DMA_wdata,
    S01_AXI_DMA_wlast,
    S01_AXI_DMA_wready,
    S01_AXI_DMA_wstrb,
    S01_AXI_DMA_wvalid,
    aclk_100M,
    aclk_10M,
    aclk_40M,
    aresetn_100M,
    aresetn_10M,
    aresetn_40M,
    continuous,
    cp_len,
    dl_en,
    fft_config_en,
    fft_inv,
    fs_cycles,
    negative_freq,
    nfft,
    nfft_scaled,
    playback_en,
    symbols);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  output [13:0]M_AXI_BRAM_araddr;
  output [1:0]M_AXI_BRAM_arburst;
  output [3:0]M_AXI_BRAM_arcache;
  output [7:0]M_AXI_BRAM_arlen;
  output [0:0]M_AXI_BRAM_arlock;
  output [2:0]M_AXI_BRAM_arprot;
  input M_AXI_BRAM_arready;
  output [2:0]M_AXI_BRAM_arsize;
  output M_AXI_BRAM_arvalid;
  output [13:0]M_AXI_BRAM_awaddr;
  output [1:0]M_AXI_BRAM_awburst;
  output [3:0]M_AXI_BRAM_awcache;
  output [7:0]M_AXI_BRAM_awlen;
  output [0:0]M_AXI_BRAM_awlock;
  output [2:0]M_AXI_BRAM_awprot;
  input M_AXI_BRAM_awready;
  output [2:0]M_AXI_BRAM_awsize;
  output M_AXI_BRAM_awvalid;
  output M_AXI_BRAM_bready;
  input [1:0]M_AXI_BRAM_bresp;
  input M_AXI_BRAM_bvalid;
  input [31:0]M_AXI_BRAM_rdata;
  input M_AXI_BRAM_rlast;
  output M_AXI_BRAM_rready;
  input [1:0]M_AXI_BRAM_rresp;
  input M_AXI_BRAM_rvalid;
  output [31:0]M_AXI_BRAM_wdata;
  output M_AXI_BRAM_wlast;
  input M_AXI_BRAM_wready;
  output [3:0]M_AXI_BRAM_wstrb;
  output M_AXI_BRAM_wvalid;
  output [9:0]M_AXI_DMA_araddr;
  input M_AXI_DMA_arready;
  output M_AXI_DMA_arvalid;
  output [9:0]M_AXI_DMA_awaddr;
  input M_AXI_DMA_awready;
  output M_AXI_DMA_awvalid;
  output M_AXI_DMA_bready;
  input [1:0]M_AXI_DMA_bresp;
  input M_AXI_DMA_bvalid;
  input [31:0]M_AXI_DMA_rdata;
  output M_AXI_DMA_rready;
  input [1:0]M_AXI_DMA_rresp;
  input M_AXI_DMA_rvalid;
  output [31:0]M_AXI_DMA_wdata;
  input M_AXI_DMA_wready;
  output M_AXI_DMA_wvalid;
  input [31:0]S00_AXI_DMA_araddr;
  input [1:0]S00_AXI_DMA_arburst;
  input [3:0]S00_AXI_DMA_arcache;
  input [7:0]S00_AXI_DMA_arlen;
  input [2:0]S00_AXI_DMA_arprot;
  output S00_AXI_DMA_arready;
  input [2:0]S00_AXI_DMA_arsize;
  input S00_AXI_DMA_arvalid;
  output [31:0]S00_AXI_DMA_rdata;
  output S00_AXI_DMA_rlast;
  input S00_AXI_DMA_rready;
  output [1:0]S00_AXI_DMA_rresp;
  output S00_AXI_DMA_rvalid;
  input [31:0]S01_AXI_DMA_awaddr;
  input [1:0]S01_AXI_DMA_awburst;
  input [3:0]S01_AXI_DMA_awcache;
  input [7:0]S01_AXI_DMA_awlen;
  input [2:0]S01_AXI_DMA_awprot;
  output S01_AXI_DMA_awready;
  input [2:0]S01_AXI_DMA_awsize;
  input S01_AXI_DMA_awvalid;
  input S01_AXI_DMA_bready;
  output [1:0]S01_AXI_DMA_bresp;
  output S01_AXI_DMA_bvalid;
  input [31:0]S01_AXI_DMA_wdata;
  input S01_AXI_DMA_wlast;
  output S01_AXI_DMA_wready;
  input [3:0]S01_AXI_DMA_wstrb;
  input S01_AXI_DMA_wvalid;
  output aclk_100M;
  output aclk_10M;
  output aclk_40M;
  output [0:0]aresetn_100M;
  output [0:0]aresetn_10M;
  output [0:0]aresetn_40M;
  output [0:0]continuous;
  output [15:0]cp_len;
  output [0:0]dl_en;
  output [0:0]fft_config_en;
  output [0:0]fft_inv;
  output [26:0]fs_cycles;
  output [0:0]negative_freq;
  output [4:0]nfft;
  output [11:0]nfft_scaled;
  output [0:0]playback_en;
  output [3:0]symbols;

  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [13:0]M_AXI_BRAM_araddr;
  wire [1:0]M_AXI_BRAM_arburst;
  wire [3:0]M_AXI_BRAM_arcache;
  wire [7:0]M_AXI_BRAM_arlen;
  wire [0:0]M_AXI_BRAM_arlock;
  wire [2:0]M_AXI_BRAM_arprot;
  wire M_AXI_BRAM_arready;
  wire [2:0]M_AXI_BRAM_arsize;
  wire M_AXI_BRAM_arvalid;
  wire [13:0]M_AXI_BRAM_awaddr;
  wire [1:0]M_AXI_BRAM_awburst;
  wire [3:0]M_AXI_BRAM_awcache;
  wire [7:0]M_AXI_BRAM_awlen;
  wire [0:0]M_AXI_BRAM_awlock;
  wire [2:0]M_AXI_BRAM_awprot;
  wire M_AXI_BRAM_awready;
  wire [2:0]M_AXI_BRAM_awsize;
  wire M_AXI_BRAM_awvalid;
  wire M_AXI_BRAM_bready;
  wire [1:0]M_AXI_BRAM_bresp;
  wire M_AXI_BRAM_bvalid;
  wire [31:0]M_AXI_BRAM_rdata;
  wire M_AXI_BRAM_rlast;
  wire M_AXI_BRAM_rready;
  wire [1:0]M_AXI_BRAM_rresp;
  wire M_AXI_BRAM_rvalid;
  wire [31:0]M_AXI_BRAM_wdata;
  wire M_AXI_BRAM_wlast;
  wire M_AXI_BRAM_wready;
  wire [3:0]M_AXI_BRAM_wstrb;
  wire M_AXI_BRAM_wvalid;
  wire [9:0]M_AXI_DMA_araddr;
  wire M_AXI_DMA_arready;
  wire M_AXI_DMA_arvalid;
  wire [9:0]M_AXI_DMA_awaddr;
  wire M_AXI_DMA_awready;
  wire M_AXI_DMA_awvalid;
  wire M_AXI_DMA_bready;
  wire [1:0]M_AXI_DMA_bresp;
  wire M_AXI_DMA_bvalid;
  wire [31:0]M_AXI_DMA_rdata;
  wire M_AXI_DMA_rready;
  wire [1:0]M_AXI_DMA_rresp;
  wire M_AXI_DMA_rvalid;
  wire [31:0]M_AXI_DMA_wdata;
  wire M_AXI_DMA_wready;
  wire M_AXI_DMA_wvalid;
  wire [31:0]S00_AXI_DMA_araddr;
  wire [1:0]S00_AXI_DMA_arburst;
  wire [3:0]S00_AXI_DMA_arcache;
  wire [7:0]S00_AXI_DMA_arlen;
  wire [2:0]S00_AXI_DMA_arprot;
  wire S00_AXI_DMA_arready;
  wire [2:0]S00_AXI_DMA_arsize;
  wire S00_AXI_DMA_arvalid;
  wire [31:0]S00_AXI_DMA_rdata;
  wire S00_AXI_DMA_rlast;
  wire S00_AXI_DMA_rready;
  wire [1:0]S00_AXI_DMA_rresp;
  wire S00_AXI_DMA_rvalid;
  wire [31:0]S01_AXI_DMA_awaddr;
  wire [1:0]S01_AXI_DMA_awburst;
  wire [3:0]S01_AXI_DMA_awcache;
  wire [7:0]S01_AXI_DMA_awlen;
  wire [2:0]S01_AXI_DMA_awprot;
  wire S01_AXI_DMA_awready;
  wire [2:0]S01_AXI_DMA_awsize;
  wire S01_AXI_DMA_awvalid;
  wire S01_AXI_DMA_bready;
  wire [1:0]S01_AXI_DMA_bresp;
  wire S01_AXI_DMA_bvalid;
  wire [31:0]S01_AXI_DMA_wdata;
  wire S01_AXI_DMA_wlast;
  wire S01_AXI_DMA_wready;
  wire [3:0]S01_AXI_DMA_wstrb;
  wire S01_AXI_DMA_wvalid;
  wire aclk_100M;
  wire aclk_10M;
  wire aclk_40M;
  wire [0:0]aresetn_100M;
  wire [0:0]aresetn_10M;
  wire [0:0]aresetn_40M;
  wire [0:0]continuous;
  wire [15:0]cp_len;
  wire [0:0]dl_en;
  wire [0:0]fft_config_en;
  wire [0:0]fft_inv;
  wire [26:0]fs_cycles;
  wire [0:0]negative_freq;
  wire [4:0]nfft;
  wire [11:0]nfft_scaled;
  wire [0:0]playback_en;
  wire [3:0]symbols;

  PS_Zynq_inst_0 PS_Zynq_inst_0_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .M_AXI_BRAM_araddr(M_AXI_BRAM_araddr),
        .M_AXI_BRAM_arburst(M_AXI_BRAM_arburst),
        .M_AXI_BRAM_arcache(M_AXI_BRAM_arcache),
        .M_AXI_BRAM_arlen(M_AXI_BRAM_arlen),
        .M_AXI_BRAM_arlock(M_AXI_BRAM_arlock),
        .M_AXI_BRAM_arprot(M_AXI_BRAM_arprot),
        .M_AXI_BRAM_arready(M_AXI_BRAM_arready),
        .M_AXI_BRAM_arsize(M_AXI_BRAM_arsize),
        .M_AXI_BRAM_arvalid(M_AXI_BRAM_arvalid),
        .M_AXI_BRAM_awaddr(M_AXI_BRAM_awaddr),
        .M_AXI_BRAM_awburst(M_AXI_BRAM_awburst),
        .M_AXI_BRAM_awcache(M_AXI_BRAM_awcache),
        .M_AXI_BRAM_awlen(M_AXI_BRAM_awlen),
        .M_AXI_BRAM_awlock(M_AXI_BRAM_awlock),
        .M_AXI_BRAM_awprot(M_AXI_BRAM_awprot),
        .M_AXI_BRAM_awready(M_AXI_BRAM_awready),
        .M_AXI_BRAM_awsize(M_AXI_BRAM_awsize),
        .M_AXI_BRAM_awvalid(M_AXI_BRAM_awvalid),
        .M_AXI_BRAM_bready(M_AXI_BRAM_bready),
        .M_AXI_BRAM_bresp(M_AXI_BRAM_bresp),
        .M_AXI_BRAM_bvalid(M_AXI_BRAM_bvalid),
        .M_AXI_BRAM_rdata(M_AXI_BRAM_rdata),
        .M_AXI_BRAM_rlast(M_AXI_BRAM_rlast),
        .M_AXI_BRAM_rready(M_AXI_BRAM_rready),
        .M_AXI_BRAM_rresp(M_AXI_BRAM_rresp),
        .M_AXI_BRAM_rvalid(M_AXI_BRAM_rvalid),
        .M_AXI_BRAM_wdata(M_AXI_BRAM_wdata),
        .M_AXI_BRAM_wlast(M_AXI_BRAM_wlast),
        .M_AXI_BRAM_wready(M_AXI_BRAM_wready),
        .M_AXI_BRAM_wstrb(M_AXI_BRAM_wstrb),
        .M_AXI_BRAM_wvalid(M_AXI_BRAM_wvalid),
        .M_AXI_DMA_araddr(M_AXI_DMA_araddr),
        .M_AXI_DMA_arready(M_AXI_DMA_arready),
        .M_AXI_DMA_arvalid(M_AXI_DMA_arvalid),
        .M_AXI_DMA_awaddr(M_AXI_DMA_awaddr),
        .M_AXI_DMA_awready(M_AXI_DMA_awready),
        .M_AXI_DMA_awvalid(M_AXI_DMA_awvalid),
        .M_AXI_DMA_bready(M_AXI_DMA_bready),
        .M_AXI_DMA_bresp(M_AXI_DMA_bresp),
        .M_AXI_DMA_bvalid(M_AXI_DMA_bvalid),
        .M_AXI_DMA_rdata(M_AXI_DMA_rdata),
        .M_AXI_DMA_rready(M_AXI_DMA_rready),
        .M_AXI_DMA_rresp(M_AXI_DMA_rresp),
        .M_AXI_DMA_rvalid(M_AXI_DMA_rvalid),
        .M_AXI_DMA_wdata(M_AXI_DMA_wdata),
        .M_AXI_DMA_wready(M_AXI_DMA_wready),
        .M_AXI_DMA_wvalid(M_AXI_DMA_wvalid),
        .S00_AXI_DMA_araddr(S00_AXI_DMA_araddr),
        .S00_AXI_DMA_arburst(S00_AXI_DMA_arburst),
        .S00_AXI_DMA_arcache(S00_AXI_DMA_arcache),
        .S00_AXI_DMA_arlen(S00_AXI_DMA_arlen),
        .S00_AXI_DMA_arprot(S00_AXI_DMA_arprot),
        .S00_AXI_DMA_arready(S00_AXI_DMA_arready),
        .S00_AXI_DMA_arsize(S00_AXI_DMA_arsize),
        .S00_AXI_DMA_arvalid(S00_AXI_DMA_arvalid),
        .S00_AXI_DMA_rdata(S00_AXI_DMA_rdata),
        .S00_AXI_DMA_rlast(S00_AXI_DMA_rlast),
        .S00_AXI_DMA_rready(S00_AXI_DMA_rready),
        .S00_AXI_DMA_rresp(S00_AXI_DMA_rresp),
        .S00_AXI_DMA_rvalid(S00_AXI_DMA_rvalid),
        .S01_AXI_DMA_awaddr(S01_AXI_DMA_awaddr),
        .S01_AXI_DMA_awburst(S01_AXI_DMA_awburst),
        .S01_AXI_DMA_awcache(S01_AXI_DMA_awcache),
        .S01_AXI_DMA_awlen(S01_AXI_DMA_awlen),
        .S01_AXI_DMA_awprot(S01_AXI_DMA_awprot),
        .S01_AXI_DMA_awready(S01_AXI_DMA_awready),
        .S01_AXI_DMA_awsize(S01_AXI_DMA_awsize),
        .S01_AXI_DMA_awvalid(S01_AXI_DMA_awvalid),
        .S01_AXI_DMA_bready(S01_AXI_DMA_bready),
        .S01_AXI_DMA_bresp(S01_AXI_DMA_bresp),
        .S01_AXI_DMA_bvalid(S01_AXI_DMA_bvalid),
        .S01_AXI_DMA_wdata(S01_AXI_DMA_wdata),
        .S01_AXI_DMA_wlast(S01_AXI_DMA_wlast),
        .S01_AXI_DMA_wready(S01_AXI_DMA_wready),
        .S01_AXI_DMA_wstrb(S01_AXI_DMA_wstrb),
        .S01_AXI_DMA_wvalid(S01_AXI_DMA_wvalid),
        .aclk_100M(aclk_100M),
        .aclk_10M(aclk_10M),
        .aclk_40M(aclk_40M),
        .aresetn_100M(aresetn_100M),
        .aresetn_10M(aresetn_10M),
        .aresetn_40M(aresetn_40M),
        .continuous(continuous),
        .cp_len(cp_len),
        .dl_en(dl_en),
        .fft_config_en(fft_config_en),
        .fft_inv(fft_inv),
        .fs_cycles(fs_cycles),
        .negative_freq(negative_freq),
        .nfft(nfft),
        .nfft_scaled(nfft_scaled),
        .playback_en(playback_en),
        .symbols(symbols));
endmodule
