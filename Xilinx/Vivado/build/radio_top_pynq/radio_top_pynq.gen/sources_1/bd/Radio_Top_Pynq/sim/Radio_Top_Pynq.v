//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
//Date        : Sun Feb 26 21:30:15 2023
//Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
//Command     : generate_target Radio_Top_Pynq.bd
//Design      : Radio_Top_Pynq
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "Radio_Top_Pynq,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=Radio_Top_Pynq,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=36,numReposBlks=29,numNonXlnxBlks=3,numHierBlks=7,maxHierDepth=1,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=6,numPkgbdBlks=2,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "Radio_Top_Pynq.hwdef" *) 
module Radio_Top_Pynq
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
    FIXED_IO_ps_srstb);
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR ADDR" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DDR, AXI_ARBITRATION_SCHEME TDM, BURST_LENGTH 8, CAN_DEBUG false, CAS_LATENCY 11, CAS_WRITE_LATENCY 11, CS_ENABLED true, DATA_MASK_ENABLED true, DATA_WIDTH 8, MEMORY_TYPE COMPONENTS, MEM_ADDR_MAP ROW_COLUMN_BANK, SLOT Single, TIMEPERIOD_PS 1250" *) inout [14:0]DDR_addr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR BA" *) inout [2:0]DDR_ba;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CAS_N" *) inout DDR_cas_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CK_N" *) inout DDR_ck_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CK_P" *) inout DDR_ck_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CKE" *) inout DDR_cke;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR CS_N" *) inout DDR_cs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DM" *) inout [3:0]DDR_dm;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQ" *) inout [31:0]DDR_dq;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQS_N" *) inout [3:0]DDR_dqs_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR DQS_P" *) inout [3:0]DDR_dqs_p;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR ODT" *) inout DDR_odt;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR RAS_N" *) inout DDR_ras_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR RESET_N" *) inout DDR_reset_n;
  (* X_INTERFACE_INFO = "xilinx.com:interface:ddrx:1.0 DDR WE_N" *) inout DDR_we_n;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRN" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME FIXED_IO, CAN_DEBUG false" *) inout FIXED_IO_ddr_vrn;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRP" *) inout FIXED_IO_ddr_vrp;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO MIO" *) inout [53:0]FIXED_IO_mio;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_CLK" *) inout FIXED_IO_ps_clk;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_PORB" *) inout FIXED_IO_ps_porb;
  (* X_INTERFACE_INFO = "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_SRSTB" *) inout FIXED_IO_ps_srstb;

  wire [0:0]ARESETN_1;
  wire [14:0]PS_Zynq_0_DDR_ADDR;
  wire [2:0]PS_Zynq_0_DDR_BA;
  wire PS_Zynq_0_DDR_CAS_N;
  wire PS_Zynq_0_DDR_CKE;
  wire PS_Zynq_0_DDR_CK_N;
  wire PS_Zynq_0_DDR_CK_P;
  wire PS_Zynq_0_DDR_CS_N;
  wire [3:0]PS_Zynq_0_DDR_DM;
  wire [31:0]PS_Zynq_0_DDR_DQ;
  wire [3:0]PS_Zynq_0_DDR_DQS_N;
  wire [3:0]PS_Zynq_0_DDR_DQS_P;
  wire PS_Zynq_0_DDR_ODT;
  wire PS_Zynq_0_DDR_RAS_N;
  wire PS_Zynq_0_DDR_RESET_N;
  wire PS_Zynq_0_DDR_WE_N;
  wire PS_Zynq_0_FIXED_IO_DDR_VRN;
  wire PS_Zynq_0_FIXED_IO_DDR_VRP;
  wire [53:0]PS_Zynq_0_FIXED_IO_MIO;
  wire PS_Zynq_0_FIXED_IO_PS_CLK;
  wire PS_Zynq_0_FIXED_IO_PS_PORB;
  wire PS_Zynq_0_FIXED_IO_PS_SRSTB;
  wire [13:0]PS_Zynq_0_M_AXI_BRAM_ARADDR;
  wire [1:0]PS_Zynq_0_M_AXI_BRAM_ARBURST;
  wire [3:0]PS_Zynq_0_M_AXI_BRAM_ARCACHE;
  wire [7:0]PS_Zynq_0_M_AXI_BRAM_ARLEN;
  wire [0:0]PS_Zynq_0_M_AXI_BRAM_ARLOCK;
  wire [2:0]PS_Zynq_0_M_AXI_BRAM_ARPROT;
  wire PS_Zynq_0_M_AXI_BRAM_ARREADY;
  wire [2:0]PS_Zynq_0_M_AXI_BRAM_ARSIZE;
  wire PS_Zynq_0_M_AXI_BRAM_ARVALID;
  wire [13:0]PS_Zynq_0_M_AXI_BRAM_AWADDR;
  wire [1:0]PS_Zynq_0_M_AXI_BRAM_AWBURST;
  wire [3:0]PS_Zynq_0_M_AXI_BRAM_AWCACHE;
  wire [7:0]PS_Zynq_0_M_AXI_BRAM_AWLEN;
  wire [0:0]PS_Zynq_0_M_AXI_BRAM_AWLOCK;
  wire [2:0]PS_Zynq_0_M_AXI_BRAM_AWPROT;
  wire PS_Zynq_0_M_AXI_BRAM_AWREADY;
  wire [2:0]PS_Zynq_0_M_AXI_BRAM_AWSIZE;
  wire PS_Zynq_0_M_AXI_BRAM_AWVALID;
  wire PS_Zynq_0_M_AXI_BRAM_BREADY;
  wire [1:0]PS_Zynq_0_M_AXI_BRAM_BRESP;
  wire PS_Zynq_0_M_AXI_BRAM_BVALID;
  wire [31:0]PS_Zynq_0_M_AXI_BRAM_RDATA;
  wire PS_Zynq_0_M_AXI_BRAM_RLAST;
  wire PS_Zynq_0_M_AXI_BRAM_RREADY;
  wire [1:0]PS_Zynq_0_M_AXI_BRAM_RRESP;
  wire PS_Zynq_0_M_AXI_BRAM_RVALID;
  wire [31:0]PS_Zynq_0_M_AXI_BRAM_WDATA;
  wire PS_Zynq_0_M_AXI_BRAM_WLAST;
  wire PS_Zynq_0_M_AXI_BRAM_WREADY;
  wire [3:0]PS_Zynq_0_M_AXI_BRAM_WSTRB;
  wire PS_Zynq_0_M_AXI_BRAM_WVALID;
  wire [9:0]PS_Zynq_0_M_AXI_DMA_ARADDR;
  wire PS_Zynq_0_M_AXI_DMA_ARREADY;
  wire PS_Zynq_0_M_AXI_DMA_ARVALID;
  wire [9:0]PS_Zynq_0_M_AXI_DMA_AWADDR;
  wire PS_Zynq_0_M_AXI_DMA_AWREADY;
  wire PS_Zynq_0_M_AXI_DMA_AWVALID;
  wire PS_Zynq_0_M_AXI_DMA_BREADY;
  wire [1:0]PS_Zynq_0_M_AXI_DMA_BRESP;
  wire PS_Zynq_0_M_AXI_DMA_BVALID;
  wire [31:0]PS_Zynq_0_M_AXI_DMA_RDATA;
  wire PS_Zynq_0_M_AXI_DMA_RREADY;
  wire [1:0]PS_Zynq_0_M_AXI_DMA_RRESP;
  wire PS_Zynq_0_M_AXI_DMA_RVALID;
  wire [31:0]PS_Zynq_0_M_AXI_DMA_WDATA;
  wire PS_Zynq_0_M_AXI_DMA_WREADY;
  wire PS_Zynq_0_M_AXI_DMA_WVALID;
  wire [31:0]S00_AXI_DMA_1_ARADDR;
  wire [1:0]S00_AXI_DMA_1_ARBURST;
  wire [3:0]S00_AXI_DMA_1_ARCACHE;
  wire [7:0]S00_AXI_DMA_1_ARLEN;
  wire [2:0]S00_AXI_DMA_1_ARPROT;
  wire S00_AXI_DMA_1_ARREADY;
  wire [2:0]S00_AXI_DMA_1_ARSIZE;
  wire S00_AXI_DMA_1_ARVALID;
  wire [31:0]S00_AXI_DMA_1_RDATA;
  wire S00_AXI_DMA_1_RLAST;
  wire S00_AXI_DMA_1_RREADY;
  wire [1:0]S00_AXI_DMA_1_RRESP;
  wire S00_AXI_DMA_1_RVALID;
  wire [31:0]S01_AXI_DMA_1_AWADDR;
  wire [1:0]S01_AXI_DMA_1_AWBURST;
  wire [3:0]S01_AXI_DMA_1_AWCACHE;
  wire [7:0]S01_AXI_DMA_1_AWLEN;
  wire [2:0]S01_AXI_DMA_1_AWPROT;
  wire S01_AXI_DMA_1_AWREADY;
  wire [2:0]S01_AXI_DMA_1_AWSIZE;
  wire S01_AXI_DMA_1_AWVALID;
  wire S01_AXI_DMA_1_BREADY;
  wire [1:0]S01_AXI_DMA_1_BRESP;
  wire S01_AXI_DMA_1_BVALID;
  wire [31:0]S01_AXI_DMA_1_WDATA;
  wire S01_AXI_DMA_1_WLAST;
  wire S01_AXI_DMA_1_WREADY;
  wire [3:0]S01_AXI_DMA_1_WSTRB;
  wire S01_AXI_DMA_1_WVALID;
  (* CONN_BUS_INFO = "S_AXIS_1 xilinx.com:interface:axis:1.0 None TDATA" *) (* DEBUG = "true" *) (* DONT_TOUCH *) wire [31:0]S_AXIS_1_TDATA;
  (* CONN_BUS_INFO = "S_AXIS_1 xilinx.com:interface:axis:1.0 None TKEEP" *) (* DEBUG = "true" *) (* DONT_TOUCH *) wire [3:0]S_AXIS_1_TKEEP;
  (* CONN_BUS_INFO = "S_AXIS_1 xilinx.com:interface:axis:1.0 None TLAST" *) (* DEBUG = "true" *) (* DONT_TOUCH *) wire S_AXIS_1_TLAST;
  (* CONN_BUS_INFO = "S_AXIS_1 xilinx.com:interface:axis:1.0 None TREADY" *) (* DEBUG = "true" *) (* DONT_TOUCH *) wire S_AXIS_1_TREADY;
  (* CONN_BUS_INFO = "S_AXIS_1 xilinx.com:interface:axis:1.0 None TVALID" *) (* DEBUG = "true" *) (* DONT_TOUCH *) wire S_AXIS_1_TVALID;
  (* CONN_BUS_INFO = "Transmit_Chain_0_M_AXIS xilinx.com:interface:axis:1.0 None TDATA" *) (* DONT_TOUCH *) wire [31:0]Transmit_Chain_0_M_AXIS_TDATA;
  (* CONN_BUS_INFO = "Transmit_Chain_0_M_AXIS xilinx.com:interface:axis:1.0 None TLAST" *) (* DONT_TOUCH *) wire Transmit_Chain_0_M_AXIS_TLAST;
  (* CONN_BUS_INFO = "Transmit_Chain_0_M_AXIS xilinx.com:interface:axis:1.0 None TVALID" *) (* DONT_TOUCH *) wire Transmit_Chain_0_M_AXIS_TVALID;
  wire [31:0]axis_data_fifo_1_M_AXIS_TDATA;
  wire axis_data_fifo_1_M_AXIS_TLAST;
  wire axis_data_fifo_1_M_AXIS_TREADY;
  wire axis_data_fifo_1_M_AXIS_TVALID;
  wire [0:0]config_start_0_1;
  wire [0:0]continuous_0_1;
  wire [15:0]cp_len_0_1;
  wire [0:0]dl_en_0_1;
  wire [26:0]fs_cycles_0_1;
  wire [0:0]i_negative_freq_0_1;
  wire [0:0]inv_0_1;
  wire [4:0]nfft_0_1;
  wire [11:0]nfft_scaled_0_1;
  wire [0:0]playback_en_1;
  wire processing_system7_0_FCLK_CLK0;
  wire [3:0]symbols_0_1;

  PS_Zynq_inst_0 PS_Zynq_0
       (.DDR_addr(DDR_addr[14:0]),
        .DDR_ba(DDR_ba[2:0]),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm[3:0]),
        .DDR_dq(DDR_dq[31:0]),
        .DDR_dqs_n(DDR_dqs_n[3:0]),
        .DDR_dqs_p(DDR_dqs_p[3:0]),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio[53:0]),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .M_AXI_BRAM_araddr(PS_Zynq_0_M_AXI_BRAM_ARADDR),
        .M_AXI_BRAM_arburst(PS_Zynq_0_M_AXI_BRAM_ARBURST),
        .M_AXI_BRAM_arcache(PS_Zynq_0_M_AXI_BRAM_ARCACHE),
        .M_AXI_BRAM_arlen(PS_Zynq_0_M_AXI_BRAM_ARLEN),
        .M_AXI_BRAM_arlock(PS_Zynq_0_M_AXI_BRAM_ARLOCK),
        .M_AXI_BRAM_arprot(PS_Zynq_0_M_AXI_BRAM_ARPROT),
        .M_AXI_BRAM_arready(PS_Zynq_0_M_AXI_BRAM_ARREADY),
        .M_AXI_BRAM_arsize(PS_Zynq_0_M_AXI_BRAM_ARSIZE),
        .M_AXI_BRAM_arvalid(PS_Zynq_0_M_AXI_BRAM_ARVALID),
        .M_AXI_BRAM_awaddr(PS_Zynq_0_M_AXI_BRAM_AWADDR),
        .M_AXI_BRAM_awburst(PS_Zynq_0_M_AXI_BRAM_AWBURST),
        .M_AXI_BRAM_awcache(PS_Zynq_0_M_AXI_BRAM_AWCACHE),
        .M_AXI_BRAM_awlen(PS_Zynq_0_M_AXI_BRAM_AWLEN),
        .M_AXI_BRAM_awlock(PS_Zynq_0_M_AXI_BRAM_AWLOCK),
        .M_AXI_BRAM_awprot(PS_Zynq_0_M_AXI_BRAM_AWPROT),
        .M_AXI_BRAM_awready(PS_Zynq_0_M_AXI_BRAM_AWREADY),
        .M_AXI_BRAM_awsize(PS_Zynq_0_M_AXI_BRAM_AWSIZE),
        .M_AXI_BRAM_awvalid(PS_Zynq_0_M_AXI_BRAM_AWVALID),
        .M_AXI_BRAM_bready(PS_Zynq_0_M_AXI_BRAM_BREADY),
        .M_AXI_BRAM_bresp(PS_Zynq_0_M_AXI_BRAM_BRESP),
        .M_AXI_BRAM_bvalid(PS_Zynq_0_M_AXI_BRAM_BVALID),
        .M_AXI_BRAM_rdata(PS_Zynq_0_M_AXI_BRAM_RDATA),
        .M_AXI_BRAM_rlast(PS_Zynq_0_M_AXI_BRAM_RLAST),
        .M_AXI_BRAM_rready(PS_Zynq_0_M_AXI_BRAM_RREADY),
        .M_AXI_BRAM_rresp(PS_Zynq_0_M_AXI_BRAM_RRESP),
        .M_AXI_BRAM_rvalid(PS_Zynq_0_M_AXI_BRAM_RVALID),
        .M_AXI_BRAM_wdata(PS_Zynq_0_M_AXI_BRAM_WDATA),
        .M_AXI_BRAM_wlast(PS_Zynq_0_M_AXI_BRAM_WLAST),
        .M_AXI_BRAM_wready(PS_Zynq_0_M_AXI_BRAM_WREADY),
        .M_AXI_BRAM_wstrb(PS_Zynq_0_M_AXI_BRAM_WSTRB),
        .M_AXI_BRAM_wvalid(PS_Zynq_0_M_AXI_BRAM_WVALID),
        .M_AXI_DMA_araddr(PS_Zynq_0_M_AXI_DMA_ARADDR),
        .M_AXI_DMA_arready(PS_Zynq_0_M_AXI_DMA_ARREADY),
        .M_AXI_DMA_arvalid(PS_Zynq_0_M_AXI_DMA_ARVALID),
        .M_AXI_DMA_awaddr(PS_Zynq_0_M_AXI_DMA_AWADDR),
        .M_AXI_DMA_awready(PS_Zynq_0_M_AXI_DMA_AWREADY),
        .M_AXI_DMA_awvalid(PS_Zynq_0_M_AXI_DMA_AWVALID),
        .M_AXI_DMA_bready(PS_Zynq_0_M_AXI_DMA_BREADY),
        .M_AXI_DMA_bresp(PS_Zynq_0_M_AXI_DMA_BRESP),
        .M_AXI_DMA_bvalid(PS_Zynq_0_M_AXI_DMA_BVALID),
        .M_AXI_DMA_rdata(PS_Zynq_0_M_AXI_DMA_RDATA),
        .M_AXI_DMA_rready(PS_Zynq_0_M_AXI_DMA_RREADY),
        .M_AXI_DMA_rresp(PS_Zynq_0_M_AXI_DMA_RRESP),
        .M_AXI_DMA_rvalid(PS_Zynq_0_M_AXI_DMA_RVALID),
        .M_AXI_DMA_wdata(PS_Zynq_0_M_AXI_DMA_WDATA),
        .M_AXI_DMA_wready(PS_Zynq_0_M_AXI_DMA_WREADY),
        .M_AXI_DMA_wvalid(PS_Zynq_0_M_AXI_DMA_WVALID),
        .S00_AXI_DMA_araddr(S00_AXI_DMA_1_ARADDR),
        .S00_AXI_DMA_arburst(S00_AXI_DMA_1_ARBURST),
        .S00_AXI_DMA_arcache(S00_AXI_DMA_1_ARCACHE),
        .S00_AXI_DMA_arlen(S00_AXI_DMA_1_ARLEN),
        .S00_AXI_DMA_arprot(S00_AXI_DMA_1_ARPROT),
        .S00_AXI_DMA_arready(S00_AXI_DMA_1_ARREADY),
        .S00_AXI_DMA_arsize(S00_AXI_DMA_1_ARSIZE),
        .S00_AXI_DMA_arvalid(S00_AXI_DMA_1_ARVALID),
        .S00_AXI_DMA_rdata(S00_AXI_DMA_1_RDATA),
        .S00_AXI_DMA_rlast(S00_AXI_DMA_1_RLAST),
        .S00_AXI_DMA_rready(S00_AXI_DMA_1_RREADY),
        .S00_AXI_DMA_rresp(S00_AXI_DMA_1_RRESP),
        .S00_AXI_DMA_rvalid(S00_AXI_DMA_1_RVALID),
        .S01_AXI_DMA_awaddr(S01_AXI_DMA_1_AWADDR),
        .S01_AXI_DMA_awburst(S01_AXI_DMA_1_AWBURST),
        .S01_AXI_DMA_awcache(S01_AXI_DMA_1_AWCACHE),
        .S01_AXI_DMA_awlen(S01_AXI_DMA_1_AWLEN),
        .S01_AXI_DMA_awprot(S01_AXI_DMA_1_AWPROT),
        .S01_AXI_DMA_awready(S01_AXI_DMA_1_AWREADY),
        .S01_AXI_DMA_awsize(S01_AXI_DMA_1_AWSIZE),
        .S01_AXI_DMA_awvalid(S01_AXI_DMA_1_AWVALID),
        .S01_AXI_DMA_bready(S01_AXI_DMA_1_BREADY),
        .S01_AXI_DMA_bresp(S01_AXI_DMA_1_BRESP),
        .S01_AXI_DMA_bvalid(S01_AXI_DMA_1_BVALID),
        .S01_AXI_DMA_wdata(S01_AXI_DMA_1_WDATA),
        .S01_AXI_DMA_wlast(S01_AXI_DMA_1_WLAST),
        .S01_AXI_DMA_wready(S01_AXI_DMA_1_WREADY),
        .S01_AXI_DMA_wstrb(S01_AXI_DMA_1_WSTRB),
        .S01_AXI_DMA_wvalid(S01_AXI_DMA_1_WVALID),
        .aclk_100M(processing_system7_0_FCLK_CLK0),
        .aresetn_100M(ARESETN_1),
        .continuous(continuous_0_1),
        .cp_len(cp_len_0_1),
        .dl_en(dl_en_0_1),
        .fft_config_en(config_start_0_1),
        .fft_inv(inv_0_1),
        .fs_cycles(fs_cycles_0_1),
        .negative_freq(i_negative_freq_0_1),
        .nfft(nfft_0_1),
        .nfft_scaled(nfft_scaled_0_1),
        .playback_en(playback_en_1),
        .symbols(symbols_0_1));
  Transmit_Chain_inst_0 Transmit_Chain_0
       (.M_AXIS_tdata(Transmit_Chain_0_M_AXIS_TDATA),
        .M_AXIS_tlast(Transmit_Chain_0_M_AXIS_TLAST),
        .M_AXIS_tvalid(Transmit_Chain_0_M_AXIS_TVALID),
        .S_AXIS_tdata(S_AXIS_1_TDATA),
        .S_AXIS_tkeep(S_AXIS_1_TKEEP),
        .S_AXIS_tlast(S_AXIS_1_TLAST),
        .S_AXIS_tready(S_AXIS_1_TREADY),
        .S_AXIS_tvalid(S_AXIS_1_TVALID),
        .S_BRAM_AXI_araddr(PS_Zynq_0_M_AXI_BRAM_ARADDR),
        .S_BRAM_AXI_arburst(PS_Zynq_0_M_AXI_BRAM_ARBURST),
        .S_BRAM_AXI_arcache(PS_Zynq_0_M_AXI_BRAM_ARCACHE),
        .S_BRAM_AXI_arlen(PS_Zynq_0_M_AXI_BRAM_ARLEN),
        .S_BRAM_AXI_arlock(PS_Zynq_0_M_AXI_BRAM_ARLOCK),
        .S_BRAM_AXI_arprot(PS_Zynq_0_M_AXI_BRAM_ARPROT),
        .S_BRAM_AXI_arready(PS_Zynq_0_M_AXI_BRAM_ARREADY),
        .S_BRAM_AXI_arsize(PS_Zynq_0_M_AXI_BRAM_ARSIZE),
        .S_BRAM_AXI_arvalid(PS_Zynq_0_M_AXI_BRAM_ARVALID),
        .S_BRAM_AXI_awaddr(PS_Zynq_0_M_AXI_BRAM_AWADDR),
        .S_BRAM_AXI_awburst(PS_Zynq_0_M_AXI_BRAM_AWBURST),
        .S_BRAM_AXI_awcache(PS_Zynq_0_M_AXI_BRAM_AWCACHE),
        .S_BRAM_AXI_awlen(PS_Zynq_0_M_AXI_BRAM_AWLEN),
        .S_BRAM_AXI_awlock(PS_Zynq_0_M_AXI_BRAM_AWLOCK),
        .S_BRAM_AXI_awprot(PS_Zynq_0_M_AXI_BRAM_AWPROT),
        .S_BRAM_AXI_awready(PS_Zynq_0_M_AXI_BRAM_AWREADY),
        .S_BRAM_AXI_awsize(PS_Zynq_0_M_AXI_BRAM_AWSIZE),
        .S_BRAM_AXI_awvalid(PS_Zynq_0_M_AXI_BRAM_AWVALID),
        .S_BRAM_AXI_bready(PS_Zynq_0_M_AXI_BRAM_BREADY),
        .S_BRAM_AXI_bresp(PS_Zynq_0_M_AXI_BRAM_BRESP),
        .S_BRAM_AXI_bvalid(PS_Zynq_0_M_AXI_BRAM_BVALID),
        .S_BRAM_AXI_rdata(PS_Zynq_0_M_AXI_BRAM_RDATA),
        .S_BRAM_AXI_rlast(PS_Zynq_0_M_AXI_BRAM_RLAST),
        .S_BRAM_AXI_rready(PS_Zynq_0_M_AXI_BRAM_RREADY),
        .S_BRAM_AXI_rresp(PS_Zynq_0_M_AXI_BRAM_RRESP),
        .S_BRAM_AXI_rvalid(PS_Zynq_0_M_AXI_BRAM_RVALID),
        .S_BRAM_AXI_wdata(PS_Zynq_0_M_AXI_BRAM_WDATA),
        .S_BRAM_AXI_wlast(PS_Zynq_0_M_AXI_BRAM_WLAST),
        .S_BRAM_AXI_wready(PS_Zynq_0_M_AXI_BRAM_WREADY),
        .S_BRAM_AXI_wstrb(PS_Zynq_0_M_AXI_BRAM_WSTRB),
        .S_BRAM_AXI_wvalid(PS_Zynq_0_M_AXI_BRAM_WVALID),
        .aclk(processing_system7_0_FCLK_CLK0),
        .aresetn(ARESETN_1),
        .config_start_0(config_start_0_1),
        .continuous_0(continuous_0_1),
        .cp_len_0(cp_len_0_1),
        .dl_en_0(dl_en_0_1),
        .fs_cycles_0(fs_cycles_0_1),
        .i_negative_freq_0(i_negative_freq_0_1),
        .inv_0(inv_0_1),
        .nfft_0(nfft_0_1),
        .nfft_scaled_0(nfft_scaled_0_1),
        .playback_en(playback_en_1),
        .symbols_0(symbols_0_1));
  Radio_Top_Pynq_axi_dma_0_0 axi_dma_0
       (.axi_resetn(ARESETN_1),
        .m_axi_mm2s_aclk(processing_system7_0_FCLK_CLK0),
        .m_axi_mm2s_araddr(S00_AXI_DMA_1_ARADDR),
        .m_axi_mm2s_arburst(S00_AXI_DMA_1_ARBURST),
        .m_axi_mm2s_arcache(S00_AXI_DMA_1_ARCACHE),
        .m_axi_mm2s_arlen(S00_AXI_DMA_1_ARLEN),
        .m_axi_mm2s_arprot(S00_AXI_DMA_1_ARPROT),
        .m_axi_mm2s_arready(S00_AXI_DMA_1_ARREADY),
        .m_axi_mm2s_arsize(S00_AXI_DMA_1_ARSIZE),
        .m_axi_mm2s_arvalid(S00_AXI_DMA_1_ARVALID),
        .m_axi_mm2s_rdata(S00_AXI_DMA_1_RDATA),
        .m_axi_mm2s_rlast(S00_AXI_DMA_1_RLAST),
        .m_axi_mm2s_rready(S00_AXI_DMA_1_RREADY),
        .m_axi_mm2s_rresp(S00_AXI_DMA_1_RRESP),
        .m_axi_mm2s_rvalid(S00_AXI_DMA_1_RVALID),
        .m_axi_s2mm_aclk(processing_system7_0_FCLK_CLK0),
        .m_axi_s2mm_awaddr(S01_AXI_DMA_1_AWADDR),
        .m_axi_s2mm_awburst(S01_AXI_DMA_1_AWBURST),
        .m_axi_s2mm_awcache(S01_AXI_DMA_1_AWCACHE),
        .m_axi_s2mm_awlen(S01_AXI_DMA_1_AWLEN),
        .m_axi_s2mm_awprot(S01_AXI_DMA_1_AWPROT),
        .m_axi_s2mm_awready(S01_AXI_DMA_1_AWREADY),
        .m_axi_s2mm_awsize(S01_AXI_DMA_1_AWSIZE),
        .m_axi_s2mm_awvalid(S01_AXI_DMA_1_AWVALID),
        .m_axi_s2mm_bready(S01_AXI_DMA_1_BREADY),
        .m_axi_s2mm_bresp(S01_AXI_DMA_1_BRESP),
        .m_axi_s2mm_bvalid(S01_AXI_DMA_1_BVALID),
        .m_axi_s2mm_wdata(S01_AXI_DMA_1_WDATA),
        .m_axi_s2mm_wlast(S01_AXI_DMA_1_WLAST),
        .m_axi_s2mm_wready(S01_AXI_DMA_1_WREADY),
        .m_axi_s2mm_wstrb(S01_AXI_DMA_1_WSTRB),
        .m_axi_s2mm_wvalid(S01_AXI_DMA_1_WVALID),
        .m_axis_mm2s_tdata(S_AXIS_1_TDATA),
        .m_axis_mm2s_tkeep(S_AXIS_1_TKEEP),
        .m_axis_mm2s_tlast(S_AXIS_1_TLAST),
        .m_axis_mm2s_tready(S_AXIS_1_TREADY),
        .m_axis_mm2s_tvalid(S_AXIS_1_TVALID),
        .s_axi_lite_aclk(processing_system7_0_FCLK_CLK0),
        .s_axi_lite_araddr(PS_Zynq_0_M_AXI_DMA_ARADDR),
        .s_axi_lite_arready(PS_Zynq_0_M_AXI_DMA_ARREADY),
        .s_axi_lite_arvalid(PS_Zynq_0_M_AXI_DMA_ARVALID),
        .s_axi_lite_awaddr(PS_Zynq_0_M_AXI_DMA_AWADDR),
        .s_axi_lite_awready(PS_Zynq_0_M_AXI_DMA_AWREADY),
        .s_axi_lite_awvalid(PS_Zynq_0_M_AXI_DMA_AWVALID),
        .s_axi_lite_bready(PS_Zynq_0_M_AXI_DMA_BREADY),
        .s_axi_lite_bresp(PS_Zynq_0_M_AXI_DMA_BRESP),
        .s_axi_lite_bvalid(PS_Zynq_0_M_AXI_DMA_BVALID),
        .s_axi_lite_rdata(PS_Zynq_0_M_AXI_DMA_RDATA),
        .s_axi_lite_rready(PS_Zynq_0_M_AXI_DMA_RREADY),
        .s_axi_lite_rresp(PS_Zynq_0_M_AXI_DMA_RRESP),
        .s_axi_lite_rvalid(PS_Zynq_0_M_AXI_DMA_RVALID),
        .s_axi_lite_wdata(PS_Zynq_0_M_AXI_DMA_WDATA),
        .s_axi_lite_wready(PS_Zynq_0_M_AXI_DMA_WREADY),
        .s_axi_lite_wvalid(PS_Zynq_0_M_AXI_DMA_WVALID),
        .s_axis_s2mm_tdata(axis_data_fifo_1_M_AXIS_TDATA),
        .s_axis_s2mm_tkeep({1'b1,1'b1,1'b1,1'b1}),
        .s_axis_s2mm_tlast(axis_data_fifo_1_M_AXIS_TLAST),
        .s_axis_s2mm_tready(axis_data_fifo_1_M_AXIS_TREADY),
        .s_axis_s2mm_tvalid(axis_data_fifo_1_M_AXIS_TVALID));
  Radio_Top_Pynq_axis_data_fifo_1_0 axis_data_fifo_1
       (.m_axis_tdata(axis_data_fifo_1_M_AXIS_TDATA),
        .m_axis_tlast(axis_data_fifo_1_M_AXIS_TLAST),
        .m_axis_tready(axis_data_fifo_1_M_AXIS_TREADY),
        .m_axis_tvalid(axis_data_fifo_1_M_AXIS_TVALID),
        .s_axis_aclk(processing_system7_0_FCLK_CLK0),
        .s_axis_aresetn(ARESETN_1),
        .s_axis_tdata(Transmit_Chain_0_M_AXIS_TDATA),
        .s_axis_tlast(Transmit_Chain_0_M_AXIS_TLAST),
        .s_axis_tvalid(Transmit_Chain_0_M_AXIS_TVALID));
  Radio_Top_Pynq_system_ila_0_0 system_ila_DMA
       (.SLOT_0_AXIS_tdata(S_AXIS_1_TDATA),
        .SLOT_0_AXIS_tkeep(S_AXIS_1_TKEEP),
        .SLOT_0_AXIS_tlast(S_AXIS_1_TLAST),
        .SLOT_0_AXIS_tready(S_AXIS_1_TREADY),
        .SLOT_0_AXIS_tvalid(S_AXIS_1_TVALID),
        .SLOT_1_AXIS_tdata(Transmit_Chain_0_M_AXIS_TDATA),
        .SLOT_1_AXIS_tlast(Transmit_Chain_0_M_AXIS_TLAST),
        .SLOT_1_AXIS_tvalid(Transmit_Chain_0_M_AXIS_TVALID),
        .clk(processing_system7_0_FCLK_CLK0),
        .resetn(ARESETN_1));
endmodule
