// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Sun Feb 26 20:54:37 2023
// Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top Transmit_Chain_inst_0_tlast_gen_0_0 -prefix
//               Transmit_Chain_inst_0_tlast_gen_0_0_ Transmit_Chain_inst_0_tlast_gen_0_0_sim_netlist.v
// Design      : Transmit_Chain_inst_0_tlast_gen_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "Transmit_Chain_inst_0_tlast_gen_0_0,tlast_gen,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "tlast_gen,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module Transmit_Chain_inst_0_tlast_gen_0_0
   (axis_aclk,
    axis_aresetn,
    i_start,
    nfft_scaled,
    symbols,
    dl_en,
    s_axis_tdata,
    s_axis_tvalid,
    s_axis_tlast,
    s_axis_tready,
    m_axis_tdata,
    m_axis_tvalid,
    m_axis_tlast,
    m_axis_tready);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 axis_aclk CLK" *) (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000" *) input axis_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axis_aresetn RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axis_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input axis_aresetn;
  input i_start;
  input [11:0]nfft_scaled;
  input [3:0]symbols;
  input dl_en;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TDATA" *) input [31:0]s_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TVALID" *) input s_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TLAST" *) input s_axis_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) output s_axis_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *) output [31:0]m_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *) output m_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TLAST" *) output m_axis_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) input m_axis_tready;

  wire axis_aclk;
  wire axis_aresetn;
  wire dl_en;
  wire i_start;
  wire [31:0]m_axis_tdata;
  wire m_axis_tlast;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire [11:0]nfft_scaled;
  wire [31:0]s_axis_tdata;
  wire s_axis_tready;
  wire s_axis_tvalid;
  wire [3:0]symbols;

  Transmit_Chain_inst_0_tlast_gen_0_0_tlast_gen inst
       (.axis_aclk(axis_aclk),
        .axis_aresetn(axis_aresetn),
        .dl_en(dl_en),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tready(m_axis_tready),
        .m_axis_tvalid(m_axis_tvalid),
        .nfft_scaled(nfft_scaled),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tvalid(s_axis_tvalid),
        .symbols(symbols));
  LUT2 #(
    .INIT(4'h8)) 
    s_axis_tready_INST_0
       (.I0(i_start),
        .I1(m_axis_tready),
        .O(s_axis_tready));
endmodule

module Transmit_Chain_inst_0_tlast_gen_0_0_tlast_gen
   (m_axis_tvalid,
    m_axis_tlast,
    m_axis_tdata,
    axis_aclk,
    nfft_scaled,
    dl_en,
    axis_aresetn,
    m_axis_tready,
    s_axis_tvalid,
    symbols,
    s_axis_tdata);
  output m_axis_tvalid;
  output m_axis_tlast;
  output [31:0]m_axis_tdata;
  input axis_aclk;
  input [11:0]nfft_scaled;
  input dl_en;
  input axis_aresetn;
  input m_axis_tready;
  input s_axis_tvalid;
  input [3:0]symbols;
  input [31:0]s_axis_tdata;

  wire axis_aclk;
  wire axis_aresetn;
  wire clear;
  wire [11:0]counter;
  wire \counter[11]_i_1_n_0 ;
  wire dl_en;
  wire eqOp;
  wire eqOp_carry_i_1_n_0;
  wire eqOp_carry_i_2_n_0;
  wire eqOp_carry_i_3_n_0;
  wire eqOp_carry_i_4_n_0;
  wire eqOp_carry_n_1;
  wire eqOp_carry_n_2;
  wire eqOp_carry_n_3;
  wire [31:0]m_axis_tdata;
  wire m_axis_tlast;
  wire m_axis_tready;
  wire m_axis_tvalid;
  wire m_axis_tvalid_i_1_n_0;
  wire m_axis_tvalid_i_2_n_0;
  wire m_axis_tvalid_i_3_n_0;
  wire [11:1]minusOp;
  wire minusOp_carry__0_i_1_n_0;
  wire minusOp_carry__0_i_2_n_0;
  wire minusOp_carry__0_i_3_n_0;
  wire minusOp_carry__0_i_4_n_0;
  wire minusOp_carry__0_n_0;
  wire minusOp_carry__0_n_1;
  wire minusOp_carry__0_n_2;
  wire minusOp_carry__0_n_3;
  wire minusOp_carry__1_i_1_n_0;
  wire minusOp_carry__1_i_2_n_0;
  wire minusOp_carry__1_i_3_n_0;
  wire minusOp_carry__1_n_2;
  wire minusOp_carry__1_n_3;
  wire minusOp_carry_i_1_n_0;
  wire minusOp_carry_i_2_n_0;
  wire minusOp_carry_i_3_n_0;
  wire minusOp_carry_i_4_n_0;
  wire minusOp_carry_n_0;
  wire minusOp_carry_n_1;
  wire minusOp_carry_n_2;
  wire minusOp_carry_n_3;
  wire [11:0]nfft_scaled;
  wire out_tlast_i_1_n_0;
  wire out_tlast_i_2_n_0;
  wire [3:1]p_0_in;
  wire [11:0]p_2_in;
  wire [11:1]plusOp;
  wire plusOp_carry__0_n_0;
  wire plusOp_carry__0_n_1;
  wire plusOp_carry__0_n_2;
  wire plusOp_carry__0_n_3;
  wire plusOp_carry__1_n_2;
  wire plusOp_carry__1_n_3;
  wire plusOp_carry_n_0;
  wire plusOp_carry_n_1;
  wire plusOp_carry_n_2;
  wire plusOp_carry_n_3;
  wire [31:0]s_axis_tdata;
  wire s_axis_tvalid;
  wire \symbol_counter[0]_i_1_n_0 ;
  wire \symbol_counter[3]_i_1_n_0 ;
  wire [3:0]symbol_counter_reg;
  wire [3:0]symbols;
  wire [3:0]NLW_eqOp_carry_O_UNCONNECTED;
  wire [3:2]NLW_minusOp_carry__1_CO_UNCONNECTED;
  wire [3:3]NLW_minusOp_carry__1_O_UNCONNECTED;
  wire [3:2]NLW_plusOp_carry__1_CO_UNCONNECTED;
  wire [3:3]NLW_plusOp_carry__1_O_UNCONNECTED;

  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h1F000000)) 
    \counter[0]_i_1 
       (.I0(counter[0]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[0]));
  LUT5 #(
    .INIT(32'h2F000000)) 
    \counter[10]_i_1 
       (.I0(plusOp[10]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[10]));
  LUT3 #(
    .INIT(8'hF7)) 
    \counter[11]_i_1 
       (.I0(s_axis_tvalid),
        .I1(dl_en),
        .I2(m_axis_tready),
        .O(\counter[11]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h2F000000)) 
    \counter[11]_i_2 
       (.I0(plusOp[11]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[11]));
  LUT1 #(
    .INIT(2'h1)) 
    \counter[11]_i_3 
       (.I0(axis_aresetn),
        .O(clear));
  LUT5 #(
    .INIT(32'h2F000000)) 
    \counter[1]_i_1 
       (.I0(plusOp[1]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[1]));
  LUT5 #(
    .INIT(32'h2F000000)) 
    \counter[2]_i_1 
       (.I0(plusOp[2]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[2]));
  LUT5 #(
    .INIT(32'h2F000000)) 
    \counter[3]_i_1 
       (.I0(plusOp[3]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[3]));
  LUT5 #(
    .INIT(32'h2F000000)) 
    \counter[4]_i_1 
       (.I0(plusOp[4]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[4]));
  LUT5 #(
    .INIT(32'h2F000000)) 
    \counter[5]_i_1 
       (.I0(plusOp[5]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[5]));
  LUT5 #(
    .INIT(32'h2F000000)) 
    \counter[6]_i_1 
       (.I0(plusOp[6]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[6]));
  LUT5 #(
    .INIT(32'h2F000000)) 
    \counter[7]_i_1 
       (.I0(plusOp[7]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[7]));
  LUT5 #(
    .INIT(32'h2F000000)) 
    \counter[8]_i_1 
       (.I0(plusOp[8]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[8]));
  LUT5 #(
    .INIT(32'h2F000000)) 
    \counter[9]_i_1 
       (.I0(plusOp[9]),
        .I1(eqOp),
        .I2(m_axis_tready),
        .I3(dl_en),
        .I4(s_axis_tvalid),
        .O(p_2_in[9]));
  FDCE \counter_reg[0] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[0]),
        .Q(counter[0]));
  FDCE \counter_reg[10] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[10]),
        .Q(counter[10]));
  FDCE \counter_reg[11] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[11]),
        .Q(counter[11]));
  FDCE \counter_reg[1] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[1]),
        .Q(counter[1]));
  FDCE \counter_reg[2] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[2]),
        .Q(counter[2]));
  FDCE \counter_reg[3] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[3]),
        .Q(counter[3]));
  FDCE \counter_reg[4] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[4]),
        .Q(counter[4]));
  FDCE \counter_reg[5] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[5]),
        .Q(counter[5]));
  FDCE \counter_reg[6] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[6]),
        .Q(counter[6]));
  FDCE \counter_reg[7] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[7]),
        .Q(counter[7]));
  FDCE \counter_reg[8] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[8]),
        .Q(counter[8]));
  FDCE \counter_reg[9] 
       (.C(axis_aclk),
        .CE(\counter[11]_i_1_n_0 ),
        .CLR(clear),
        .D(p_2_in[9]),
        .Q(counter[9]));
  CARRY4 eqOp_carry
       (.CI(1'b0),
        .CO({eqOp,eqOp_carry_n_1,eqOp_carry_n_2,eqOp_carry_n_3}),
        .CYINIT(1'b1),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eqOp_carry_O_UNCONNECTED[3:0]),
        .S({eqOp_carry_i_1_n_0,eqOp_carry_i_2_n_0,eqOp_carry_i_3_n_0,eqOp_carry_i_4_n_0}));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry_i_1
       (.I0(minusOp[11]),
        .I1(counter[11]),
        .I2(minusOp[10]),
        .I3(counter[10]),
        .I4(counter[9]),
        .I5(minusOp[9]),
        .O(eqOp_carry_i_1_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry_i_2
       (.I0(minusOp[8]),
        .I1(counter[8]),
        .I2(minusOp[7]),
        .I3(counter[7]),
        .I4(counter[6]),
        .I5(minusOp[6]),
        .O(eqOp_carry_i_2_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry_i_3
       (.I0(minusOp[5]),
        .I1(counter[5]),
        .I2(minusOp[4]),
        .I3(counter[4]),
        .I4(counter[3]),
        .I5(minusOp[3]),
        .O(eqOp_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h0000900990090000)) 
    eqOp_carry_i_4
       (.I0(minusOp[2]),
        .I1(counter[2]),
        .I2(minusOp[1]),
        .I3(counter[1]),
        .I4(counter[0]),
        .I5(nfft_scaled[0]),
        .O(eqOp_carry_i_4_n_0));
  FDRE \m_axis_tdata_reg[0] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[0]),
        .Q(m_axis_tdata[0]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[10] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[10]),
        .Q(m_axis_tdata[10]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[11] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[11]),
        .Q(m_axis_tdata[11]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[12] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[12]),
        .Q(m_axis_tdata[12]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[13] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[13]),
        .Q(m_axis_tdata[13]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[14] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[14]),
        .Q(m_axis_tdata[14]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[15] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[15]),
        .Q(m_axis_tdata[15]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[16] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[16]),
        .Q(m_axis_tdata[16]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[17] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[17]),
        .Q(m_axis_tdata[17]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[18] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[18]),
        .Q(m_axis_tdata[18]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[19] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[19]),
        .Q(m_axis_tdata[19]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[1] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[1]),
        .Q(m_axis_tdata[1]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[20] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[20]),
        .Q(m_axis_tdata[20]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[21] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[21]),
        .Q(m_axis_tdata[21]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[22] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[22]),
        .Q(m_axis_tdata[22]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[23] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[23]),
        .Q(m_axis_tdata[23]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[24] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[24]),
        .Q(m_axis_tdata[24]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[25] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[25]),
        .Q(m_axis_tdata[25]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[26] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[26]),
        .Q(m_axis_tdata[26]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[27] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[27]),
        .Q(m_axis_tdata[27]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[28] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[28]),
        .Q(m_axis_tdata[28]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[29] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[29]),
        .Q(m_axis_tdata[29]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[2] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[2]),
        .Q(m_axis_tdata[2]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[30] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[30]),
        .Q(m_axis_tdata[30]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[31] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[31]),
        .Q(m_axis_tdata[31]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[3] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[3]),
        .Q(m_axis_tdata[3]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[4] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[4]),
        .Q(m_axis_tdata[4]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[5] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[5]),
        .Q(m_axis_tdata[5]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[6] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[6]),
        .Q(m_axis_tdata[6]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[7] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[7]),
        .Q(m_axis_tdata[7]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[8] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[8]),
        .Q(m_axis_tdata[8]),
        .R(1'b0));
  FDRE \m_axis_tdata_reg[9] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(s_axis_tdata[9]),
        .Q(m_axis_tdata[9]),
        .R(1'b0));
  LUT2 #(
    .INIT(4'hB)) 
    m_axis_tvalid_i_1
       (.I0(s_axis_tvalid),
        .I1(m_axis_tvalid_i_2_n_0),
        .O(m_axis_tvalid_i_1_n_0));
  LUT5 #(
    .INIT(32'hFFFFED7B)) 
    m_axis_tvalid_i_2
       (.I0(symbols[1]),
        .I1(symbols[0]),
        .I2(symbol_counter_reg[1]),
        .I3(symbol_counter_reg[0]),
        .I4(m_axis_tvalid_i_3_n_0),
        .O(m_axis_tvalid_i_2_n_0));
  LUT6 #(
    .INIT(64'h777BBBBDDDDEEEE7)) 
    m_axis_tvalid_i_3
       (.I0(symbol_counter_reg[2]),
        .I1(symbol_counter_reg[3]),
        .I2(symbols[0]),
        .I3(symbols[1]),
        .I4(symbols[2]),
        .I5(symbols[3]),
        .O(m_axis_tvalid_i_3_n_0));
  FDRE m_axis_tvalid_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(m_axis_tvalid_i_1_n_0),
        .Q(m_axis_tvalid),
        .R(1'b0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp_carry
       (.CI(1'b0),
        .CO({minusOp_carry_n_0,minusOp_carry_n_1,minusOp_carry_n_2,minusOp_carry_n_3}),
        .CYINIT(nfft_scaled[0]),
        .DI(nfft_scaled[4:1]),
        .O(minusOp[4:1]),
        .S({minusOp_carry_i_1_n_0,minusOp_carry_i_2_n_0,minusOp_carry_i_3_n_0,minusOp_carry_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp_carry__0
       (.CI(minusOp_carry_n_0),
        .CO({minusOp_carry__0_n_0,minusOp_carry__0_n_1,minusOp_carry__0_n_2,minusOp_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI(nfft_scaled[8:5]),
        .O(minusOp[8:5]),
        .S({minusOp_carry__0_i_1_n_0,minusOp_carry__0_i_2_n_0,minusOp_carry__0_i_3_n_0,minusOp_carry__0_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__0_i_1
       (.I0(nfft_scaled[8]),
        .O(minusOp_carry__0_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__0_i_2
       (.I0(nfft_scaled[7]),
        .O(minusOp_carry__0_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__0_i_3
       (.I0(nfft_scaled[6]),
        .O(minusOp_carry__0_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__0_i_4
       (.I0(nfft_scaled[5]),
        .O(minusOp_carry__0_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp_carry__1
       (.CI(minusOp_carry__0_n_0),
        .CO({NLW_minusOp_carry__1_CO_UNCONNECTED[3:2],minusOp_carry__1_n_2,minusOp_carry__1_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,nfft_scaled[10:9]}),
        .O({NLW_minusOp_carry__1_O_UNCONNECTED[3],minusOp[11:9]}),
        .S({1'b0,minusOp_carry__1_i_1_n_0,minusOp_carry__1_i_2_n_0,minusOp_carry__1_i_3_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__1_i_1
       (.I0(nfft_scaled[11]),
        .O(minusOp_carry__1_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__1_i_2
       (.I0(nfft_scaled[10]),
        .O(minusOp_carry__1_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__1_i_3
       (.I0(nfft_scaled[9]),
        .O(minusOp_carry__1_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry_i_1
       (.I0(nfft_scaled[4]),
        .O(minusOp_carry_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry_i_2
       (.I0(nfft_scaled[3]),
        .O(minusOp_carry_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry_i_3
       (.I0(nfft_scaled[2]),
        .O(minusOp_carry_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry_i_4
       (.I0(nfft_scaled[1]),
        .O(minusOp_carry_i_4_n_0));
  LUT6 #(
    .INIT(64'h0F0F8F0F00008000)) 
    out_tlast_i_1
       (.I0(m_axis_tvalid_i_2_n_0),
        .I1(dl_en),
        .I2(axis_aresetn),
        .I3(eqOp),
        .I4(out_tlast_i_2_n_0),
        .I5(m_axis_tlast),
        .O(out_tlast_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h7)) 
    out_tlast_i_2
       (.I0(s_axis_tvalid),
        .I1(m_axis_tready),
        .O(out_tlast_i_2_n_0));
  FDRE out_tlast_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(out_tlast_i_1_n_0),
        .Q(m_axis_tlast),
        .R(1'b0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 plusOp_carry
       (.CI(1'b0),
        .CO({plusOp_carry_n_0,plusOp_carry_n_1,plusOp_carry_n_2,plusOp_carry_n_3}),
        .CYINIT(counter[0]),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(plusOp[4:1]),
        .S(counter[4:1]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 plusOp_carry__0
       (.CI(plusOp_carry_n_0),
        .CO({plusOp_carry__0_n_0,plusOp_carry__0_n_1,plusOp_carry__0_n_2,plusOp_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(plusOp[8:5]),
        .S(counter[8:5]));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 plusOp_carry__1
       (.CI(plusOp_carry__0_n_0),
        .CO({NLW_plusOp_carry__1_CO_UNCONNECTED[3:2],plusOp_carry__1_n_2,plusOp_carry__1_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({NLW_plusOp_carry__1_O_UNCONNECTED[3],plusOp[11:9]}),
        .S({1'b0,counter[11:9]}));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \symbol_counter[0]_i_1 
       (.I0(dl_en),
        .I1(symbol_counter_reg[0]),
        .O(\symbol_counter[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'h28)) 
    \symbol_counter[1]_i_1 
       (.I0(dl_en),
        .I1(symbol_counter_reg[1]),
        .I2(symbol_counter_reg[0]),
        .O(p_0_in[1]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h2888)) 
    \symbol_counter[2]_i_1 
       (.I0(dl_en),
        .I1(symbol_counter_reg[2]),
        .I2(symbol_counter_reg[1]),
        .I3(symbol_counter_reg[0]),
        .O(p_0_in[2]));
  LUT5 #(
    .INIT(32'h8000FFFF)) 
    \symbol_counter[3]_i_1 
       (.I0(m_axis_tready),
        .I1(s_axis_tvalid),
        .I2(eqOp),
        .I3(m_axis_tvalid_i_2_n_0),
        .I4(dl_en),
        .O(\symbol_counter[3]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'h28888888)) 
    \symbol_counter[3]_i_2 
       (.I0(dl_en),
        .I1(symbol_counter_reg[3]),
        .I2(symbol_counter_reg[2]),
        .I3(symbol_counter_reg[1]),
        .I4(symbol_counter_reg[0]),
        .O(p_0_in[3]));
  FDCE \symbol_counter_reg[0] 
       (.C(axis_aclk),
        .CE(\symbol_counter[3]_i_1_n_0 ),
        .CLR(clear),
        .D(\symbol_counter[0]_i_1_n_0 ),
        .Q(symbol_counter_reg[0]));
  FDCE \symbol_counter_reg[1] 
       (.C(axis_aclk),
        .CE(\symbol_counter[3]_i_1_n_0 ),
        .CLR(clear),
        .D(p_0_in[1]),
        .Q(symbol_counter_reg[1]));
  FDCE \symbol_counter_reg[2] 
       (.C(axis_aclk),
        .CE(\symbol_counter[3]_i_1_n_0 ),
        .CLR(clear),
        .D(p_0_in[2]),
        .Q(symbol_counter_reg[2]));
  FDCE \symbol_counter_reg[3] 
       (.C(axis_aclk),
        .CE(\symbol_counter[3]_i_1_n_0 ),
        .CLR(clear),
        .D(p_0_in[3]),
        .Q(symbol_counter_reg[3]));
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
