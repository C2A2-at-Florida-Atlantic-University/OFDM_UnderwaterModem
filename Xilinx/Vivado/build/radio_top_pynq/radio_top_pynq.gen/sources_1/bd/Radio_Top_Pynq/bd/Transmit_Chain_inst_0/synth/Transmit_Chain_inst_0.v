//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
//Date        : Tue Feb 28 17:49:07 2023
//Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
//Command     : generate_target Transmit_Chain_inst_0.bd
//Design      : Transmit_Chain_inst_0
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "Transmit_Chain_inst_0,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=Transmit_Chain_inst_0,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=11,numReposBlks=11,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=6,numPkgbdBlks=0,bdsource=c_/Projects/FAU-Modem/OFDM/Xilinx/Vivado/build/radio_top_pynq/radio_top_pynq.srcs/sources_1/bd/Transmit_Chain/Transmit_Chain.bd,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "Transmit_Chain_inst_0.hwdef" *) 
module Transmit_Chain_inst_0
   (M_AXIS_tdata,
    M_AXIS_tlast,
    M_AXIS_tvalid,
    S_AXIS_tdata,
    S_AXIS_tkeep,
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
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 1, HAS_TREADY 0, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) output [31:0]M_AXIS_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TLAST" *) output M_AXIS_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *) output M_AXIS_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, FREQ_HZ 100000000, HAS_TKEEP 1, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [31:0]S_AXIS_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TKEEP" *) input [3:0]S_AXIS_tkeep;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TLAST" *) input S_AXIS_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TREADY" *) output S_AXIS_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *) input S_AXIS_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_BRAM_AXI, ADDR_WIDTH 14, ARUSER_WIDTH 0, AWUSER_WIDTH 0, BUSER_WIDTH 0, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, DATA_WIDTH 32, FREQ_HZ 100000000, HAS_BRESP 1, HAS_BURST 1, HAS_CACHE 1, HAS_LOCK 1, HAS_PROT 1, HAS_QOS 1, HAS_REGION 0, HAS_RRESP 1, HAS_WSTRB 1, ID_WIDTH 0, INSERT_VIP 0, MAX_BURST_LENGTH 16, NUM_READ_OUTSTANDING 8, NUM_READ_THREADS 1, NUM_WRITE_OUTSTANDING 8, NUM_WRITE_THREADS 1, PHASE 0.0, PROTOCOL AXI4, READ_WRITE_MODE READ_WRITE, RUSER_BITS_PER_BYTE 0, RUSER_WIDTH 0, SUPPORTS_NARROW_BURST 0, WUSER_BITS_PER_BYTE 0, WUSER_WIDTH 0" *) input [13:0]S_BRAM_AXI_araddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARBURST" *) input [1:0]S_BRAM_AXI_arburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARCACHE" *) input [3:0]S_BRAM_AXI_arcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARLEN" *) input [7:0]S_BRAM_AXI_arlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARLOCK" *) input [0:0]S_BRAM_AXI_arlock;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARPROT" *) input [2:0]S_BRAM_AXI_arprot;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARREADY" *) output S_BRAM_AXI_arready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARSIZE" *) input [2:0]S_BRAM_AXI_arsize;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI ARVALID" *) input S_BRAM_AXI_arvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWADDR" *) input [13:0]S_BRAM_AXI_awaddr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWBURST" *) input [1:0]S_BRAM_AXI_awburst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWCACHE" *) input [3:0]S_BRAM_AXI_awcache;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWLEN" *) input [7:0]S_BRAM_AXI_awlen;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_BRAM_AXI AWLOCK" *) input [0:0]S_BRAM_AXI_awlock;
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, ASSOCIATED_BUSIF S_AXIS:M_AXIS:S_BRAM_AXI, ASSOCIATED_RESET aresetn, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input aresetn;
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

  (* DEBUG = "true" *) wire [31:0]S_AXIS_1_TDATA;
  (* DEBUG = "true" *) wire [3:0]S_AXIS_1_TKEEP;
  (* DEBUG = "true" *) wire S_AXIS_1_TLAST;
  (* DEBUG = "true" *) wire S_AXIS_1_TREADY;
  (* DEBUG = "true" *) wire S_AXIS_1_TVALID;
  wire [13:0]S_BRAM_AXI_1_ARADDR;
  wire [1:0]S_BRAM_AXI_1_ARBURST;
  wire [3:0]S_BRAM_AXI_1_ARCACHE;
  wire [7:0]S_BRAM_AXI_1_ARLEN;
  wire [0:0]S_BRAM_AXI_1_ARLOCK;
  wire [2:0]S_BRAM_AXI_1_ARPROT;
  wire S_BRAM_AXI_1_ARREADY;
  wire [2:0]S_BRAM_AXI_1_ARSIZE;
  wire S_BRAM_AXI_1_ARVALID;
  wire [13:0]S_BRAM_AXI_1_AWADDR;
  wire [1:0]S_BRAM_AXI_1_AWBURST;
  wire [3:0]S_BRAM_AXI_1_AWCACHE;
  wire [7:0]S_BRAM_AXI_1_AWLEN;
  wire [0:0]S_BRAM_AXI_1_AWLOCK;
  wire [2:0]S_BRAM_AXI_1_AWPROT;
  wire S_BRAM_AXI_1_AWREADY;
  wire [2:0]S_BRAM_AXI_1_AWSIZE;
  wire S_BRAM_AXI_1_AWVALID;
  wire S_BRAM_AXI_1_BREADY;
  wire [1:0]S_BRAM_AXI_1_BRESP;
  wire S_BRAM_AXI_1_BVALID;
  wire [31:0]S_BRAM_AXI_1_RDATA;
  wire S_BRAM_AXI_1_RLAST;
  wire S_BRAM_AXI_1_RREADY;
  wire [1:0]S_BRAM_AXI_1_RRESP;
  wire S_BRAM_AXI_1_RVALID;
  wire [31:0]S_BRAM_AXI_1_WDATA;
  wire S_BRAM_AXI_1_WLAST;
  wire S_BRAM_AXI_1_WREADY;
  wire [3:0]S_BRAM_AXI_1_WSTRB;
  wire S_BRAM_AXI_1_WVALID;
  wire [13:0]axi_bram_ctrl_0_BRAM_PORTA_ADDR;
  wire axi_bram_ctrl_0_BRAM_PORTA_CLK;
  wire [31:0]axi_bram_ctrl_0_BRAM_PORTA_DIN;
  wire [31:0]axi_bram_ctrl_0_BRAM_PORTA_DOUT;
  wire axi_bram_ctrl_0_BRAM_PORTA_EN;
  wire [3:0]axi_bram_ctrl_0_BRAM_PORTA_WE;
  wire [31:0]axis_data_fifo_0_M_AXIS_TDATA;
  wire axis_data_fifo_0_M_AXIS_TLAST;
  wire axis_data_fifo_0_M_AXIS_TREADY;
  wire axis_data_fifo_0_M_AXIS_TVALID;
  wire [31:0]axis_data_fifo_1_M_AXIS_TDATA;
  wire axis_data_fifo_1_M_AXIS_TLAST;
  wire axis_data_fifo_1_M_AXIS_TREADY;
  wire axis_data_fifo_1_M_AXIS_TVALID;
  wire config_start_0_1;
  wire [31:0]conj_0_m_axis_TDATA;
  wire conj_0_m_axis_TLAST;
  wire conj_0_m_axis_TREADY;
  wire conj_0_m_axis_TVALID;
  wire continuous_0_1;
  wire [15:0]cp_len_0_1;
  wire dl_en_0_1;
  wire [39:0]fft_config_0_m_axis_TDATA;
  wire fft_config_0_m_axis_TVALID;
  wire [26:0]fs_cycles_0_1;
  wire i_negative_freq_0_1;
  wire i_select_0_1;
  wire [31:0]ifft_M_AXIS_DATA_TDATA;
  wire ifft_M_AXIS_DATA_TLAST;
  wire ifft_M_AXIS_DATA_TREADY;
  wire ifft_M_AXIS_DATA_TVALID;
  wire inv_0_1;
  wire [31:0]mux_0_m_axis_TDATA;
  wire mux_0_m_axis_TLAST;
  wire mux_0_m_axis_TREADY;
  wire mux_0_m_axis_TVALID;
  wire [4:0]nfft_0_1;
  wire [11:0]nfft_scaled_0_1;
  wire [31:0]playback_ctrl_0_BRAM_PORT_ADDR;
  wire playback_ctrl_0_BRAM_PORT_CLK;
  wire [31:0]playback_ctrl_0_BRAM_PORT_DIN;
  wire [31:0]playback_ctrl_0_BRAM_PORT_DOUT;
  wire playback_ctrl_0_BRAM_PORT_EN;
  wire [0:0]playback_ctrl_0_BRAM_PORT_WE;
  wire [31:0]playback_ctrl_0_M_AXIS_TDATA;
  wire playback_ctrl_0_M_AXIS_TLAST;
  wire playback_ctrl_0_M_AXIS_TREADY;
  wire playback_ctrl_0_M_AXIS_TVALID;
  wire [31:0]real_time_sampler_0_m_axis_TDATA;
  wire real_time_sampler_0_m_axis_TLAST;
  wire real_time_sampler_0_m_axis_TVALID;
  wire s_axi_aclk_0_1;
  wire s_axi_aresetn_0_1;
  wire [3:0]symbols_0_1;
  wire [31:0]tlast_gen_0_m_axis_TDATA;
  wire tlast_gen_0_m_axis_TLAST;
  wire tlast_gen_0_m_axis_TREADY;
  wire tlast_gen_0_m_axis_TVALID;

  assign M_AXIS_tdata[31:0] = real_time_sampler_0_m_axis_TDATA;
  assign M_AXIS_tlast = real_time_sampler_0_m_axis_TLAST;
  assign M_AXIS_tvalid = real_time_sampler_0_m_axis_TVALID;
  assign S_AXIS_1_TDATA = S_AXIS_tdata[31:0];
  assign S_AXIS_1_TKEEP = S_AXIS_tkeep[3:0];
  assign S_AXIS_1_TLAST = S_AXIS_tlast;
  assign S_AXIS_1_TVALID = S_AXIS_tvalid;
  assign S_AXIS_tready = S_AXIS_1_TREADY;
  assign S_BRAM_AXI_1_ARADDR = S_BRAM_AXI_araddr[13:0];
  assign S_BRAM_AXI_1_ARBURST = S_BRAM_AXI_arburst[1:0];
  assign S_BRAM_AXI_1_ARCACHE = S_BRAM_AXI_arcache[3:0];
  assign S_BRAM_AXI_1_ARLEN = S_BRAM_AXI_arlen[7:0];
  assign S_BRAM_AXI_1_ARLOCK = S_BRAM_AXI_arlock[0];
  assign S_BRAM_AXI_1_ARPROT = S_BRAM_AXI_arprot[2:0];
  assign S_BRAM_AXI_1_ARSIZE = S_BRAM_AXI_arsize[2:0];
  assign S_BRAM_AXI_1_ARVALID = S_BRAM_AXI_arvalid;
  assign S_BRAM_AXI_1_AWADDR = S_BRAM_AXI_awaddr[13:0];
  assign S_BRAM_AXI_1_AWBURST = S_BRAM_AXI_awburst[1:0];
  assign S_BRAM_AXI_1_AWCACHE = S_BRAM_AXI_awcache[3:0];
  assign S_BRAM_AXI_1_AWLEN = S_BRAM_AXI_awlen[7:0];
  assign S_BRAM_AXI_1_AWLOCK = S_BRAM_AXI_awlock[0];
  assign S_BRAM_AXI_1_AWPROT = S_BRAM_AXI_awprot[2:0];
  assign S_BRAM_AXI_1_AWSIZE = S_BRAM_AXI_awsize[2:0];
  assign S_BRAM_AXI_1_AWVALID = S_BRAM_AXI_awvalid;
  assign S_BRAM_AXI_1_BREADY = S_BRAM_AXI_bready;
  assign S_BRAM_AXI_1_RREADY = S_BRAM_AXI_rready;
  assign S_BRAM_AXI_1_WDATA = S_BRAM_AXI_wdata[31:0];
  assign S_BRAM_AXI_1_WLAST = S_BRAM_AXI_wlast;
  assign S_BRAM_AXI_1_WSTRB = S_BRAM_AXI_wstrb[3:0];
  assign S_BRAM_AXI_1_WVALID = S_BRAM_AXI_wvalid;
  assign S_BRAM_AXI_arready = S_BRAM_AXI_1_ARREADY;
  assign S_BRAM_AXI_awready = S_BRAM_AXI_1_AWREADY;
  assign S_BRAM_AXI_bresp[1:0] = S_BRAM_AXI_1_BRESP;
  assign S_BRAM_AXI_bvalid = S_BRAM_AXI_1_BVALID;
  assign S_BRAM_AXI_rdata[31:0] = S_BRAM_AXI_1_RDATA;
  assign S_BRAM_AXI_rlast = S_BRAM_AXI_1_RLAST;
  assign S_BRAM_AXI_rresp[1:0] = S_BRAM_AXI_1_RRESP;
  assign S_BRAM_AXI_rvalid = S_BRAM_AXI_1_RVALID;
  assign S_BRAM_AXI_wready = S_BRAM_AXI_1_WREADY;
  assign config_start_0_1 = config_start_0;
  assign continuous_0_1 = continuous_0;
  assign cp_len_0_1 = cp_len_0[15:0];
  assign dl_en_0_1 = dl_en_0;
  assign fs_cycles_0_1 = fs_cycles_0[26:0];
  assign i_negative_freq_0_1 = i_negative_freq_0;
  assign i_select_0_1 = playback_en;
  assign inv_0_1 = inv_0;
  assign nfft_0_1 = nfft_0[4:0];
  assign nfft_scaled_0_1 = nfft_scaled_0[11:0];
  assign s_axi_aclk_0_1 = aclk;
  assign s_axi_aresetn_0_1 = aresetn;
  assign symbols_0_1 = symbols_0[3:0];
  Transmit_Chain_inst_0_axi_bram_ctrl_0_0 axi_bram_ctrl_0
       (.bram_addr_a(axi_bram_ctrl_0_BRAM_PORTA_ADDR),
        .bram_clk_a(axi_bram_ctrl_0_BRAM_PORTA_CLK),
        .bram_en_a(axi_bram_ctrl_0_BRAM_PORTA_EN),
        .bram_rddata_a(axi_bram_ctrl_0_BRAM_PORTA_DOUT),
        .bram_we_a(axi_bram_ctrl_0_BRAM_PORTA_WE),
        .bram_wrdata_a(axi_bram_ctrl_0_BRAM_PORTA_DIN),
        .s_axi_aclk(s_axi_aclk_0_1),
        .s_axi_araddr(S_BRAM_AXI_1_ARADDR),
        .s_axi_arburst(S_BRAM_AXI_1_ARBURST),
        .s_axi_arcache(S_BRAM_AXI_1_ARCACHE),
        .s_axi_aresetn(s_axi_aresetn_0_1),
        .s_axi_arlen(S_BRAM_AXI_1_ARLEN),
        .s_axi_arlock(S_BRAM_AXI_1_ARLOCK),
        .s_axi_arprot(S_BRAM_AXI_1_ARPROT),
        .s_axi_arready(S_BRAM_AXI_1_ARREADY),
        .s_axi_arsize(S_BRAM_AXI_1_ARSIZE),
        .s_axi_arvalid(S_BRAM_AXI_1_ARVALID),
        .s_axi_awaddr(S_BRAM_AXI_1_AWADDR),
        .s_axi_awburst(S_BRAM_AXI_1_AWBURST),
        .s_axi_awcache(S_BRAM_AXI_1_AWCACHE),
        .s_axi_awlen(S_BRAM_AXI_1_AWLEN),
        .s_axi_awlock(S_BRAM_AXI_1_AWLOCK),
        .s_axi_awprot(S_BRAM_AXI_1_AWPROT),
        .s_axi_awready(S_BRAM_AXI_1_AWREADY),
        .s_axi_awsize(S_BRAM_AXI_1_AWSIZE),
        .s_axi_awvalid(S_BRAM_AXI_1_AWVALID),
        .s_axi_bready(S_BRAM_AXI_1_BREADY),
        .s_axi_bresp(S_BRAM_AXI_1_BRESP),
        .s_axi_bvalid(S_BRAM_AXI_1_BVALID),
        .s_axi_rdata(S_BRAM_AXI_1_RDATA),
        .s_axi_rlast(S_BRAM_AXI_1_RLAST),
        .s_axi_rready(S_BRAM_AXI_1_RREADY),
        .s_axi_rresp(S_BRAM_AXI_1_RRESP),
        .s_axi_rvalid(S_BRAM_AXI_1_RVALID),
        .s_axi_wdata(S_BRAM_AXI_1_WDATA),
        .s_axi_wlast(S_BRAM_AXI_1_WLAST),
        .s_axi_wready(S_BRAM_AXI_1_WREADY),
        .s_axi_wstrb(S_BRAM_AXI_1_WSTRB),
        .s_axi_wvalid(S_BRAM_AXI_1_WVALID));
  Transmit_Chain_inst_0_axis_data_fifo_0_0 axis_data_fifo_0
       (.m_axis_tdata(axis_data_fifo_0_M_AXIS_TDATA),
        .m_axis_tlast(axis_data_fifo_0_M_AXIS_TLAST),
        .m_axis_tready(axis_data_fifo_0_M_AXIS_TREADY),
        .m_axis_tvalid(axis_data_fifo_0_M_AXIS_TVALID),
        .s_axis_aclk(s_axi_aclk_0_1),
        .s_axis_aresetn(s_axi_aresetn_0_1),
        .s_axis_tdata(conj_0_m_axis_TDATA),
        .s_axis_tlast(conj_0_m_axis_TLAST),
        .s_axis_tready(conj_0_m_axis_TREADY),
        .s_axis_tvalid(conj_0_m_axis_TVALID));
  Transmit_Chain_inst_0_axis_data_fifo_1_0 axis_data_fifo_1
       (.m_axis_tdata(axis_data_fifo_1_M_AXIS_TDATA),
        .m_axis_tlast(axis_data_fifo_1_M_AXIS_TLAST),
        .m_axis_tready(axis_data_fifo_1_M_AXIS_TREADY),
        .m_axis_tvalid(axis_data_fifo_1_M_AXIS_TVALID),
        .s_axis_aclk(s_axi_aclk_0_1),
        .s_axis_aresetn(s_axi_aresetn_0_1),
        .s_axis_tdata(S_AXIS_1_TDATA),
        .s_axis_tkeep(S_AXIS_1_TKEEP),
        .s_axis_tlast(S_AXIS_1_TLAST),
        .s_axis_tready(S_AXIS_1_TREADY),
        .s_axis_tvalid(S_AXIS_1_TVALID));
  Transmit_Chain_inst_0_conj_0_0 conj_0
       (.axis_aclk(s_axi_aclk_0_1),
        .axis_aresetn(s_axi_aresetn_0_1),
        .i_negative_freq(i_negative_freq_0_1),
        .m_axis_tdata(conj_0_m_axis_TDATA),
        .m_axis_tlast(conj_0_m_axis_TLAST),
        .m_axis_tready(conj_0_m_axis_TREADY),
        .m_axis_tvalid(conj_0_m_axis_TVALID),
        .s_axis_tdata(ifft_M_AXIS_DATA_TDATA),
        .s_axis_tlast(ifft_M_AXIS_DATA_TLAST),
        .s_axis_tready(ifft_M_AXIS_DATA_TREADY),
        .s_axis_tvalid(ifft_M_AXIS_DATA_TVALID));
  Transmit_Chain_inst_0_fft_config_0_0 fft_config_0
       (.axis_aclk(s_axi_aclk_0_1),
        .axis_aresetn(s_axi_aresetn_0_1),
        .config_start(config_start_0_1),
        .cp_len(cp_len_0_1),
        .inv(inv_0_1),
        .m_axis_tdata(fft_config_0_m_axis_TDATA),
        .m_axis_tvalid(fft_config_0_m_axis_TVALID),
        .nfft(nfft_0_1));
  Transmit_Chain_inst_0_ifft_0 ifft
       (.aclk(s_axi_aclk_0_1),
        .aresetn(s_axi_aresetn_0_1),
        .m_axis_data_tdata(ifft_M_AXIS_DATA_TDATA),
        .m_axis_data_tlast(ifft_M_AXIS_DATA_TLAST),
        .m_axis_data_tready(ifft_M_AXIS_DATA_TREADY),
        .m_axis_data_tvalid(ifft_M_AXIS_DATA_TVALID),
        .s_axis_config_tdata(fft_config_0_m_axis_TDATA),
        .s_axis_config_tvalid(fft_config_0_m_axis_TVALID),
        .s_axis_data_tdata(mux_0_m_axis_TDATA),
        .s_axis_data_tlast(mux_0_m_axis_TLAST),
        .s_axis_data_tready(mux_0_m_axis_TREADY),
        .s_axis_data_tvalid(mux_0_m_axis_TVALID));
  Transmit_Chain_inst_0_mux_0_0 mux_0
       (.axis_aclk(s_axi_aclk_0_1),
        .axis_aresetn(s_axi_aresetn_0_1),
        .i_select(i_select_0_1),
        .m_axis_tdata(mux_0_m_axis_TDATA),
        .m_axis_tlast(mux_0_m_axis_TLAST),
        .m_axis_tready(mux_0_m_axis_TREADY),
        .m_axis_tvalid(mux_0_m_axis_TVALID),
        .s_axis0_tdata(tlast_gen_0_m_axis_TDATA),
        .s_axis0_tlast(tlast_gen_0_m_axis_TLAST),
        .s_axis0_tready(tlast_gen_0_m_axis_TREADY),
        .s_axis0_tvalid(tlast_gen_0_m_axis_TVALID),
        .s_axis1_tdata(playback_ctrl_0_M_AXIS_TDATA),
        .s_axis1_tlast(playback_ctrl_0_M_AXIS_TLAST),
        .s_axis1_tready(playback_ctrl_0_M_AXIS_TREADY),
        .s_axis1_tvalid(playback_ctrl_0_M_AXIS_TVALID));
  Transmit_Chain_inst_0_playback_ctrl_0_0 playback_ctrl_0
       (.BRAM_PORT_addr(playback_ctrl_0_BRAM_PORT_ADDR),
        .BRAM_PORT_clk(playback_ctrl_0_BRAM_PORT_CLK),
        .BRAM_PORT_din(playback_ctrl_0_BRAM_PORT_DIN),
        .BRAM_PORT_dout(playback_ctrl_0_BRAM_PORT_DOUT),
        .BRAM_PORT_en(playback_ctrl_0_BRAM_PORT_EN),
        .BRAM_PORT_we(playback_ctrl_0_BRAM_PORT_WE),
        .M_AXIS_tdata(playback_ctrl_0_M_AXIS_TDATA),
        .M_AXIS_tlast(playback_ctrl_0_M_AXIS_TLAST),
        .M_AXIS_tready(playback_ctrl_0_M_AXIS_TREADY),
        .M_AXIS_tvalid(playback_ctrl_0_M_AXIS_TVALID),
        .axis_aclk(s_axi_aclk_0_1),
        .axis_aresetn(s_axi_aresetn_0_1),
        .continuous(continuous_0_1),
        .fs_cycles(fs_cycles_0_1),
        .nfft_scaled(nfft_scaled_0_1),
        .playback_en(i_select_0_1),
        .symbols(symbols_0_1));
  Transmit_Chain_inst_0_playback_mem_0 playback_mem
       (.addra(axi_bram_ctrl_0_BRAM_PORTA_ADDR[11:0]),
        .addrb(playback_ctrl_0_BRAM_PORT_ADDR[11:0]),
        .clka(axi_bram_ctrl_0_BRAM_PORTA_CLK),
        .clkb(playback_ctrl_0_BRAM_PORT_CLK),
        .dina(axi_bram_ctrl_0_BRAM_PORTA_DIN),
        .dinb(playback_ctrl_0_BRAM_PORT_DIN),
        .douta(axi_bram_ctrl_0_BRAM_PORTA_DOUT),
        .doutb(playback_ctrl_0_BRAM_PORT_DOUT),
        .ena(axi_bram_ctrl_0_BRAM_PORTA_EN),
        .enb(playback_ctrl_0_BRAM_PORT_EN),
        .wea(axi_bram_ctrl_0_BRAM_PORTA_WE[0]),
        .web(playback_ctrl_0_BRAM_PORT_WE));
  Transmit_Chain_inst_0_real_time_sampler_0_0 real_time_sampler_0
       (.axis_aclk(s_axi_aclk_0_1),
        .axis_aresetn(s_axi_aresetn_0_1),
        .dl_en(dl_en_0_1),
        .fs_cycles(fs_cycles_0_1),
        .m_axis_tdata(real_time_sampler_0_m_axis_TDATA),
        .m_axis_tlast(real_time_sampler_0_m_axis_TLAST),
        .m_axis_tvalid(real_time_sampler_0_m_axis_TVALID),
        .s_axis_tdata(axis_data_fifo_0_M_AXIS_TDATA),
        .s_axis_tlast(axis_data_fifo_0_M_AXIS_TLAST),
        .s_axis_tready(axis_data_fifo_0_M_AXIS_TREADY),
        .s_axis_tvalid(axis_data_fifo_0_M_AXIS_TVALID));
  Transmit_Chain_inst_0_tlast_gen_0_0 tlast_gen_0
       (.axis_aclk(s_axi_aclk_0_1),
        .axis_aresetn(s_axi_aresetn_0_1),
        .dl_en(dl_en_0_1),
        .i_start(dl_en_0_1),
        .m_axis_tdata(tlast_gen_0_m_axis_TDATA),
        .m_axis_tlast(tlast_gen_0_m_axis_TLAST),
        .m_axis_tready(tlast_gen_0_m_axis_TREADY),
        .m_axis_tvalid(tlast_gen_0_m_axis_TVALID),
        .nfft_scaled(nfft_scaled_0_1),
        .s_axis_tdata(axis_data_fifo_1_M_AXIS_TDATA),
        .s_axis_tlast(axis_data_fifo_1_M_AXIS_TLAST),
        .s_axis_tready(axis_data_fifo_1_M_AXIS_TREADY),
        .s_axis_tvalid(axis_data_fifo_1_M_AXIS_TVALID),
        .symbols(symbols_0_1));
endmodule
