// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Sun Feb 26 20:54:35 2023
// Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top Transmit_Chain_inst_0_real_time_sampler_0_0 -prefix
//               Transmit_Chain_inst_0_real_time_sampler_0_0_ Transmit_Chain_inst_0_real_time_sampler_0_0_sim_netlist.v
// Design      : Transmit_Chain_inst_0_real_time_sampler_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "Transmit_Chain_inst_0_real_time_sampler_0_0,real_time_sampler,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "real_time_sampler,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module Transmit_Chain_inst_0_real_time_sampler_0_0
   (axis_aclk,
    axis_aresetn,
    s_axis_tdata,
    s_axis_tvalid,
    s_axis_tlast,
    s_axis_tready,
    m_axis_tdata,
    m_axis_tvalid,
    m_axis_tlast,
    dl_en,
    fs_cycles);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 axis_aclk CLK" *) (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000" *) input axis_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axis_aresetn RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axis_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input axis_aresetn;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TDATA" *) input [31:0]s_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TVALID" *) input s_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TLAST" *) input s_axis_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) output s_axis_tready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *) output [31:0]m_axis_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *) output m_axis_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TLAST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) output m_axis_tlast;
  input dl_en;
  input [26:0]fs_cycles;

  wire axis_aclk;
  wire axis_aresetn;
  wire dl_en;
  wire eqOp__8_carry__0_i_10_n_0;
  wire eqOp__8_carry__0_i_11_n_0;
  wire eqOp__8_carry__0_i_12_n_0;
  wire eqOp__8_carry__0_i_13_n_0;
  wire eqOp__8_carry__0_i_14_n_0;
  wire eqOp__8_carry__0_i_15_n_0;
  wire eqOp__8_carry__0_i_16_n_0;
  wire eqOp__8_carry__0_i_17_n_0;
  wire eqOp__8_carry__0_i_18_n_0;
  wire eqOp__8_carry__0_i_19_n_0;
  wire eqOp__8_carry__0_i_5_n_0;
  wire eqOp__8_carry__0_i_5_n_1;
  wire eqOp__8_carry__0_i_5_n_2;
  wire eqOp__8_carry__0_i_5_n_3;
  wire eqOp__8_carry__0_i_6_n_0;
  wire eqOp__8_carry__0_i_6_n_1;
  wire eqOp__8_carry__0_i_6_n_2;
  wire eqOp__8_carry__0_i_6_n_3;
  wire eqOp__8_carry__0_i_7_n_0;
  wire eqOp__8_carry__0_i_7_n_1;
  wire eqOp__8_carry__0_i_7_n_2;
  wire eqOp__8_carry__0_i_7_n_3;
  wire eqOp__8_carry__0_i_8_n_0;
  wire eqOp__8_carry__0_i_9_n_0;
  wire eqOp__8_carry__1_i_2_n_2;
  wire eqOp__8_carry__1_i_2_n_3;
  wire eqOp__8_carry__1_i_3_n_0;
  wire eqOp__8_carry__1_i_4_n_0;
  wire eqOp__8_carry__1_i_5_n_0;
  wire eqOp__8_carry_i_10_n_0;
  wire eqOp__8_carry_i_11_n_0;
  wire eqOp__8_carry_i_12_n_0;
  wire eqOp__8_carry_i_13_n_0;
  wire eqOp__8_carry_i_14_n_0;
  wire eqOp__8_carry_i_15_n_0;
  wire eqOp__8_carry_i_16_n_0;
  wire eqOp__8_carry_i_17_n_0;
  wire eqOp__8_carry_i_18_n_0;
  wire eqOp__8_carry_i_5_n_0;
  wire eqOp__8_carry_i_5_n_1;
  wire eqOp__8_carry_i_5_n_2;
  wire eqOp__8_carry_i_5_n_3;
  wire eqOp__8_carry_i_6_n_0;
  wire eqOp__8_carry_i_6_n_1;
  wire eqOp__8_carry_i_6_n_2;
  wire eqOp__8_carry_i_6_n_3;
  wire eqOp__8_carry_i_7_n_0;
  wire eqOp__8_carry_i_7_n_1;
  wire eqOp__8_carry_i_7_n_2;
  wire eqOp__8_carry_i_7_n_3;
  wire eqOp__8_carry_i_8_n_0;
  wire eqOp__8_carry_i_9_n_0;
  wire [26:0]fs_cycles;
  wire [31:0]m_axis_tdata;
  wire m_axis_tlast;
  wire m_axis_tvalid;
  wire [26:0]minusOp;
  wire [31:0]s_axis_tdata;
  wire s_axis_tlast;
  wire s_axis_tready;
  wire s_axis_tvalid;
  wire [3:2]NLW_eqOp__8_carry__1_i_2_CO_UNCONNECTED;
  wire [3:3]NLW_eqOp__8_carry__1_i_2_O_UNCONNECTED;

  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_10
       (.I0(fs_cycles[21]),
        .O(eqOp__8_carry__0_i_10_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_11
       (.I0(fs_cycles[20]),
        .O(eqOp__8_carry__0_i_11_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_12
       (.I0(fs_cycles[19]),
        .O(eqOp__8_carry__0_i_12_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_13
       (.I0(fs_cycles[18]),
        .O(eqOp__8_carry__0_i_13_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_14
       (.I0(fs_cycles[17]),
        .O(eqOp__8_carry__0_i_14_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_15
       (.I0(fs_cycles[16]),
        .O(eqOp__8_carry__0_i_15_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_16
       (.I0(fs_cycles[15]),
        .O(eqOp__8_carry__0_i_16_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_17
       (.I0(fs_cycles[14]),
        .O(eqOp__8_carry__0_i_17_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_18
       (.I0(fs_cycles[13]),
        .O(eqOp__8_carry__0_i_18_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_19
       (.I0(fs_cycles[12]),
        .O(eqOp__8_carry__0_i_19_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 eqOp__8_carry__0_i_5
       (.CI(eqOp__8_carry__0_i_6_n_0),
        .CO({eqOp__8_carry__0_i_5_n_0,eqOp__8_carry__0_i_5_n_1,eqOp__8_carry__0_i_5_n_2,eqOp__8_carry__0_i_5_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[23:20]),
        .O(minusOp[23:20]),
        .S({eqOp__8_carry__0_i_8_n_0,eqOp__8_carry__0_i_9_n_0,eqOp__8_carry__0_i_10_n_0,eqOp__8_carry__0_i_11_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 eqOp__8_carry__0_i_6
       (.CI(eqOp__8_carry__0_i_7_n_0),
        .CO({eqOp__8_carry__0_i_6_n_0,eqOp__8_carry__0_i_6_n_1,eqOp__8_carry__0_i_6_n_2,eqOp__8_carry__0_i_6_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[19:16]),
        .O(minusOp[19:16]),
        .S({eqOp__8_carry__0_i_12_n_0,eqOp__8_carry__0_i_13_n_0,eqOp__8_carry__0_i_14_n_0,eqOp__8_carry__0_i_15_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 eqOp__8_carry__0_i_7
       (.CI(eqOp__8_carry_i_5_n_0),
        .CO({eqOp__8_carry__0_i_7_n_0,eqOp__8_carry__0_i_7_n_1,eqOp__8_carry__0_i_7_n_2,eqOp__8_carry__0_i_7_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[15:12]),
        .O(minusOp[15:12]),
        .S({eqOp__8_carry__0_i_16_n_0,eqOp__8_carry__0_i_17_n_0,eqOp__8_carry__0_i_18_n_0,eqOp__8_carry__0_i_19_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_8
       (.I0(fs_cycles[23]),
        .O(eqOp__8_carry__0_i_8_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__0_i_9
       (.I0(fs_cycles[22]),
        .O(eqOp__8_carry__0_i_9_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 eqOp__8_carry__1_i_2
       (.CI(eqOp__8_carry__0_i_5_n_0),
        .CO({NLW_eqOp__8_carry__1_i_2_CO_UNCONNECTED[3:2],eqOp__8_carry__1_i_2_n_2,eqOp__8_carry__1_i_2_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,fs_cycles[25:24]}),
        .O({NLW_eqOp__8_carry__1_i_2_O_UNCONNECTED[3],minusOp[26:24]}),
        .S({1'b0,eqOp__8_carry__1_i_3_n_0,eqOp__8_carry__1_i_4_n_0,eqOp__8_carry__1_i_5_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__1_i_3
       (.I0(fs_cycles[26]),
        .O(eqOp__8_carry__1_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__1_i_4
       (.I0(fs_cycles[25]),
        .O(eqOp__8_carry__1_i_4_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry__1_i_5
       (.I0(fs_cycles[24]),
        .O(eqOp__8_carry__1_i_5_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry_i_10
       (.I0(fs_cycles[9]),
        .O(eqOp__8_carry_i_10_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry_i_11
       (.I0(fs_cycles[8]),
        .O(eqOp__8_carry_i_11_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry_i_12
       (.I0(fs_cycles[7]),
        .O(eqOp__8_carry_i_12_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry_i_13
       (.I0(fs_cycles[6]),
        .O(eqOp__8_carry_i_13_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry_i_14
       (.I0(fs_cycles[5]),
        .O(eqOp__8_carry_i_14_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry_i_15
       (.I0(fs_cycles[4]),
        .O(eqOp__8_carry_i_15_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry_i_16
       (.I0(fs_cycles[3]),
        .O(eqOp__8_carry_i_16_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry_i_17
       (.I0(fs_cycles[2]),
        .O(eqOp__8_carry_i_17_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry_i_18
       (.I0(fs_cycles[1]),
        .O(eqOp__8_carry_i_18_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 eqOp__8_carry_i_5
       (.CI(eqOp__8_carry_i_6_n_0),
        .CO({eqOp__8_carry_i_5_n_0,eqOp__8_carry_i_5_n_1,eqOp__8_carry_i_5_n_2,eqOp__8_carry_i_5_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[11:8]),
        .O(minusOp[11:8]),
        .S({eqOp__8_carry_i_8_n_0,eqOp__8_carry_i_9_n_0,eqOp__8_carry_i_10_n_0,eqOp__8_carry_i_11_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 eqOp__8_carry_i_6
       (.CI(eqOp__8_carry_i_7_n_0),
        .CO({eqOp__8_carry_i_6_n_0,eqOp__8_carry_i_6_n_1,eqOp__8_carry_i_6_n_2,eqOp__8_carry_i_6_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[7:4]),
        .O(minusOp[7:4]),
        .S({eqOp__8_carry_i_12_n_0,eqOp__8_carry_i_13_n_0,eqOp__8_carry_i_14_n_0,eqOp__8_carry_i_15_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 eqOp__8_carry_i_7
       (.CI(1'b0),
        .CO({eqOp__8_carry_i_7_n_0,eqOp__8_carry_i_7_n_1,eqOp__8_carry_i_7_n_2,eqOp__8_carry_i_7_n_3}),
        .CYINIT(1'b0),
        .DI({fs_cycles[3:1],1'b0}),
        .O(minusOp[3:0]),
        .S({eqOp__8_carry_i_16_n_0,eqOp__8_carry_i_17_n_0,eqOp__8_carry_i_18_n_0,fs_cycles[0]}));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry_i_8
       (.I0(fs_cycles[11]),
        .O(eqOp__8_carry_i_8_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    eqOp__8_carry_i_9
       (.I0(fs_cycles[10]),
        .O(eqOp__8_carry_i_9_n_0));
  Transmit_Chain_inst_0_real_time_sampler_0_0_real_time_sampler inst
       (.axis_aclk(axis_aclk),
        .axis_aresetn(axis_aresetn),
        .dl_en(dl_en),
        .fs_cycles(fs_cycles),
        .m_axis_tdata(m_axis_tdata),
        .m_axis_tlast(m_axis_tlast),
        .m_axis_tvalid(m_axis_tvalid),
        .minusOp(minusOp),
        .s_axis_tdata(s_axis_tdata),
        .s_axis_tlast(s_axis_tlast),
        .s_axis_tready(s_axis_tready),
        .s_axis_tvalid(s_axis_tvalid));
endmodule

module Transmit_Chain_inst_0_real_time_sampler_0_0_real_time_sampler
   (s_axis_tready,
    m_axis_tvalid,
    m_axis_tlast,
    m_axis_tdata,
    axis_aclk,
    dl_en,
    fs_cycles,
    axis_aresetn,
    minusOp,
    s_axis_tvalid,
    s_axis_tlast,
    s_axis_tdata);
  output s_axis_tready;
  output m_axis_tvalid;
  output m_axis_tlast;
  output [31:0]m_axis_tdata;
  input axis_aclk;
  input dl_en;
  input [26:0]fs_cycles;
  input axis_aresetn;
  input [26:0]minusOp;
  input s_axis_tvalid;
  input s_axis_tlast;
  input [31:0]s_axis_tdata;

  wire axis_aclk;
  wire axis_aresetn;
  wire [26:0]cycle_counter;
  wire \cycle_counter_reg[0]_C_n_0 ;
  wire \cycle_counter_reg[0]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[0]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[0]_LDC_n_0 ;
  wire \cycle_counter_reg[0]_P_n_0 ;
  wire \cycle_counter_reg[10]_C_n_0 ;
  wire \cycle_counter_reg[10]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[10]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[10]_LDC_n_0 ;
  wire \cycle_counter_reg[10]_P_n_0 ;
  wire \cycle_counter_reg[11]_C_n_0 ;
  wire \cycle_counter_reg[11]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[11]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[11]_LDC_n_0 ;
  wire \cycle_counter_reg[11]_P_n_0 ;
  wire \cycle_counter_reg[12]_C_n_0 ;
  wire \cycle_counter_reg[12]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[12]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[12]_LDC_n_0 ;
  wire \cycle_counter_reg[12]_P_n_0 ;
  wire \cycle_counter_reg[13]_C_n_0 ;
  wire \cycle_counter_reg[13]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[13]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[13]_LDC_n_0 ;
  wire \cycle_counter_reg[13]_P_n_0 ;
  wire \cycle_counter_reg[14]_C_n_0 ;
  wire \cycle_counter_reg[14]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[14]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[14]_LDC_n_0 ;
  wire \cycle_counter_reg[14]_P_n_0 ;
  wire \cycle_counter_reg[15]_C_n_0 ;
  wire \cycle_counter_reg[15]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[15]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[15]_LDC_n_0 ;
  wire \cycle_counter_reg[15]_P_n_0 ;
  wire \cycle_counter_reg[16]_C_n_0 ;
  wire \cycle_counter_reg[16]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[16]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[16]_LDC_n_0 ;
  wire \cycle_counter_reg[16]_P_n_0 ;
  wire \cycle_counter_reg[17]_C_n_0 ;
  wire \cycle_counter_reg[17]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[17]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[17]_LDC_n_0 ;
  wire \cycle_counter_reg[17]_P_n_0 ;
  wire \cycle_counter_reg[18]_C_n_0 ;
  wire \cycle_counter_reg[18]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[18]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[18]_LDC_n_0 ;
  wire \cycle_counter_reg[18]_P_n_0 ;
  wire \cycle_counter_reg[19]_C_n_0 ;
  wire \cycle_counter_reg[19]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[19]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[19]_LDC_n_0 ;
  wire \cycle_counter_reg[19]_P_n_0 ;
  wire \cycle_counter_reg[1]_C_n_0 ;
  wire \cycle_counter_reg[1]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[1]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[1]_LDC_n_0 ;
  wire \cycle_counter_reg[1]_P_n_0 ;
  wire \cycle_counter_reg[20]_C_n_0 ;
  wire \cycle_counter_reg[20]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[20]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[20]_LDC_n_0 ;
  wire \cycle_counter_reg[20]_P_n_0 ;
  wire \cycle_counter_reg[21]_C_n_0 ;
  wire \cycle_counter_reg[21]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[21]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[21]_LDC_n_0 ;
  wire \cycle_counter_reg[21]_P_n_0 ;
  wire \cycle_counter_reg[22]_C_n_0 ;
  wire \cycle_counter_reg[22]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[22]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[22]_LDC_n_0 ;
  wire \cycle_counter_reg[22]_P_n_0 ;
  wire \cycle_counter_reg[23]_C_n_0 ;
  wire \cycle_counter_reg[23]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[23]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[23]_LDC_n_0 ;
  wire \cycle_counter_reg[23]_P_n_0 ;
  wire \cycle_counter_reg[24]_C_n_0 ;
  wire \cycle_counter_reg[24]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[24]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[24]_LDC_n_0 ;
  wire \cycle_counter_reg[24]_P_n_0 ;
  wire \cycle_counter_reg[25]_C_n_0 ;
  wire \cycle_counter_reg[25]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[25]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[25]_LDC_n_0 ;
  wire \cycle_counter_reg[25]_P_n_0 ;
  wire \cycle_counter_reg[26]_C_n_0 ;
  wire \cycle_counter_reg[26]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[26]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[26]_LDC_n_0 ;
  wire \cycle_counter_reg[26]_P_n_0 ;
  wire \cycle_counter_reg[2]_C_n_0 ;
  wire \cycle_counter_reg[2]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[2]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[2]_LDC_n_0 ;
  wire \cycle_counter_reg[2]_P_n_0 ;
  wire \cycle_counter_reg[3]_C_n_0 ;
  wire \cycle_counter_reg[3]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[3]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[3]_LDC_n_0 ;
  wire \cycle_counter_reg[3]_P_n_0 ;
  wire \cycle_counter_reg[4]_C_n_0 ;
  wire \cycle_counter_reg[4]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[4]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[4]_LDC_n_0 ;
  wire \cycle_counter_reg[4]_P_n_0 ;
  wire \cycle_counter_reg[5]_C_n_0 ;
  wire \cycle_counter_reg[5]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[5]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[5]_LDC_n_0 ;
  wire \cycle_counter_reg[5]_P_n_0 ;
  wire \cycle_counter_reg[6]_C_n_0 ;
  wire \cycle_counter_reg[6]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[6]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[6]_LDC_n_0 ;
  wire \cycle_counter_reg[6]_P_n_0 ;
  wire \cycle_counter_reg[7]_C_n_0 ;
  wire \cycle_counter_reg[7]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[7]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[7]_LDC_n_0 ;
  wire \cycle_counter_reg[7]_P_n_0 ;
  wire \cycle_counter_reg[8]_C_n_0 ;
  wire \cycle_counter_reg[8]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[8]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[8]_LDC_n_0 ;
  wire \cycle_counter_reg[8]_P_n_0 ;
  wire \cycle_counter_reg[9]_C_n_0 ;
  wire \cycle_counter_reg[9]_LDC_i_1_n_0 ;
  wire \cycle_counter_reg[9]_LDC_i_2_n_0 ;
  wire \cycle_counter_reg[9]_LDC_n_0 ;
  wire \cycle_counter_reg[9]_P_n_0 ;
  wire dl_en;
  wire eqOp;
  wire eqOp1_out;
  wire eqOp__8_carry__0_i_1_n_0;
  wire eqOp__8_carry__0_i_2_n_0;
  wire eqOp__8_carry__0_i_3_n_0;
  wire eqOp__8_carry__0_i_4_n_0;
  wire eqOp__8_carry__0_n_0;
  wire eqOp__8_carry__0_n_1;
  wire eqOp__8_carry__0_n_2;
  wire eqOp__8_carry__0_n_3;
  wire eqOp__8_carry__1_i_1_n_0;
  wire eqOp__8_carry_i_1_n_0;
  wire eqOp__8_carry_i_2_n_0;
  wire eqOp__8_carry_i_3_n_0;
  wire eqOp__8_carry_i_4_n_0;
  wire eqOp__8_carry_n_0;
  wire eqOp__8_carry_n_1;
  wire eqOp__8_carry_n_2;
  wire eqOp__8_carry_n_3;
  wire eqOp_carry__0_i_1_n_0;
  wire eqOp_carry__0_i_2_n_0;
  wire eqOp_carry__0_i_3_n_0;
  wire eqOp_carry__0_i_4_n_0;
  wire eqOp_carry__0_n_0;
  wire eqOp_carry__0_n_1;
  wire eqOp_carry__0_n_2;
  wire eqOp_carry__0_n_3;
  wire eqOp_carry__1_i_1_n_0;
  wire eqOp_carry_i_1_n_0;
  wire eqOp_carry_i_2_n_0;
  wire eqOp_carry_i_3_n_0;
  wire eqOp_carry_i_4_n_0;
  wire eqOp_carry_n_0;
  wire eqOp_carry_n_1;
  wire eqOp_carry_n_2;
  wire eqOp_carry_n_3;
  wire [26:0]fs_cycles;
  wire [31:0]in_tdata;
  wire in_tdata0;
  wire \in_tdata[31]_i_1_n_0 ;
  wire in_tlast;
  wire in_tlast_i_1_n_0;
  wire in_tvalid;
  wire in_tvalid_i_1_n_0;
  wire [31:0]m_axis_tdata;
  wire \m_axis_tdata[31]_i_1_n_0 ;
  wire m_axis_tlast;
  wire m_axis_tvalid;
  wire [26:0]minusOp;
  wire [26:1]minusOp0_in;
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
  wire minusOp_carry__1_i_4_n_0;
  wire minusOp_carry__1_n_0;
  wire minusOp_carry__1_n_1;
  wire minusOp_carry__1_n_2;
  wire minusOp_carry__1_n_3;
  wire minusOp_carry__2_i_1_n_0;
  wire minusOp_carry__2_i_2_n_0;
  wire minusOp_carry__2_i_3_n_0;
  wire minusOp_carry__2_i_4_n_0;
  wire minusOp_carry__2_n_0;
  wire minusOp_carry__2_n_1;
  wire minusOp_carry__2_n_2;
  wire minusOp_carry__2_n_3;
  wire minusOp_carry__3_i_1_n_0;
  wire minusOp_carry__3_i_2_n_0;
  wire minusOp_carry__3_i_3_n_0;
  wire minusOp_carry__3_i_4_n_0;
  wire minusOp_carry__3_n_0;
  wire minusOp_carry__3_n_1;
  wire minusOp_carry__3_n_2;
  wire minusOp_carry__3_n_3;
  wire minusOp_carry__4_i_1_n_0;
  wire minusOp_carry__4_i_2_n_0;
  wire minusOp_carry__4_i_3_n_0;
  wire minusOp_carry__4_i_4_n_0;
  wire minusOp_carry__4_n_0;
  wire minusOp_carry__4_n_1;
  wire minusOp_carry__4_n_2;
  wire minusOp_carry__4_n_3;
  wire minusOp_carry__5_i_1_n_0;
  wire minusOp_carry__5_i_2_n_0;
  wire minusOp_carry__5_n_3;
  wire minusOp_carry_i_1_n_0;
  wire minusOp_carry_i_2_n_0;
  wire minusOp_carry_i_3_n_0;
  wire minusOp_carry_i_4_n_0;
  wire minusOp_carry_n_0;
  wire minusOp_carry_n_1;
  wire minusOp_carry_n_2;
  wire minusOp_carry_n_3;
  wire p_0_in;
  wire [26:0]p_2_in;
  wire [26:1]plusOp;
  wire plusOp_carry__0_i_1_n_0;
  wire plusOp_carry__0_i_2_n_0;
  wire plusOp_carry__0_i_3_n_0;
  wire plusOp_carry__0_i_4_n_0;
  wire plusOp_carry__0_n_0;
  wire plusOp_carry__0_n_1;
  wire plusOp_carry__0_n_2;
  wire plusOp_carry__0_n_3;
  wire plusOp_carry__1_i_1_n_0;
  wire plusOp_carry__1_i_2_n_0;
  wire plusOp_carry__1_i_3_n_0;
  wire plusOp_carry__1_i_4_n_0;
  wire plusOp_carry__1_n_0;
  wire plusOp_carry__1_n_1;
  wire plusOp_carry__1_n_2;
  wire plusOp_carry__1_n_3;
  wire plusOp_carry__2_i_1_n_0;
  wire plusOp_carry__2_i_2_n_0;
  wire plusOp_carry__2_i_3_n_0;
  wire plusOp_carry__2_i_4_n_0;
  wire plusOp_carry__2_n_0;
  wire plusOp_carry__2_n_1;
  wire plusOp_carry__2_n_2;
  wire plusOp_carry__2_n_3;
  wire plusOp_carry__3_i_1_n_0;
  wire plusOp_carry__3_i_2_n_0;
  wire plusOp_carry__3_i_3_n_0;
  wire plusOp_carry__3_i_4_n_0;
  wire plusOp_carry__3_n_0;
  wire plusOp_carry__3_n_1;
  wire plusOp_carry__3_n_2;
  wire plusOp_carry__3_n_3;
  wire plusOp_carry__4_i_1_n_0;
  wire plusOp_carry__4_i_2_n_0;
  wire plusOp_carry__4_i_3_n_0;
  wire plusOp_carry__4_i_4_n_0;
  wire plusOp_carry__4_n_0;
  wire plusOp_carry__4_n_1;
  wire plusOp_carry__4_n_2;
  wire plusOp_carry__4_n_3;
  wire plusOp_carry__5_i_1_n_0;
  wire plusOp_carry__5_i_2_n_0;
  wire plusOp_carry__5_n_3;
  wire plusOp_carry_i_2_n_0;
  wire plusOp_carry_i_3_n_0;
  wire plusOp_carry_i_4_n_0;
  wire plusOp_carry_i_5_n_0;
  wire plusOp_carry_n_0;
  wire plusOp_carry_n_1;
  wire plusOp_carry_n_2;
  wire plusOp_carry_n_3;
  wire [31:0]s_axis_tdata;
  wire s_axis_tlast;
  wire s_axis_tready;
  wire s_axis_tvalid;
  wire w_axis_tready__0;
  wire [3:0]NLW_eqOp__8_carry_O_UNCONNECTED;
  wire [3:0]NLW_eqOp__8_carry__0_O_UNCONNECTED;
  wire [3:1]NLW_eqOp__8_carry__1_CO_UNCONNECTED;
  wire [3:0]NLW_eqOp__8_carry__1_O_UNCONNECTED;
  wire [3:0]NLW_eqOp_carry_O_UNCONNECTED;
  wire [3:0]NLW_eqOp_carry__0_O_UNCONNECTED;
  wire [3:1]NLW_eqOp_carry__1_CO_UNCONNECTED;
  wire [3:0]NLW_eqOp_carry__1_O_UNCONNECTED;
  wire [3:1]NLW_minusOp_carry__5_CO_UNCONNECTED;
  wire [3:2]NLW_minusOp_carry__5_O_UNCONNECTED;
  wire [3:1]NLW_plusOp_carry__5_CO_UNCONNECTED;
  wire [3:2]NLW_plusOp_carry__5_O_UNCONNECTED;

  LUT6 #(
    .INIT(64'h001DFFFF001D0000)) 
    \cycle_counter[0]_C_i_1 
       (.I0(\cycle_counter_reg[0]_C_n_0 ),
        .I1(\cycle_counter_reg[0]_LDC_n_0 ),
        .I2(\cycle_counter_reg[0]_P_n_0 ),
        .I3(eqOp1_out),
        .I4(dl_en),
        .I5(fs_cycles[0]),
        .O(p_2_in[0]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[10]_C_i_1 
       (.I0(plusOp[10]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[10]),
        .O(p_2_in[10]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[11]_C_i_1 
       (.I0(plusOp[11]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[11]),
        .O(p_2_in[11]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[12]_C_i_1 
       (.I0(plusOp[12]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[12]),
        .O(p_2_in[12]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[13]_C_i_1 
       (.I0(plusOp[13]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[13]),
        .O(p_2_in[13]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[14]_C_i_1 
       (.I0(plusOp[14]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[14]),
        .O(p_2_in[14]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[15]_C_i_1 
       (.I0(plusOp[15]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[15]),
        .O(p_2_in[15]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[16]_C_i_1 
       (.I0(plusOp[16]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[16]),
        .O(p_2_in[16]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[17]_C_i_1 
       (.I0(plusOp[17]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[17]),
        .O(p_2_in[17]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[18]_C_i_1 
       (.I0(plusOp[18]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[18]),
        .O(p_2_in[18]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[19]_C_i_1 
       (.I0(plusOp[19]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[19]),
        .O(p_2_in[19]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[1]_C_i_1 
       (.I0(plusOp[1]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[1]),
        .O(p_2_in[1]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[20]_C_i_1 
       (.I0(plusOp[20]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[20]),
        .O(p_2_in[20]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[21]_C_i_1 
       (.I0(plusOp[21]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[21]),
        .O(p_2_in[21]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[22]_C_i_1 
       (.I0(plusOp[22]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[22]),
        .O(p_2_in[22]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[23]_C_i_1 
       (.I0(plusOp[23]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[23]),
        .O(p_2_in[23]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[24]_C_i_1 
       (.I0(plusOp[24]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[24]),
        .O(p_2_in[24]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[25]_C_i_1 
       (.I0(plusOp[25]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[25]),
        .O(p_2_in[25]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[26]_C_i_1 
       (.I0(plusOp[26]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[26]),
        .O(p_2_in[26]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[2]_C_i_1 
       (.I0(plusOp[2]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[2]),
        .O(p_2_in[2]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[3]_C_i_1 
       (.I0(plusOp[3]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[3]),
        .O(p_2_in[3]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[4]_C_i_1 
       (.I0(plusOp[4]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[4]),
        .O(p_2_in[4]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[5]_C_i_1 
       (.I0(plusOp[5]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[5]),
        .O(p_2_in[5]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[6]_C_i_1 
       (.I0(plusOp[6]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[6]),
        .O(p_2_in[6]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[7]_C_i_1 
       (.I0(plusOp[7]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[7]),
        .O(p_2_in[7]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[8]_C_i_1 
       (.I0(plusOp[8]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[8]),
        .O(p_2_in[8]));
  LUT4 #(
    .INIT(16'h2F20)) 
    \cycle_counter[9]_C_i_1 
       (.I0(plusOp[9]),
        .I1(eqOp1_out),
        .I2(dl_en),
        .I3(fs_cycles[9]),
        .O(p_2_in[9]));
  FDCE \cycle_counter_reg[0]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[0]_LDC_i_2_n_0 ),
        .D(p_2_in[0]),
        .Q(\cycle_counter_reg[0]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[0]_LDC 
       (.CLR(\cycle_counter_reg[0]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[0]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[0]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[0]_LDC_i_1 
       (.I0(fs_cycles[0]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[0]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[0]_LDC_i_2 
       (.I0(fs_cycles[0]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[0]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[0]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[0]),
        .PRE(\cycle_counter_reg[0]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[0]_P_n_0 ));
  FDCE \cycle_counter_reg[10]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[10]_LDC_i_2_n_0 ),
        .D(p_2_in[10]),
        .Q(\cycle_counter_reg[10]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[10]_LDC 
       (.CLR(\cycle_counter_reg[10]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[10]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[10]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[10]_LDC_i_1 
       (.I0(minusOp0_in[10]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[10]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[10]_LDC_i_2 
       (.I0(minusOp0_in[10]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[10]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[10]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[10]),
        .PRE(\cycle_counter_reg[10]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[10]_P_n_0 ));
  FDCE \cycle_counter_reg[11]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[11]_LDC_i_2_n_0 ),
        .D(p_2_in[11]),
        .Q(\cycle_counter_reg[11]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[11]_LDC 
       (.CLR(\cycle_counter_reg[11]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[11]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[11]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[11]_LDC_i_1 
       (.I0(minusOp0_in[11]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[11]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[11]_LDC_i_2 
       (.I0(minusOp0_in[11]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[11]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[11]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[11]),
        .PRE(\cycle_counter_reg[11]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[11]_P_n_0 ));
  FDCE \cycle_counter_reg[12]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[12]_LDC_i_2_n_0 ),
        .D(p_2_in[12]),
        .Q(\cycle_counter_reg[12]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[12]_LDC 
       (.CLR(\cycle_counter_reg[12]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[12]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[12]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[12]_LDC_i_1 
       (.I0(minusOp0_in[12]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[12]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[12]_LDC_i_2 
       (.I0(minusOp0_in[12]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[12]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[12]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[12]),
        .PRE(\cycle_counter_reg[12]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[12]_P_n_0 ));
  FDCE \cycle_counter_reg[13]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[13]_LDC_i_2_n_0 ),
        .D(p_2_in[13]),
        .Q(\cycle_counter_reg[13]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[13]_LDC 
       (.CLR(\cycle_counter_reg[13]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[13]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[13]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[13]_LDC_i_1 
       (.I0(minusOp0_in[13]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[13]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[13]_LDC_i_2 
       (.I0(minusOp0_in[13]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[13]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[13]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[13]),
        .PRE(\cycle_counter_reg[13]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[13]_P_n_0 ));
  FDCE \cycle_counter_reg[14]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[14]_LDC_i_2_n_0 ),
        .D(p_2_in[14]),
        .Q(\cycle_counter_reg[14]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[14]_LDC 
       (.CLR(\cycle_counter_reg[14]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[14]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[14]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[14]_LDC_i_1 
       (.I0(minusOp0_in[14]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[14]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[14]_LDC_i_2 
       (.I0(minusOp0_in[14]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[14]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[14]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[14]),
        .PRE(\cycle_counter_reg[14]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[14]_P_n_0 ));
  FDCE \cycle_counter_reg[15]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[15]_LDC_i_2_n_0 ),
        .D(p_2_in[15]),
        .Q(\cycle_counter_reg[15]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[15]_LDC 
       (.CLR(\cycle_counter_reg[15]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[15]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[15]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[15]_LDC_i_1 
       (.I0(minusOp0_in[15]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[15]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[15]_LDC_i_2 
       (.I0(minusOp0_in[15]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[15]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[15]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[15]),
        .PRE(\cycle_counter_reg[15]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[15]_P_n_0 ));
  FDCE \cycle_counter_reg[16]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[16]_LDC_i_2_n_0 ),
        .D(p_2_in[16]),
        .Q(\cycle_counter_reg[16]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[16]_LDC 
       (.CLR(\cycle_counter_reg[16]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[16]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[16]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[16]_LDC_i_1 
       (.I0(minusOp0_in[16]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[16]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[16]_LDC_i_2 
       (.I0(minusOp0_in[16]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[16]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[16]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[16]),
        .PRE(\cycle_counter_reg[16]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[16]_P_n_0 ));
  FDCE \cycle_counter_reg[17]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[17]_LDC_i_2_n_0 ),
        .D(p_2_in[17]),
        .Q(\cycle_counter_reg[17]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[17]_LDC 
       (.CLR(\cycle_counter_reg[17]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[17]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[17]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[17]_LDC_i_1 
       (.I0(minusOp0_in[17]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[17]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[17]_LDC_i_2 
       (.I0(minusOp0_in[17]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[17]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[17]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[17]),
        .PRE(\cycle_counter_reg[17]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[17]_P_n_0 ));
  FDCE \cycle_counter_reg[18]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[18]_LDC_i_2_n_0 ),
        .D(p_2_in[18]),
        .Q(\cycle_counter_reg[18]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[18]_LDC 
       (.CLR(\cycle_counter_reg[18]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[18]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[18]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[18]_LDC_i_1 
       (.I0(minusOp0_in[18]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[18]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[18]_LDC_i_2 
       (.I0(minusOp0_in[18]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[18]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[18]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[18]),
        .PRE(\cycle_counter_reg[18]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[18]_P_n_0 ));
  FDCE \cycle_counter_reg[19]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[19]_LDC_i_2_n_0 ),
        .D(p_2_in[19]),
        .Q(\cycle_counter_reg[19]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[19]_LDC 
       (.CLR(\cycle_counter_reg[19]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[19]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[19]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[19]_LDC_i_1 
       (.I0(minusOp0_in[19]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[19]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[19]_LDC_i_2 
       (.I0(minusOp0_in[19]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[19]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[19]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[19]),
        .PRE(\cycle_counter_reg[19]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[19]_P_n_0 ));
  FDCE \cycle_counter_reg[1]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[1]_LDC_i_2_n_0 ),
        .D(p_2_in[1]),
        .Q(\cycle_counter_reg[1]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[1]_LDC 
       (.CLR(\cycle_counter_reg[1]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[1]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[1]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[1]_LDC_i_1 
       (.I0(minusOp0_in[1]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[1]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[1]_LDC_i_2 
       (.I0(minusOp0_in[1]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[1]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[1]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[1]),
        .PRE(\cycle_counter_reg[1]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[1]_P_n_0 ));
  FDCE \cycle_counter_reg[20]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[20]_LDC_i_2_n_0 ),
        .D(p_2_in[20]),
        .Q(\cycle_counter_reg[20]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[20]_LDC 
       (.CLR(\cycle_counter_reg[20]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[20]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[20]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[20]_LDC_i_1 
       (.I0(minusOp0_in[20]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[20]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[20]_LDC_i_2 
       (.I0(minusOp0_in[20]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[20]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[20]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[20]),
        .PRE(\cycle_counter_reg[20]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[20]_P_n_0 ));
  FDCE \cycle_counter_reg[21]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[21]_LDC_i_2_n_0 ),
        .D(p_2_in[21]),
        .Q(\cycle_counter_reg[21]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[21]_LDC 
       (.CLR(\cycle_counter_reg[21]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[21]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[21]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[21]_LDC_i_1 
       (.I0(minusOp0_in[21]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[21]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[21]_LDC_i_2 
       (.I0(minusOp0_in[21]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[21]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[21]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[21]),
        .PRE(\cycle_counter_reg[21]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[21]_P_n_0 ));
  FDCE \cycle_counter_reg[22]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[22]_LDC_i_2_n_0 ),
        .D(p_2_in[22]),
        .Q(\cycle_counter_reg[22]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[22]_LDC 
       (.CLR(\cycle_counter_reg[22]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[22]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[22]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[22]_LDC_i_1 
       (.I0(minusOp0_in[22]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[22]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[22]_LDC_i_2 
       (.I0(minusOp0_in[22]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[22]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[22]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[22]),
        .PRE(\cycle_counter_reg[22]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[22]_P_n_0 ));
  FDCE \cycle_counter_reg[23]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[23]_LDC_i_2_n_0 ),
        .D(p_2_in[23]),
        .Q(\cycle_counter_reg[23]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[23]_LDC 
       (.CLR(\cycle_counter_reg[23]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[23]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[23]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[23]_LDC_i_1 
       (.I0(minusOp0_in[23]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[23]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[23]_LDC_i_2 
       (.I0(minusOp0_in[23]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[23]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[23]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[23]),
        .PRE(\cycle_counter_reg[23]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[23]_P_n_0 ));
  FDCE \cycle_counter_reg[24]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[24]_LDC_i_2_n_0 ),
        .D(p_2_in[24]),
        .Q(\cycle_counter_reg[24]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[24]_LDC 
       (.CLR(\cycle_counter_reg[24]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[24]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[24]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[24]_LDC_i_1 
       (.I0(minusOp0_in[24]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[24]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[24]_LDC_i_2 
       (.I0(minusOp0_in[24]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[24]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[24]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[24]),
        .PRE(\cycle_counter_reg[24]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[24]_P_n_0 ));
  FDCE \cycle_counter_reg[25]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[25]_LDC_i_2_n_0 ),
        .D(p_2_in[25]),
        .Q(\cycle_counter_reg[25]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[25]_LDC 
       (.CLR(\cycle_counter_reg[25]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[25]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[25]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[25]_LDC_i_1 
       (.I0(minusOp0_in[25]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[25]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[25]_LDC_i_2 
       (.I0(minusOp0_in[25]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[25]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[25]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[25]),
        .PRE(\cycle_counter_reg[25]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[25]_P_n_0 ));
  FDCE \cycle_counter_reg[26]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[26]_LDC_i_2_n_0 ),
        .D(p_2_in[26]),
        .Q(\cycle_counter_reg[26]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[26]_LDC 
       (.CLR(\cycle_counter_reg[26]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[26]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[26]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[26]_LDC_i_1 
       (.I0(minusOp0_in[26]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[26]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[26]_LDC_i_2 
       (.I0(minusOp0_in[26]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[26]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[26]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[26]),
        .PRE(\cycle_counter_reg[26]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[26]_P_n_0 ));
  FDCE \cycle_counter_reg[2]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[2]_LDC_i_2_n_0 ),
        .D(p_2_in[2]),
        .Q(\cycle_counter_reg[2]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[2]_LDC 
       (.CLR(\cycle_counter_reg[2]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[2]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[2]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[2]_LDC_i_1 
       (.I0(minusOp0_in[2]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[2]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[2]_LDC_i_2 
       (.I0(minusOp0_in[2]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[2]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[2]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[2]),
        .PRE(\cycle_counter_reg[2]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[2]_P_n_0 ));
  FDCE \cycle_counter_reg[3]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[3]_LDC_i_2_n_0 ),
        .D(p_2_in[3]),
        .Q(\cycle_counter_reg[3]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[3]_LDC 
       (.CLR(\cycle_counter_reg[3]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[3]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[3]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[3]_LDC_i_1 
       (.I0(minusOp0_in[3]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[3]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[3]_LDC_i_2 
       (.I0(minusOp0_in[3]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[3]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[3]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[3]),
        .PRE(\cycle_counter_reg[3]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[3]_P_n_0 ));
  FDCE \cycle_counter_reg[4]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[4]_LDC_i_2_n_0 ),
        .D(p_2_in[4]),
        .Q(\cycle_counter_reg[4]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[4]_LDC 
       (.CLR(\cycle_counter_reg[4]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[4]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[4]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[4]_LDC_i_1 
       (.I0(minusOp0_in[4]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[4]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[4]_LDC_i_2 
       (.I0(minusOp0_in[4]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[4]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[4]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[4]),
        .PRE(\cycle_counter_reg[4]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[4]_P_n_0 ));
  FDCE \cycle_counter_reg[5]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[5]_LDC_i_2_n_0 ),
        .D(p_2_in[5]),
        .Q(\cycle_counter_reg[5]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[5]_LDC 
       (.CLR(\cycle_counter_reg[5]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[5]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[5]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[5]_LDC_i_1 
       (.I0(minusOp0_in[5]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[5]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[5]_LDC_i_2 
       (.I0(minusOp0_in[5]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[5]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[5]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[5]),
        .PRE(\cycle_counter_reg[5]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[5]_P_n_0 ));
  FDCE \cycle_counter_reg[6]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[6]_LDC_i_2_n_0 ),
        .D(p_2_in[6]),
        .Q(\cycle_counter_reg[6]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[6]_LDC 
       (.CLR(\cycle_counter_reg[6]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[6]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[6]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[6]_LDC_i_1 
       (.I0(minusOp0_in[6]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[6]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[6]_LDC_i_2 
       (.I0(minusOp0_in[6]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[6]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[6]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[6]),
        .PRE(\cycle_counter_reg[6]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[6]_P_n_0 ));
  FDCE \cycle_counter_reg[7]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[7]_LDC_i_2_n_0 ),
        .D(p_2_in[7]),
        .Q(\cycle_counter_reg[7]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[7]_LDC 
       (.CLR(\cycle_counter_reg[7]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[7]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[7]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[7]_LDC_i_1 
       (.I0(minusOp0_in[7]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[7]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[7]_LDC_i_2 
       (.I0(minusOp0_in[7]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[7]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[7]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[7]),
        .PRE(\cycle_counter_reg[7]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[7]_P_n_0 ));
  FDCE \cycle_counter_reg[8]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[8]_LDC_i_2_n_0 ),
        .D(p_2_in[8]),
        .Q(\cycle_counter_reg[8]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[8]_LDC 
       (.CLR(\cycle_counter_reg[8]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[8]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[8]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[8]_LDC_i_1 
       (.I0(minusOp0_in[8]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[8]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[8]_LDC_i_2 
       (.I0(minusOp0_in[8]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[8]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[8]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[8]),
        .PRE(\cycle_counter_reg[8]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[8]_P_n_0 ));
  FDCE \cycle_counter_reg[9]_C 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(\cycle_counter_reg[9]_LDC_i_2_n_0 ),
        .D(p_2_in[9]),
        .Q(\cycle_counter_reg[9]_C_n_0 ));
  (* XILINX_LEGACY_PRIM = "LDC" *) 
  (* XILINX_TRANSFORM_PINMAP = "VCC:GE" *) 
  LDCE #(
    .INIT(1'b0)) 
    \cycle_counter_reg[9]_LDC 
       (.CLR(\cycle_counter_reg[9]_LDC_i_2_n_0 ),
        .D(1'b1),
        .G(\cycle_counter_reg[9]_LDC_i_1_n_0 ),
        .GE(1'b1),
        .Q(\cycle_counter_reg[9]_LDC_n_0 ));
  LUT2 #(
    .INIT(4'h2)) 
    \cycle_counter_reg[9]_LDC_i_1 
       (.I0(minusOp0_in[9]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[9]_LDC_i_1_n_0 ));
  LUT2 #(
    .INIT(4'h1)) 
    \cycle_counter_reg[9]_LDC_i_2 
       (.I0(minusOp0_in[9]),
        .I1(axis_aresetn),
        .O(\cycle_counter_reg[9]_LDC_i_2_n_0 ));
  FDPE \cycle_counter_reg[9]_P 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(p_2_in[9]),
        .PRE(\cycle_counter_reg[9]_LDC_i_1_n_0 ),
        .Q(\cycle_counter_reg[9]_P_n_0 ));
  CARRY4 eqOp__8_carry
       (.CI(1'b0),
        .CO({eqOp__8_carry_n_0,eqOp__8_carry_n_1,eqOp__8_carry_n_2,eqOp__8_carry_n_3}),
        .CYINIT(1'b1),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eqOp__8_carry_O_UNCONNECTED[3:0]),
        .S({eqOp__8_carry_i_1_n_0,eqOp__8_carry_i_2_n_0,eqOp__8_carry_i_3_n_0,eqOp__8_carry_i_4_n_0}));
  CARRY4 eqOp__8_carry__0
       (.CI(eqOp__8_carry_n_0),
        .CO({eqOp__8_carry__0_n_0,eqOp__8_carry__0_n_1,eqOp__8_carry__0_n_2,eqOp__8_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eqOp__8_carry__0_O_UNCONNECTED[3:0]),
        .S({eqOp__8_carry__0_i_1_n_0,eqOp__8_carry__0_i_2_n_0,eqOp__8_carry__0_i_3_n_0,eqOp__8_carry__0_i_4_n_0}));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__8_carry__0_i_1
       (.I0(cycle_counter[21]),
        .I1(minusOp[21]),
        .I2(minusOp[23]),
        .I3(cycle_counter[23]),
        .I4(minusOp[22]),
        .I5(cycle_counter[22]),
        .O(eqOp__8_carry__0_i_1_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__8_carry__0_i_2
       (.I0(cycle_counter[18]),
        .I1(minusOp[18]),
        .I2(minusOp[20]),
        .I3(cycle_counter[20]),
        .I4(minusOp[19]),
        .I5(cycle_counter[19]),
        .O(eqOp__8_carry__0_i_2_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__8_carry__0_i_3
       (.I0(cycle_counter[15]),
        .I1(minusOp[15]),
        .I2(minusOp[17]),
        .I3(cycle_counter[17]),
        .I4(minusOp[16]),
        .I5(cycle_counter[16]),
        .O(eqOp__8_carry__0_i_3_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__8_carry__0_i_4
       (.I0(cycle_counter[12]),
        .I1(minusOp[12]),
        .I2(minusOp[14]),
        .I3(cycle_counter[14]),
        .I4(minusOp[13]),
        .I5(cycle_counter[13]),
        .O(eqOp__8_carry__0_i_4_n_0));
  CARRY4 eqOp__8_carry__1
       (.CI(eqOp__8_carry__0_n_0),
        .CO({NLW_eqOp__8_carry__1_CO_UNCONNECTED[3:1],eqOp}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eqOp__8_carry__1_O_UNCONNECTED[3:0]),
        .S({1'b0,1'b0,1'b0,eqOp__8_carry__1_i_1_n_0}));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__8_carry__1_i_1
       (.I0(cycle_counter[24]),
        .I1(minusOp[24]),
        .I2(minusOp[26]),
        .I3(cycle_counter[26]),
        .I4(minusOp[25]),
        .I5(cycle_counter[25]),
        .O(eqOp__8_carry__1_i_1_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__8_carry_i_1
       (.I0(cycle_counter[9]),
        .I1(minusOp[9]),
        .I2(minusOp[11]),
        .I3(cycle_counter[11]),
        .I4(minusOp[10]),
        .I5(cycle_counter[10]),
        .O(eqOp__8_carry_i_1_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__8_carry_i_2
       (.I0(cycle_counter[6]),
        .I1(minusOp[6]),
        .I2(minusOp[8]),
        .I3(cycle_counter[8]),
        .I4(minusOp[7]),
        .I5(cycle_counter[7]),
        .O(eqOp__8_carry_i_2_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__8_carry_i_3
       (.I0(cycle_counter[3]),
        .I1(minusOp[3]),
        .I2(minusOp[5]),
        .I3(cycle_counter[5]),
        .I4(minusOp[4]),
        .I5(cycle_counter[4]),
        .O(eqOp__8_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__8_carry_i_4
       (.I0(cycle_counter[0]),
        .I1(minusOp[0]),
        .I2(minusOp[2]),
        .I3(cycle_counter[2]),
        .I4(minusOp[1]),
        .I5(cycle_counter[1]),
        .O(eqOp__8_carry_i_4_n_0));
  CARRY4 eqOp_carry
       (.CI(1'b0),
        .CO({eqOp_carry_n_0,eqOp_carry_n_1,eqOp_carry_n_2,eqOp_carry_n_3}),
        .CYINIT(1'b1),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eqOp_carry_O_UNCONNECTED[3:0]),
        .S({eqOp_carry_i_1_n_0,eqOp_carry_i_2_n_0,eqOp_carry_i_3_n_0,eqOp_carry_i_4_n_0}));
  CARRY4 eqOp_carry__0
       (.CI(eqOp_carry_n_0),
        .CO({eqOp_carry__0_n_0,eqOp_carry__0_n_1,eqOp_carry__0_n_2,eqOp_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eqOp_carry__0_O_UNCONNECTED[3:0]),
        .S({eqOp_carry__0_i_1_n_0,eqOp_carry__0_i_2_n_0,eqOp_carry__0_i_3_n_0,eqOp_carry__0_i_4_n_0}));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry__0_i_1
       (.I0(cycle_counter[21]),
        .I1(minusOp0_in[21]),
        .I2(minusOp0_in[23]),
        .I3(cycle_counter[23]),
        .I4(minusOp0_in[22]),
        .I5(cycle_counter[22]),
        .O(eqOp_carry__0_i_1_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_10
       (.I0(\cycle_counter_reg[19]_P_n_0 ),
        .I1(\cycle_counter_reg[19]_LDC_n_0 ),
        .I2(\cycle_counter_reg[19]_C_n_0 ),
        .O(cycle_counter[19]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_11
       (.I0(\cycle_counter_reg[15]_P_n_0 ),
        .I1(\cycle_counter_reg[15]_LDC_n_0 ),
        .I2(\cycle_counter_reg[15]_C_n_0 ),
        .O(cycle_counter[15]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_12
       (.I0(\cycle_counter_reg[17]_P_n_0 ),
        .I1(\cycle_counter_reg[17]_LDC_n_0 ),
        .I2(\cycle_counter_reg[17]_C_n_0 ),
        .O(cycle_counter[17]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_13
       (.I0(\cycle_counter_reg[16]_P_n_0 ),
        .I1(\cycle_counter_reg[16]_LDC_n_0 ),
        .I2(\cycle_counter_reg[16]_C_n_0 ),
        .O(cycle_counter[16]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_14
       (.I0(\cycle_counter_reg[12]_P_n_0 ),
        .I1(\cycle_counter_reg[12]_LDC_n_0 ),
        .I2(\cycle_counter_reg[12]_C_n_0 ),
        .O(cycle_counter[12]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_15
       (.I0(\cycle_counter_reg[14]_P_n_0 ),
        .I1(\cycle_counter_reg[14]_LDC_n_0 ),
        .I2(\cycle_counter_reg[14]_C_n_0 ),
        .O(cycle_counter[14]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_16
       (.I0(\cycle_counter_reg[13]_P_n_0 ),
        .I1(\cycle_counter_reg[13]_LDC_n_0 ),
        .I2(\cycle_counter_reg[13]_C_n_0 ),
        .O(cycle_counter[13]));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry__0_i_2
       (.I0(cycle_counter[18]),
        .I1(minusOp0_in[18]),
        .I2(minusOp0_in[20]),
        .I3(cycle_counter[20]),
        .I4(minusOp0_in[19]),
        .I5(cycle_counter[19]),
        .O(eqOp_carry__0_i_2_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry__0_i_3
       (.I0(cycle_counter[15]),
        .I1(minusOp0_in[15]),
        .I2(minusOp0_in[17]),
        .I3(cycle_counter[17]),
        .I4(minusOp0_in[16]),
        .I5(cycle_counter[16]),
        .O(eqOp_carry__0_i_3_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry__0_i_4
       (.I0(cycle_counter[12]),
        .I1(minusOp0_in[12]),
        .I2(minusOp0_in[14]),
        .I3(cycle_counter[14]),
        .I4(minusOp0_in[13]),
        .I5(cycle_counter[13]),
        .O(eqOp_carry__0_i_4_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_5
       (.I0(\cycle_counter_reg[21]_P_n_0 ),
        .I1(\cycle_counter_reg[21]_LDC_n_0 ),
        .I2(\cycle_counter_reg[21]_C_n_0 ),
        .O(cycle_counter[21]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_6
       (.I0(\cycle_counter_reg[23]_P_n_0 ),
        .I1(\cycle_counter_reg[23]_LDC_n_0 ),
        .I2(\cycle_counter_reg[23]_C_n_0 ),
        .O(cycle_counter[23]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_7
       (.I0(\cycle_counter_reg[22]_P_n_0 ),
        .I1(\cycle_counter_reg[22]_LDC_n_0 ),
        .I2(\cycle_counter_reg[22]_C_n_0 ),
        .O(cycle_counter[22]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_8
       (.I0(\cycle_counter_reg[18]_P_n_0 ),
        .I1(\cycle_counter_reg[18]_LDC_n_0 ),
        .I2(\cycle_counter_reg[18]_C_n_0 ),
        .O(cycle_counter[18]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__0_i_9
       (.I0(\cycle_counter_reg[20]_P_n_0 ),
        .I1(\cycle_counter_reg[20]_LDC_n_0 ),
        .I2(\cycle_counter_reg[20]_C_n_0 ),
        .O(cycle_counter[20]));
  CARRY4 eqOp_carry__1
       (.CI(eqOp_carry__0_n_0),
        .CO({NLW_eqOp_carry__1_CO_UNCONNECTED[3:1],eqOp1_out}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eqOp_carry__1_O_UNCONNECTED[3:0]),
        .S({1'b0,1'b0,1'b0,eqOp_carry__1_i_1_n_0}));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry__1_i_1
       (.I0(cycle_counter[24]),
        .I1(minusOp0_in[24]),
        .I2(minusOp0_in[26]),
        .I3(cycle_counter[26]),
        .I4(minusOp0_in[25]),
        .I5(cycle_counter[25]),
        .O(eqOp_carry__1_i_1_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__1_i_2
       (.I0(\cycle_counter_reg[24]_P_n_0 ),
        .I1(\cycle_counter_reg[24]_LDC_n_0 ),
        .I2(\cycle_counter_reg[24]_C_n_0 ),
        .O(cycle_counter[24]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__1_i_3
       (.I0(\cycle_counter_reg[26]_P_n_0 ),
        .I1(\cycle_counter_reg[26]_LDC_n_0 ),
        .I2(\cycle_counter_reg[26]_C_n_0 ),
        .O(cycle_counter[26]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry__1_i_4
       (.I0(\cycle_counter_reg[25]_P_n_0 ),
        .I1(\cycle_counter_reg[25]_LDC_n_0 ),
        .I2(\cycle_counter_reg[25]_C_n_0 ),
        .O(cycle_counter[25]));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry_i_1
       (.I0(cycle_counter[9]),
        .I1(minusOp0_in[9]),
        .I2(minusOp0_in[11]),
        .I3(cycle_counter[11]),
        .I4(minusOp0_in[10]),
        .I5(cycle_counter[10]),
        .O(eqOp_carry_i_1_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry_i_10
       (.I0(\cycle_counter_reg[7]_P_n_0 ),
        .I1(\cycle_counter_reg[7]_LDC_n_0 ),
        .I2(\cycle_counter_reg[7]_C_n_0 ),
        .O(cycle_counter[7]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry_i_11
       (.I0(\cycle_counter_reg[3]_P_n_0 ),
        .I1(\cycle_counter_reg[3]_LDC_n_0 ),
        .I2(\cycle_counter_reg[3]_C_n_0 ),
        .O(cycle_counter[3]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry_i_12
       (.I0(\cycle_counter_reg[5]_P_n_0 ),
        .I1(\cycle_counter_reg[5]_LDC_n_0 ),
        .I2(\cycle_counter_reg[5]_C_n_0 ),
        .O(cycle_counter[5]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry_i_13
       (.I0(\cycle_counter_reg[4]_P_n_0 ),
        .I1(\cycle_counter_reg[4]_LDC_n_0 ),
        .I2(\cycle_counter_reg[4]_C_n_0 ),
        .O(cycle_counter[4]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry_i_14
       (.I0(\cycle_counter_reg[2]_P_n_0 ),
        .I1(\cycle_counter_reg[2]_LDC_n_0 ),
        .I2(\cycle_counter_reg[2]_C_n_0 ),
        .O(cycle_counter[2]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry_i_15
       (.I0(\cycle_counter_reg[1]_P_n_0 ),
        .I1(\cycle_counter_reg[1]_LDC_n_0 ),
        .I2(\cycle_counter_reg[1]_C_n_0 ),
        .O(cycle_counter[1]));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry_i_2
       (.I0(cycle_counter[6]),
        .I1(minusOp0_in[6]),
        .I2(minusOp0_in[8]),
        .I3(cycle_counter[8]),
        .I4(minusOp0_in[7]),
        .I5(cycle_counter[7]),
        .O(eqOp_carry_i_2_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry_i_3
       (.I0(cycle_counter[3]),
        .I1(minusOp0_in[3]),
        .I2(minusOp0_in[5]),
        .I3(cycle_counter[5]),
        .I4(minusOp0_in[4]),
        .I5(cycle_counter[4]),
        .O(eqOp_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h6006000000006006)) 
    eqOp_carry_i_4
       (.I0(cycle_counter[0]),
        .I1(fs_cycles[0]),
        .I2(minusOp0_in[2]),
        .I3(cycle_counter[2]),
        .I4(minusOp0_in[1]),
        .I5(cycle_counter[1]),
        .O(eqOp_carry_i_4_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry_i_5
       (.I0(\cycle_counter_reg[9]_P_n_0 ),
        .I1(\cycle_counter_reg[9]_LDC_n_0 ),
        .I2(\cycle_counter_reg[9]_C_n_0 ),
        .O(cycle_counter[9]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry_i_6
       (.I0(\cycle_counter_reg[11]_P_n_0 ),
        .I1(\cycle_counter_reg[11]_LDC_n_0 ),
        .I2(\cycle_counter_reg[11]_C_n_0 ),
        .O(cycle_counter[11]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry_i_7
       (.I0(\cycle_counter_reg[10]_P_n_0 ),
        .I1(\cycle_counter_reg[10]_LDC_n_0 ),
        .I2(\cycle_counter_reg[10]_C_n_0 ),
        .O(cycle_counter[10]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry_i_8
       (.I0(\cycle_counter_reg[6]_P_n_0 ),
        .I1(\cycle_counter_reg[6]_LDC_n_0 ),
        .I2(\cycle_counter_reg[6]_C_n_0 ),
        .O(cycle_counter[6]));
  LUT3 #(
    .INIT(8'hB8)) 
    eqOp_carry_i_9
       (.I0(\cycle_counter_reg[8]_P_n_0 ),
        .I1(\cycle_counter_reg[8]_LDC_n_0 ),
        .I2(\cycle_counter_reg[8]_C_n_0 ),
        .O(cycle_counter[8]));
  LUT2 #(
    .INIT(4'h2)) 
    \in_tdata[31]_i_1 
       (.I0(axis_aresetn),
        .I1(dl_en),
        .O(\in_tdata[31]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'hA2)) 
    \in_tdata[31]_i_2 
       (.I0(axis_aresetn),
        .I1(dl_en),
        .I2(eqOp1_out),
        .O(in_tdata0));
  FDRE \in_tdata_reg[0] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[0]),
        .Q(in_tdata[0]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[10] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[10]),
        .Q(in_tdata[10]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[11] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[11]),
        .Q(in_tdata[11]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[12] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[12]),
        .Q(in_tdata[12]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[13] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[13]),
        .Q(in_tdata[13]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[14] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[14]),
        .Q(in_tdata[14]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[15] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[15]),
        .Q(in_tdata[15]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[16] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[16]),
        .Q(in_tdata[16]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[17] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[17]),
        .Q(in_tdata[17]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[18] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[18]),
        .Q(in_tdata[18]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[19] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[19]),
        .Q(in_tdata[19]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[1] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[1]),
        .Q(in_tdata[1]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[20] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[20]),
        .Q(in_tdata[20]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[21] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[21]),
        .Q(in_tdata[21]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[22] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[22]),
        .Q(in_tdata[22]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[23] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[23]),
        .Q(in_tdata[23]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[24] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[24]),
        .Q(in_tdata[24]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[25] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[25]),
        .Q(in_tdata[25]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[26] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[26]),
        .Q(in_tdata[26]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[27] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[27]),
        .Q(in_tdata[27]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[28] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[28]),
        .Q(in_tdata[28]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[29] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[29]),
        .Q(in_tdata[29]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[2] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[2]),
        .Q(in_tdata[2]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[30] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[30]),
        .Q(in_tdata[30]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[31] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[31]),
        .Q(in_tdata[31]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[3] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[3]),
        .Q(in_tdata[3]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[4] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[4]),
        .Q(in_tdata[4]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[5] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[5]),
        .Q(in_tdata[5]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[6] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[6]),
        .Q(in_tdata[6]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[7] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[7]),
        .Q(in_tdata[7]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[8] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[8]),
        .Q(in_tdata[8]),
        .R(\in_tdata[31]_i_1_n_0 ));
  FDRE \in_tdata_reg[9] 
       (.C(axis_aclk),
        .CE(in_tdata0),
        .D(s_axis_tdata[9]),
        .Q(in_tdata[9]),
        .R(\in_tdata[31]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h80FF8000)) 
    in_tlast_i_1
       (.I0(eqOp1_out),
        .I1(dl_en),
        .I2(s_axis_tlast),
        .I3(axis_aresetn),
        .I4(in_tlast),
        .O(in_tlast_i_1_n_0));
  FDRE in_tlast_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tlast_i_1_n_0),
        .Q(in_tlast),
        .R(1'b0));
  LUT5 #(
    .INIT(32'h80FF8000)) 
    in_tvalid_i_1
       (.I0(eqOp1_out),
        .I1(dl_en),
        .I2(s_axis_tvalid),
        .I3(axis_aresetn),
        .I4(in_tvalid),
        .O(in_tvalid_i_1_n_0));
  FDRE in_tvalid_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tvalid_i_1_n_0),
        .Q(in_tvalid),
        .R(1'b0));
  LUT1 #(
    .INIT(2'h1)) 
    \m_axis_tdata[31]_i_1 
       (.I0(dl_en),
        .O(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[0] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[0]),
        .Q(m_axis_tdata[0]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[10] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[10]),
        .Q(m_axis_tdata[10]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[11] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[11]),
        .Q(m_axis_tdata[11]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[12] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[12]),
        .Q(m_axis_tdata[12]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[13] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[13]),
        .Q(m_axis_tdata[13]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[14] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[14]),
        .Q(m_axis_tdata[14]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[15] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[15]),
        .Q(m_axis_tdata[15]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[16] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[16]),
        .Q(m_axis_tdata[16]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[17] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[17]),
        .Q(m_axis_tdata[17]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[18] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[18]),
        .Q(m_axis_tdata[18]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[19] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[19]),
        .Q(m_axis_tdata[19]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[1] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[1]),
        .Q(m_axis_tdata[1]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[20] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[20]),
        .Q(m_axis_tdata[20]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[21] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[21]),
        .Q(m_axis_tdata[21]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[22] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[22]),
        .Q(m_axis_tdata[22]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[23] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[23]),
        .Q(m_axis_tdata[23]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[24] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[24]),
        .Q(m_axis_tdata[24]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[25] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[25]),
        .Q(m_axis_tdata[25]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[26] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[26]),
        .Q(m_axis_tdata[26]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[27] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[27]),
        .Q(m_axis_tdata[27]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[28] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[28]),
        .Q(m_axis_tdata[28]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[29] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[29]),
        .Q(m_axis_tdata[29]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[2] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[2]),
        .Q(m_axis_tdata[2]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[30] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[30]),
        .Q(m_axis_tdata[30]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[31] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[31]),
        .Q(m_axis_tdata[31]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[3] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[3]),
        .Q(m_axis_tdata[3]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[4] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[4]),
        .Q(m_axis_tdata[4]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[5] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[5]),
        .Q(m_axis_tdata[5]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[6] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[6]),
        .Q(m_axis_tdata[6]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[7] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[7]),
        .Q(m_axis_tdata[7]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[8] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[8]),
        .Q(m_axis_tdata[8]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE \m_axis_tdata_reg[9] 
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tdata[9]),
        .Q(m_axis_tdata[9]),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE m_axis_tlast_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tlast),
        .Q(m_axis_tlast),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  FDRE m_axis_tvalid_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(in_tvalid),
        .Q(m_axis_tvalid),
        .R(\m_axis_tdata[31]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp_carry
       (.CI(1'b0),
        .CO({minusOp_carry_n_0,minusOp_carry_n_1,minusOp_carry_n_2,minusOp_carry_n_3}),
        .CYINIT(fs_cycles[0]),
        .DI(fs_cycles[4:1]),
        .O(minusOp0_in[4:1]),
        .S({minusOp_carry_i_1_n_0,minusOp_carry_i_2_n_0,minusOp_carry_i_3_n_0,minusOp_carry_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp_carry__0
       (.CI(minusOp_carry_n_0),
        .CO({minusOp_carry__0_n_0,minusOp_carry__0_n_1,minusOp_carry__0_n_2,minusOp_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[8:5]),
        .O(minusOp0_in[8:5]),
        .S({minusOp_carry__0_i_1_n_0,minusOp_carry__0_i_2_n_0,minusOp_carry__0_i_3_n_0,minusOp_carry__0_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__0_i_1
       (.I0(fs_cycles[8]),
        .O(minusOp_carry__0_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__0_i_2
       (.I0(fs_cycles[7]),
        .O(minusOp_carry__0_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__0_i_3
       (.I0(fs_cycles[6]),
        .O(minusOp_carry__0_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__0_i_4
       (.I0(fs_cycles[5]),
        .O(minusOp_carry__0_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp_carry__1
       (.CI(minusOp_carry__0_n_0),
        .CO({minusOp_carry__1_n_0,minusOp_carry__1_n_1,minusOp_carry__1_n_2,minusOp_carry__1_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[12:9]),
        .O(minusOp0_in[12:9]),
        .S({minusOp_carry__1_i_1_n_0,minusOp_carry__1_i_2_n_0,minusOp_carry__1_i_3_n_0,minusOp_carry__1_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__1_i_1
       (.I0(fs_cycles[12]),
        .O(minusOp_carry__1_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__1_i_2
       (.I0(fs_cycles[11]),
        .O(minusOp_carry__1_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__1_i_3
       (.I0(fs_cycles[10]),
        .O(minusOp_carry__1_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__1_i_4
       (.I0(fs_cycles[9]),
        .O(minusOp_carry__1_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp_carry__2
       (.CI(minusOp_carry__1_n_0),
        .CO({minusOp_carry__2_n_0,minusOp_carry__2_n_1,minusOp_carry__2_n_2,minusOp_carry__2_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[16:13]),
        .O(minusOp0_in[16:13]),
        .S({minusOp_carry__2_i_1_n_0,minusOp_carry__2_i_2_n_0,minusOp_carry__2_i_3_n_0,minusOp_carry__2_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__2_i_1
       (.I0(fs_cycles[16]),
        .O(minusOp_carry__2_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__2_i_2
       (.I0(fs_cycles[15]),
        .O(minusOp_carry__2_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__2_i_3
       (.I0(fs_cycles[14]),
        .O(minusOp_carry__2_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__2_i_4
       (.I0(fs_cycles[13]),
        .O(minusOp_carry__2_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp_carry__3
       (.CI(minusOp_carry__2_n_0),
        .CO({minusOp_carry__3_n_0,minusOp_carry__3_n_1,minusOp_carry__3_n_2,minusOp_carry__3_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[20:17]),
        .O(minusOp0_in[20:17]),
        .S({minusOp_carry__3_i_1_n_0,minusOp_carry__3_i_2_n_0,minusOp_carry__3_i_3_n_0,minusOp_carry__3_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__3_i_1
       (.I0(fs_cycles[20]),
        .O(minusOp_carry__3_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__3_i_2
       (.I0(fs_cycles[19]),
        .O(minusOp_carry__3_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__3_i_3
       (.I0(fs_cycles[18]),
        .O(minusOp_carry__3_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__3_i_4
       (.I0(fs_cycles[17]),
        .O(minusOp_carry__3_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp_carry__4
       (.CI(minusOp_carry__3_n_0),
        .CO({minusOp_carry__4_n_0,minusOp_carry__4_n_1,minusOp_carry__4_n_2,minusOp_carry__4_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[24:21]),
        .O(minusOp0_in[24:21]),
        .S({minusOp_carry__4_i_1_n_0,minusOp_carry__4_i_2_n_0,minusOp_carry__4_i_3_n_0,minusOp_carry__4_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__4_i_1
       (.I0(fs_cycles[24]),
        .O(minusOp_carry__4_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__4_i_2
       (.I0(fs_cycles[23]),
        .O(minusOp_carry__4_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__4_i_3
       (.I0(fs_cycles[22]),
        .O(minusOp_carry__4_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__4_i_4
       (.I0(fs_cycles[21]),
        .O(minusOp_carry__4_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp_carry__5
       (.CI(minusOp_carry__4_n_0),
        .CO({NLW_minusOp_carry__5_CO_UNCONNECTED[3:1],minusOp_carry__5_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,fs_cycles[25]}),
        .O({NLW_minusOp_carry__5_O_UNCONNECTED[3:2],minusOp0_in[26:25]}),
        .S({1'b0,1'b0,minusOp_carry__5_i_1_n_0,minusOp_carry__5_i_2_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__5_i_1
       (.I0(fs_cycles[26]),
        .O(minusOp_carry__5_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry__5_i_2
       (.I0(fs_cycles[25]),
        .O(minusOp_carry__5_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry_i_1
       (.I0(fs_cycles[4]),
        .O(minusOp_carry_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry_i_2
       (.I0(fs_cycles[3]),
        .O(minusOp_carry_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry_i_3
       (.I0(fs_cycles[2]),
        .O(minusOp_carry_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp_carry_i_4
       (.I0(fs_cycles[1]),
        .O(minusOp_carry_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 plusOp_carry
       (.CI(1'b0),
        .CO({plusOp_carry_n_0,plusOp_carry_n_1,plusOp_carry_n_2,plusOp_carry_n_3}),
        .CYINIT(cycle_counter[0]),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(plusOp[4:1]),
        .S({plusOp_carry_i_2_n_0,plusOp_carry_i_3_n_0,plusOp_carry_i_4_n_0,plusOp_carry_i_5_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 plusOp_carry__0
       (.CI(plusOp_carry_n_0),
        .CO({plusOp_carry__0_n_0,plusOp_carry__0_n_1,plusOp_carry__0_n_2,plusOp_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(plusOp[8:5]),
        .S({plusOp_carry__0_i_1_n_0,plusOp_carry__0_i_2_n_0,plusOp_carry__0_i_3_n_0,plusOp_carry__0_i_4_n_0}));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__0_i_1
       (.I0(\cycle_counter_reg[8]_P_n_0 ),
        .I1(\cycle_counter_reg[8]_LDC_n_0 ),
        .I2(\cycle_counter_reg[8]_C_n_0 ),
        .O(plusOp_carry__0_i_1_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__0_i_2
       (.I0(\cycle_counter_reg[7]_P_n_0 ),
        .I1(\cycle_counter_reg[7]_LDC_n_0 ),
        .I2(\cycle_counter_reg[7]_C_n_0 ),
        .O(plusOp_carry__0_i_2_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__0_i_3
       (.I0(\cycle_counter_reg[6]_P_n_0 ),
        .I1(\cycle_counter_reg[6]_LDC_n_0 ),
        .I2(\cycle_counter_reg[6]_C_n_0 ),
        .O(plusOp_carry__0_i_3_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__0_i_4
       (.I0(\cycle_counter_reg[5]_P_n_0 ),
        .I1(\cycle_counter_reg[5]_LDC_n_0 ),
        .I2(\cycle_counter_reg[5]_C_n_0 ),
        .O(plusOp_carry__0_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 plusOp_carry__1
       (.CI(plusOp_carry__0_n_0),
        .CO({plusOp_carry__1_n_0,plusOp_carry__1_n_1,plusOp_carry__1_n_2,plusOp_carry__1_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(plusOp[12:9]),
        .S({plusOp_carry__1_i_1_n_0,plusOp_carry__1_i_2_n_0,plusOp_carry__1_i_3_n_0,plusOp_carry__1_i_4_n_0}));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__1_i_1
       (.I0(\cycle_counter_reg[12]_P_n_0 ),
        .I1(\cycle_counter_reg[12]_LDC_n_0 ),
        .I2(\cycle_counter_reg[12]_C_n_0 ),
        .O(plusOp_carry__1_i_1_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__1_i_2
       (.I0(\cycle_counter_reg[11]_P_n_0 ),
        .I1(\cycle_counter_reg[11]_LDC_n_0 ),
        .I2(\cycle_counter_reg[11]_C_n_0 ),
        .O(plusOp_carry__1_i_2_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__1_i_3
       (.I0(\cycle_counter_reg[10]_P_n_0 ),
        .I1(\cycle_counter_reg[10]_LDC_n_0 ),
        .I2(\cycle_counter_reg[10]_C_n_0 ),
        .O(plusOp_carry__1_i_3_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__1_i_4
       (.I0(\cycle_counter_reg[9]_P_n_0 ),
        .I1(\cycle_counter_reg[9]_LDC_n_0 ),
        .I2(\cycle_counter_reg[9]_C_n_0 ),
        .O(plusOp_carry__1_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 plusOp_carry__2
       (.CI(plusOp_carry__1_n_0),
        .CO({plusOp_carry__2_n_0,plusOp_carry__2_n_1,plusOp_carry__2_n_2,plusOp_carry__2_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(plusOp[16:13]),
        .S({plusOp_carry__2_i_1_n_0,plusOp_carry__2_i_2_n_0,plusOp_carry__2_i_3_n_0,plusOp_carry__2_i_4_n_0}));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__2_i_1
       (.I0(\cycle_counter_reg[16]_P_n_0 ),
        .I1(\cycle_counter_reg[16]_LDC_n_0 ),
        .I2(\cycle_counter_reg[16]_C_n_0 ),
        .O(plusOp_carry__2_i_1_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__2_i_2
       (.I0(\cycle_counter_reg[15]_P_n_0 ),
        .I1(\cycle_counter_reg[15]_LDC_n_0 ),
        .I2(\cycle_counter_reg[15]_C_n_0 ),
        .O(plusOp_carry__2_i_2_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__2_i_3
       (.I0(\cycle_counter_reg[14]_P_n_0 ),
        .I1(\cycle_counter_reg[14]_LDC_n_0 ),
        .I2(\cycle_counter_reg[14]_C_n_0 ),
        .O(plusOp_carry__2_i_3_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__2_i_4
       (.I0(\cycle_counter_reg[13]_P_n_0 ),
        .I1(\cycle_counter_reg[13]_LDC_n_0 ),
        .I2(\cycle_counter_reg[13]_C_n_0 ),
        .O(plusOp_carry__2_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 plusOp_carry__3
       (.CI(plusOp_carry__2_n_0),
        .CO({plusOp_carry__3_n_0,plusOp_carry__3_n_1,plusOp_carry__3_n_2,plusOp_carry__3_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(plusOp[20:17]),
        .S({plusOp_carry__3_i_1_n_0,plusOp_carry__3_i_2_n_0,plusOp_carry__3_i_3_n_0,plusOp_carry__3_i_4_n_0}));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__3_i_1
       (.I0(\cycle_counter_reg[20]_P_n_0 ),
        .I1(\cycle_counter_reg[20]_LDC_n_0 ),
        .I2(\cycle_counter_reg[20]_C_n_0 ),
        .O(plusOp_carry__3_i_1_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__3_i_2
       (.I0(\cycle_counter_reg[19]_P_n_0 ),
        .I1(\cycle_counter_reg[19]_LDC_n_0 ),
        .I2(\cycle_counter_reg[19]_C_n_0 ),
        .O(plusOp_carry__3_i_2_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__3_i_3
       (.I0(\cycle_counter_reg[18]_P_n_0 ),
        .I1(\cycle_counter_reg[18]_LDC_n_0 ),
        .I2(\cycle_counter_reg[18]_C_n_0 ),
        .O(plusOp_carry__3_i_3_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__3_i_4
       (.I0(\cycle_counter_reg[17]_P_n_0 ),
        .I1(\cycle_counter_reg[17]_LDC_n_0 ),
        .I2(\cycle_counter_reg[17]_C_n_0 ),
        .O(plusOp_carry__3_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 plusOp_carry__4
       (.CI(plusOp_carry__3_n_0),
        .CO({plusOp_carry__4_n_0,plusOp_carry__4_n_1,plusOp_carry__4_n_2,plusOp_carry__4_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(plusOp[24:21]),
        .S({plusOp_carry__4_i_1_n_0,plusOp_carry__4_i_2_n_0,plusOp_carry__4_i_3_n_0,plusOp_carry__4_i_4_n_0}));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__4_i_1
       (.I0(\cycle_counter_reg[24]_P_n_0 ),
        .I1(\cycle_counter_reg[24]_LDC_n_0 ),
        .I2(\cycle_counter_reg[24]_C_n_0 ),
        .O(plusOp_carry__4_i_1_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__4_i_2
       (.I0(\cycle_counter_reg[23]_P_n_0 ),
        .I1(\cycle_counter_reg[23]_LDC_n_0 ),
        .I2(\cycle_counter_reg[23]_C_n_0 ),
        .O(plusOp_carry__4_i_2_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__4_i_3
       (.I0(\cycle_counter_reg[22]_P_n_0 ),
        .I1(\cycle_counter_reg[22]_LDC_n_0 ),
        .I2(\cycle_counter_reg[22]_C_n_0 ),
        .O(plusOp_carry__4_i_3_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__4_i_4
       (.I0(\cycle_counter_reg[21]_P_n_0 ),
        .I1(\cycle_counter_reg[21]_LDC_n_0 ),
        .I2(\cycle_counter_reg[21]_C_n_0 ),
        .O(plusOp_carry__4_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 plusOp_carry__5
       (.CI(plusOp_carry__4_n_0),
        .CO({NLW_plusOp_carry__5_CO_UNCONNECTED[3:1],plusOp_carry__5_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({NLW_plusOp_carry__5_O_UNCONNECTED[3:2],plusOp[26:25]}),
        .S({1'b0,1'b0,plusOp_carry__5_i_1_n_0,plusOp_carry__5_i_2_n_0}));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__5_i_1
       (.I0(\cycle_counter_reg[26]_P_n_0 ),
        .I1(\cycle_counter_reg[26]_LDC_n_0 ),
        .I2(\cycle_counter_reg[26]_C_n_0 ),
        .O(plusOp_carry__5_i_1_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry__5_i_2
       (.I0(\cycle_counter_reg[25]_P_n_0 ),
        .I1(\cycle_counter_reg[25]_LDC_n_0 ),
        .I2(\cycle_counter_reg[25]_C_n_0 ),
        .O(plusOp_carry__5_i_2_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry_i_1
       (.I0(\cycle_counter_reg[0]_P_n_0 ),
        .I1(\cycle_counter_reg[0]_LDC_n_0 ),
        .I2(\cycle_counter_reg[0]_C_n_0 ),
        .O(cycle_counter[0]));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry_i_2
       (.I0(\cycle_counter_reg[4]_P_n_0 ),
        .I1(\cycle_counter_reg[4]_LDC_n_0 ),
        .I2(\cycle_counter_reg[4]_C_n_0 ),
        .O(plusOp_carry_i_2_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry_i_3
       (.I0(\cycle_counter_reg[3]_P_n_0 ),
        .I1(\cycle_counter_reg[3]_LDC_n_0 ),
        .I2(\cycle_counter_reg[3]_C_n_0 ),
        .O(plusOp_carry_i_3_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry_i_4
       (.I0(\cycle_counter_reg[2]_P_n_0 ),
        .I1(\cycle_counter_reg[2]_LDC_n_0 ),
        .I2(\cycle_counter_reg[2]_C_n_0 ),
        .O(plusOp_carry_i_4_n_0));
  LUT3 #(
    .INIT(8'hB8)) 
    plusOp_carry_i_5
       (.I0(\cycle_counter_reg[1]_P_n_0 ),
        .I1(\cycle_counter_reg[1]_LDC_n_0 ),
        .I2(\cycle_counter_reg[1]_C_n_0 ),
        .O(plusOp_carry_i_5_n_0));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h08)) 
    w_axis_tready
       (.I0(eqOp),
        .I1(dl_en),
        .I2(eqOp1_out),
        .O(w_axis_tready__0));
  LUT1 #(
    .INIT(2'h1)) 
    w_axis_tready_i_1
       (.I0(axis_aresetn),
        .O(p_0_in));
  FDCE w_axis_tready_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(w_axis_tready__0),
        .Q(s_axis_tready));
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
