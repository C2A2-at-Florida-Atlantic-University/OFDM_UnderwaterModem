-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Sun Feb 26 20:54:36 2023
-- Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ Transmit_Chain_inst_0_real_time_sampler_0_0_sim_netlist.vhdl
-- Design      : Transmit_Chain_inst_0_real_time_sampler_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_real_time_sampler is
  port (
    s_axis_tready : out STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tlast : out STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    axis_aclk : in STD_LOGIC;
    dl_en : in STD_LOGIC;
    fs_cycles : in STD_LOGIC_VECTOR ( 26 downto 0 );
    axis_aresetn : in STD_LOGIC;
    minusOp : in STD_LOGIC_VECTOR ( 26 downto 0 );
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tlast : in STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 )
  );
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_real_time_sampler;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_real_time_sampler is
  signal cycle_counter : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal \cycle_counter_reg[0]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[0]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[0]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[0]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[0]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[10]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[10]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[10]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[10]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[10]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[11]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[11]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[11]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[11]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[11]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[12]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[12]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[12]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[12]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[12]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[13]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[13]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[13]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[13]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[13]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[14]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[14]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[14]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[14]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[14]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[15]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[15]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[15]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[15]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[15]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[16]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[16]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[16]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[16]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[16]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[17]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[17]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[17]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[17]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[17]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[18]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[18]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[18]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[18]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[18]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[19]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[19]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[19]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[19]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[19]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[1]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[1]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[1]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[1]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[1]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[20]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[20]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[20]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[20]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[20]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[21]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[21]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[21]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[21]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[21]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[22]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[22]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[22]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[22]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[22]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[23]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[23]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[23]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[23]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[23]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[24]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[24]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[24]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[24]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[24]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[25]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[25]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[25]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[25]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[25]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[26]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[26]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[26]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[26]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[26]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[2]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[2]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[2]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[2]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[2]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[3]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[3]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[3]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[3]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[3]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[4]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[4]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[4]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[4]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[4]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[5]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[5]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[5]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[5]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[5]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[6]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[6]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[6]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[6]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[6]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[7]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[7]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[7]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[7]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[7]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[8]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[8]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[8]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[8]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[8]_P_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[9]_C_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[9]_LDC_i_1_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[9]_LDC_i_2_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[9]_LDC_n_0\ : STD_LOGIC;
  signal \cycle_counter_reg[9]_P_n_0\ : STD_LOGIC;
  signal eqOp : STD_LOGIC;
  signal eqOp1_out : STD_LOGIC;
  signal \eqOp__8_carry__0_i_1_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_2_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_3_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_4_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_n_1\ : STD_LOGIC;
  signal \eqOp__8_carry__0_n_2\ : STD_LOGIC;
  signal \eqOp__8_carry__0_n_3\ : STD_LOGIC;
  signal \eqOp__8_carry__1_i_1_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_1_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_2_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_3_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_4_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_n_1\ : STD_LOGIC;
  signal \eqOp__8_carry_n_2\ : STD_LOGIC;
  signal \eqOp__8_carry_n_3\ : STD_LOGIC;
  signal \eqOp_carry__0_i_1_n_0\ : STD_LOGIC;
  signal \eqOp_carry__0_i_2_n_0\ : STD_LOGIC;
  signal \eqOp_carry__0_i_3_n_0\ : STD_LOGIC;
  signal \eqOp_carry__0_i_4_n_0\ : STD_LOGIC;
  signal \eqOp_carry__0_n_0\ : STD_LOGIC;
  signal \eqOp_carry__0_n_1\ : STD_LOGIC;
  signal \eqOp_carry__0_n_2\ : STD_LOGIC;
  signal \eqOp_carry__0_n_3\ : STD_LOGIC;
  signal \eqOp_carry__1_i_1_n_0\ : STD_LOGIC;
  signal eqOp_carry_i_1_n_0 : STD_LOGIC;
  signal eqOp_carry_i_2_n_0 : STD_LOGIC;
  signal eqOp_carry_i_3_n_0 : STD_LOGIC;
  signal eqOp_carry_i_4_n_0 : STD_LOGIC;
  signal eqOp_carry_n_0 : STD_LOGIC;
  signal eqOp_carry_n_1 : STD_LOGIC;
  signal eqOp_carry_n_2 : STD_LOGIC;
  signal eqOp_carry_n_3 : STD_LOGIC;
  signal in_tdata : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal in_tdata0 : STD_LOGIC;
  signal \in_tdata[31]_i_1_n_0\ : STD_LOGIC;
  signal in_tlast : STD_LOGIC;
  signal in_tlast_i_1_n_0 : STD_LOGIC;
  signal in_tvalid : STD_LOGIC;
  signal in_tvalid_i_1_n_0 : STD_LOGIC;
  signal \m_axis_tdata[31]_i_1_n_0\ : STD_LOGIC;
  signal minusOp0_in : STD_LOGIC_VECTOR ( 26 downto 1 );
  signal \minusOp_carry__0_i_1_n_0\ : STD_LOGIC;
  signal \minusOp_carry__0_i_2_n_0\ : STD_LOGIC;
  signal \minusOp_carry__0_i_3_n_0\ : STD_LOGIC;
  signal \minusOp_carry__0_i_4_n_0\ : STD_LOGIC;
  signal \minusOp_carry__0_n_0\ : STD_LOGIC;
  signal \minusOp_carry__0_n_1\ : STD_LOGIC;
  signal \minusOp_carry__0_n_2\ : STD_LOGIC;
  signal \minusOp_carry__0_n_3\ : STD_LOGIC;
  signal \minusOp_carry__1_i_1_n_0\ : STD_LOGIC;
  signal \minusOp_carry__1_i_2_n_0\ : STD_LOGIC;
  signal \minusOp_carry__1_i_3_n_0\ : STD_LOGIC;
  signal \minusOp_carry__1_i_4_n_0\ : STD_LOGIC;
  signal \minusOp_carry__1_n_0\ : STD_LOGIC;
  signal \minusOp_carry__1_n_1\ : STD_LOGIC;
  signal \minusOp_carry__1_n_2\ : STD_LOGIC;
  signal \minusOp_carry__1_n_3\ : STD_LOGIC;
  signal \minusOp_carry__2_i_1_n_0\ : STD_LOGIC;
  signal \minusOp_carry__2_i_2_n_0\ : STD_LOGIC;
  signal \minusOp_carry__2_i_3_n_0\ : STD_LOGIC;
  signal \minusOp_carry__2_i_4_n_0\ : STD_LOGIC;
  signal \minusOp_carry__2_n_0\ : STD_LOGIC;
  signal \minusOp_carry__2_n_1\ : STD_LOGIC;
  signal \minusOp_carry__2_n_2\ : STD_LOGIC;
  signal \minusOp_carry__2_n_3\ : STD_LOGIC;
  signal \minusOp_carry__3_i_1_n_0\ : STD_LOGIC;
  signal \minusOp_carry__3_i_2_n_0\ : STD_LOGIC;
  signal \minusOp_carry__3_i_3_n_0\ : STD_LOGIC;
  signal \minusOp_carry__3_i_4_n_0\ : STD_LOGIC;
  signal \minusOp_carry__3_n_0\ : STD_LOGIC;
  signal \minusOp_carry__3_n_1\ : STD_LOGIC;
  signal \minusOp_carry__3_n_2\ : STD_LOGIC;
  signal \minusOp_carry__3_n_3\ : STD_LOGIC;
  signal \minusOp_carry__4_i_1_n_0\ : STD_LOGIC;
  signal \minusOp_carry__4_i_2_n_0\ : STD_LOGIC;
  signal \minusOp_carry__4_i_3_n_0\ : STD_LOGIC;
  signal \minusOp_carry__4_i_4_n_0\ : STD_LOGIC;
  signal \minusOp_carry__4_n_0\ : STD_LOGIC;
  signal \minusOp_carry__4_n_1\ : STD_LOGIC;
  signal \minusOp_carry__4_n_2\ : STD_LOGIC;
  signal \minusOp_carry__4_n_3\ : STD_LOGIC;
  signal \minusOp_carry__5_i_1_n_0\ : STD_LOGIC;
  signal \minusOp_carry__5_i_2_n_0\ : STD_LOGIC;
  signal \minusOp_carry__5_n_3\ : STD_LOGIC;
  signal minusOp_carry_i_1_n_0 : STD_LOGIC;
  signal minusOp_carry_i_2_n_0 : STD_LOGIC;
  signal minusOp_carry_i_3_n_0 : STD_LOGIC;
  signal minusOp_carry_i_4_n_0 : STD_LOGIC;
  signal minusOp_carry_n_0 : STD_LOGIC;
  signal minusOp_carry_n_1 : STD_LOGIC;
  signal minusOp_carry_n_2 : STD_LOGIC;
  signal minusOp_carry_n_3 : STD_LOGIC;
  signal p_0_in : STD_LOGIC;
  signal p_2_in : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal plusOp : STD_LOGIC_VECTOR ( 26 downto 1 );
  signal \plusOp_carry__0_i_1_n_0\ : STD_LOGIC;
  signal \plusOp_carry__0_i_2_n_0\ : STD_LOGIC;
  signal \plusOp_carry__0_i_3_n_0\ : STD_LOGIC;
  signal \plusOp_carry__0_i_4_n_0\ : STD_LOGIC;
  signal \plusOp_carry__0_n_0\ : STD_LOGIC;
  signal \plusOp_carry__0_n_1\ : STD_LOGIC;
  signal \plusOp_carry__0_n_2\ : STD_LOGIC;
  signal \plusOp_carry__0_n_3\ : STD_LOGIC;
  signal \plusOp_carry__1_i_1_n_0\ : STD_LOGIC;
  signal \plusOp_carry__1_i_2_n_0\ : STD_LOGIC;
  signal \plusOp_carry__1_i_3_n_0\ : STD_LOGIC;
  signal \plusOp_carry__1_i_4_n_0\ : STD_LOGIC;
  signal \plusOp_carry__1_n_0\ : STD_LOGIC;
  signal \plusOp_carry__1_n_1\ : STD_LOGIC;
  signal \plusOp_carry__1_n_2\ : STD_LOGIC;
  signal \plusOp_carry__1_n_3\ : STD_LOGIC;
  signal \plusOp_carry__2_i_1_n_0\ : STD_LOGIC;
  signal \plusOp_carry__2_i_2_n_0\ : STD_LOGIC;
  signal \plusOp_carry__2_i_3_n_0\ : STD_LOGIC;
  signal \plusOp_carry__2_i_4_n_0\ : STD_LOGIC;
  signal \plusOp_carry__2_n_0\ : STD_LOGIC;
  signal \plusOp_carry__2_n_1\ : STD_LOGIC;
  signal \plusOp_carry__2_n_2\ : STD_LOGIC;
  signal \plusOp_carry__2_n_3\ : STD_LOGIC;
  signal \plusOp_carry__3_i_1_n_0\ : STD_LOGIC;
  signal \plusOp_carry__3_i_2_n_0\ : STD_LOGIC;
  signal \plusOp_carry__3_i_3_n_0\ : STD_LOGIC;
  signal \plusOp_carry__3_i_4_n_0\ : STD_LOGIC;
  signal \plusOp_carry__3_n_0\ : STD_LOGIC;
  signal \plusOp_carry__3_n_1\ : STD_LOGIC;
  signal \plusOp_carry__3_n_2\ : STD_LOGIC;
  signal \plusOp_carry__3_n_3\ : STD_LOGIC;
  signal \plusOp_carry__4_i_1_n_0\ : STD_LOGIC;
  signal \plusOp_carry__4_i_2_n_0\ : STD_LOGIC;
  signal \plusOp_carry__4_i_3_n_0\ : STD_LOGIC;
  signal \plusOp_carry__4_i_4_n_0\ : STD_LOGIC;
  signal \plusOp_carry__4_n_0\ : STD_LOGIC;
  signal \plusOp_carry__4_n_1\ : STD_LOGIC;
  signal \plusOp_carry__4_n_2\ : STD_LOGIC;
  signal \plusOp_carry__4_n_3\ : STD_LOGIC;
  signal \plusOp_carry__5_i_1_n_0\ : STD_LOGIC;
  signal \plusOp_carry__5_i_2_n_0\ : STD_LOGIC;
  signal \plusOp_carry__5_n_3\ : STD_LOGIC;
  signal plusOp_carry_i_2_n_0 : STD_LOGIC;
  signal plusOp_carry_i_3_n_0 : STD_LOGIC;
  signal plusOp_carry_i_4_n_0 : STD_LOGIC;
  signal plusOp_carry_i_5_n_0 : STD_LOGIC;
  signal plusOp_carry_n_0 : STD_LOGIC;
  signal plusOp_carry_n_1 : STD_LOGIC;
  signal plusOp_carry_n_2 : STD_LOGIC;
  signal plusOp_carry_n_3 : STD_LOGIC;
  signal \w_axis_tready__0\ : STD_LOGIC;
  signal \NLW_eqOp__8_carry_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_eqOp__8_carry__0_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_eqOp__8_carry__1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \NLW_eqOp__8_carry__1_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_eqOp_carry_O_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_eqOp_carry__0_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_eqOp_carry__1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \NLW_eqOp_carry__1_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_minusOp_carry__5_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \NLW_minusOp_carry__5_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal \NLW_plusOp_carry__5_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \NLW_plusOp_carry__5_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \cycle_counter[1]_C_i_1\ : label is "soft_lutpair0";
  attribute XILINX_LEGACY_PRIM : string;
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[0]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP : string;
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[0]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[10]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[10]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[11]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[11]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[12]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[12]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[13]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[13]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[14]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[14]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[15]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[15]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[16]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[16]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[17]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[17]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[18]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[18]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[19]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[19]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[1]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[1]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[20]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[20]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[21]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[21]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[22]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[22]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[23]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[23]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[24]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[24]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[25]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[25]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[26]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[26]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[2]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[2]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[3]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[3]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[4]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[4]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[5]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[5]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[6]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[6]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[7]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[7]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[8]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[8]_LDC\ : label is "VCC:GE";
  attribute XILINX_LEGACY_PRIM of \cycle_counter_reg[9]_LDC\ : label is "LDC";
  attribute XILINX_TRANSFORM_PINMAP of \cycle_counter_reg[9]_LDC\ : label is "VCC:GE";
  attribute ADDER_THRESHOLD : integer;
  attribute ADDER_THRESHOLD of minusOp_carry : label is 35;
  attribute ADDER_THRESHOLD of \minusOp_carry__0\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp_carry__1\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp_carry__2\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp_carry__3\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp_carry__4\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp_carry__5\ : label is 35;
  attribute ADDER_THRESHOLD of plusOp_carry : label is 35;
  attribute ADDER_THRESHOLD of \plusOp_carry__0\ : label is 35;
  attribute ADDER_THRESHOLD of \plusOp_carry__1\ : label is 35;
  attribute ADDER_THRESHOLD of \plusOp_carry__2\ : label is 35;
  attribute ADDER_THRESHOLD of \plusOp_carry__3\ : label is 35;
  attribute ADDER_THRESHOLD of \plusOp_carry__4\ : label is 35;
  attribute ADDER_THRESHOLD of \plusOp_carry__5\ : label is 35;
  attribute SOFT_HLUTNM of w_axis_tready : label is "soft_lutpair0";
begin
\cycle_counter[0]_C_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"001DFFFF001D0000"
    )
        port map (
      I0 => \cycle_counter_reg[0]_C_n_0\,
      I1 => \cycle_counter_reg[0]_LDC_n_0\,
      I2 => \cycle_counter_reg[0]_P_n_0\,
      I3 => eqOp1_out,
      I4 => dl_en,
      I5 => fs_cycles(0),
      O => p_2_in(0)
    );
\cycle_counter[10]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(10),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(10),
      O => p_2_in(10)
    );
\cycle_counter[11]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(11),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(11),
      O => p_2_in(11)
    );
\cycle_counter[12]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(12),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(12),
      O => p_2_in(12)
    );
\cycle_counter[13]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(13),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(13),
      O => p_2_in(13)
    );
\cycle_counter[14]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(14),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(14),
      O => p_2_in(14)
    );
\cycle_counter[15]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(15),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(15),
      O => p_2_in(15)
    );
\cycle_counter[16]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(16),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(16),
      O => p_2_in(16)
    );
\cycle_counter[17]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(17),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(17),
      O => p_2_in(17)
    );
\cycle_counter[18]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(18),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(18),
      O => p_2_in(18)
    );
\cycle_counter[19]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(19),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(19),
      O => p_2_in(19)
    );
\cycle_counter[1]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(1),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(1),
      O => p_2_in(1)
    );
\cycle_counter[20]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(20),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(20),
      O => p_2_in(20)
    );
\cycle_counter[21]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(21),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(21),
      O => p_2_in(21)
    );
\cycle_counter[22]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(22),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(22),
      O => p_2_in(22)
    );
\cycle_counter[23]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(23),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(23),
      O => p_2_in(23)
    );
\cycle_counter[24]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(24),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(24),
      O => p_2_in(24)
    );
\cycle_counter[25]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(25),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(25),
      O => p_2_in(25)
    );
\cycle_counter[26]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(26),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(26),
      O => p_2_in(26)
    );
\cycle_counter[2]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(2),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(2),
      O => p_2_in(2)
    );
\cycle_counter[3]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(3),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(3),
      O => p_2_in(3)
    );
\cycle_counter[4]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(4),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(4),
      O => p_2_in(4)
    );
\cycle_counter[5]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(5),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(5),
      O => p_2_in(5)
    );
\cycle_counter[6]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(6),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(6),
      O => p_2_in(6)
    );
\cycle_counter[7]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(7),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(7),
      O => p_2_in(7)
    );
\cycle_counter[8]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(8),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(8),
      O => p_2_in(8)
    );
\cycle_counter[9]_C_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"2F20"
    )
        port map (
      I0 => plusOp(9),
      I1 => eqOp1_out,
      I2 => dl_en,
      I3 => fs_cycles(9),
      O => p_2_in(9)
    );
\cycle_counter_reg[0]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[0]_LDC_i_2_n_0\,
      D => p_2_in(0),
      Q => \cycle_counter_reg[0]_C_n_0\
    );
\cycle_counter_reg[0]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[0]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[0]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[0]_LDC_n_0\
    );
\cycle_counter_reg[0]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(0),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[0]_LDC_i_1_n_0\
    );
\cycle_counter_reg[0]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => fs_cycles(0),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[0]_LDC_i_2_n_0\
    );
\cycle_counter_reg[0]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(0),
      PRE => \cycle_counter_reg[0]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[0]_P_n_0\
    );
\cycle_counter_reg[10]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[10]_LDC_i_2_n_0\,
      D => p_2_in(10),
      Q => \cycle_counter_reg[10]_C_n_0\
    );
\cycle_counter_reg[10]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[10]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[10]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[10]_LDC_n_0\
    );
\cycle_counter_reg[10]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(10),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[10]_LDC_i_1_n_0\
    );
\cycle_counter_reg[10]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(10),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[10]_LDC_i_2_n_0\
    );
\cycle_counter_reg[10]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(10),
      PRE => \cycle_counter_reg[10]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[10]_P_n_0\
    );
\cycle_counter_reg[11]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[11]_LDC_i_2_n_0\,
      D => p_2_in(11),
      Q => \cycle_counter_reg[11]_C_n_0\
    );
\cycle_counter_reg[11]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[11]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[11]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[11]_LDC_n_0\
    );
\cycle_counter_reg[11]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(11),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[11]_LDC_i_1_n_0\
    );
\cycle_counter_reg[11]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(11),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[11]_LDC_i_2_n_0\
    );
\cycle_counter_reg[11]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(11),
      PRE => \cycle_counter_reg[11]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[11]_P_n_0\
    );
\cycle_counter_reg[12]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[12]_LDC_i_2_n_0\,
      D => p_2_in(12),
      Q => \cycle_counter_reg[12]_C_n_0\
    );
\cycle_counter_reg[12]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[12]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[12]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[12]_LDC_n_0\
    );
\cycle_counter_reg[12]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(12),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[12]_LDC_i_1_n_0\
    );
\cycle_counter_reg[12]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(12),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[12]_LDC_i_2_n_0\
    );
\cycle_counter_reg[12]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(12),
      PRE => \cycle_counter_reg[12]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[12]_P_n_0\
    );
\cycle_counter_reg[13]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[13]_LDC_i_2_n_0\,
      D => p_2_in(13),
      Q => \cycle_counter_reg[13]_C_n_0\
    );
\cycle_counter_reg[13]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[13]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[13]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[13]_LDC_n_0\
    );
\cycle_counter_reg[13]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(13),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[13]_LDC_i_1_n_0\
    );
\cycle_counter_reg[13]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(13),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[13]_LDC_i_2_n_0\
    );
\cycle_counter_reg[13]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(13),
      PRE => \cycle_counter_reg[13]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[13]_P_n_0\
    );
\cycle_counter_reg[14]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[14]_LDC_i_2_n_0\,
      D => p_2_in(14),
      Q => \cycle_counter_reg[14]_C_n_0\
    );
\cycle_counter_reg[14]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[14]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[14]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[14]_LDC_n_0\
    );
\cycle_counter_reg[14]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(14),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[14]_LDC_i_1_n_0\
    );
\cycle_counter_reg[14]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(14),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[14]_LDC_i_2_n_0\
    );
\cycle_counter_reg[14]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(14),
      PRE => \cycle_counter_reg[14]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[14]_P_n_0\
    );
\cycle_counter_reg[15]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[15]_LDC_i_2_n_0\,
      D => p_2_in(15),
      Q => \cycle_counter_reg[15]_C_n_0\
    );
\cycle_counter_reg[15]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[15]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[15]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[15]_LDC_n_0\
    );
\cycle_counter_reg[15]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(15),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[15]_LDC_i_1_n_0\
    );
\cycle_counter_reg[15]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(15),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[15]_LDC_i_2_n_0\
    );
\cycle_counter_reg[15]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(15),
      PRE => \cycle_counter_reg[15]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[15]_P_n_0\
    );
\cycle_counter_reg[16]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[16]_LDC_i_2_n_0\,
      D => p_2_in(16),
      Q => \cycle_counter_reg[16]_C_n_0\
    );
\cycle_counter_reg[16]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[16]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[16]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[16]_LDC_n_0\
    );
\cycle_counter_reg[16]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(16),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[16]_LDC_i_1_n_0\
    );
\cycle_counter_reg[16]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(16),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[16]_LDC_i_2_n_0\
    );
\cycle_counter_reg[16]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(16),
      PRE => \cycle_counter_reg[16]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[16]_P_n_0\
    );
\cycle_counter_reg[17]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[17]_LDC_i_2_n_0\,
      D => p_2_in(17),
      Q => \cycle_counter_reg[17]_C_n_0\
    );
\cycle_counter_reg[17]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[17]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[17]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[17]_LDC_n_0\
    );
\cycle_counter_reg[17]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(17),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[17]_LDC_i_1_n_0\
    );
\cycle_counter_reg[17]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(17),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[17]_LDC_i_2_n_0\
    );
\cycle_counter_reg[17]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(17),
      PRE => \cycle_counter_reg[17]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[17]_P_n_0\
    );
\cycle_counter_reg[18]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[18]_LDC_i_2_n_0\,
      D => p_2_in(18),
      Q => \cycle_counter_reg[18]_C_n_0\
    );
\cycle_counter_reg[18]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[18]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[18]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[18]_LDC_n_0\
    );
\cycle_counter_reg[18]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(18),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[18]_LDC_i_1_n_0\
    );
\cycle_counter_reg[18]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(18),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[18]_LDC_i_2_n_0\
    );
\cycle_counter_reg[18]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(18),
      PRE => \cycle_counter_reg[18]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[18]_P_n_0\
    );
\cycle_counter_reg[19]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[19]_LDC_i_2_n_0\,
      D => p_2_in(19),
      Q => \cycle_counter_reg[19]_C_n_0\
    );
\cycle_counter_reg[19]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[19]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[19]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[19]_LDC_n_0\
    );
\cycle_counter_reg[19]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(19),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[19]_LDC_i_1_n_0\
    );
\cycle_counter_reg[19]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(19),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[19]_LDC_i_2_n_0\
    );
\cycle_counter_reg[19]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(19),
      PRE => \cycle_counter_reg[19]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[19]_P_n_0\
    );
\cycle_counter_reg[1]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[1]_LDC_i_2_n_0\,
      D => p_2_in(1),
      Q => \cycle_counter_reg[1]_C_n_0\
    );
\cycle_counter_reg[1]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[1]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[1]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[1]_LDC_n_0\
    );
\cycle_counter_reg[1]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(1),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[1]_LDC_i_1_n_0\
    );
\cycle_counter_reg[1]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(1),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[1]_LDC_i_2_n_0\
    );
\cycle_counter_reg[1]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(1),
      PRE => \cycle_counter_reg[1]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[1]_P_n_0\
    );
\cycle_counter_reg[20]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[20]_LDC_i_2_n_0\,
      D => p_2_in(20),
      Q => \cycle_counter_reg[20]_C_n_0\
    );
\cycle_counter_reg[20]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[20]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[20]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[20]_LDC_n_0\
    );
\cycle_counter_reg[20]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(20),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[20]_LDC_i_1_n_0\
    );
\cycle_counter_reg[20]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(20),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[20]_LDC_i_2_n_0\
    );
\cycle_counter_reg[20]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(20),
      PRE => \cycle_counter_reg[20]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[20]_P_n_0\
    );
\cycle_counter_reg[21]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[21]_LDC_i_2_n_0\,
      D => p_2_in(21),
      Q => \cycle_counter_reg[21]_C_n_0\
    );
\cycle_counter_reg[21]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[21]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[21]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[21]_LDC_n_0\
    );
\cycle_counter_reg[21]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(21),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[21]_LDC_i_1_n_0\
    );
\cycle_counter_reg[21]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(21),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[21]_LDC_i_2_n_0\
    );
\cycle_counter_reg[21]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(21),
      PRE => \cycle_counter_reg[21]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[21]_P_n_0\
    );
\cycle_counter_reg[22]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[22]_LDC_i_2_n_0\,
      D => p_2_in(22),
      Q => \cycle_counter_reg[22]_C_n_0\
    );
\cycle_counter_reg[22]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[22]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[22]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[22]_LDC_n_0\
    );
\cycle_counter_reg[22]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(22),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[22]_LDC_i_1_n_0\
    );
\cycle_counter_reg[22]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(22),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[22]_LDC_i_2_n_0\
    );
\cycle_counter_reg[22]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(22),
      PRE => \cycle_counter_reg[22]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[22]_P_n_0\
    );
\cycle_counter_reg[23]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[23]_LDC_i_2_n_0\,
      D => p_2_in(23),
      Q => \cycle_counter_reg[23]_C_n_0\
    );
\cycle_counter_reg[23]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[23]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[23]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[23]_LDC_n_0\
    );
\cycle_counter_reg[23]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(23),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[23]_LDC_i_1_n_0\
    );
\cycle_counter_reg[23]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(23),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[23]_LDC_i_2_n_0\
    );
\cycle_counter_reg[23]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(23),
      PRE => \cycle_counter_reg[23]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[23]_P_n_0\
    );
\cycle_counter_reg[24]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[24]_LDC_i_2_n_0\,
      D => p_2_in(24),
      Q => \cycle_counter_reg[24]_C_n_0\
    );
\cycle_counter_reg[24]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[24]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[24]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[24]_LDC_n_0\
    );
\cycle_counter_reg[24]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(24),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[24]_LDC_i_1_n_0\
    );
\cycle_counter_reg[24]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(24),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[24]_LDC_i_2_n_0\
    );
\cycle_counter_reg[24]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(24),
      PRE => \cycle_counter_reg[24]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[24]_P_n_0\
    );
\cycle_counter_reg[25]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[25]_LDC_i_2_n_0\,
      D => p_2_in(25),
      Q => \cycle_counter_reg[25]_C_n_0\
    );
\cycle_counter_reg[25]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[25]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[25]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[25]_LDC_n_0\
    );
\cycle_counter_reg[25]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(25),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[25]_LDC_i_1_n_0\
    );
\cycle_counter_reg[25]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(25),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[25]_LDC_i_2_n_0\
    );
\cycle_counter_reg[25]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(25),
      PRE => \cycle_counter_reg[25]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[25]_P_n_0\
    );
\cycle_counter_reg[26]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[26]_LDC_i_2_n_0\,
      D => p_2_in(26),
      Q => \cycle_counter_reg[26]_C_n_0\
    );
\cycle_counter_reg[26]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[26]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[26]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[26]_LDC_n_0\
    );
\cycle_counter_reg[26]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(26),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[26]_LDC_i_1_n_0\
    );
\cycle_counter_reg[26]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(26),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[26]_LDC_i_2_n_0\
    );
\cycle_counter_reg[26]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(26),
      PRE => \cycle_counter_reg[26]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[26]_P_n_0\
    );
\cycle_counter_reg[2]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[2]_LDC_i_2_n_0\,
      D => p_2_in(2),
      Q => \cycle_counter_reg[2]_C_n_0\
    );
\cycle_counter_reg[2]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[2]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[2]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[2]_LDC_n_0\
    );
\cycle_counter_reg[2]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(2),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[2]_LDC_i_1_n_0\
    );
\cycle_counter_reg[2]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(2),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[2]_LDC_i_2_n_0\
    );
\cycle_counter_reg[2]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(2),
      PRE => \cycle_counter_reg[2]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[2]_P_n_0\
    );
\cycle_counter_reg[3]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[3]_LDC_i_2_n_0\,
      D => p_2_in(3),
      Q => \cycle_counter_reg[3]_C_n_0\
    );
\cycle_counter_reg[3]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[3]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[3]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[3]_LDC_n_0\
    );
\cycle_counter_reg[3]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(3),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[3]_LDC_i_1_n_0\
    );
\cycle_counter_reg[3]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(3),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[3]_LDC_i_2_n_0\
    );
\cycle_counter_reg[3]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(3),
      PRE => \cycle_counter_reg[3]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[3]_P_n_0\
    );
\cycle_counter_reg[4]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[4]_LDC_i_2_n_0\,
      D => p_2_in(4),
      Q => \cycle_counter_reg[4]_C_n_0\
    );
\cycle_counter_reg[4]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[4]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[4]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[4]_LDC_n_0\
    );
\cycle_counter_reg[4]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(4),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[4]_LDC_i_1_n_0\
    );
\cycle_counter_reg[4]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(4),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[4]_LDC_i_2_n_0\
    );
\cycle_counter_reg[4]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(4),
      PRE => \cycle_counter_reg[4]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[4]_P_n_0\
    );
\cycle_counter_reg[5]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[5]_LDC_i_2_n_0\,
      D => p_2_in(5),
      Q => \cycle_counter_reg[5]_C_n_0\
    );
\cycle_counter_reg[5]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[5]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[5]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[5]_LDC_n_0\
    );
\cycle_counter_reg[5]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(5),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[5]_LDC_i_1_n_0\
    );
\cycle_counter_reg[5]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(5),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[5]_LDC_i_2_n_0\
    );
\cycle_counter_reg[5]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(5),
      PRE => \cycle_counter_reg[5]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[5]_P_n_0\
    );
\cycle_counter_reg[6]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[6]_LDC_i_2_n_0\,
      D => p_2_in(6),
      Q => \cycle_counter_reg[6]_C_n_0\
    );
\cycle_counter_reg[6]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[6]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[6]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[6]_LDC_n_0\
    );
\cycle_counter_reg[6]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(6),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[6]_LDC_i_1_n_0\
    );
\cycle_counter_reg[6]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(6),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[6]_LDC_i_2_n_0\
    );
\cycle_counter_reg[6]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(6),
      PRE => \cycle_counter_reg[6]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[6]_P_n_0\
    );
\cycle_counter_reg[7]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[7]_LDC_i_2_n_0\,
      D => p_2_in(7),
      Q => \cycle_counter_reg[7]_C_n_0\
    );
\cycle_counter_reg[7]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[7]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[7]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[7]_LDC_n_0\
    );
\cycle_counter_reg[7]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(7),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[7]_LDC_i_1_n_0\
    );
\cycle_counter_reg[7]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(7),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[7]_LDC_i_2_n_0\
    );
\cycle_counter_reg[7]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(7),
      PRE => \cycle_counter_reg[7]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[7]_P_n_0\
    );
\cycle_counter_reg[8]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[8]_LDC_i_2_n_0\,
      D => p_2_in(8),
      Q => \cycle_counter_reg[8]_C_n_0\
    );
\cycle_counter_reg[8]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[8]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[8]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[8]_LDC_n_0\
    );
\cycle_counter_reg[8]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(8),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[8]_LDC_i_1_n_0\
    );
\cycle_counter_reg[8]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(8),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[8]_LDC_i_2_n_0\
    );
\cycle_counter_reg[8]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(8),
      PRE => \cycle_counter_reg[8]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[8]_P_n_0\
    );
\cycle_counter_reg[9]_C\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => \cycle_counter_reg[9]_LDC_i_2_n_0\,
      D => p_2_in(9),
      Q => \cycle_counter_reg[9]_C_n_0\
    );
\cycle_counter_reg[9]_LDC\: unisim.vcomponents.LDCE
    generic map(
      INIT => '0'
    )
        port map (
      CLR => \cycle_counter_reg[9]_LDC_i_2_n_0\,
      D => '1',
      G => \cycle_counter_reg[9]_LDC_i_1_n_0\,
      GE => '1',
      Q => \cycle_counter_reg[9]_LDC_n_0\
    );
\cycle_counter_reg[9]_LDC_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => minusOp0_in(9),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[9]_LDC_i_1_n_0\
    );
\cycle_counter_reg[9]_LDC_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => minusOp0_in(9),
      I1 => axis_aresetn,
      O => \cycle_counter_reg[9]_LDC_i_2_n_0\
    );
\cycle_counter_reg[9]_P\: unisim.vcomponents.FDPE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_2_in(9),
      PRE => \cycle_counter_reg[9]_LDC_i_1_n_0\,
      Q => \cycle_counter_reg[9]_P_n_0\
    );
\eqOp__8_carry\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \eqOp__8_carry_n_0\,
      CO(2) => \eqOp__8_carry_n_1\,
      CO(1) => \eqOp__8_carry_n_2\,
      CO(0) => \eqOp__8_carry_n_3\,
      CYINIT => '1',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => \NLW_eqOp__8_carry_O_UNCONNECTED\(3 downto 0),
      S(3) => \eqOp__8_carry_i_1_n_0\,
      S(2) => \eqOp__8_carry_i_2_n_0\,
      S(1) => \eqOp__8_carry_i_3_n_0\,
      S(0) => \eqOp__8_carry_i_4_n_0\
    );
\eqOp__8_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => \eqOp__8_carry_n_0\,
      CO(3) => \eqOp__8_carry__0_n_0\,
      CO(2) => \eqOp__8_carry__0_n_1\,
      CO(1) => \eqOp__8_carry__0_n_2\,
      CO(0) => \eqOp__8_carry__0_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => \NLW_eqOp__8_carry__0_O_UNCONNECTED\(3 downto 0),
      S(3) => \eqOp__8_carry__0_i_1_n_0\,
      S(2) => \eqOp__8_carry__0_i_2_n_0\,
      S(1) => \eqOp__8_carry__0_i_3_n_0\,
      S(0) => \eqOp__8_carry__0_i_4_n_0\
    );
\eqOp__8_carry__0_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(21),
      I1 => minusOp(21),
      I2 => minusOp(23),
      I3 => cycle_counter(23),
      I4 => minusOp(22),
      I5 => cycle_counter(22),
      O => \eqOp__8_carry__0_i_1_n_0\
    );
\eqOp__8_carry__0_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(18),
      I1 => minusOp(18),
      I2 => minusOp(20),
      I3 => cycle_counter(20),
      I4 => minusOp(19),
      I5 => cycle_counter(19),
      O => \eqOp__8_carry__0_i_2_n_0\
    );
\eqOp__8_carry__0_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(15),
      I1 => minusOp(15),
      I2 => minusOp(17),
      I3 => cycle_counter(17),
      I4 => minusOp(16),
      I5 => cycle_counter(16),
      O => \eqOp__8_carry__0_i_3_n_0\
    );
\eqOp__8_carry__0_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(12),
      I1 => minusOp(12),
      I2 => minusOp(14),
      I3 => cycle_counter(14),
      I4 => minusOp(13),
      I5 => cycle_counter(13),
      O => \eqOp__8_carry__0_i_4_n_0\
    );
\eqOp__8_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \eqOp__8_carry__0_n_0\,
      CO(3 downto 1) => \NLW_eqOp__8_carry__1_CO_UNCONNECTED\(3 downto 1),
      CO(0) => eqOp,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => \NLW_eqOp__8_carry__1_O_UNCONNECTED\(3 downto 0),
      S(3 downto 1) => B"000",
      S(0) => \eqOp__8_carry__1_i_1_n_0\
    );
\eqOp__8_carry__1_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(24),
      I1 => minusOp(24),
      I2 => minusOp(26),
      I3 => cycle_counter(26),
      I4 => minusOp(25),
      I5 => cycle_counter(25),
      O => \eqOp__8_carry__1_i_1_n_0\
    );
\eqOp__8_carry_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(9),
      I1 => minusOp(9),
      I2 => minusOp(11),
      I3 => cycle_counter(11),
      I4 => minusOp(10),
      I5 => cycle_counter(10),
      O => \eqOp__8_carry_i_1_n_0\
    );
\eqOp__8_carry_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(6),
      I1 => minusOp(6),
      I2 => minusOp(8),
      I3 => cycle_counter(8),
      I4 => minusOp(7),
      I5 => cycle_counter(7),
      O => \eqOp__8_carry_i_2_n_0\
    );
\eqOp__8_carry_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(3),
      I1 => minusOp(3),
      I2 => minusOp(5),
      I3 => cycle_counter(5),
      I4 => minusOp(4),
      I5 => cycle_counter(4),
      O => \eqOp__8_carry_i_3_n_0\
    );
\eqOp__8_carry_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(0),
      I1 => minusOp(0),
      I2 => minusOp(2),
      I3 => cycle_counter(2),
      I4 => minusOp(1),
      I5 => cycle_counter(1),
      O => \eqOp__8_carry_i_4_n_0\
    );
eqOp_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => eqOp_carry_n_0,
      CO(2) => eqOp_carry_n_1,
      CO(1) => eqOp_carry_n_2,
      CO(0) => eqOp_carry_n_3,
      CYINIT => '1',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => NLW_eqOp_carry_O_UNCONNECTED(3 downto 0),
      S(3) => eqOp_carry_i_1_n_0,
      S(2) => eqOp_carry_i_2_n_0,
      S(1) => eqOp_carry_i_3_n_0,
      S(0) => eqOp_carry_i_4_n_0
    );
\eqOp_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => eqOp_carry_n_0,
      CO(3) => \eqOp_carry__0_n_0\,
      CO(2) => \eqOp_carry__0_n_1\,
      CO(1) => \eqOp_carry__0_n_2\,
      CO(0) => \eqOp_carry__0_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => \NLW_eqOp_carry__0_O_UNCONNECTED\(3 downto 0),
      S(3) => \eqOp_carry__0_i_1_n_0\,
      S(2) => \eqOp_carry__0_i_2_n_0\,
      S(1) => \eqOp_carry__0_i_3_n_0\,
      S(0) => \eqOp_carry__0_i_4_n_0\
    );
\eqOp_carry__0_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(21),
      I1 => minusOp0_in(21),
      I2 => minusOp0_in(23),
      I3 => cycle_counter(23),
      I4 => minusOp0_in(22),
      I5 => cycle_counter(22),
      O => \eqOp_carry__0_i_1_n_0\
    );
\eqOp_carry__0_i_10\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[19]_P_n_0\,
      I1 => \cycle_counter_reg[19]_LDC_n_0\,
      I2 => \cycle_counter_reg[19]_C_n_0\,
      O => cycle_counter(19)
    );
\eqOp_carry__0_i_11\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[15]_P_n_0\,
      I1 => \cycle_counter_reg[15]_LDC_n_0\,
      I2 => \cycle_counter_reg[15]_C_n_0\,
      O => cycle_counter(15)
    );
\eqOp_carry__0_i_12\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[17]_P_n_0\,
      I1 => \cycle_counter_reg[17]_LDC_n_0\,
      I2 => \cycle_counter_reg[17]_C_n_0\,
      O => cycle_counter(17)
    );
\eqOp_carry__0_i_13\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[16]_P_n_0\,
      I1 => \cycle_counter_reg[16]_LDC_n_0\,
      I2 => \cycle_counter_reg[16]_C_n_0\,
      O => cycle_counter(16)
    );
\eqOp_carry__0_i_14\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[12]_P_n_0\,
      I1 => \cycle_counter_reg[12]_LDC_n_0\,
      I2 => \cycle_counter_reg[12]_C_n_0\,
      O => cycle_counter(12)
    );
\eqOp_carry__0_i_15\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[14]_P_n_0\,
      I1 => \cycle_counter_reg[14]_LDC_n_0\,
      I2 => \cycle_counter_reg[14]_C_n_0\,
      O => cycle_counter(14)
    );
\eqOp_carry__0_i_16\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[13]_P_n_0\,
      I1 => \cycle_counter_reg[13]_LDC_n_0\,
      I2 => \cycle_counter_reg[13]_C_n_0\,
      O => cycle_counter(13)
    );
\eqOp_carry__0_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(18),
      I1 => minusOp0_in(18),
      I2 => minusOp0_in(20),
      I3 => cycle_counter(20),
      I4 => minusOp0_in(19),
      I5 => cycle_counter(19),
      O => \eqOp_carry__0_i_2_n_0\
    );
\eqOp_carry__0_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(15),
      I1 => minusOp0_in(15),
      I2 => minusOp0_in(17),
      I3 => cycle_counter(17),
      I4 => minusOp0_in(16),
      I5 => cycle_counter(16),
      O => \eqOp_carry__0_i_3_n_0\
    );
\eqOp_carry__0_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(12),
      I1 => minusOp0_in(12),
      I2 => minusOp0_in(14),
      I3 => cycle_counter(14),
      I4 => minusOp0_in(13),
      I5 => cycle_counter(13),
      O => \eqOp_carry__0_i_4_n_0\
    );
\eqOp_carry__0_i_5\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[21]_P_n_0\,
      I1 => \cycle_counter_reg[21]_LDC_n_0\,
      I2 => \cycle_counter_reg[21]_C_n_0\,
      O => cycle_counter(21)
    );
\eqOp_carry__0_i_6\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[23]_P_n_0\,
      I1 => \cycle_counter_reg[23]_LDC_n_0\,
      I2 => \cycle_counter_reg[23]_C_n_0\,
      O => cycle_counter(23)
    );
\eqOp_carry__0_i_7\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[22]_P_n_0\,
      I1 => \cycle_counter_reg[22]_LDC_n_0\,
      I2 => \cycle_counter_reg[22]_C_n_0\,
      O => cycle_counter(22)
    );
\eqOp_carry__0_i_8\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[18]_P_n_0\,
      I1 => \cycle_counter_reg[18]_LDC_n_0\,
      I2 => \cycle_counter_reg[18]_C_n_0\,
      O => cycle_counter(18)
    );
\eqOp_carry__0_i_9\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[20]_P_n_0\,
      I1 => \cycle_counter_reg[20]_LDC_n_0\,
      I2 => \cycle_counter_reg[20]_C_n_0\,
      O => cycle_counter(20)
    );
\eqOp_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \eqOp_carry__0_n_0\,
      CO(3 downto 1) => \NLW_eqOp_carry__1_CO_UNCONNECTED\(3 downto 1),
      CO(0) => eqOp1_out,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => \NLW_eqOp_carry__1_O_UNCONNECTED\(3 downto 0),
      S(3 downto 1) => B"000",
      S(0) => \eqOp_carry__1_i_1_n_0\
    );
\eqOp_carry__1_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(24),
      I1 => minusOp0_in(24),
      I2 => minusOp0_in(26),
      I3 => cycle_counter(26),
      I4 => minusOp0_in(25),
      I5 => cycle_counter(25),
      O => \eqOp_carry__1_i_1_n_0\
    );
\eqOp_carry__1_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[24]_P_n_0\,
      I1 => \cycle_counter_reg[24]_LDC_n_0\,
      I2 => \cycle_counter_reg[24]_C_n_0\,
      O => cycle_counter(24)
    );
\eqOp_carry__1_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[26]_P_n_0\,
      I1 => \cycle_counter_reg[26]_LDC_n_0\,
      I2 => \cycle_counter_reg[26]_C_n_0\,
      O => cycle_counter(26)
    );
\eqOp_carry__1_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[25]_P_n_0\,
      I1 => \cycle_counter_reg[25]_LDC_n_0\,
      I2 => \cycle_counter_reg[25]_C_n_0\,
      O => cycle_counter(25)
    );
eqOp_carry_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(9),
      I1 => minusOp0_in(9),
      I2 => minusOp0_in(11),
      I3 => cycle_counter(11),
      I4 => minusOp0_in(10),
      I5 => cycle_counter(10),
      O => eqOp_carry_i_1_n_0
    );
eqOp_carry_i_10: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[7]_P_n_0\,
      I1 => \cycle_counter_reg[7]_LDC_n_0\,
      I2 => \cycle_counter_reg[7]_C_n_0\,
      O => cycle_counter(7)
    );
eqOp_carry_i_11: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[3]_P_n_0\,
      I1 => \cycle_counter_reg[3]_LDC_n_0\,
      I2 => \cycle_counter_reg[3]_C_n_0\,
      O => cycle_counter(3)
    );
eqOp_carry_i_12: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[5]_P_n_0\,
      I1 => \cycle_counter_reg[5]_LDC_n_0\,
      I2 => \cycle_counter_reg[5]_C_n_0\,
      O => cycle_counter(5)
    );
eqOp_carry_i_13: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[4]_P_n_0\,
      I1 => \cycle_counter_reg[4]_LDC_n_0\,
      I2 => \cycle_counter_reg[4]_C_n_0\,
      O => cycle_counter(4)
    );
eqOp_carry_i_14: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[2]_P_n_0\,
      I1 => \cycle_counter_reg[2]_LDC_n_0\,
      I2 => \cycle_counter_reg[2]_C_n_0\,
      O => cycle_counter(2)
    );
eqOp_carry_i_15: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[1]_P_n_0\,
      I1 => \cycle_counter_reg[1]_LDC_n_0\,
      I2 => \cycle_counter_reg[1]_C_n_0\,
      O => cycle_counter(1)
    );
eqOp_carry_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(6),
      I1 => minusOp0_in(6),
      I2 => minusOp0_in(8),
      I3 => cycle_counter(8),
      I4 => minusOp0_in(7),
      I5 => cycle_counter(7),
      O => eqOp_carry_i_2_n_0
    );
eqOp_carry_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => cycle_counter(3),
      I1 => minusOp0_in(3),
      I2 => minusOp0_in(5),
      I3 => cycle_counter(5),
      I4 => minusOp0_in(4),
      I5 => cycle_counter(4),
      O => eqOp_carry_i_3_n_0
    );
eqOp_carry_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"6006000000006006"
    )
        port map (
      I0 => cycle_counter(0),
      I1 => fs_cycles(0),
      I2 => minusOp0_in(2),
      I3 => cycle_counter(2),
      I4 => minusOp0_in(1),
      I5 => cycle_counter(1),
      O => eqOp_carry_i_4_n_0
    );
eqOp_carry_i_5: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[9]_P_n_0\,
      I1 => \cycle_counter_reg[9]_LDC_n_0\,
      I2 => \cycle_counter_reg[9]_C_n_0\,
      O => cycle_counter(9)
    );
eqOp_carry_i_6: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[11]_P_n_0\,
      I1 => \cycle_counter_reg[11]_LDC_n_0\,
      I2 => \cycle_counter_reg[11]_C_n_0\,
      O => cycle_counter(11)
    );
eqOp_carry_i_7: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[10]_P_n_0\,
      I1 => \cycle_counter_reg[10]_LDC_n_0\,
      I2 => \cycle_counter_reg[10]_C_n_0\,
      O => cycle_counter(10)
    );
eqOp_carry_i_8: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[6]_P_n_0\,
      I1 => \cycle_counter_reg[6]_LDC_n_0\,
      I2 => \cycle_counter_reg[6]_C_n_0\,
      O => cycle_counter(6)
    );
eqOp_carry_i_9: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[8]_P_n_0\,
      I1 => \cycle_counter_reg[8]_LDC_n_0\,
      I2 => \cycle_counter_reg[8]_C_n_0\,
      O => cycle_counter(8)
    );
\in_tdata[31]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => axis_aresetn,
      I1 => dl_en,
      O => \in_tdata[31]_i_1_n_0\
    );
\in_tdata[31]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"A2"
    )
        port map (
      I0 => axis_aresetn,
      I1 => dl_en,
      I2 => eqOp1_out,
      O => in_tdata0
    );
\in_tdata_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(0),
      Q => in_tdata(0),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(10),
      Q => in_tdata(10),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(11),
      Q => in_tdata(11),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(12),
      Q => in_tdata(12),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(13),
      Q => in_tdata(13),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(14),
      Q => in_tdata(14),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(15),
      Q => in_tdata(15),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(16),
      Q => in_tdata(16),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(17),
      Q => in_tdata(17),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(18),
      Q => in_tdata(18),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(19),
      Q => in_tdata(19),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(1),
      Q => in_tdata(1),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(20),
      Q => in_tdata(20),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(21),
      Q => in_tdata(21),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(22),
      Q => in_tdata(22),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(23),
      Q => in_tdata(23),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(24),
      Q => in_tdata(24),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(25),
      Q => in_tdata(25),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(26),
      Q => in_tdata(26),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(27),
      Q => in_tdata(27),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(28),
      Q => in_tdata(28),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(29),
      Q => in_tdata(29),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(2),
      Q => in_tdata(2),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(30),
      Q => in_tdata(30),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(31),
      Q => in_tdata(31),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(3),
      Q => in_tdata(3),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(4),
      Q => in_tdata(4),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(5),
      Q => in_tdata(5),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(6),
      Q => in_tdata(6),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(7),
      Q => in_tdata(7),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(8),
      Q => in_tdata(8),
      R => \in_tdata[31]_i_1_n_0\
    );
\in_tdata_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => in_tdata0,
      D => s_axis_tdata(9),
      Q => in_tdata(9),
      R => \in_tdata[31]_i_1_n_0\
    );
in_tlast_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80FF8000"
    )
        port map (
      I0 => eqOp1_out,
      I1 => dl_en,
      I2 => s_axis_tlast,
      I3 => axis_aresetn,
      I4 => in_tlast,
      O => in_tlast_i_1_n_0
    );
in_tlast_reg: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tlast_i_1_n_0,
      Q => in_tlast,
      R => '0'
    );
in_tvalid_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"80FF8000"
    )
        port map (
      I0 => eqOp1_out,
      I1 => dl_en,
      I2 => s_axis_tvalid,
      I3 => axis_aresetn,
      I4 => in_tvalid,
      O => in_tvalid_i_1_n_0
    );
in_tvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tvalid_i_1_n_0,
      Q => in_tvalid,
      R => '0'
    );
\m_axis_tdata[31]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => dl_en,
      O => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(0),
      Q => m_axis_tdata(0),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(10),
      Q => m_axis_tdata(10),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(11),
      Q => m_axis_tdata(11),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(12),
      Q => m_axis_tdata(12),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(13),
      Q => m_axis_tdata(13),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(14),
      Q => m_axis_tdata(14),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(15),
      Q => m_axis_tdata(15),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(16),
      Q => m_axis_tdata(16),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(17),
      Q => m_axis_tdata(17),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(18),
      Q => m_axis_tdata(18),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(19),
      Q => m_axis_tdata(19),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(1),
      Q => m_axis_tdata(1),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(20),
      Q => m_axis_tdata(20),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(21),
      Q => m_axis_tdata(21),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(22),
      Q => m_axis_tdata(22),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(23),
      Q => m_axis_tdata(23),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(24),
      Q => m_axis_tdata(24),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(25),
      Q => m_axis_tdata(25),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(26),
      Q => m_axis_tdata(26),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(27),
      Q => m_axis_tdata(27),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(28),
      Q => m_axis_tdata(28),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(29),
      Q => m_axis_tdata(29),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(2),
      Q => m_axis_tdata(2),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(30),
      Q => m_axis_tdata(30),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(31),
      Q => m_axis_tdata(31),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(3),
      Q => m_axis_tdata(3),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(4),
      Q => m_axis_tdata(4),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(5),
      Q => m_axis_tdata(5),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(6),
      Q => m_axis_tdata(6),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(7),
      Q => m_axis_tdata(7),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(8),
      Q => m_axis_tdata(8),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
\m_axis_tdata_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tdata(9),
      Q => m_axis_tdata(9),
      R => \m_axis_tdata[31]_i_1_n_0\
    );
m_axis_tlast_reg: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tlast,
      Q => m_axis_tlast,
      R => \m_axis_tdata[31]_i_1_n_0\
    );
m_axis_tvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => in_tvalid,
      Q => m_axis_tvalid,
      R => \m_axis_tdata[31]_i_1_n_0\
    );
minusOp_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => minusOp_carry_n_0,
      CO(2) => minusOp_carry_n_1,
      CO(1) => minusOp_carry_n_2,
      CO(0) => minusOp_carry_n_3,
      CYINIT => fs_cycles(0),
      DI(3 downto 0) => fs_cycles(4 downto 1),
      O(3 downto 0) => minusOp0_in(4 downto 1),
      S(3) => minusOp_carry_i_1_n_0,
      S(2) => minusOp_carry_i_2_n_0,
      S(1) => minusOp_carry_i_3_n_0,
      S(0) => minusOp_carry_i_4_n_0
    );
\minusOp_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => minusOp_carry_n_0,
      CO(3) => \minusOp_carry__0_n_0\,
      CO(2) => \minusOp_carry__0_n_1\,
      CO(1) => \minusOp_carry__0_n_2\,
      CO(0) => \minusOp_carry__0_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(8 downto 5),
      O(3 downto 0) => minusOp0_in(8 downto 5),
      S(3) => \minusOp_carry__0_i_1_n_0\,
      S(2) => \minusOp_carry__0_i_2_n_0\,
      S(1) => \minusOp_carry__0_i_3_n_0\,
      S(0) => \minusOp_carry__0_i_4_n_0\
    );
\minusOp_carry__0_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(8),
      O => \minusOp_carry__0_i_1_n_0\
    );
\minusOp_carry__0_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(7),
      O => \minusOp_carry__0_i_2_n_0\
    );
\minusOp_carry__0_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(6),
      O => \minusOp_carry__0_i_3_n_0\
    );
\minusOp_carry__0_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(5),
      O => \minusOp_carry__0_i_4_n_0\
    );
\minusOp_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp_carry__0_n_0\,
      CO(3) => \minusOp_carry__1_n_0\,
      CO(2) => \minusOp_carry__1_n_1\,
      CO(1) => \minusOp_carry__1_n_2\,
      CO(0) => \minusOp_carry__1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(12 downto 9),
      O(3 downto 0) => minusOp0_in(12 downto 9),
      S(3) => \minusOp_carry__1_i_1_n_0\,
      S(2) => \minusOp_carry__1_i_2_n_0\,
      S(1) => \minusOp_carry__1_i_3_n_0\,
      S(0) => \minusOp_carry__1_i_4_n_0\
    );
\minusOp_carry__1_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(12),
      O => \minusOp_carry__1_i_1_n_0\
    );
\minusOp_carry__1_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(11),
      O => \minusOp_carry__1_i_2_n_0\
    );
\minusOp_carry__1_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(10),
      O => \minusOp_carry__1_i_3_n_0\
    );
\minusOp_carry__1_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(9),
      O => \minusOp_carry__1_i_4_n_0\
    );
\minusOp_carry__2\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp_carry__1_n_0\,
      CO(3) => \minusOp_carry__2_n_0\,
      CO(2) => \minusOp_carry__2_n_1\,
      CO(1) => \minusOp_carry__2_n_2\,
      CO(0) => \minusOp_carry__2_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(16 downto 13),
      O(3 downto 0) => minusOp0_in(16 downto 13),
      S(3) => \minusOp_carry__2_i_1_n_0\,
      S(2) => \minusOp_carry__2_i_2_n_0\,
      S(1) => \minusOp_carry__2_i_3_n_0\,
      S(0) => \minusOp_carry__2_i_4_n_0\
    );
\minusOp_carry__2_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(16),
      O => \minusOp_carry__2_i_1_n_0\
    );
\minusOp_carry__2_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(15),
      O => \minusOp_carry__2_i_2_n_0\
    );
\minusOp_carry__2_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(14),
      O => \minusOp_carry__2_i_3_n_0\
    );
\minusOp_carry__2_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(13),
      O => \minusOp_carry__2_i_4_n_0\
    );
\minusOp_carry__3\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp_carry__2_n_0\,
      CO(3) => \minusOp_carry__3_n_0\,
      CO(2) => \minusOp_carry__3_n_1\,
      CO(1) => \minusOp_carry__3_n_2\,
      CO(0) => \minusOp_carry__3_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(20 downto 17),
      O(3 downto 0) => minusOp0_in(20 downto 17),
      S(3) => \minusOp_carry__3_i_1_n_0\,
      S(2) => \minusOp_carry__3_i_2_n_0\,
      S(1) => \minusOp_carry__3_i_3_n_0\,
      S(0) => \minusOp_carry__3_i_4_n_0\
    );
\minusOp_carry__3_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(20),
      O => \minusOp_carry__3_i_1_n_0\
    );
\minusOp_carry__3_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(19),
      O => \minusOp_carry__3_i_2_n_0\
    );
\minusOp_carry__3_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(18),
      O => \minusOp_carry__3_i_3_n_0\
    );
\minusOp_carry__3_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(17),
      O => \minusOp_carry__3_i_4_n_0\
    );
\minusOp_carry__4\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp_carry__3_n_0\,
      CO(3) => \minusOp_carry__4_n_0\,
      CO(2) => \minusOp_carry__4_n_1\,
      CO(1) => \minusOp_carry__4_n_2\,
      CO(0) => \minusOp_carry__4_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(24 downto 21),
      O(3 downto 0) => minusOp0_in(24 downto 21),
      S(3) => \minusOp_carry__4_i_1_n_0\,
      S(2) => \minusOp_carry__4_i_2_n_0\,
      S(1) => \minusOp_carry__4_i_3_n_0\,
      S(0) => \minusOp_carry__4_i_4_n_0\
    );
\minusOp_carry__4_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(24),
      O => \minusOp_carry__4_i_1_n_0\
    );
\minusOp_carry__4_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(23),
      O => \minusOp_carry__4_i_2_n_0\
    );
\minusOp_carry__4_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(22),
      O => \minusOp_carry__4_i_3_n_0\
    );
\minusOp_carry__4_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(21),
      O => \minusOp_carry__4_i_4_n_0\
    );
\minusOp_carry__5\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp_carry__4_n_0\,
      CO(3 downto 1) => \NLW_minusOp_carry__5_CO_UNCONNECTED\(3 downto 1),
      CO(0) => \minusOp_carry__5_n_3\,
      CYINIT => '0',
      DI(3 downto 1) => B"000",
      DI(0) => fs_cycles(25),
      O(3 downto 2) => \NLW_minusOp_carry__5_O_UNCONNECTED\(3 downto 2),
      O(1 downto 0) => minusOp0_in(26 downto 25),
      S(3 downto 2) => B"00",
      S(1) => \minusOp_carry__5_i_1_n_0\,
      S(0) => \minusOp_carry__5_i_2_n_0\
    );
\minusOp_carry__5_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(26),
      O => \minusOp_carry__5_i_1_n_0\
    );
\minusOp_carry__5_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(25),
      O => \minusOp_carry__5_i_2_n_0\
    );
minusOp_carry_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(4),
      O => minusOp_carry_i_1_n_0
    );
minusOp_carry_i_2: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(3),
      O => minusOp_carry_i_2_n_0
    );
minusOp_carry_i_3: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(2),
      O => minusOp_carry_i_3_n_0
    );
minusOp_carry_i_4: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(1),
      O => minusOp_carry_i_4_n_0
    );
plusOp_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => plusOp_carry_n_0,
      CO(2) => plusOp_carry_n_1,
      CO(1) => plusOp_carry_n_2,
      CO(0) => plusOp_carry_n_3,
      CYINIT => cycle_counter(0),
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => plusOp(4 downto 1),
      S(3) => plusOp_carry_i_2_n_0,
      S(2) => plusOp_carry_i_3_n_0,
      S(1) => plusOp_carry_i_4_n_0,
      S(0) => plusOp_carry_i_5_n_0
    );
\plusOp_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => plusOp_carry_n_0,
      CO(3) => \plusOp_carry__0_n_0\,
      CO(2) => \plusOp_carry__0_n_1\,
      CO(1) => \plusOp_carry__0_n_2\,
      CO(0) => \plusOp_carry__0_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => plusOp(8 downto 5),
      S(3) => \plusOp_carry__0_i_1_n_0\,
      S(2) => \plusOp_carry__0_i_2_n_0\,
      S(1) => \plusOp_carry__0_i_3_n_0\,
      S(0) => \plusOp_carry__0_i_4_n_0\
    );
\plusOp_carry__0_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[8]_P_n_0\,
      I1 => \cycle_counter_reg[8]_LDC_n_0\,
      I2 => \cycle_counter_reg[8]_C_n_0\,
      O => \plusOp_carry__0_i_1_n_0\
    );
\plusOp_carry__0_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[7]_P_n_0\,
      I1 => \cycle_counter_reg[7]_LDC_n_0\,
      I2 => \cycle_counter_reg[7]_C_n_0\,
      O => \plusOp_carry__0_i_2_n_0\
    );
\plusOp_carry__0_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[6]_P_n_0\,
      I1 => \cycle_counter_reg[6]_LDC_n_0\,
      I2 => \cycle_counter_reg[6]_C_n_0\,
      O => \plusOp_carry__0_i_3_n_0\
    );
\plusOp_carry__0_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[5]_P_n_0\,
      I1 => \cycle_counter_reg[5]_LDC_n_0\,
      I2 => \cycle_counter_reg[5]_C_n_0\,
      O => \plusOp_carry__0_i_4_n_0\
    );
\plusOp_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \plusOp_carry__0_n_0\,
      CO(3) => \plusOp_carry__1_n_0\,
      CO(2) => \plusOp_carry__1_n_1\,
      CO(1) => \plusOp_carry__1_n_2\,
      CO(0) => \plusOp_carry__1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => plusOp(12 downto 9),
      S(3) => \plusOp_carry__1_i_1_n_0\,
      S(2) => \plusOp_carry__1_i_2_n_0\,
      S(1) => \plusOp_carry__1_i_3_n_0\,
      S(0) => \plusOp_carry__1_i_4_n_0\
    );
\plusOp_carry__1_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[12]_P_n_0\,
      I1 => \cycle_counter_reg[12]_LDC_n_0\,
      I2 => \cycle_counter_reg[12]_C_n_0\,
      O => \plusOp_carry__1_i_1_n_0\
    );
\plusOp_carry__1_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[11]_P_n_0\,
      I1 => \cycle_counter_reg[11]_LDC_n_0\,
      I2 => \cycle_counter_reg[11]_C_n_0\,
      O => \plusOp_carry__1_i_2_n_0\
    );
\plusOp_carry__1_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[10]_P_n_0\,
      I1 => \cycle_counter_reg[10]_LDC_n_0\,
      I2 => \cycle_counter_reg[10]_C_n_0\,
      O => \plusOp_carry__1_i_3_n_0\
    );
\plusOp_carry__1_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[9]_P_n_0\,
      I1 => \cycle_counter_reg[9]_LDC_n_0\,
      I2 => \cycle_counter_reg[9]_C_n_0\,
      O => \plusOp_carry__1_i_4_n_0\
    );
\plusOp_carry__2\: unisim.vcomponents.CARRY4
     port map (
      CI => \plusOp_carry__1_n_0\,
      CO(3) => \plusOp_carry__2_n_0\,
      CO(2) => \plusOp_carry__2_n_1\,
      CO(1) => \plusOp_carry__2_n_2\,
      CO(0) => \plusOp_carry__2_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => plusOp(16 downto 13),
      S(3) => \plusOp_carry__2_i_1_n_0\,
      S(2) => \plusOp_carry__2_i_2_n_0\,
      S(1) => \plusOp_carry__2_i_3_n_0\,
      S(0) => \plusOp_carry__2_i_4_n_0\
    );
\plusOp_carry__2_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[16]_P_n_0\,
      I1 => \cycle_counter_reg[16]_LDC_n_0\,
      I2 => \cycle_counter_reg[16]_C_n_0\,
      O => \plusOp_carry__2_i_1_n_0\
    );
\plusOp_carry__2_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[15]_P_n_0\,
      I1 => \cycle_counter_reg[15]_LDC_n_0\,
      I2 => \cycle_counter_reg[15]_C_n_0\,
      O => \plusOp_carry__2_i_2_n_0\
    );
\plusOp_carry__2_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[14]_P_n_0\,
      I1 => \cycle_counter_reg[14]_LDC_n_0\,
      I2 => \cycle_counter_reg[14]_C_n_0\,
      O => \plusOp_carry__2_i_3_n_0\
    );
\plusOp_carry__2_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[13]_P_n_0\,
      I1 => \cycle_counter_reg[13]_LDC_n_0\,
      I2 => \cycle_counter_reg[13]_C_n_0\,
      O => \plusOp_carry__2_i_4_n_0\
    );
\plusOp_carry__3\: unisim.vcomponents.CARRY4
     port map (
      CI => \plusOp_carry__2_n_0\,
      CO(3) => \plusOp_carry__3_n_0\,
      CO(2) => \plusOp_carry__3_n_1\,
      CO(1) => \plusOp_carry__3_n_2\,
      CO(0) => \plusOp_carry__3_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => plusOp(20 downto 17),
      S(3) => \plusOp_carry__3_i_1_n_0\,
      S(2) => \plusOp_carry__3_i_2_n_0\,
      S(1) => \plusOp_carry__3_i_3_n_0\,
      S(0) => \plusOp_carry__3_i_4_n_0\
    );
\plusOp_carry__3_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[20]_P_n_0\,
      I1 => \cycle_counter_reg[20]_LDC_n_0\,
      I2 => \cycle_counter_reg[20]_C_n_0\,
      O => \plusOp_carry__3_i_1_n_0\
    );
\plusOp_carry__3_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[19]_P_n_0\,
      I1 => \cycle_counter_reg[19]_LDC_n_0\,
      I2 => \cycle_counter_reg[19]_C_n_0\,
      O => \plusOp_carry__3_i_2_n_0\
    );
\plusOp_carry__3_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[18]_P_n_0\,
      I1 => \cycle_counter_reg[18]_LDC_n_0\,
      I2 => \cycle_counter_reg[18]_C_n_0\,
      O => \plusOp_carry__3_i_3_n_0\
    );
\plusOp_carry__3_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[17]_P_n_0\,
      I1 => \cycle_counter_reg[17]_LDC_n_0\,
      I2 => \cycle_counter_reg[17]_C_n_0\,
      O => \plusOp_carry__3_i_4_n_0\
    );
\plusOp_carry__4\: unisim.vcomponents.CARRY4
     port map (
      CI => \plusOp_carry__3_n_0\,
      CO(3) => \plusOp_carry__4_n_0\,
      CO(2) => \plusOp_carry__4_n_1\,
      CO(1) => \plusOp_carry__4_n_2\,
      CO(0) => \plusOp_carry__4_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => plusOp(24 downto 21),
      S(3) => \plusOp_carry__4_i_1_n_0\,
      S(2) => \plusOp_carry__4_i_2_n_0\,
      S(1) => \plusOp_carry__4_i_3_n_0\,
      S(0) => \plusOp_carry__4_i_4_n_0\
    );
\plusOp_carry__4_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[24]_P_n_0\,
      I1 => \cycle_counter_reg[24]_LDC_n_0\,
      I2 => \cycle_counter_reg[24]_C_n_0\,
      O => \plusOp_carry__4_i_1_n_0\
    );
\plusOp_carry__4_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[23]_P_n_0\,
      I1 => \cycle_counter_reg[23]_LDC_n_0\,
      I2 => \cycle_counter_reg[23]_C_n_0\,
      O => \plusOp_carry__4_i_2_n_0\
    );
\plusOp_carry__4_i_3\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[22]_P_n_0\,
      I1 => \cycle_counter_reg[22]_LDC_n_0\,
      I2 => \cycle_counter_reg[22]_C_n_0\,
      O => \plusOp_carry__4_i_3_n_0\
    );
\plusOp_carry__4_i_4\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[21]_P_n_0\,
      I1 => \cycle_counter_reg[21]_LDC_n_0\,
      I2 => \cycle_counter_reg[21]_C_n_0\,
      O => \plusOp_carry__4_i_4_n_0\
    );
\plusOp_carry__5\: unisim.vcomponents.CARRY4
     port map (
      CI => \plusOp_carry__4_n_0\,
      CO(3 downto 1) => \NLW_plusOp_carry__5_CO_UNCONNECTED\(3 downto 1),
      CO(0) => \plusOp_carry__5_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 2) => \NLW_plusOp_carry__5_O_UNCONNECTED\(3 downto 2),
      O(1 downto 0) => plusOp(26 downto 25),
      S(3 downto 2) => B"00",
      S(1) => \plusOp_carry__5_i_1_n_0\,
      S(0) => \plusOp_carry__5_i_2_n_0\
    );
\plusOp_carry__5_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[26]_P_n_0\,
      I1 => \cycle_counter_reg[26]_LDC_n_0\,
      I2 => \cycle_counter_reg[26]_C_n_0\,
      O => \plusOp_carry__5_i_1_n_0\
    );
\plusOp_carry__5_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[25]_P_n_0\,
      I1 => \cycle_counter_reg[25]_LDC_n_0\,
      I2 => \cycle_counter_reg[25]_C_n_0\,
      O => \plusOp_carry__5_i_2_n_0\
    );
plusOp_carry_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[0]_P_n_0\,
      I1 => \cycle_counter_reg[0]_LDC_n_0\,
      I2 => \cycle_counter_reg[0]_C_n_0\,
      O => cycle_counter(0)
    );
plusOp_carry_i_2: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[4]_P_n_0\,
      I1 => \cycle_counter_reg[4]_LDC_n_0\,
      I2 => \cycle_counter_reg[4]_C_n_0\,
      O => plusOp_carry_i_2_n_0
    );
plusOp_carry_i_3: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[3]_P_n_0\,
      I1 => \cycle_counter_reg[3]_LDC_n_0\,
      I2 => \cycle_counter_reg[3]_C_n_0\,
      O => plusOp_carry_i_3_n_0
    );
plusOp_carry_i_4: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[2]_P_n_0\,
      I1 => \cycle_counter_reg[2]_LDC_n_0\,
      I2 => \cycle_counter_reg[2]_C_n_0\,
      O => plusOp_carry_i_4_n_0
    );
plusOp_carry_i_5: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => \cycle_counter_reg[1]_P_n_0\,
      I1 => \cycle_counter_reg[1]_LDC_n_0\,
      I2 => \cycle_counter_reg[1]_C_n_0\,
      O => plusOp_carry_i_5_n_0
    );
w_axis_tready: unisim.vcomponents.LUT3
    generic map(
      INIT => X"08"
    )
        port map (
      I0 => eqOp,
      I1 => dl_en,
      I2 => eqOp1_out,
      O => \w_axis_tready__0\
    );
w_axis_tready_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => axis_aresetn,
      O => p_0_in
    );
w_axis_tready_reg: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => \w_axis_tready__0\,
      Q => s_axis_tready
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  port (
    axis_aclk : in STD_LOGIC;
    axis_aresetn : in STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tlast : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tlast : out STD_LOGIC;
    dl_en : in STD_LOGIC;
    fs_cycles : in STD_LOGIC_VECTOR ( 26 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "Transmit_Chain_inst_0_real_time_sampler_0_0,real_time_sampler,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix : entity is "real_time_sampler,Vivado 2022.1";
end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture STRUCTURE of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  signal \eqOp__8_carry__0_i_10_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_11_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_12_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_13_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_14_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_15_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_16_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_17_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_18_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_19_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_5_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_5_n_1\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_5_n_2\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_5_n_3\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_6_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_6_n_1\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_6_n_2\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_6_n_3\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_7_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_7_n_1\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_7_n_2\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_7_n_3\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_8_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__0_i_9_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__1_i_2_n_2\ : STD_LOGIC;
  signal \eqOp__8_carry__1_i_2_n_3\ : STD_LOGIC;
  signal \eqOp__8_carry__1_i_3_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__1_i_4_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry__1_i_5_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_10_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_11_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_12_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_13_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_14_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_15_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_16_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_17_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_18_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_5_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_5_n_1\ : STD_LOGIC;
  signal \eqOp__8_carry_i_5_n_2\ : STD_LOGIC;
  signal \eqOp__8_carry_i_5_n_3\ : STD_LOGIC;
  signal \eqOp__8_carry_i_6_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_6_n_1\ : STD_LOGIC;
  signal \eqOp__8_carry_i_6_n_2\ : STD_LOGIC;
  signal \eqOp__8_carry_i_6_n_3\ : STD_LOGIC;
  signal \eqOp__8_carry_i_7_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_7_n_1\ : STD_LOGIC;
  signal \eqOp__8_carry_i_7_n_2\ : STD_LOGIC;
  signal \eqOp__8_carry_i_7_n_3\ : STD_LOGIC;
  signal \eqOp__8_carry_i_8_n_0\ : STD_LOGIC;
  signal \eqOp__8_carry_i_9_n_0\ : STD_LOGIC;
  signal minusOp : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal \NLW_eqOp__8_carry__1_i_2_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal \NLW_eqOp__8_carry__1_i_2_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  attribute ADDER_THRESHOLD : integer;
  attribute ADDER_THRESHOLD of \eqOp__8_carry__0_i_5\ : label is 35;
  attribute ADDER_THRESHOLD of \eqOp__8_carry__0_i_6\ : label is 35;
  attribute ADDER_THRESHOLD of \eqOp__8_carry__0_i_7\ : label is 35;
  attribute ADDER_THRESHOLD of \eqOp__8_carry__1_i_2\ : label is 35;
  attribute ADDER_THRESHOLD of \eqOp__8_carry_i_5\ : label is 35;
  attribute ADDER_THRESHOLD of \eqOp__8_carry_i_6\ : label is 35;
  attribute ADDER_THRESHOLD of \eqOp__8_carry_i_7\ : label is 35;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of axis_aclk : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of axis_aclk : signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";
  attribute X_INTERFACE_INFO of axis_aresetn : signal is "xilinx.com:signal:reset:1.0 axis_aresetn RST";
  attribute X_INTERFACE_PARAMETER of axis_aresetn : signal is "XIL_INTERFACENAME axis_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of m_axis_tlast : signal is "xilinx.com:interface:axis:1.0 m_axis TLAST";
  attribute X_INTERFACE_PARAMETER of m_axis_tlast : signal is "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of m_axis_tvalid : signal is "xilinx.com:interface:axis:1.0 m_axis TVALID";
  attribute X_INTERFACE_INFO of s_axis_tlast : signal is "xilinx.com:interface:axis:1.0 s_axis TLAST";
  attribute X_INTERFACE_INFO of s_axis_tready : signal is "xilinx.com:interface:axis:1.0 s_axis TREADY";
  attribute X_INTERFACE_PARAMETER of s_axis_tready : signal is "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of s_axis_tvalid : signal is "xilinx.com:interface:axis:1.0 s_axis TVALID";
  attribute X_INTERFACE_INFO of m_axis_tdata : signal is "xilinx.com:interface:axis:1.0 m_axis TDATA";
  attribute X_INTERFACE_INFO of s_axis_tdata : signal is "xilinx.com:interface:axis:1.0 s_axis TDATA";
begin
\eqOp__8_carry__0_i_10\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(21),
      O => \eqOp__8_carry__0_i_10_n_0\
    );
\eqOp__8_carry__0_i_11\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(20),
      O => \eqOp__8_carry__0_i_11_n_0\
    );
\eqOp__8_carry__0_i_12\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(19),
      O => \eqOp__8_carry__0_i_12_n_0\
    );
\eqOp__8_carry__0_i_13\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(18),
      O => \eqOp__8_carry__0_i_13_n_0\
    );
\eqOp__8_carry__0_i_14\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(17),
      O => \eqOp__8_carry__0_i_14_n_0\
    );
\eqOp__8_carry__0_i_15\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(16),
      O => \eqOp__8_carry__0_i_15_n_0\
    );
\eqOp__8_carry__0_i_16\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(15),
      O => \eqOp__8_carry__0_i_16_n_0\
    );
\eqOp__8_carry__0_i_17\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(14),
      O => \eqOp__8_carry__0_i_17_n_0\
    );
\eqOp__8_carry__0_i_18\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(13),
      O => \eqOp__8_carry__0_i_18_n_0\
    );
\eqOp__8_carry__0_i_19\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(12),
      O => \eqOp__8_carry__0_i_19_n_0\
    );
\eqOp__8_carry__0_i_5\: unisim.vcomponents.CARRY4
     port map (
      CI => \eqOp__8_carry__0_i_6_n_0\,
      CO(3) => \eqOp__8_carry__0_i_5_n_0\,
      CO(2) => \eqOp__8_carry__0_i_5_n_1\,
      CO(1) => \eqOp__8_carry__0_i_5_n_2\,
      CO(0) => \eqOp__8_carry__0_i_5_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(23 downto 20),
      O(3 downto 0) => minusOp(23 downto 20),
      S(3) => \eqOp__8_carry__0_i_8_n_0\,
      S(2) => \eqOp__8_carry__0_i_9_n_0\,
      S(1) => \eqOp__8_carry__0_i_10_n_0\,
      S(0) => \eqOp__8_carry__0_i_11_n_0\
    );
\eqOp__8_carry__0_i_6\: unisim.vcomponents.CARRY4
     port map (
      CI => \eqOp__8_carry__0_i_7_n_0\,
      CO(3) => \eqOp__8_carry__0_i_6_n_0\,
      CO(2) => \eqOp__8_carry__0_i_6_n_1\,
      CO(1) => \eqOp__8_carry__0_i_6_n_2\,
      CO(0) => \eqOp__8_carry__0_i_6_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(19 downto 16),
      O(3 downto 0) => minusOp(19 downto 16),
      S(3) => \eqOp__8_carry__0_i_12_n_0\,
      S(2) => \eqOp__8_carry__0_i_13_n_0\,
      S(1) => \eqOp__8_carry__0_i_14_n_0\,
      S(0) => \eqOp__8_carry__0_i_15_n_0\
    );
\eqOp__8_carry__0_i_7\: unisim.vcomponents.CARRY4
     port map (
      CI => \eqOp__8_carry_i_5_n_0\,
      CO(3) => \eqOp__8_carry__0_i_7_n_0\,
      CO(2) => \eqOp__8_carry__0_i_7_n_1\,
      CO(1) => \eqOp__8_carry__0_i_7_n_2\,
      CO(0) => \eqOp__8_carry__0_i_7_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(15 downto 12),
      O(3 downto 0) => minusOp(15 downto 12),
      S(3) => \eqOp__8_carry__0_i_16_n_0\,
      S(2) => \eqOp__8_carry__0_i_17_n_0\,
      S(1) => \eqOp__8_carry__0_i_18_n_0\,
      S(0) => \eqOp__8_carry__0_i_19_n_0\
    );
\eqOp__8_carry__0_i_8\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(23),
      O => \eqOp__8_carry__0_i_8_n_0\
    );
\eqOp__8_carry__0_i_9\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(22),
      O => \eqOp__8_carry__0_i_9_n_0\
    );
\eqOp__8_carry__1_i_2\: unisim.vcomponents.CARRY4
     port map (
      CI => \eqOp__8_carry__0_i_5_n_0\,
      CO(3 downto 2) => \NLW_eqOp__8_carry__1_i_2_CO_UNCONNECTED\(3 downto 2),
      CO(1) => \eqOp__8_carry__1_i_2_n_2\,
      CO(0) => \eqOp__8_carry__1_i_2_n_3\,
      CYINIT => '0',
      DI(3 downto 2) => B"00",
      DI(1 downto 0) => fs_cycles(25 downto 24),
      O(3) => \NLW_eqOp__8_carry__1_i_2_O_UNCONNECTED\(3),
      O(2 downto 0) => minusOp(26 downto 24),
      S(3) => '0',
      S(2) => \eqOp__8_carry__1_i_3_n_0\,
      S(1) => \eqOp__8_carry__1_i_4_n_0\,
      S(0) => \eqOp__8_carry__1_i_5_n_0\
    );
\eqOp__8_carry__1_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(26),
      O => \eqOp__8_carry__1_i_3_n_0\
    );
\eqOp__8_carry__1_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(25),
      O => \eqOp__8_carry__1_i_4_n_0\
    );
\eqOp__8_carry__1_i_5\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(24),
      O => \eqOp__8_carry__1_i_5_n_0\
    );
\eqOp__8_carry_i_10\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(9),
      O => \eqOp__8_carry_i_10_n_0\
    );
\eqOp__8_carry_i_11\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(8),
      O => \eqOp__8_carry_i_11_n_0\
    );
\eqOp__8_carry_i_12\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(7),
      O => \eqOp__8_carry_i_12_n_0\
    );
\eqOp__8_carry_i_13\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(6),
      O => \eqOp__8_carry_i_13_n_0\
    );
\eqOp__8_carry_i_14\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(5),
      O => \eqOp__8_carry_i_14_n_0\
    );
\eqOp__8_carry_i_15\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(4),
      O => \eqOp__8_carry_i_15_n_0\
    );
\eqOp__8_carry_i_16\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(3),
      O => \eqOp__8_carry_i_16_n_0\
    );
\eqOp__8_carry_i_17\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(2),
      O => \eqOp__8_carry_i_17_n_0\
    );
\eqOp__8_carry_i_18\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(1),
      O => \eqOp__8_carry_i_18_n_0\
    );
\eqOp__8_carry_i_5\: unisim.vcomponents.CARRY4
     port map (
      CI => \eqOp__8_carry_i_6_n_0\,
      CO(3) => \eqOp__8_carry_i_5_n_0\,
      CO(2) => \eqOp__8_carry_i_5_n_1\,
      CO(1) => \eqOp__8_carry_i_5_n_2\,
      CO(0) => \eqOp__8_carry_i_5_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(11 downto 8),
      O(3 downto 0) => minusOp(11 downto 8),
      S(3) => \eqOp__8_carry_i_8_n_0\,
      S(2) => \eqOp__8_carry_i_9_n_0\,
      S(1) => \eqOp__8_carry_i_10_n_0\,
      S(0) => \eqOp__8_carry_i_11_n_0\
    );
\eqOp__8_carry_i_6\: unisim.vcomponents.CARRY4
     port map (
      CI => \eqOp__8_carry_i_7_n_0\,
      CO(3) => \eqOp__8_carry_i_6_n_0\,
      CO(2) => \eqOp__8_carry_i_6_n_1\,
      CO(1) => \eqOp__8_carry_i_6_n_2\,
      CO(0) => \eqOp__8_carry_i_6_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(7 downto 4),
      O(3 downto 0) => minusOp(7 downto 4),
      S(3) => \eqOp__8_carry_i_12_n_0\,
      S(2) => \eqOp__8_carry_i_13_n_0\,
      S(1) => \eqOp__8_carry_i_14_n_0\,
      S(0) => \eqOp__8_carry_i_15_n_0\
    );
\eqOp__8_carry_i_7\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \eqOp__8_carry_i_7_n_0\,
      CO(2) => \eqOp__8_carry_i_7_n_1\,
      CO(1) => \eqOp__8_carry_i_7_n_2\,
      CO(0) => \eqOp__8_carry_i_7_n_3\,
      CYINIT => '0',
      DI(3 downto 1) => fs_cycles(3 downto 1),
      DI(0) => '0',
      O(3 downto 0) => minusOp(3 downto 0),
      S(3) => \eqOp__8_carry_i_16_n_0\,
      S(2) => \eqOp__8_carry_i_17_n_0\,
      S(1) => \eqOp__8_carry_i_18_n_0\,
      S(0) => fs_cycles(0)
    );
\eqOp__8_carry_i_8\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(11),
      O => \eqOp__8_carry_i_8_n_0\
    );
\eqOp__8_carry_i_9\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(10),
      O => \eqOp__8_carry_i_9_n_0\
    );
inst: entity work.decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_real_time_sampler
     port map (
      axis_aclk => axis_aclk,
      axis_aresetn => axis_aresetn,
      dl_en => dl_en,
      fs_cycles(26 downto 0) => fs_cycles(26 downto 0),
      m_axis_tdata(31 downto 0) => m_axis_tdata(31 downto 0),
      m_axis_tlast => m_axis_tlast,
      m_axis_tvalid => m_axis_tvalid,
      minusOp(26 downto 0) => minusOp(26 downto 0),
      s_axis_tdata(31 downto 0) => s_axis_tdata(31 downto 0),
      s_axis_tlast => s_axis_tlast,
      s_axis_tready => s_axis_tready,
      s_axis_tvalid => s_axis_tvalid
    );
end STRUCTURE;
