// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Sun Feb 26 20:54:37 2023
// Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ Transmit_Chain_inst_0_playback_ctrl_0_0_sim_netlist.v
// Design      : Transmit_Chain_inst_0_playback_ctrl_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "Transmit_Chain_inst_0_playback_ctrl_0_0,playback_ctrl,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "playback_ctrl,Vivado 2022.1" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
   (axis_aclk,
    axis_aresetn,
    playback_en,
    fs_cycles,
    symbols,
    nfft_scaled,
    continuous,
    BRAM_PORT_addr,
    BRAM_PORT_clk,
    BRAM_PORT_din,
    BRAM_PORT_dout,
    BRAM_PORT_en,
    BRAM_PORT_rst,
    BRAM_PORT_we,
    M_AXIS_tdata,
    M_AXIS_tvalid,
    M_AXIS_tlast,
    M_AXIS_tready);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 axis_aclk CLK" *) (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF axis_aclk:m_axis, FREQ_HZ 100000000" *) input axis_aclk;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axis_aresetn RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axis_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input axis_aresetn;
  input playback_en;
  input [26:0]fs_cycles;
  input [3:0]symbols;
  input [11:0]nfft_scaled;
  input continuous;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) output [31:0]BRAM_PORT_addr;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT CLK" *) output BRAM_PORT_clk;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT DIN" *) output [31:0]BRAM_PORT_din;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT DOUT" *) (* X_INTERFACE_PARAMETER = "MASTER_TYPE BRAM_CTRL" *) input [31:0]BRAM_PORT_dout;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT EN" *) output BRAM_PORT_en;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT RST" *) output BRAM_PORT_rst;
  (* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 BRAM_PORT WE" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME BRAM_PORT, MASTER_TYPE BRAM_CTRL, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, READ_LATENCY 1" *) output [0:0]BRAM_PORT_we;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TDATA" *) output [31:0]M_AXIS_tdata;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TVALID" *) output M_AXIS_tvalid;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TLAST" *) output M_AXIS_tlast;
  (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 M_AXIS TREADY" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME M_AXIS, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0" *) input M_AXIS_tready;

  wire \<const0> ;
  wire \<const1> ;
  wire [31:0]BRAM_PORT_addr;
  wire [31:0]BRAM_PORT_dout;
  wire [31:0]M_AXIS_tdata;
  wire M_AXIS_tlast;
  wire M_AXIS_tready;
  wire M_AXIS_tvalid;
  wire axis_aclk;
  wire axis_aresetn;
  wire continuous;
  wire [26:0]fs_cycles;
  wire [11:0]nfft_scaled;
  wire playback_en;
  wire [3:0]symbols;

  assign BRAM_PORT_clk = axis_aclk;
  assign BRAM_PORT_din[31] = \<const0> ;
  assign BRAM_PORT_din[30] = \<const0> ;
  assign BRAM_PORT_din[29] = \<const0> ;
  assign BRAM_PORT_din[28] = \<const0> ;
  assign BRAM_PORT_din[27] = \<const0> ;
  assign BRAM_PORT_din[26] = \<const0> ;
  assign BRAM_PORT_din[25] = \<const0> ;
  assign BRAM_PORT_din[24] = \<const0> ;
  assign BRAM_PORT_din[23] = \<const0> ;
  assign BRAM_PORT_din[22] = \<const0> ;
  assign BRAM_PORT_din[21] = \<const0> ;
  assign BRAM_PORT_din[20] = \<const0> ;
  assign BRAM_PORT_din[19] = \<const0> ;
  assign BRAM_PORT_din[18] = \<const0> ;
  assign BRAM_PORT_din[17] = \<const0> ;
  assign BRAM_PORT_din[16] = \<const0> ;
  assign BRAM_PORT_din[15] = \<const0> ;
  assign BRAM_PORT_din[14] = \<const0> ;
  assign BRAM_PORT_din[13] = \<const0> ;
  assign BRAM_PORT_din[12] = \<const0> ;
  assign BRAM_PORT_din[11] = \<const0> ;
  assign BRAM_PORT_din[10] = \<const0> ;
  assign BRAM_PORT_din[9] = \<const0> ;
  assign BRAM_PORT_din[8] = \<const0> ;
  assign BRAM_PORT_din[7] = \<const0> ;
  assign BRAM_PORT_din[6] = \<const0> ;
  assign BRAM_PORT_din[5] = \<const0> ;
  assign BRAM_PORT_din[4] = \<const0> ;
  assign BRAM_PORT_din[3] = \<const0> ;
  assign BRAM_PORT_din[2] = \<const0> ;
  assign BRAM_PORT_din[1] = \<const0> ;
  assign BRAM_PORT_din[0] = \<const0> ;
  assign BRAM_PORT_en = \<const1> ;
  assign BRAM_PORT_rst = \<const0> ;
  assign BRAM_PORT_we[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_playback_ctrl inst
       (.BRAM_PORT_addr(BRAM_PORT_addr),
        .BRAM_PORT_dout(BRAM_PORT_dout),
        .M_AXIS_tdata(M_AXIS_tdata),
        .M_AXIS_tlast(M_AXIS_tlast),
        .M_AXIS_tready(M_AXIS_tready),
        .M_AXIS_tvalid(M_AXIS_tvalid),
        .axis_aclk(axis_aclk),
        .axis_aresetn(axis_aresetn),
        .continuous(continuous),
        .fs_cycles(fs_cycles),
        .nfft_scaled(nfft_scaled),
        .playback_en(playback_en),
        .symbols(symbols));
endmodule

module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_playback_ctrl
   (BRAM_PORT_addr,
    M_AXIS_tdata,
    M_AXIS_tvalid,
    M_AXIS_tlast,
    M_AXIS_tready,
    BRAM_PORT_dout,
    axis_aclk,
    playback_en,
    axis_aresetn,
    symbols,
    continuous,
    nfft_scaled,
    fs_cycles);
  output [31:0]BRAM_PORT_addr;
  output [31:0]M_AXIS_tdata;
  output M_AXIS_tvalid;
  output M_AXIS_tlast;
  input M_AXIS_tready;
  input [31:0]BRAM_PORT_dout;
  input axis_aclk;
  input playback_en;
  input axis_aresetn;
  input [3:0]symbols;
  input continuous;
  input [11:0]nfft_scaled;
  input [26:0]fs_cycles;

  wire [31:0]BRAM_PORT_addr;
  wire [31:0]BRAM_PORT_dout;
  wire [31:0]M_AXIS_tdata;
  wire M_AXIS_tlast;
  wire M_AXIS_tlast_i_1_n_0;
  wire M_AXIS_tready;
  wire M_AXIS_tvalid;
  wire M_AXIS_tvalid_i_1_n_0;
  wire axis_aclk;
  wire axis_aresetn;
  wire bram_addr0;
  wire \bram_addr[11]_i_2_n_0 ;
  wire \bram_addr[11]_i_3_n_0 ;
  wire \bram_addr[11]_i_4_n_0 ;
  wire \bram_addr[11]_i_5_n_0 ;
  wire \bram_addr[15]_i_2_n_0 ;
  wire \bram_addr[15]_i_3_n_0 ;
  wire \bram_addr[15]_i_4_n_0 ;
  wire \bram_addr[15]_i_5_n_0 ;
  wire \bram_addr[19]_i_2_n_0 ;
  wire \bram_addr[19]_i_3_n_0 ;
  wire \bram_addr[19]_i_4_n_0 ;
  wire \bram_addr[19]_i_5_n_0 ;
  wire \bram_addr[23]_i_2_n_0 ;
  wire \bram_addr[23]_i_3_n_0 ;
  wire \bram_addr[23]_i_4_n_0 ;
  wire \bram_addr[23]_i_5_n_0 ;
  wire \bram_addr[27]_i_2_n_0 ;
  wire \bram_addr[27]_i_3_n_0 ;
  wire \bram_addr[27]_i_4_n_0 ;
  wire \bram_addr[27]_i_5_n_0 ;
  wire \bram_addr[31]_i_1_n_0 ;
  wire \bram_addr[31]_i_4_n_0 ;
  wire \bram_addr[31]_i_5_n_0 ;
  wire \bram_addr[31]_i_6_n_0 ;
  wire \bram_addr[31]_i_7_n_0 ;
  wire \bram_addr[31]_i_8_n_0 ;
  wire \bram_addr[31]_i_9_n_0 ;
  wire \bram_addr[3]_i_2_n_0 ;
  wire \bram_addr[3]_i_3_n_0 ;
  wire \bram_addr[3]_i_4_n_0 ;
  wire \bram_addr[7]_i_2_n_0 ;
  wire \bram_addr[7]_i_3_n_0 ;
  wire \bram_addr[7]_i_4_n_0 ;
  wire \bram_addr[7]_i_5_n_0 ;
  wire \bram_addr_reg[11]_i_1_n_0 ;
  wire \bram_addr_reg[11]_i_1_n_1 ;
  wire \bram_addr_reg[11]_i_1_n_2 ;
  wire \bram_addr_reg[11]_i_1_n_3 ;
  wire \bram_addr_reg[11]_i_1_n_4 ;
  wire \bram_addr_reg[11]_i_1_n_5 ;
  wire \bram_addr_reg[11]_i_1_n_6 ;
  wire \bram_addr_reg[11]_i_1_n_7 ;
  wire \bram_addr_reg[15]_i_1_n_0 ;
  wire \bram_addr_reg[15]_i_1_n_1 ;
  wire \bram_addr_reg[15]_i_1_n_2 ;
  wire \bram_addr_reg[15]_i_1_n_3 ;
  wire \bram_addr_reg[15]_i_1_n_4 ;
  wire \bram_addr_reg[15]_i_1_n_5 ;
  wire \bram_addr_reg[15]_i_1_n_6 ;
  wire \bram_addr_reg[15]_i_1_n_7 ;
  wire \bram_addr_reg[19]_i_1_n_0 ;
  wire \bram_addr_reg[19]_i_1_n_1 ;
  wire \bram_addr_reg[19]_i_1_n_2 ;
  wire \bram_addr_reg[19]_i_1_n_3 ;
  wire \bram_addr_reg[19]_i_1_n_4 ;
  wire \bram_addr_reg[19]_i_1_n_5 ;
  wire \bram_addr_reg[19]_i_1_n_6 ;
  wire \bram_addr_reg[19]_i_1_n_7 ;
  wire \bram_addr_reg[23]_i_1_n_0 ;
  wire \bram_addr_reg[23]_i_1_n_1 ;
  wire \bram_addr_reg[23]_i_1_n_2 ;
  wire \bram_addr_reg[23]_i_1_n_3 ;
  wire \bram_addr_reg[23]_i_1_n_4 ;
  wire \bram_addr_reg[23]_i_1_n_5 ;
  wire \bram_addr_reg[23]_i_1_n_6 ;
  wire \bram_addr_reg[23]_i_1_n_7 ;
  wire \bram_addr_reg[27]_i_1_n_0 ;
  wire \bram_addr_reg[27]_i_1_n_1 ;
  wire \bram_addr_reg[27]_i_1_n_2 ;
  wire \bram_addr_reg[27]_i_1_n_3 ;
  wire \bram_addr_reg[27]_i_1_n_4 ;
  wire \bram_addr_reg[27]_i_1_n_5 ;
  wire \bram_addr_reg[27]_i_1_n_6 ;
  wire \bram_addr_reg[27]_i_1_n_7 ;
  wire \bram_addr_reg[31]_i_3_n_1 ;
  wire \bram_addr_reg[31]_i_3_n_2 ;
  wire \bram_addr_reg[31]_i_3_n_3 ;
  wire \bram_addr_reg[31]_i_3_n_4 ;
  wire \bram_addr_reg[31]_i_3_n_5 ;
  wire \bram_addr_reg[31]_i_3_n_6 ;
  wire \bram_addr_reg[31]_i_3_n_7 ;
  wire \bram_addr_reg[3]_i_1_n_0 ;
  wire \bram_addr_reg[3]_i_1_n_1 ;
  wire \bram_addr_reg[3]_i_1_n_2 ;
  wire \bram_addr_reg[3]_i_1_n_3 ;
  wire \bram_addr_reg[3]_i_1_n_4 ;
  wire \bram_addr_reg[3]_i_1_n_5 ;
  wire \bram_addr_reg[3]_i_1_n_6 ;
  wire \bram_addr_reg[3]_i_1_n_7 ;
  wire \bram_addr_reg[7]_i_1_n_0 ;
  wire \bram_addr_reg[7]_i_1_n_1 ;
  wire \bram_addr_reg[7]_i_1_n_2 ;
  wire \bram_addr_reg[7]_i_1_n_3 ;
  wire \bram_addr_reg[7]_i_1_n_4 ;
  wire \bram_addr_reg[7]_i_1_n_5 ;
  wire \bram_addr_reg[7]_i_1_n_6 ;
  wire \bram_addr_reg[7]_i_1_n_7 ;
  wire continuous;
  wire eqOp;
  wire eqOp__3_carry__0_i_1_n_0;
  wire eqOp__3_carry__0_i_2_n_0;
  wire eqOp__3_carry__0_i_3_n_0;
  wire eqOp__3_carry__0_i_4_n_0;
  wire eqOp__3_carry__0_n_0;
  wire eqOp__3_carry__0_n_1;
  wire eqOp__3_carry__0_n_2;
  wire eqOp__3_carry__0_n_3;
  wire eqOp__3_carry__1_i_1_n_0;
  wire eqOp__3_carry_i_1_n_0;
  wire eqOp__3_carry_i_2_n_0;
  wire eqOp__3_carry_i_3_n_0;
  wire eqOp__3_carry_i_4_n_0;
  wire eqOp__3_carry_n_0;
  wire eqOp__3_carry_n_1;
  wire eqOp__3_carry_n_2;
  wire eqOp__3_carry_n_3;
  wire eqOp_carry_i_1_n_0;
  wire eqOp_carry_i_2_n_0;
  wire eqOp_carry_i_3_n_0;
  wire eqOp_carry_i_4_n_0;
  wire eqOp_carry_n_0;
  wire eqOp_carry_n_1;
  wire eqOp_carry_n_2;
  wire eqOp_carry_n_3;
  wire [26:0]fs_cycles;
  wire [11:1]minusOp;
  wire minusOp__20_carry__0_i_1_n_0;
  wire minusOp__20_carry__0_i_2_n_0;
  wire minusOp__20_carry__0_i_3_n_0;
  wire minusOp__20_carry__0_i_4_n_0;
  wire minusOp__20_carry__0_n_0;
  wire minusOp__20_carry__0_n_1;
  wire minusOp__20_carry__0_n_2;
  wire minusOp__20_carry__0_n_3;
  wire minusOp__20_carry__0_n_4;
  wire minusOp__20_carry__0_n_5;
  wire minusOp__20_carry__0_n_6;
  wire minusOp__20_carry__0_n_7;
  wire minusOp__20_carry__1_i_1_n_0;
  wire minusOp__20_carry__1_i_2_n_0;
  wire minusOp__20_carry__1_i_3_n_0;
  wire minusOp__20_carry__1_i_4_n_0;
  wire minusOp__20_carry__1_n_0;
  wire minusOp__20_carry__1_n_1;
  wire minusOp__20_carry__1_n_2;
  wire minusOp__20_carry__1_n_3;
  wire minusOp__20_carry__1_n_4;
  wire minusOp__20_carry__1_n_5;
  wire minusOp__20_carry__1_n_6;
  wire minusOp__20_carry__1_n_7;
  wire minusOp__20_carry__2_i_1_n_0;
  wire minusOp__20_carry__2_i_2_n_0;
  wire minusOp__20_carry__2_i_3_n_0;
  wire minusOp__20_carry__2_i_4_n_0;
  wire minusOp__20_carry__2_n_0;
  wire minusOp__20_carry__2_n_1;
  wire minusOp__20_carry__2_n_2;
  wire minusOp__20_carry__2_n_3;
  wire minusOp__20_carry__2_n_4;
  wire minusOp__20_carry__2_n_5;
  wire minusOp__20_carry__2_n_6;
  wire minusOp__20_carry__2_n_7;
  wire minusOp__20_carry__3_i_1_n_0;
  wire minusOp__20_carry__3_i_2_n_0;
  wire minusOp__20_carry__3_i_3_n_0;
  wire minusOp__20_carry__3_i_4_n_0;
  wire minusOp__20_carry__3_n_0;
  wire minusOp__20_carry__3_n_1;
  wire minusOp__20_carry__3_n_2;
  wire minusOp__20_carry__3_n_3;
  wire minusOp__20_carry__3_n_4;
  wire minusOp__20_carry__3_n_5;
  wire minusOp__20_carry__3_n_6;
  wire minusOp__20_carry__3_n_7;
  wire minusOp__20_carry__4_i_1_n_0;
  wire minusOp__20_carry__4_i_2_n_0;
  wire minusOp__20_carry__4_i_3_n_0;
  wire minusOp__20_carry__4_i_4_n_0;
  wire minusOp__20_carry__4_n_0;
  wire minusOp__20_carry__4_n_1;
  wire minusOp__20_carry__4_n_2;
  wire minusOp__20_carry__4_n_3;
  wire minusOp__20_carry__4_n_4;
  wire minusOp__20_carry__4_n_5;
  wire minusOp__20_carry__4_n_6;
  wire minusOp__20_carry__4_n_7;
  wire minusOp__20_carry__5_i_1_n_0;
  wire minusOp__20_carry__5_i_2_n_0;
  wire minusOp__20_carry__5_n_3;
  wire minusOp__20_carry__5_n_6;
  wire minusOp__20_carry__5_n_7;
  wire minusOp__20_carry_i_1_n_0;
  wire minusOp__20_carry_i_2_n_0;
  wire minusOp__20_carry_i_3_n_0;
  wire minusOp__20_carry_i_4_n_0;
  wire minusOp__20_carry_n_0;
  wire minusOp__20_carry_n_1;
  wire minusOp__20_carry_n_2;
  wire minusOp__20_carry_n_3;
  wire minusOp__20_carry_n_4;
  wire minusOp__20_carry_n_5;
  wire minusOp__20_carry_n_6;
  wire minusOp__20_carry_n_7;
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
  wire nfft_counter0;
  wire \nfft_counter[0]_i_1_n_0 ;
  wire \nfft_counter[0]_i_4_n_0 ;
  wire \nfft_counter[0]_i_5_n_0 ;
  wire \nfft_counter[0]_i_6_n_0 ;
  wire \nfft_counter[4]_i_2_n_0 ;
  wire \nfft_counter[4]_i_3_n_0 ;
  wire \nfft_counter[4]_i_4_n_0 ;
  wire \nfft_counter[4]_i_5_n_0 ;
  wire \nfft_counter[8]_i_2_n_0 ;
  wire \nfft_counter[8]_i_3_n_0 ;
  wire \nfft_counter[8]_i_4_n_0 ;
  wire \nfft_counter[8]_i_5_n_0 ;
  wire [11:0]nfft_counter_reg;
  wire \nfft_counter_reg[0]_i_3_n_0 ;
  wire \nfft_counter_reg[0]_i_3_n_1 ;
  wire \nfft_counter_reg[0]_i_3_n_2 ;
  wire \nfft_counter_reg[0]_i_3_n_3 ;
  wire \nfft_counter_reg[0]_i_3_n_4 ;
  wire \nfft_counter_reg[0]_i_3_n_5 ;
  wire \nfft_counter_reg[0]_i_3_n_6 ;
  wire \nfft_counter_reg[0]_i_3_n_7 ;
  wire \nfft_counter_reg[4]_i_1_n_0 ;
  wire \nfft_counter_reg[4]_i_1_n_1 ;
  wire \nfft_counter_reg[4]_i_1_n_2 ;
  wire \nfft_counter_reg[4]_i_1_n_3 ;
  wire \nfft_counter_reg[4]_i_1_n_4 ;
  wire \nfft_counter_reg[4]_i_1_n_5 ;
  wire \nfft_counter_reg[4]_i_1_n_6 ;
  wire \nfft_counter_reg[4]_i_1_n_7 ;
  wire \nfft_counter_reg[8]_i_1_n_1 ;
  wire \nfft_counter_reg[8]_i_1_n_2 ;
  wire \nfft_counter_reg[8]_i_1_n_3 ;
  wire \nfft_counter_reg[8]_i_1_n_4 ;
  wire \nfft_counter_reg[8]_i_1_n_5 ;
  wire \nfft_counter_reg[8]_i_1_n_6 ;
  wire \nfft_counter_reg[8]_i_1_n_7 ;
  wire [11:0]nfft_scaled;
  wire out_tlast;
  wire out_tlast_i_1_n_0;
  wire out_tlast_i_2_n_0;
  wire out_tvalid;
  wire out_tvalid_i_1_n_0;
  wire p_0_in;
  wire playback_en;
  wire [3:0]plusOp;
  wire quiet_counter0;
  wire \quiet_counter[0]_i_1_n_0 ;
  wire \quiet_counter[0]_i_4_n_0 ;
  wire [26:0]quiet_counter_reg;
  wire \quiet_counter_reg[0]_i_3_n_0 ;
  wire \quiet_counter_reg[0]_i_3_n_1 ;
  wire \quiet_counter_reg[0]_i_3_n_2 ;
  wire \quiet_counter_reg[0]_i_3_n_3 ;
  wire \quiet_counter_reg[0]_i_3_n_4 ;
  wire \quiet_counter_reg[0]_i_3_n_5 ;
  wire \quiet_counter_reg[0]_i_3_n_6 ;
  wire \quiet_counter_reg[0]_i_3_n_7 ;
  wire \quiet_counter_reg[12]_i_1_n_0 ;
  wire \quiet_counter_reg[12]_i_1_n_1 ;
  wire \quiet_counter_reg[12]_i_1_n_2 ;
  wire \quiet_counter_reg[12]_i_1_n_3 ;
  wire \quiet_counter_reg[12]_i_1_n_4 ;
  wire \quiet_counter_reg[12]_i_1_n_5 ;
  wire \quiet_counter_reg[12]_i_1_n_6 ;
  wire \quiet_counter_reg[12]_i_1_n_7 ;
  wire \quiet_counter_reg[16]_i_1_n_0 ;
  wire \quiet_counter_reg[16]_i_1_n_1 ;
  wire \quiet_counter_reg[16]_i_1_n_2 ;
  wire \quiet_counter_reg[16]_i_1_n_3 ;
  wire \quiet_counter_reg[16]_i_1_n_4 ;
  wire \quiet_counter_reg[16]_i_1_n_5 ;
  wire \quiet_counter_reg[16]_i_1_n_6 ;
  wire \quiet_counter_reg[16]_i_1_n_7 ;
  wire \quiet_counter_reg[20]_i_1_n_0 ;
  wire \quiet_counter_reg[20]_i_1_n_1 ;
  wire \quiet_counter_reg[20]_i_1_n_2 ;
  wire \quiet_counter_reg[20]_i_1_n_3 ;
  wire \quiet_counter_reg[20]_i_1_n_4 ;
  wire \quiet_counter_reg[20]_i_1_n_5 ;
  wire \quiet_counter_reg[20]_i_1_n_6 ;
  wire \quiet_counter_reg[20]_i_1_n_7 ;
  wire \quiet_counter_reg[24]_i_1_n_2 ;
  wire \quiet_counter_reg[24]_i_1_n_3 ;
  wire \quiet_counter_reg[24]_i_1_n_5 ;
  wire \quiet_counter_reg[24]_i_1_n_6 ;
  wire \quiet_counter_reg[24]_i_1_n_7 ;
  wire \quiet_counter_reg[4]_i_1_n_0 ;
  wire \quiet_counter_reg[4]_i_1_n_1 ;
  wire \quiet_counter_reg[4]_i_1_n_2 ;
  wire \quiet_counter_reg[4]_i_1_n_3 ;
  wire \quiet_counter_reg[4]_i_1_n_4 ;
  wire \quiet_counter_reg[4]_i_1_n_5 ;
  wire \quiet_counter_reg[4]_i_1_n_6 ;
  wire \quiet_counter_reg[4]_i_1_n_7 ;
  wire \quiet_counter_reg[8]_i_1_n_0 ;
  wire \quiet_counter_reg[8]_i_1_n_1 ;
  wire \quiet_counter_reg[8]_i_1_n_2 ;
  wire \quiet_counter_reg[8]_i_1_n_3 ;
  wire \quiet_counter_reg[8]_i_1_n_4 ;
  wire \quiet_counter_reg[8]_i_1_n_5 ;
  wire \quiet_counter_reg[8]_i_1_n_6 ;
  wire \quiet_counter_reg[8]_i_1_n_7 ;
  wire r_axis_tready;
  wire r_axis_tready_i_1_n_0;
  wire symbol_counter0;
  wire \symbol_counter[3]_i_1_n_0 ;
  wire [3:0]symbol_counter_reg;
  wire [3:0]symbols;
  wire [3:3]\NLW_bram_addr_reg[31]_i_3_CO_UNCONNECTED ;
  wire [3:0]NLW_eqOp__3_carry_O_UNCONNECTED;
  wire [3:0]NLW_eqOp__3_carry__0_O_UNCONNECTED;
  wire [3:1]NLW_eqOp__3_carry__1_CO_UNCONNECTED;
  wire [3:0]NLW_eqOp__3_carry__1_O_UNCONNECTED;
  wire [3:0]NLW_eqOp_carry_O_UNCONNECTED;
  wire [3:1]NLW_minusOp__20_carry__5_CO_UNCONNECTED;
  wire [3:2]NLW_minusOp__20_carry__5_O_UNCONNECTED;
  wire [3:2]NLW_minusOp_carry__1_CO_UNCONNECTED;
  wire [3:3]NLW_minusOp_carry__1_O_UNCONNECTED;
  wire [3:3]\NLW_nfft_counter_reg[8]_i_1_CO_UNCONNECTED ;
  wire [3:2]\NLW_quiet_counter_reg[24]_i_1_CO_UNCONNECTED ;
  wire [3:3]\NLW_quiet_counter_reg[24]_i_1_O_UNCONNECTED ;

  LUT1 #(
    .INIT(2'h1)) 
    \M_AXIS_tdata[31]_i_1 
       (.I0(axis_aresetn),
        .O(p_0_in));
  FDCE \M_AXIS_tdata_reg[0] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[0]),
        .Q(M_AXIS_tdata[0]));
  FDCE \M_AXIS_tdata_reg[10] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[10]),
        .Q(M_AXIS_tdata[10]));
  FDCE \M_AXIS_tdata_reg[11] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[11]),
        .Q(M_AXIS_tdata[11]));
  FDCE \M_AXIS_tdata_reg[12] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[12]),
        .Q(M_AXIS_tdata[12]));
  FDCE \M_AXIS_tdata_reg[13] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[13]),
        .Q(M_AXIS_tdata[13]));
  FDCE \M_AXIS_tdata_reg[14] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[14]),
        .Q(M_AXIS_tdata[14]));
  FDCE \M_AXIS_tdata_reg[15] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[15]),
        .Q(M_AXIS_tdata[15]));
  FDCE \M_AXIS_tdata_reg[16] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[16]),
        .Q(M_AXIS_tdata[16]));
  FDCE \M_AXIS_tdata_reg[17] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[17]),
        .Q(M_AXIS_tdata[17]));
  FDCE \M_AXIS_tdata_reg[18] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[18]),
        .Q(M_AXIS_tdata[18]));
  FDCE \M_AXIS_tdata_reg[19] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[19]),
        .Q(M_AXIS_tdata[19]));
  FDCE \M_AXIS_tdata_reg[1] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[1]),
        .Q(M_AXIS_tdata[1]));
  FDCE \M_AXIS_tdata_reg[20] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[20]),
        .Q(M_AXIS_tdata[20]));
  FDCE \M_AXIS_tdata_reg[21] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[21]),
        .Q(M_AXIS_tdata[21]));
  FDCE \M_AXIS_tdata_reg[22] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[22]),
        .Q(M_AXIS_tdata[22]));
  FDCE \M_AXIS_tdata_reg[23] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[23]),
        .Q(M_AXIS_tdata[23]));
  FDCE \M_AXIS_tdata_reg[24] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[24]),
        .Q(M_AXIS_tdata[24]));
  FDCE \M_AXIS_tdata_reg[25] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[25]),
        .Q(M_AXIS_tdata[25]));
  FDCE \M_AXIS_tdata_reg[26] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[26]),
        .Q(M_AXIS_tdata[26]));
  FDCE \M_AXIS_tdata_reg[27] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[27]),
        .Q(M_AXIS_tdata[27]));
  FDCE \M_AXIS_tdata_reg[28] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[28]),
        .Q(M_AXIS_tdata[28]));
  FDCE \M_AXIS_tdata_reg[29] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[29]),
        .Q(M_AXIS_tdata[29]));
  FDCE \M_AXIS_tdata_reg[2] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[2]),
        .Q(M_AXIS_tdata[2]));
  FDCE \M_AXIS_tdata_reg[30] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[30]),
        .Q(M_AXIS_tdata[30]));
  FDCE \M_AXIS_tdata_reg[31] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[31]),
        .Q(M_AXIS_tdata[31]));
  FDCE \M_AXIS_tdata_reg[3] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[3]),
        .Q(M_AXIS_tdata[3]));
  FDCE \M_AXIS_tdata_reg[4] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[4]),
        .Q(M_AXIS_tdata[4]));
  FDCE \M_AXIS_tdata_reg[5] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[5]),
        .Q(M_AXIS_tdata[5]));
  FDCE \M_AXIS_tdata_reg[6] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[6]),
        .Q(M_AXIS_tdata[6]));
  FDCE \M_AXIS_tdata_reg[7] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[7]),
        .Q(M_AXIS_tdata[7]));
  FDCE \M_AXIS_tdata_reg[8] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[8]),
        .Q(M_AXIS_tdata[8]));
  FDCE \M_AXIS_tdata_reg[9] 
       (.C(axis_aclk),
        .CE(1'b1),
        .CLR(p_0_in),
        .D(BRAM_PORT_dout[9]),
        .Q(M_AXIS_tdata[9]));
  LUT3 #(
    .INIT(8'hB8)) 
    M_AXIS_tlast_i_1
       (.I0(out_tlast),
        .I1(axis_aresetn),
        .I2(M_AXIS_tlast),
        .O(M_AXIS_tlast_i_1_n_0));
  FDRE M_AXIS_tlast_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(M_AXIS_tlast_i_1_n_0),
        .Q(M_AXIS_tlast),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    M_AXIS_tvalid_i_1
       (.I0(out_tvalid),
        .I1(axis_aresetn),
        .I2(M_AXIS_tvalid),
        .O(M_AXIS_tvalid_i_1_n_0));
  FDRE M_AXIS_tvalid_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(M_AXIS_tvalid_i_1_n_0),
        .Q(M_AXIS_tvalid),
        .R(1'b0));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[11]_i_2 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[11]),
        .O(\bram_addr[11]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[11]_i_3 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[10]),
        .O(\bram_addr[11]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[11]_i_4 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[9]),
        .O(\bram_addr[11]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[11]_i_5 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[8]),
        .O(\bram_addr[11]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[15]_i_2 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[15]),
        .O(\bram_addr[15]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[15]_i_3 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[14]),
        .O(\bram_addr[15]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[15]_i_4 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[13]),
        .O(\bram_addr[15]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[15]_i_5 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[12]),
        .O(\bram_addr[15]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[19]_i_2 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[19]),
        .O(\bram_addr[19]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[19]_i_3 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[18]),
        .O(\bram_addr[19]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[19]_i_4 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[17]),
        .O(\bram_addr[19]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[19]_i_5 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[16]),
        .O(\bram_addr[19]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[23]_i_2 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[23]),
        .O(\bram_addr[23]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[23]_i_3 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[22]),
        .O(\bram_addr[23]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[23]_i_4 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[21]),
        .O(\bram_addr[23]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[23]_i_5 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[20]),
        .O(\bram_addr[23]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[27]_i_2 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[27]),
        .O(\bram_addr[27]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[27]_i_3 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[26]),
        .O(\bram_addr[27]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[27]_i_4 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[25]),
        .O(\bram_addr[27]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[27]_i_5 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[24]),
        .O(\bram_addr[27]_i_5_n_0 ));
  LUT3 #(
    .INIT(8'hD0)) 
    \bram_addr[31]_i_1 
       (.I0(playback_en),
        .I1(\bram_addr[31]_i_4_n_0 ),
        .I2(axis_aresetn),
        .O(\bram_addr[31]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'hA808)) 
    \bram_addr[31]_i_2 
       (.I0(axis_aresetn),
        .I1(r_axis_tready),
        .I2(M_AXIS_tready),
        .I3(eqOp),
        .O(bram_addr0));
  LUT5 #(
    .INIT(32'h90090000)) 
    \bram_addr[31]_i_4 
       (.I0(symbols[3]),
        .I1(symbol_counter_reg[3]),
        .I2(symbols[2]),
        .I3(symbol_counter_reg[2]),
        .I4(\bram_addr[31]_i_9_n_0 ),
        .O(\bram_addr[31]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[31]_i_5 
       (.I0(BRAM_PORT_addr[31]),
        .I1(M_AXIS_tready),
        .O(\bram_addr[31]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[31]_i_6 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[30]),
        .O(\bram_addr[31]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[31]_i_7 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[29]),
        .O(\bram_addr[31]_i_7_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[31]_i_8 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[28]),
        .O(\bram_addr[31]_i_8_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT4 #(
    .INIT(16'h9009)) 
    \bram_addr[31]_i_9 
       (.I0(symbol_counter_reg[0]),
        .I1(symbols[0]),
        .I2(symbol_counter_reg[1]),
        .I3(symbols[1]),
        .O(\bram_addr[31]_i_9_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[3]_i_2 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[3]),
        .O(\bram_addr[3]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[3]_i_3 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[2]),
        .O(\bram_addr[3]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[3]_i_4 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[1]),
        .O(\bram_addr[3]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[7]_i_2 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[7]),
        .O(\bram_addr[7]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[7]_i_3 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[6]),
        .O(\bram_addr[7]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[7]_i_4 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[5]),
        .O(\bram_addr[7]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \bram_addr[7]_i_5 
       (.I0(M_AXIS_tready),
        .I1(BRAM_PORT_addr[4]),
        .O(\bram_addr[7]_i_5_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[0] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[3]_i_1_n_7 ),
        .Q(BRAM_PORT_addr[0]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[10] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[11]_i_1_n_5 ),
        .Q(BRAM_PORT_addr[10]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[11] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[11]_i_1_n_4 ),
        .Q(BRAM_PORT_addr[11]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \bram_addr_reg[11]_i_1 
       (.CI(\bram_addr_reg[7]_i_1_n_0 ),
        .CO({\bram_addr_reg[11]_i_1_n_0 ,\bram_addr_reg[11]_i_1_n_1 ,\bram_addr_reg[11]_i_1_n_2 ,\bram_addr_reg[11]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(BRAM_PORT_addr[11:8]),
        .O({\bram_addr_reg[11]_i_1_n_4 ,\bram_addr_reg[11]_i_1_n_5 ,\bram_addr_reg[11]_i_1_n_6 ,\bram_addr_reg[11]_i_1_n_7 }),
        .S({\bram_addr[11]_i_2_n_0 ,\bram_addr[11]_i_3_n_0 ,\bram_addr[11]_i_4_n_0 ,\bram_addr[11]_i_5_n_0 }));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[12] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[15]_i_1_n_7 ),
        .Q(BRAM_PORT_addr[12]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[13] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[15]_i_1_n_6 ),
        .Q(BRAM_PORT_addr[13]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[14] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[15]_i_1_n_5 ),
        .Q(BRAM_PORT_addr[14]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[15] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[15]_i_1_n_4 ),
        .Q(BRAM_PORT_addr[15]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \bram_addr_reg[15]_i_1 
       (.CI(\bram_addr_reg[11]_i_1_n_0 ),
        .CO({\bram_addr_reg[15]_i_1_n_0 ,\bram_addr_reg[15]_i_1_n_1 ,\bram_addr_reg[15]_i_1_n_2 ,\bram_addr_reg[15]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(BRAM_PORT_addr[15:12]),
        .O({\bram_addr_reg[15]_i_1_n_4 ,\bram_addr_reg[15]_i_1_n_5 ,\bram_addr_reg[15]_i_1_n_6 ,\bram_addr_reg[15]_i_1_n_7 }),
        .S({\bram_addr[15]_i_2_n_0 ,\bram_addr[15]_i_3_n_0 ,\bram_addr[15]_i_4_n_0 ,\bram_addr[15]_i_5_n_0 }));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[16] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[19]_i_1_n_7 ),
        .Q(BRAM_PORT_addr[16]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[17] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[19]_i_1_n_6 ),
        .Q(BRAM_PORT_addr[17]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[18] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[19]_i_1_n_5 ),
        .Q(BRAM_PORT_addr[18]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[19] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[19]_i_1_n_4 ),
        .Q(BRAM_PORT_addr[19]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \bram_addr_reg[19]_i_1 
       (.CI(\bram_addr_reg[15]_i_1_n_0 ),
        .CO({\bram_addr_reg[19]_i_1_n_0 ,\bram_addr_reg[19]_i_1_n_1 ,\bram_addr_reg[19]_i_1_n_2 ,\bram_addr_reg[19]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(BRAM_PORT_addr[19:16]),
        .O({\bram_addr_reg[19]_i_1_n_4 ,\bram_addr_reg[19]_i_1_n_5 ,\bram_addr_reg[19]_i_1_n_6 ,\bram_addr_reg[19]_i_1_n_7 }),
        .S({\bram_addr[19]_i_2_n_0 ,\bram_addr[19]_i_3_n_0 ,\bram_addr[19]_i_4_n_0 ,\bram_addr[19]_i_5_n_0 }));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[1] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[3]_i_1_n_6 ),
        .Q(BRAM_PORT_addr[1]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[20] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[23]_i_1_n_7 ),
        .Q(BRAM_PORT_addr[20]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[21] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[23]_i_1_n_6 ),
        .Q(BRAM_PORT_addr[21]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[22] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[23]_i_1_n_5 ),
        .Q(BRAM_PORT_addr[22]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[23] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[23]_i_1_n_4 ),
        .Q(BRAM_PORT_addr[23]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \bram_addr_reg[23]_i_1 
       (.CI(\bram_addr_reg[19]_i_1_n_0 ),
        .CO({\bram_addr_reg[23]_i_1_n_0 ,\bram_addr_reg[23]_i_1_n_1 ,\bram_addr_reg[23]_i_1_n_2 ,\bram_addr_reg[23]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(BRAM_PORT_addr[23:20]),
        .O({\bram_addr_reg[23]_i_1_n_4 ,\bram_addr_reg[23]_i_1_n_5 ,\bram_addr_reg[23]_i_1_n_6 ,\bram_addr_reg[23]_i_1_n_7 }),
        .S({\bram_addr[23]_i_2_n_0 ,\bram_addr[23]_i_3_n_0 ,\bram_addr[23]_i_4_n_0 ,\bram_addr[23]_i_5_n_0 }));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[24] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[27]_i_1_n_7 ),
        .Q(BRAM_PORT_addr[24]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[25] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[27]_i_1_n_6 ),
        .Q(BRAM_PORT_addr[25]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[26] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[27]_i_1_n_5 ),
        .Q(BRAM_PORT_addr[26]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[27] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[27]_i_1_n_4 ),
        .Q(BRAM_PORT_addr[27]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \bram_addr_reg[27]_i_1 
       (.CI(\bram_addr_reg[23]_i_1_n_0 ),
        .CO({\bram_addr_reg[27]_i_1_n_0 ,\bram_addr_reg[27]_i_1_n_1 ,\bram_addr_reg[27]_i_1_n_2 ,\bram_addr_reg[27]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(BRAM_PORT_addr[27:24]),
        .O({\bram_addr_reg[27]_i_1_n_4 ,\bram_addr_reg[27]_i_1_n_5 ,\bram_addr_reg[27]_i_1_n_6 ,\bram_addr_reg[27]_i_1_n_7 }),
        .S({\bram_addr[27]_i_2_n_0 ,\bram_addr[27]_i_3_n_0 ,\bram_addr[27]_i_4_n_0 ,\bram_addr[27]_i_5_n_0 }));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[28] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[31]_i_3_n_7 ),
        .Q(BRAM_PORT_addr[28]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[29] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[31]_i_3_n_6 ),
        .Q(BRAM_PORT_addr[29]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[2] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[3]_i_1_n_5 ),
        .Q(BRAM_PORT_addr[2]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[30] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[31]_i_3_n_5 ),
        .Q(BRAM_PORT_addr[30]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[31] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[31]_i_3_n_4 ),
        .Q(BRAM_PORT_addr[31]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \bram_addr_reg[31]_i_3 
       (.CI(\bram_addr_reg[27]_i_1_n_0 ),
        .CO({\NLW_bram_addr_reg[31]_i_3_CO_UNCONNECTED [3],\bram_addr_reg[31]_i_3_n_1 ,\bram_addr_reg[31]_i_3_n_2 ,\bram_addr_reg[31]_i_3_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,BRAM_PORT_addr[30:28]}),
        .O({\bram_addr_reg[31]_i_3_n_4 ,\bram_addr_reg[31]_i_3_n_5 ,\bram_addr_reg[31]_i_3_n_6 ,\bram_addr_reg[31]_i_3_n_7 }),
        .S({\bram_addr[31]_i_5_n_0 ,\bram_addr[31]_i_6_n_0 ,\bram_addr[31]_i_7_n_0 ,\bram_addr[31]_i_8_n_0 }));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[3] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[3]_i_1_n_4 ),
        .Q(BRAM_PORT_addr[3]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \bram_addr_reg[3]_i_1 
       (.CI(1'b0),
        .CO({\bram_addr_reg[3]_i_1_n_0 ,\bram_addr_reg[3]_i_1_n_1 ,\bram_addr_reg[3]_i_1_n_2 ,\bram_addr_reg[3]_i_1_n_3 }),
        .CYINIT(1'b1),
        .DI({BRAM_PORT_addr[3:1],1'b0}),
        .O({\bram_addr_reg[3]_i_1_n_4 ,\bram_addr_reg[3]_i_1_n_5 ,\bram_addr_reg[3]_i_1_n_6 ,\bram_addr_reg[3]_i_1_n_7 }),
        .S({\bram_addr[3]_i_2_n_0 ,\bram_addr[3]_i_3_n_0 ,\bram_addr[3]_i_4_n_0 ,BRAM_PORT_addr[0]}));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[4] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[7]_i_1_n_7 ),
        .Q(BRAM_PORT_addr[4]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[5] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[7]_i_1_n_6 ),
        .Q(BRAM_PORT_addr[5]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[6] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[7]_i_1_n_5 ),
        .Q(BRAM_PORT_addr[6]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[7] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[7]_i_1_n_4 ),
        .Q(BRAM_PORT_addr[7]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \bram_addr_reg[7]_i_1 
       (.CI(\bram_addr_reg[3]_i_1_n_0 ),
        .CO({\bram_addr_reg[7]_i_1_n_0 ,\bram_addr_reg[7]_i_1_n_1 ,\bram_addr_reg[7]_i_1_n_2 ,\bram_addr_reg[7]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(BRAM_PORT_addr[7:4]),
        .O({\bram_addr_reg[7]_i_1_n_4 ,\bram_addr_reg[7]_i_1_n_5 ,\bram_addr_reg[7]_i_1_n_6 ,\bram_addr_reg[7]_i_1_n_7 }),
        .S({\bram_addr[7]_i_2_n_0 ,\bram_addr[7]_i_3_n_0 ,\bram_addr[7]_i_4_n_0 ,\bram_addr[7]_i_5_n_0 }));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[8] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[11]_i_1_n_7 ),
        .Q(BRAM_PORT_addr[8]),
        .R(\bram_addr[31]_i_1_n_0 ));
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR" *) 
  (* x_interface_parameter = "MASTER_TYPE BRAM_CTRL" *) 
  FDRE \bram_addr_reg[9] 
       (.C(axis_aclk),
        .CE(bram_addr0),
        .D(\bram_addr_reg[11]_i_1_n_6 ),
        .Q(BRAM_PORT_addr[9]),
        .R(\bram_addr[31]_i_1_n_0 ));
  CARRY4 eqOp__3_carry
       (.CI(1'b0),
        .CO({eqOp__3_carry_n_0,eqOp__3_carry_n_1,eqOp__3_carry_n_2,eqOp__3_carry_n_3}),
        .CYINIT(1'b1),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eqOp__3_carry_O_UNCONNECTED[3:0]),
        .S({eqOp__3_carry_i_1_n_0,eqOp__3_carry_i_2_n_0,eqOp__3_carry_i_3_n_0,eqOp__3_carry_i_4_n_0}));
  CARRY4 eqOp__3_carry__0
       (.CI(eqOp__3_carry_n_0),
        .CO({eqOp__3_carry__0_n_0,eqOp__3_carry__0_n_1,eqOp__3_carry__0_n_2,eqOp__3_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eqOp__3_carry__0_O_UNCONNECTED[3:0]),
        .S({eqOp__3_carry__0_i_1_n_0,eqOp__3_carry__0_i_2_n_0,eqOp__3_carry__0_i_3_n_0,eqOp__3_carry__0_i_4_n_0}));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__3_carry__0_i_1
       (.I0(quiet_counter_reg[22]),
        .I1(minusOp__20_carry__4_n_6),
        .I2(quiet_counter_reg[21]),
        .I3(minusOp__20_carry__4_n_7),
        .I4(minusOp__20_carry__4_n_5),
        .I5(quiet_counter_reg[23]),
        .O(eqOp__3_carry__0_i_1_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__3_carry__0_i_2
       (.I0(quiet_counter_reg[19]),
        .I1(minusOp__20_carry__3_n_5),
        .I2(quiet_counter_reg[18]),
        .I3(minusOp__20_carry__3_n_6),
        .I4(minusOp__20_carry__3_n_4),
        .I5(quiet_counter_reg[20]),
        .O(eqOp__3_carry__0_i_2_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__3_carry__0_i_3
       (.I0(quiet_counter_reg[16]),
        .I1(minusOp__20_carry__2_n_4),
        .I2(quiet_counter_reg[15]),
        .I3(minusOp__20_carry__2_n_5),
        .I4(minusOp__20_carry__3_n_7),
        .I5(quiet_counter_reg[17]),
        .O(eqOp__3_carry__0_i_3_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__3_carry__0_i_4
       (.I0(quiet_counter_reg[13]),
        .I1(minusOp__20_carry__2_n_7),
        .I2(quiet_counter_reg[12]),
        .I3(minusOp__20_carry__1_n_4),
        .I4(minusOp__20_carry__2_n_6),
        .I5(quiet_counter_reg[14]),
        .O(eqOp__3_carry__0_i_4_n_0));
  CARRY4 eqOp__3_carry__1
       (.CI(eqOp__3_carry__0_n_0),
        .CO({NLW_eqOp__3_carry__1_CO_UNCONNECTED[3:1],eqOp}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eqOp__3_carry__1_O_UNCONNECTED[3:0]),
        .S({1'b0,1'b0,1'b0,eqOp__3_carry__1_i_1_n_0}));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__3_carry__1_i_1
       (.I0(quiet_counter_reg[25]),
        .I1(minusOp__20_carry__5_n_7),
        .I2(quiet_counter_reg[24]),
        .I3(minusOp__20_carry__4_n_4),
        .I4(minusOp__20_carry__5_n_6),
        .I5(quiet_counter_reg[26]),
        .O(eqOp__3_carry__1_i_1_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__3_carry_i_1
       (.I0(quiet_counter_reg[10]),
        .I1(minusOp__20_carry__1_n_6),
        .I2(quiet_counter_reg[9]),
        .I3(minusOp__20_carry__1_n_7),
        .I4(minusOp__20_carry__1_n_5),
        .I5(quiet_counter_reg[11]),
        .O(eqOp__3_carry_i_1_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__3_carry_i_2
       (.I0(quiet_counter_reg[7]),
        .I1(minusOp__20_carry__0_n_5),
        .I2(quiet_counter_reg[6]),
        .I3(minusOp__20_carry__0_n_6),
        .I4(minusOp__20_carry__0_n_4),
        .I5(quiet_counter_reg[8]),
        .O(eqOp__3_carry_i_2_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp__3_carry_i_3
       (.I0(quiet_counter_reg[4]),
        .I1(minusOp__20_carry_n_4),
        .I2(quiet_counter_reg[3]),
        .I3(minusOp__20_carry_n_5),
        .I4(minusOp__20_carry__0_n_7),
        .I5(quiet_counter_reg[5]),
        .O(eqOp__3_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h0990000000000990)) 
    eqOp__3_carry_i_4
       (.I0(quiet_counter_reg[1]),
        .I1(minusOp__20_carry_n_7),
        .I2(fs_cycles[0]),
        .I3(quiet_counter_reg[0]),
        .I4(minusOp__20_carry_n_6),
        .I5(quiet_counter_reg[2]),
        .O(eqOp__3_carry_i_4_n_0));
  CARRY4 eqOp_carry
       (.CI(1'b0),
        .CO({eqOp_carry_n_0,eqOp_carry_n_1,eqOp_carry_n_2,eqOp_carry_n_3}),
        .CYINIT(1'b1),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O(NLW_eqOp_carry_O_UNCONNECTED[3:0]),
        .S({eqOp_carry_i_1_n_0,eqOp_carry_i_2_n_0,eqOp_carry_i_3_n_0,eqOp_carry_i_4_n_0}));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry_i_1
       (.I0(nfft_counter_reg[10]),
        .I1(minusOp[10]),
        .I2(nfft_counter_reg[9]),
        .I3(minusOp[9]),
        .I4(nfft_counter_reg[11]),
        .I5(minusOp[11]),
        .O(eqOp_carry_i_1_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry_i_2
       (.I0(nfft_counter_reg[7]),
        .I1(minusOp[7]),
        .I2(nfft_counter_reg[6]),
        .I3(minusOp[6]),
        .I4(minusOp[8]),
        .I5(nfft_counter_reg[8]),
        .O(eqOp_carry_i_2_n_0));
  LUT6 #(
    .INIT(64'h9009000000009009)) 
    eqOp_carry_i_3
       (.I0(nfft_counter_reg[4]),
        .I1(minusOp[4]),
        .I2(nfft_counter_reg[3]),
        .I3(minusOp[3]),
        .I4(minusOp[5]),
        .I5(nfft_counter_reg[5]),
        .O(eqOp_carry_i_3_n_0));
  LUT6 #(
    .INIT(64'h0990000000000990)) 
    eqOp_carry_i_4
       (.I0(nfft_counter_reg[1]),
        .I1(minusOp[1]),
        .I2(nfft_scaled[0]),
        .I3(nfft_counter_reg[0]),
        .I4(minusOp[2]),
        .I5(nfft_counter_reg[2]),
        .O(eqOp_carry_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp__20_carry
       (.CI(1'b0),
        .CO({minusOp__20_carry_n_0,minusOp__20_carry_n_1,minusOp__20_carry_n_2,minusOp__20_carry_n_3}),
        .CYINIT(fs_cycles[0]),
        .DI(fs_cycles[4:1]),
        .O({minusOp__20_carry_n_4,minusOp__20_carry_n_5,minusOp__20_carry_n_6,minusOp__20_carry_n_7}),
        .S({minusOp__20_carry_i_1_n_0,minusOp__20_carry_i_2_n_0,minusOp__20_carry_i_3_n_0,minusOp__20_carry_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp__20_carry__0
       (.CI(minusOp__20_carry_n_0),
        .CO({minusOp__20_carry__0_n_0,minusOp__20_carry__0_n_1,minusOp__20_carry__0_n_2,minusOp__20_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[8:5]),
        .O({minusOp__20_carry__0_n_4,minusOp__20_carry__0_n_5,minusOp__20_carry__0_n_6,minusOp__20_carry__0_n_7}),
        .S({minusOp__20_carry__0_i_1_n_0,minusOp__20_carry__0_i_2_n_0,minusOp__20_carry__0_i_3_n_0,minusOp__20_carry__0_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__0_i_1
       (.I0(fs_cycles[8]),
        .O(minusOp__20_carry__0_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__0_i_2
       (.I0(fs_cycles[7]),
        .O(minusOp__20_carry__0_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__0_i_3
       (.I0(fs_cycles[6]),
        .O(minusOp__20_carry__0_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__0_i_4
       (.I0(fs_cycles[5]),
        .O(minusOp__20_carry__0_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp__20_carry__1
       (.CI(minusOp__20_carry__0_n_0),
        .CO({minusOp__20_carry__1_n_0,minusOp__20_carry__1_n_1,minusOp__20_carry__1_n_2,minusOp__20_carry__1_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[12:9]),
        .O({minusOp__20_carry__1_n_4,minusOp__20_carry__1_n_5,minusOp__20_carry__1_n_6,minusOp__20_carry__1_n_7}),
        .S({minusOp__20_carry__1_i_1_n_0,minusOp__20_carry__1_i_2_n_0,minusOp__20_carry__1_i_3_n_0,minusOp__20_carry__1_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__1_i_1
       (.I0(fs_cycles[12]),
        .O(minusOp__20_carry__1_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__1_i_2
       (.I0(fs_cycles[11]),
        .O(minusOp__20_carry__1_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__1_i_3
       (.I0(fs_cycles[10]),
        .O(minusOp__20_carry__1_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__1_i_4
       (.I0(fs_cycles[9]),
        .O(minusOp__20_carry__1_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp__20_carry__2
       (.CI(minusOp__20_carry__1_n_0),
        .CO({minusOp__20_carry__2_n_0,minusOp__20_carry__2_n_1,minusOp__20_carry__2_n_2,minusOp__20_carry__2_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[16:13]),
        .O({minusOp__20_carry__2_n_4,minusOp__20_carry__2_n_5,minusOp__20_carry__2_n_6,minusOp__20_carry__2_n_7}),
        .S({minusOp__20_carry__2_i_1_n_0,minusOp__20_carry__2_i_2_n_0,minusOp__20_carry__2_i_3_n_0,minusOp__20_carry__2_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__2_i_1
       (.I0(fs_cycles[16]),
        .O(minusOp__20_carry__2_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__2_i_2
       (.I0(fs_cycles[15]),
        .O(minusOp__20_carry__2_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__2_i_3
       (.I0(fs_cycles[14]),
        .O(minusOp__20_carry__2_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__2_i_4
       (.I0(fs_cycles[13]),
        .O(minusOp__20_carry__2_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp__20_carry__3
       (.CI(minusOp__20_carry__2_n_0),
        .CO({minusOp__20_carry__3_n_0,minusOp__20_carry__3_n_1,minusOp__20_carry__3_n_2,minusOp__20_carry__3_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[20:17]),
        .O({minusOp__20_carry__3_n_4,minusOp__20_carry__3_n_5,minusOp__20_carry__3_n_6,minusOp__20_carry__3_n_7}),
        .S({minusOp__20_carry__3_i_1_n_0,minusOp__20_carry__3_i_2_n_0,minusOp__20_carry__3_i_3_n_0,minusOp__20_carry__3_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__3_i_1
       (.I0(fs_cycles[20]),
        .O(minusOp__20_carry__3_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__3_i_2
       (.I0(fs_cycles[19]),
        .O(minusOp__20_carry__3_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__3_i_3
       (.I0(fs_cycles[18]),
        .O(minusOp__20_carry__3_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__3_i_4
       (.I0(fs_cycles[17]),
        .O(minusOp__20_carry__3_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp__20_carry__4
       (.CI(minusOp__20_carry__3_n_0),
        .CO({minusOp__20_carry__4_n_0,minusOp__20_carry__4_n_1,minusOp__20_carry__4_n_2,minusOp__20_carry__4_n_3}),
        .CYINIT(1'b0),
        .DI(fs_cycles[24:21]),
        .O({minusOp__20_carry__4_n_4,minusOp__20_carry__4_n_5,minusOp__20_carry__4_n_6,minusOp__20_carry__4_n_7}),
        .S({minusOp__20_carry__4_i_1_n_0,minusOp__20_carry__4_i_2_n_0,minusOp__20_carry__4_i_3_n_0,minusOp__20_carry__4_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__4_i_1
       (.I0(fs_cycles[24]),
        .O(minusOp__20_carry__4_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__4_i_2
       (.I0(fs_cycles[23]),
        .O(minusOp__20_carry__4_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__4_i_3
       (.I0(fs_cycles[22]),
        .O(minusOp__20_carry__4_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__4_i_4
       (.I0(fs_cycles[21]),
        .O(minusOp__20_carry__4_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 minusOp__20_carry__5
       (.CI(minusOp__20_carry__4_n_0),
        .CO({NLW_minusOp__20_carry__5_CO_UNCONNECTED[3:1],minusOp__20_carry__5_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,fs_cycles[25]}),
        .O({NLW_minusOp__20_carry__5_O_UNCONNECTED[3:2],minusOp__20_carry__5_n_6,minusOp__20_carry__5_n_7}),
        .S({1'b0,1'b0,minusOp__20_carry__5_i_1_n_0,minusOp__20_carry__5_i_2_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__5_i_1
       (.I0(fs_cycles[26]),
        .O(minusOp__20_carry__5_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry__5_i_2
       (.I0(fs_cycles[25]),
        .O(minusOp__20_carry__5_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry_i_1
       (.I0(fs_cycles[4]),
        .O(minusOp__20_carry_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry_i_2
       (.I0(fs_cycles[3]),
        .O(minusOp__20_carry_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry_i_3
       (.I0(fs_cycles[2]),
        .O(minusOp__20_carry_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    minusOp__20_carry_i_4
       (.I0(fs_cycles[1]),
        .O(minusOp__20_carry_i_4_n_0));
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
    .INIT(64'h0080FFFF00000000)) 
    \nfft_counter[0]_i_1 
       (.I0(eqOp_carry_n_0),
        .I1(M_AXIS_tready),
        .I2(eqOp),
        .I3(\bram_addr[31]_i_4_n_0 ),
        .I4(playback_en),
        .I5(axis_aresetn),
        .O(\nfft_counter[0]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h00008A80)) 
    \nfft_counter[0]_i_2 
       (.I0(axis_aresetn),
        .I1(eqOp),
        .I2(M_AXIS_tready),
        .I3(r_axis_tready),
        .I4(\bram_addr[31]_i_4_n_0 ),
        .O(nfft_counter0));
  LUT2 #(
    .INIT(4'h9)) 
    \nfft_counter[0]_i_4 
       (.I0(M_AXIS_tready),
        .I1(nfft_counter_reg[3]),
        .O(\nfft_counter[0]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \nfft_counter[0]_i_5 
       (.I0(M_AXIS_tready),
        .I1(nfft_counter_reg[2]),
        .O(\nfft_counter[0]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \nfft_counter[0]_i_6 
       (.I0(M_AXIS_tready),
        .I1(nfft_counter_reg[1]),
        .O(\nfft_counter[0]_i_6_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \nfft_counter[4]_i_2 
       (.I0(M_AXIS_tready),
        .I1(nfft_counter_reg[7]),
        .O(\nfft_counter[4]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \nfft_counter[4]_i_3 
       (.I0(M_AXIS_tready),
        .I1(nfft_counter_reg[6]),
        .O(\nfft_counter[4]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \nfft_counter[4]_i_4 
       (.I0(M_AXIS_tready),
        .I1(nfft_counter_reg[5]),
        .O(\nfft_counter[4]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \nfft_counter[4]_i_5 
       (.I0(M_AXIS_tready),
        .I1(nfft_counter_reg[4]),
        .O(\nfft_counter[4]_i_5_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \nfft_counter[8]_i_2 
       (.I0(nfft_counter_reg[11]),
        .I1(M_AXIS_tready),
        .O(\nfft_counter[8]_i_2_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \nfft_counter[8]_i_3 
       (.I0(M_AXIS_tready),
        .I1(nfft_counter_reg[10]),
        .O(\nfft_counter[8]_i_3_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \nfft_counter[8]_i_4 
       (.I0(M_AXIS_tready),
        .I1(nfft_counter_reg[9]),
        .O(\nfft_counter[8]_i_4_n_0 ));
  LUT2 #(
    .INIT(4'h9)) 
    \nfft_counter[8]_i_5 
       (.I0(M_AXIS_tready),
        .I1(nfft_counter_reg[8]),
        .O(\nfft_counter[8]_i_5_n_0 ));
  FDRE \nfft_counter_reg[0] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[0]_i_3_n_7 ),
        .Q(nfft_counter_reg[0]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \nfft_counter_reg[0]_i_3 
       (.CI(1'b0),
        .CO({\nfft_counter_reg[0]_i_3_n_0 ,\nfft_counter_reg[0]_i_3_n_1 ,\nfft_counter_reg[0]_i_3_n_2 ,\nfft_counter_reg[0]_i_3_n_3 }),
        .CYINIT(1'b1),
        .DI({nfft_counter_reg[3:1],1'b0}),
        .O({\nfft_counter_reg[0]_i_3_n_4 ,\nfft_counter_reg[0]_i_3_n_5 ,\nfft_counter_reg[0]_i_3_n_6 ,\nfft_counter_reg[0]_i_3_n_7 }),
        .S({\nfft_counter[0]_i_4_n_0 ,\nfft_counter[0]_i_5_n_0 ,\nfft_counter[0]_i_6_n_0 ,nfft_counter_reg[0]}));
  FDRE \nfft_counter_reg[10] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[8]_i_1_n_5 ),
        .Q(nfft_counter_reg[10]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  FDRE \nfft_counter_reg[11] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[8]_i_1_n_4 ),
        .Q(nfft_counter_reg[11]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  FDRE \nfft_counter_reg[1] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[0]_i_3_n_6 ),
        .Q(nfft_counter_reg[1]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  FDRE \nfft_counter_reg[2] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[0]_i_3_n_5 ),
        .Q(nfft_counter_reg[2]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  FDRE \nfft_counter_reg[3] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[0]_i_3_n_4 ),
        .Q(nfft_counter_reg[3]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  FDRE \nfft_counter_reg[4] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[4]_i_1_n_7 ),
        .Q(nfft_counter_reg[4]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \nfft_counter_reg[4]_i_1 
       (.CI(\nfft_counter_reg[0]_i_3_n_0 ),
        .CO({\nfft_counter_reg[4]_i_1_n_0 ,\nfft_counter_reg[4]_i_1_n_1 ,\nfft_counter_reg[4]_i_1_n_2 ,\nfft_counter_reg[4]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI(nfft_counter_reg[7:4]),
        .O({\nfft_counter_reg[4]_i_1_n_4 ,\nfft_counter_reg[4]_i_1_n_5 ,\nfft_counter_reg[4]_i_1_n_6 ,\nfft_counter_reg[4]_i_1_n_7 }),
        .S({\nfft_counter[4]_i_2_n_0 ,\nfft_counter[4]_i_3_n_0 ,\nfft_counter[4]_i_4_n_0 ,\nfft_counter[4]_i_5_n_0 }));
  FDRE \nfft_counter_reg[5] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[4]_i_1_n_6 ),
        .Q(nfft_counter_reg[5]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  FDRE \nfft_counter_reg[6] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[4]_i_1_n_5 ),
        .Q(nfft_counter_reg[6]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  FDRE \nfft_counter_reg[7] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[4]_i_1_n_4 ),
        .Q(nfft_counter_reg[7]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  FDRE \nfft_counter_reg[8] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[8]_i_1_n_7 ),
        .Q(nfft_counter_reg[8]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \nfft_counter_reg[8]_i_1 
       (.CI(\nfft_counter_reg[4]_i_1_n_0 ),
        .CO({\NLW_nfft_counter_reg[8]_i_1_CO_UNCONNECTED [3],\nfft_counter_reg[8]_i_1_n_1 ,\nfft_counter_reg[8]_i_1_n_2 ,\nfft_counter_reg[8]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,nfft_counter_reg[10:8]}),
        .O({\nfft_counter_reg[8]_i_1_n_4 ,\nfft_counter_reg[8]_i_1_n_5 ,\nfft_counter_reg[8]_i_1_n_6 ,\nfft_counter_reg[8]_i_1_n_7 }),
        .S({\nfft_counter[8]_i_2_n_0 ,\nfft_counter[8]_i_3_n_0 ,\nfft_counter[8]_i_4_n_0 ,\nfft_counter[8]_i_5_n_0 }));
  FDRE \nfft_counter_reg[9] 
       (.C(axis_aclk),
        .CE(nfft_counter0),
        .D(\nfft_counter_reg[8]_i_1_n_6 ),
        .Q(nfft_counter_reg[9]),
        .R(\nfft_counter[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0B03FFFF08000000)) 
    out_tlast_i_1
       (.I0(eqOp),
        .I1(M_AXIS_tready),
        .I2(out_tlast_i_2_n_0),
        .I3(eqOp_carry_n_0),
        .I4(axis_aresetn),
        .I5(out_tlast),
        .O(out_tlast_i_1_n_0));
  LUT6 #(
    .INIT(64'h82000082FFFFFFFF)) 
    out_tlast_i_2
       (.I0(\bram_addr[31]_i_9_n_0 ),
        .I1(symbol_counter_reg[2]),
        .I2(symbols[2]),
        .I3(symbol_counter_reg[3]),
        .I4(symbols[3]),
        .I5(playback_en),
        .O(out_tlast_i_2_n_0));
  FDRE out_tlast_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(out_tlast_i_1_n_0),
        .Q(out_tlast),
        .R(1'b0));
  LUT6 #(
    .INIT(64'h40FF00FF40000000)) 
    out_tvalid_i_1
       (.I0(\bram_addr[31]_i_4_n_0 ),
        .I1(playback_en),
        .I2(M_AXIS_tready),
        .I3(axis_aresetn),
        .I4(eqOp),
        .I5(out_tvalid),
        .O(out_tvalid_i_1_n_0));
  FDRE out_tvalid_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(out_tvalid_i_1_n_0),
        .Q(out_tvalid),
        .R(1'b0));
  LUT5 #(
    .INIT(32'h40FF0000)) 
    \quiet_counter[0]_i_1 
       (.I0(\bram_addr[31]_i_4_n_0 ),
        .I1(eqOp),
        .I2(M_AXIS_tready),
        .I3(playback_en),
        .I4(axis_aresetn),
        .O(\quiet_counter[0]_i_1_n_0 ));
  LUT3 #(
    .INIT(8'h08)) 
    \quiet_counter[0]_i_2 
       (.I0(axis_aresetn),
        .I1(M_AXIS_tready),
        .I2(\bram_addr[31]_i_4_n_0 ),
        .O(quiet_counter0));
  LUT1 #(
    .INIT(2'h1)) 
    \quiet_counter[0]_i_4 
       (.I0(quiet_counter_reg[0]),
        .O(\quiet_counter[0]_i_4_n_0 ));
  FDRE \quiet_counter_reg[0] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[0]_i_3_n_7 ),
        .Q(quiet_counter_reg[0]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \quiet_counter_reg[0]_i_3 
       (.CI(1'b0),
        .CO({\quiet_counter_reg[0]_i_3_n_0 ,\quiet_counter_reg[0]_i_3_n_1 ,\quiet_counter_reg[0]_i_3_n_2 ,\quiet_counter_reg[0]_i_3_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b1}),
        .O({\quiet_counter_reg[0]_i_3_n_4 ,\quiet_counter_reg[0]_i_3_n_5 ,\quiet_counter_reg[0]_i_3_n_6 ,\quiet_counter_reg[0]_i_3_n_7 }),
        .S({quiet_counter_reg[3:1],\quiet_counter[0]_i_4_n_0 }));
  FDRE \quiet_counter_reg[10] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[8]_i_1_n_5 ),
        .Q(quiet_counter_reg[10]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[11] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[8]_i_1_n_4 ),
        .Q(quiet_counter_reg[11]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[12] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[12]_i_1_n_7 ),
        .Q(quiet_counter_reg[12]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \quiet_counter_reg[12]_i_1 
       (.CI(\quiet_counter_reg[8]_i_1_n_0 ),
        .CO({\quiet_counter_reg[12]_i_1_n_0 ,\quiet_counter_reg[12]_i_1_n_1 ,\quiet_counter_reg[12]_i_1_n_2 ,\quiet_counter_reg[12]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\quiet_counter_reg[12]_i_1_n_4 ,\quiet_counter_reg[12]_i_1_n_5 ,\quiet_counter_reg[12]_i_1_n_6 ,\quiet_counter_reg[12]_i_1_n_7 }),
        .S(quiet_counter_reg[15:12]));
  FDRE \quiet_counter_reg[13] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[12]_i_1_n_6 ),
        .Q(quiet_counter_reg[13]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[14] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[12]_i_1_n_5 ),
        .Q(quiet_counter_reg[14]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[15] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[12]_i_1_n_4 ),
        .Q(quiet_counter_reg[15]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[16] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[16]_i_1_n_7 ),
        .Q(quiet_counter_reg[16]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \quiet_counter_reg[16]_i_1 
       (.CI(\quiet_counter_reg[12]_i_1_n_0 ),
        .CO({\quiet_counter_reg[16]_i_1_n_0 ,\quiet_counter_reg[16]_i_1_n_1 ,\quiet_counter_reg[16]_i_1_n_2 ,\quiet_counter_reg[16]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\quiet_counter_reg[16]_i_1_n_4 ,\quiet_counter_reg[16]_i_1_n_5 ,\quiet_counter_reg[16]_i_1_n_6 ,\quiet_counter_reg[16]_i_1_n_7 }),
        .S(quiet_counter_reg[19:16]));
  FDRE \quiet_counter_reg[17] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[16]_i_1_n_6 ),
        .Q(quiet_counter_reg[17]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[18] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[16]_i_1_n_5 ),
        .Q(quiet_counter_reg[18]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[19] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[16]_i_1_n_4 ),
        .Q(quiet_counter_reg[19]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[1] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[0]_i_3_n_6 ),
        .Q(quiet_counter_reg[1]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[20] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[20]_i_1_n_7 ),
        .Q(quiet_counter_reg[20]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \quiet_counter_reg[20]_i_1 
       (.CI(\quiet_counter_reg[16]_i_1_n_0 ),
        .CO({\quiet_counter_reg[20]_i_1_n_0 ,\quiet_counter_reg[20]_i_1_n_1 ,\quiet_counter_reg[20]_i_1_n_2 ,\quiet_counter_reg[20]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\quiet_counter_reg[20]_i_1_n_4 ,\quiet_counter_reg[20]_i_1_n_5 ,\quiet_counter_reg[20]_i_1_n_6 ,\quiet_counter_reg[20]_i_1_n_7 }),
        .S(quiet_counter_reg[23:20]));
  FDRE \quiet_counter_reg[21] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[20]_i_1_n_6 ),
        .Q(quiet_counter_reg[21]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[22] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[20]_i_1_n_5 ),
        .Q(quiet_counter_reg[22]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[23] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[20]_i_1_n_4 ),
        .Q(quiet_counter_reg[23]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[24] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[24]_i_1_n_7 ),
        .Q(quiet_counter_reg[24]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \quiet_counter_reg[24]_i_1 
       (.CI(\quiet_counter_reg[20]_i_1_n_0 ),
        .CO({\NLW_quiet_counter_reg[24]_i_1_CO_UNCONNECTED [3:2],\quiet_counter_reg[24]_i_1_n_2 ,\quiet_counter_reg[24]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\NLW_quiet_counter_reg[24]_i_1_O_UNCONNECTED [3],\quiet_counter_reg[24]_i_1_n_5 ,\quiet_counter_reg[24]_i_1_n_6 ,\quiet_counter_reg[24]_i_1_n_7 }),
        .S({1'b0,quiet_counter_reg[26:24]}));
  FDRE \quiet_counter_reg[25] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[24]_i_1_n_6 ),
        .Q(quiet_counter_reg[25]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[26] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[24]_i_1_n_5 ),
        .Q(quiet_counter_reg[26]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[2] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[0]_i_3_n_5 ),
        .Q(quiet_counter_reg[2]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[3] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[0]_i_3_n_4 ),
        .Q(quiet_counter_reg[3]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[4] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[4]_i_1_n_7 ),
        .Q(quiet_counter_reg[4]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \quiet_counter_reg[4]_i_1 
       (.CI(\quiet_counter_reg[0]_i_3_n_0 ),
        .CO({\quiet_counter_reg[4]_i_1_n_0 ,\quiet_counter_reg[4]_i_1_n_1 ,\quiet_counter_reg[4]_i_1_n_2 ,\quiet_counter_reg[4]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\quiet_counter_reg[4]_i_1_n_4 ,\quiet_counter_reg[4]_i_1_n_5 ,\quiet_counter_reg[4]_i_1_n_6 ,\quiet_counter_reg[4]_i_1_n_7 }),
        .S(quiet_counter_reg[7:4]));
  FDRE \quiet_counter_reg[5] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[4]_i_1_n_6 ),
        .Q(quiet_counter_reg[5]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[6] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[4]_i_1_n_5 ),
        .Q(quiet_counter_reg[6]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[7] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[4]_i_1_n_4 ),
        .Q(quiet_counter_reg[7]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  FDRE \quiet_counter_reg[8] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[8]_i_1_n_7 ),
        .Q(quiet_counter_reg[8]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  (* ADDER_THRESHOLD = "11" *) 
  CARRY4 \quiet_counter_reg[8]_i_1 
       (.CI(\quiet_counter_reg[4]_i_1_n_0 ),
        .CO({\quiet_counter_reg[8]_i_1_n_0 ,\quiet_counter_reg[8]_i_1_n_1 ,\quiet_counter_reg[8]_i_1_n_2 ,\quiet_counter_reg[8]_i_1_n_3 }),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,1'b0,1'b0}),
        .O({\quiet_counter_reg[8]_i_1_n_4 ,\quiet_counter_reg[8]_i_1_n_5 ,\quiet_counter_reg[8]_i_1_n_6 ,\quiet_counter_reg[8]_i_1_n_7 }),
        .S(quiet_counter_reg[11:8]));
  FDRE \quiet_counter_reg[9] 
       (.C(axis_aclk),
        .CE(quiet_counter0),
        .D(\quiet_counter_reg[8]_i_1_n_6 ),
        .Q(quiet_counter_reg[9]),
        .R(\quiet_counter[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT3 #(
    .INIT(8'hB8)) 
    r_axis_tready_i_1
       (.I0(M_AXIS_tready),
        .I1(axis_aresetn),
        .I2(r_axis_tready),
        .O(r_axis_tready_i_1_n_0));
  FDRE r_axis_tready_reg
       (.C(axis_aclk),
        .CE(1'b1),
        .D(r_axis_tready_i_1_n_0),
        .Q(r_axis_tready),
        .R(1'b0));
  LUT1 #(
    .INIT(2'h1)) 
    \symbol_counter[0]_i_1 
       (.I0(symbol_counter_reg[0]),
        .O(plusOp[0]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'h6)) 
    \symbol_counter[1]_i_1 
       (.I0(symbol_counter_reg[0]),
        .I1(symbol_counter_reg[1]),
        .O(plusOp[1]));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h78)) 
    \symbol_counter[2]_i_1 
       (.I0(symbol_counter_reg[0]),
        .I1(symbol_counter_reg[1]),
        .I2(symbol_counter_reg[2]),
        .O(plusOp[2]));
  LUT4 #(
    .INIT(16'h8F00)) 
    \symbol_counter[3]_i_1 
       (.I0(\bram_addr[31]_i_4_n_0 ),
        .I1(continuous),
        .I2(playback_en),
        .I3(axis_aresetn),
        .O(\symbol_counter[3]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h20000000)) 
    \symbol_counter[3]_i_2 
       (.I0(axis_aresetn),
        .I1(\bram_addr[31]_i_4_n_0 ),
        .I2(eqOp),
        .I3(M_AXIS_tready),
        .I4(eqOp_carry_n_0),
        .O(symbol_counter0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT4 #(
    .INIT(16'h7F80)) 
    \symbol_counter[3]_i_3 
       (.I0(symbol_counter_reg[1]),
        .I1(symbol_counter_reg[0]),
        .I2(symbol_counter_reg[2]),
        .I3(symbol_counter_reg[3]),
        .O(plusOp[3]));
  FDRE \symbol_counter_reg[0] 
       (.C(axis_aclk),
        .CE(symbol_counter0),
        .D(plusOp[0]),
        .Q(symbol_counter_reg[0]),
        .R(\symbol_counter[3]_i_1_n_0 ));
  FDRE \symbol_counter_reg[1] 
       (.C(axis_aclk),
        .CE(symbol_counter0),
        .D(plusOp[1]),
        .Q(symbol_counter_reg[1]),
        .R(\symbol_counter[3]_i_1_n_0 ));
  FDRE \symbol_counter_reg[2] 
       (.C(axis_aclk),
        .CE(symbol_counter0),
        .D(plusOp[2]),
        .Q(symbol_counter_reg[2]),
        .R(\symbol_counter[3]_i_1_n_0 ));
  FDRE \symbol_counter_reg[3] 
       (.C(axis_aclk),
        .CE(symbol_counter0),
        .D(plusOp[3]),
        .Q(symbol_counter_reg[3]),
        .R(\symbol_counter[3]_i_1_n_0 ));
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
