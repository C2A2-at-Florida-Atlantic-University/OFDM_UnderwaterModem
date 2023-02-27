// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Sun Feb 26 20:54:35 2023
// Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top Transmit_Chain_inst_0_fft_config_0_0 -prefix
//               Transmit_Chain_inst_0_fft_config_0_0_ Transmit_Chain_inst_0_fft_config_0_0_sim_netlist.v
// Design      : Transmit_Chain_inst_0_fft_config_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "Transmit_Chain_inst_0_fft_config_0_0,fft_config,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "fft_config,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module Transmit_Chain_inst_0_fft_config_0_0
   (axis_aclk,
    axis_aresetn,
    config_start,
    nfft,
    cp_len,
    inv,
    m_axis_tdata,
    m_axis_tvalid);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 axis_aclk CLK" *) (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF axis_aclk:m_axis, FREQ_HZ 100000000" *) input axis_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axis_aresetn RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axis_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input axis_aresetn;
  input config_start;
  input [4:0]nfft;
  input [15:0]cp_len;
  input inv;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *) output [39:0]m_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 5, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) output m_axis_tvalid;

  wire \<const0> ;
  wire axis_aclk;
  wire config_start;
  wire [15:0]cp_len;
  wire inv;
  wire [24:0]\^m_axis_tdata ;
  wire m_axis_tvalid;
  wire [4:0]nfft;

  assign m_axis_tdata[39] = \<const0> ;
  assign m_axis_tdata[38] = \<const0> ;
  assign m_axis_tdata[37] = \<const0> ;
  assign m_axis_tdata[36] = \<const0> ;
  assign m_axis_tdata[35] = \<const0> ;
  assign m_axis_tdata[34] = \<const0> ;
  assign m_axis_tdata[33] = \<const0> ;
  assign m_axis_tdata[32] = \<const0> ;
  assign m_axis_tdata[31] = \<const0> ;
  assign m_axis_tdata[30] = \<const0> ;
  assign m_axis_tdata[29] = \<const0> ;
  assign m_axis_tdata[28] = \<const0> ;
  assign m_axis_tdata[27] = \<const0> ;
  assign m_axis_tdata[26] = \<const0> ;
  assign m_axis_tdata[25] = \<const0> ;
  assign m_axis_tdata[24:8] = \^m_axis_tdata [24:8];
  assign m_axis_tdata[7] = \<const0> ;
  assign m_axis_tdata[6] = \<const0> ;
  assign m_axis_tdata[5] = \<const0> ;
  assign m_axis_tdata[4:0] = \^m_axis_tdata [4:0];
  GND GND
       (.G(\<const0> ));
  Transmit_Chain_inst_0_fft_config_0_0_fft_config inst
       (.axis_aclk(axis_aclk),
        .config_start(config_start),
        .cp_len(cp_len),
        .inv(inv),
        .m_axis_tdata({\^m_axis_tdata [24:8],\^m_axis_tdata [4:0]}),
        .m_axis_tvalid(m_axis_tvalid),
        .nfft(nfft));
endmodule

module Transmit_Chain_inst_0_fft_config_0_0_fft_config
   (m_axis_tdata,
    m_axis_tvalid,
    config_start,
    axis_aclk,
    cp_len,
    nfft,
    inv);
  output [21:0]m_axis_tdata;
  output m_axis_tvalid;
  input config_start;
  input axis_aclk;
  input [15:0]cp_len;
  input [4:0]nfft;
  input inv;

  wire axis_aclk;
  wire config_rising;
  wire config_start;
  wire [15:0]cp_len;
  wire inv;
  wire [21:0]m_axis_tdata;
  wire \m_axis_tdata[24]_i_1_n_0 ;
  wire m_axis_tvalid;
  wire [4:0]nfft;
  wire [24:24]p_0_out;
  wire r_config_start;

  LUT2 #(
    .INIT(4'hB)) 
    \m_axis_tdata[24]_i_1 
       (.I0(r_config_start),
        .I1(config_start),
        .O(\m_axis_tdata[24]_i_1_n_0 ));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[24]_i_2 
       (.I0(inv),
        .O(p_0_out));
  FDRE \m_axis_tdata_reg[0] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(nfft[0]),
        .Q(m_axis_tdata[0]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[10] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[2]),
        .Q(m_axis_tdata[7]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[11] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[3]),
        .Q(m_axis_tdata[8]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[12] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[4]),
        .Q(m_axis_tdata[9]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[13] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[5]),
        .Q(m_axis_tdata[10]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[14] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[6]),
        .Q(m_axis_tdata[11]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[15] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[7]),
        .Q(m_axis_tdata[12]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[16] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[8]),
        .Q(m_axis_tdata[13]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[17] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[9]),
        .Q(m_axis_tdata[14]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[18] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[10]),
        .Q(m_axis_tdata[15]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[19] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[11]),
        .Q(m_axis_tdata[16]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[1] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(nfft[1]),
        .Q(m_axis_tdata[1]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[20] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[12]),
        .Q(m_axis_tdata[17]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[21] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[13]),
        .Q(m_axis_tdata[18]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[22] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[14]),
        .Q(m_axis_tdata[19]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[23] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[15]),
        .Q(m_axis_tdata[20]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[24] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_0_out),
        .Q(m_axis_tdata[21]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[2] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(nfft[2]),
        .Q(m_axis_tdata[2]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[3] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(nfft[3]),
        .Q(m_axis_tdata[3]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[4] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(nfft[4]),
        .Q(m_axis_tdata[4]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[8] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[0]),
        .Q(m_axis_tdata[5]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[9] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(cp_len[1]),
        .Q(m_axis_tdata[6]),
        .R(\m_axis_tdata[24]_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    m_axis_tvalid_i_1
       (.I0(config_start),
        .I1(r_config_start),
        .O(config_rising));
  FDRE m_axis_tvalid_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(config_rising),
        .Q(m_axis_tvalid),
        .R(1'b0));
  FDRE r_config_start_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(config_start),
        .Q(r_config_start),
        .R(1'b0));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
