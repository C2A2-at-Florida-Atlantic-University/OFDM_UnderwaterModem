//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
//Date        : Mon Oct 31 18:33:10 2022
//Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
//Command     : generate_target DAC_Chain.bd
//Design      : DAC_Chain
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "DAC_Chain,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=DAC_Chain,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=1,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "DAC_Chain.hwdef" *) 
module DAC_Chain
   (S_AXIS_tdata,
    S_AXIS_tlast,
    S_AXIS_tready,
    S_AXIS_tvalid,
    aclk,
    aresetn,
    dl_en_0,
    interp_cycles_0);
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS, CLK_DOMAIN DAC_Chain_aclk, FREQ_HZ 100000000, HAS_TKEEP 0, HAS_TLAST 1, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.0, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0" *) input [31:0]S_AXIS_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TLAST" *) input S_AXIS_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TREADY" *) output S_AXIS_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *) input S_AXIS_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.ACLK CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.ACLK, ASSOCIATED_BUSIF S_AXIS, ASSOCIATED_RESET aresetn, CLK_DOMAIN DAC_Chain_aclk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.ARESETN RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.ARESETN, INSERT_VIP 0, POLARITY ACTIVE_LOW" *) input aresetn;
  input dl_en_0;
  input [23:0]interp_cycles_0;

  wire axis_aclk_0_1;
  wire axis_aresetn_0_1;
  wire dl_en_0_1;
  wire [23:0]interp_cycles_0_1;
  wire [31:0]s_axis_0_1_TDATA;
  wire s_axis_0_1_TLAST;
  wire s_axis_0_1_TREADY;
  wire s_axis_0_1_TVALID;

  assign S_AXIS_tready = s_axis_0_1_TREADY;
  assign axis_aclk_0_1 = aclk;
  assign axis_aresetn_0_1 = aresetn;
  assign dl_en_0_1 = dl_en_0;
  assign interp_cycles_0_1 = interp_cycles_0[23:0];
  assign s_axis_0_1_TDATA = S_AXIS_tdata[31:0];
  assign s_axis_0_1_TLAST = S_AXIS_tlast;
  assign s_axis_0_1_TVALID = S_AXIS_tvalid;
  DAC_Chain_dac_resampler_0_0 dac_resampler_0
       (.axis_aclk(axis_aclk_0_1),
        .axis_aresetn(axis_aresetn_0_1),
        .dl_en(dl_en_0_1),
        .interp_cycles(interp_cycles_0_1),
        .s_axis_tdata(s_axis_0_1_TDATA),
        .s_axis_tlast(s_axis_0_1_TLAST),
        .s_axis_tready(s_axis_0_1_TREADY),
        .s_axis_tvalid(s_axis_0_1_TVALID));
endmodule
