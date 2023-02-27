-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Sun Feb 26 20:54:37 2023
-- Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top Transmit_Chain_inst_0_playback_ctrl_0_0 -prefix
--               Transmit_Chain_inst_0_playback_ctrl_0_0_ Transmit_Chain_inst_0_playback_ctrl_0_0_sim_netlist.vhdl
-- Design      : Transmit_Chain_inst_0_playback_ctrl_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity Transmit_Chain_inst_0_playback_ctrl_0_0_playback_ctrl is
  port (
    BRAM_PORT_addr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_tvalid : out STD_LOGIC;
    M_AXIS_tlast : out STD_LOGIC;
    M_AXIS_tready : in STD_LOGIC;
    BRAM_PORT_dout : in STD_LOGIC_VECTOR ( 31 downto 0 );
    axis_aclk : in STD_LOGIC;
    playback_en : in STD_LOGIC;
    axis_aresetn : in STD_LOGIC;
    symbols : in STD_LOGIC_VECTOR ( 3 downto 0 );
    continuous : in STD_LOGIC;
    nfft_scaled : in STD_LOGIC_VECTOR ( 11 downto 0 );
    fs_cycles : in STD_LOGIC_VECTOR ( 26 downto 0 )
  );
end Transmit_Chain_inst_0_playback_ctrl_0_0_playback_ctrl;

architecture STRUCTURE of Transmit_Chain_inst_0_playback_ctrl_0_0_playback_ctrl is
  signal \^bram_port_addr\ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal \^m_axis_tlast\ : STD_LOGIC;
  signal M_AXIS_tlast_i_1_n_0 : STD_LOGIC;
  signal \^m_axis_tvalid\ : STD_LOGIC;
  signal M_AXIS_tvalid_i_1_n_0 : STD_LOGIC;
  signal bram_addr0 : STD_LOGIC;
  signal \bram_addr[11]_i_2_n_0\ : STD_LOGIC;
  signal \bram_addr[11]_i_3_n_0\ : STD_LOGIC;
  signal \bram_addr[11]_i_4_n_0\ : STD_LOGIC;
  signal \bram_addr[11]_i_5_n_0\ : STD_LOGIC;
  signal \bram_addr[15]_i_2_n_0\ : STD_LOGIC;
  signal \bram_addr[15]_i_3_n_0\ : STD_LOGIC;
  signal \bram_addr[15]_i_4_n_0\ : STD_LOGIC;
  signal \bram_addr[15]_i_5_n_0\ : STD_LOGIC;
  signal \bram_addr[19]_i_2_n_0\ : STD_LOGIC;
  signal \bram_addr[19]_i_3_n_0\ : STD_LOGIC;
  signal \bram_addr[19]_i_4_n_0\ : STD_LOGIC;
  signal \bram_addr[19]_i_5_n_0\ : STD_LOGIC;
  signal \bram_addr[23]_i_2_n_0\ : STD_LOGIC;
  signal \bram_addr[23]_i_3_n_0\ : STD_LOGIC;
  signal \bram_addr[23]_i_4_n_0\ : STD_LOGIC;
  signal \bram_addr[23]_i_5_n_0\ : STD_LOGIC;
  signal \bram_addr[27]_i_2_n_0\ : STD_LOGIC;
  signal \bram_addr[27]_i_3_n_0\ : STD_LOGIC;
  signal \bram_addr[27]_i_4_n_0\ : STD_LOGIC;
  signal \bram_addr[27]_i_5_n_0\ : STD_LOGIC;
  signal \bram_addr[31]_i_1_n_0\ : STD_LOGIC;
  signal \bram_addr[31]_i_4_n_0\ : STD_LOGIC;
  signal \bram_addr[31]_i_5_n_0\ : STD_LOGIC;
  signal \bram_addr[31]_i_6_n_0\ : STD_LOGIC;
  signal \bram_addr[31]_i_7_n_0\ : STD_LOGIC;
  signal \bram_addr[31]_i_8_n_0\ : STD_LOGIC;
  signal \bram_addr[31]_i_9_n_0\ : STD_LOGIC;
  signal \bram_addr[3]_i_2_n_0\ : STD_LOGIC;
  signal \bram_addr[3]_i_3_n_0\ : STD_LOGIC;
  signal \bram_addr[3]_i_4_n_0\ : STD_LOGIC;
  signal \bram_addr[7]_i_2_n_0\ : STD_LOGIC;
  signal \bram_addr[7]_i_3_n_0\ : STD_LOGIC;
  signal \bram_addr[7]_i_4_n_0\ : STD_LOGIC;
  signal \bram_addr[7]_i_5_n_0\ : STD_LOGIC;
  signal \bram_addr_reg[11]_i_1_n_0\ : STD_LOGIC;
  signal \bram_addr_reg[11]_i_1_n_1\ : STD_LOGIC;
  signal \bram_addr_reg[11]_i_1_n_2\ : STD_LOGIC;
  signal \bram_addr_reg[11]_i_1_n_3\ : STD_LOGIC;
  signal \bram_addr_reg[11]_i_1_n_4\ : STD_LOGIC;
  signal \bram_addr_reg[11]_i_1_n_5\ : STD_LOGIC;
  signal \bram_addr_reg[11]_i_1_n_6\ : STD_LOGIC;
  signal \bram_addr_reg[11]_i_1_n_7\ : STD_LOGIC;
  signal \bram_addr_reg[15]_i_1_n_0\ : STD_LOGIC;
  signal \bram_addr_reg[15]_i_1_n_1\ : STD_LOGIC;
  signal \bram_addr_reg[15]_i_1_n_2\ : STD_LOGIC;
  signal \bram_addr_reg[15]_i_1_n_3\ : STD_LOGIC;
  signal \bram_addr_reg[15]_i_1_n_4\ : STD_LOGIC;
  signal \bram_addr_reg[15]_i_1_n_5\ : STD_LOGIC;
  signal \bram_addr_reg[15]_i_1_n_6\ : STD_LOGIC;
  signal \bram_addr_reg[15]_i_1_n_7\ : STD_LOGIC;
  signal \bram_addr_reg[19]_i_1_n_0\ : STD_LOGIC;
  signal \bram_addr_reg[19]_i_1_n_1\ : STD_LOGIC;
  signal \bram_addr_reg[19]_i_1_n_2\ : STD_LOGIC;
  signal \bram_addr_reg[19]_i_1_n_3\ : STD_LOGIC;
  signal \bram_addr_reg[19]_i_1_n_4\ : STD_LOGIC;
  signal \bram_addr_reg[19]_i_1_n_5\ : STD_LOGIC;
  signal \bram_addr_reg[19]_i_1_n_6\ : STD_LOGIC;
  signal \bram_addr_reg[19]_i_1_n_7\ : STD_LOGIC;
  signal \bram_addr_reg[23]_i_1_n_0\ : STD_LOGIC;
  signal \bram_addr_reg[23]_i_1_n_1\ : STD_LOGIC;
  signal \bram_addr_reg[23]_i_1_n_2\ : STD_LOGIC;
  signal \bram_addr_reg[23]_i_1_n_3\ : STD_LOGIC;
  signal \bram_addr_reg[23]_i_1_n_4\ : STD_LOGIC;
  signal \bram_addr_reg[23]_i_1_n_5\ : STD_LOGIC;
  signal \bram_addr_reg[23]_i_1_n_6\ : STD_LOGIC;
  signal \bram_addr_reg[23]_i_1_n_7\ : STD_LOGIC;
  signal \bram_addr_reg[27]_i_1_n_0\ : STD_LOGIC;
  signal \bram_addr_reg[27]_i_1_n_1\ : STD_LOGIC;
  signal \bram_addr_reg[27]_i_1_n_2\ : STD_LOGIC;
  signal \bram_addr_reg[27]_i_1_n_3\ : STD_LOGIC;
  signal \bram_addr_reg[27]_i_1_n_4\ : STD_LOGIC;
  signal \bram_addr_reg[27]_i_1_n_5\ : STD_LOGIC;
  signal \bram_addr_reg[27]_i_1_n_6\ : STD_LOGIC;
  signal \bram_addr_reg[27]_i_1_n_7\ : STD_LOGIC;
  signal \bram_addr_reg[31]_i_3_n_1\ : STD_LOGIC;
  signal \bram_addr_reg[31]_i_3_n_2\ : STD_LOGIC;
  signal \bram_addr_reg[31]_i_3_n_3\ : STD_LOGIC;
  signal \bram_addr_reg[31]_i_3_n_4\ : STD_LOGIC;
  signal \bram_addr_reg[31]_i_3_n_5\ : STD_LOGIC;
  signal \bram_addr_reg[31]_i_3_n_6\ : STD_LOGIC;
  signal \bram_addr_reg[31]_i_3_n_7\ : STD_LOGIC;
  signal \bram_addr_reg[3]_i_1_n_0\ : STD_LOGIC;
  signal \bram_addr_reg[3]_i_1_n_1\ : STD_LOGIC;
  signal \bram_addr_reg[3]_i_1_n_2\ : STD_LOGIC;
  signal \bram_addr_reg[3]_i_1_n_3\ : STD_LOGIC;
  signal \bram_addr_reg[3]_i_1_n_4\ : STD_LOGIC;
  signal \bram_addr_reg[3]_i_1_n_5\ : STD_LOGIC;
  signal \bram_addr_reg[3]_i_1_n_6\ : STD_LOGIC;
  signal \bram_addr_reg[3]_i_1_n_7\ : STD_LOGIC;
  signal \bram_addr_reg[7]_i_1_n_0\ : STD_LOGIC;
  signal \bram_addr_reg[7]_i_1_n_1\ : STD_LOGIC;
  signal \bram_addr_reg[7]_i_1_n_2\ : STD_LOGIC;
  signal \bram_addr_reg[7]_i_1_n_3\ : STD_LOGIC;
  signal \bram_addr_reg[7]_i_1_n_4\ : STD_LOGIC;
  signal \bram_addr_reg[7]_i_1_n_5\ : STD_LOGIC;
  signal \bram_addr_reg[7]_i_1_n_6\ : STD_LOGIC;
  signal \bram_addr_reg[7]_i_1_n_7\ : STD_LOGIC;
  signal eqOp : STD_LOGIC;
  signal \eqOp__3_carry__0_i_1_n_0\ : STD_LOGIC;
  signal \eqOp__3_carry__0_i_2_n_0\ : STD_LOGIC;
  signal \eqOp__3_carry__0_i_3_n_0\ : STD_LOGIC;
  signal \eqOp__3_carry__0_i_4_n_0\ : STD_LOGIC;
  signal \eqOp__3_carry__0_n_0\ : STD_LOGIC;
  signal \eqOp__3_carry__0_n_1\ : STD_LOGIC;
  signal \eqOp__3_carry__0_n_2\ : STD_LOGIC;
  signal \eqOp__3_carry__0_n_3\ : STD_LOGIC;
  signal \eqOp__3_carry__1_i_1_n_0\ : STD_LOGIC;
  signal \eqOp__3_carry_i_1_n_0\ : STD_LOGIC;
  signal \eqOp__3_carry_i_2_n_0\ : STD_LOGIC;
  signal \eqOp__3_carry_i_3_n_0\ : STD_LOGIC;
  signal \eqOp__3_carry_i_4_n_0\ : STD_LOGIC;
  signal \eqOp__3_carry_n_0\ : STD_LOGIC;
  signal \eqOp__3_carry_n_1\ : STD_LOGIC;
  signal \eqOp__3_carry_n_2\ : STD_LOGIC;
  signal \eqOp__3_carry_n_3\ : STD_LOGIC;
  signal eqOp_carry_i_1_n_0 : STD_LOGIC;
  signal eqOp_carry_i_2_n_0 : STD_LOGIC;
  signal eqOp_carry_i_3_n_0 : STD_LOGIC;
  signal eqOp_carry_i_4_n_0 : STD_LOGIC;
  signal eqOp_carry_n_0 : STD_LOGIC;
  signal eqOp_carry_n_1 : STD_LOGIC;
  signal eqOp_carry_n_2 : STD_LOGIC;
  signal eqOp_carry_n_3 : STD_LOGIC;
  signal minusOp : STD_LOGIC_VECTOR ( 11 downto 1 );
  signal \minusOp__20_carry__0_i_1_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__0_i_2_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__0_i_3_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__0_i_4_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__0_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__0_n_1\ : STD_LOGIC;
  signal \minusOp__20_carry__0_n_2\ : STD_LOGIC;
  signal \minusOp__20_carry__0_n_3\ : STD_LOGIC;
  signal \minusOp__20_carry__0_n_4\ : STD_LOGIC;
  signal \minusOp__20_carry__0_n_5\ : STD_LOGIC;
  signal \minusOp__20_carry__0_n_6\ : STD_LOGIC;
  signal \minusOp__20_carry__0_n_7\ : STD_LOGIC;
  signal \minusOp__20_carry__1_i_1_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__1_i_2_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__1_i_3_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__1_i_4_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__1_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__1_n_1\ : STD_LOGIC;
  signal \minusOp__20_carry__1_n_2\ : STD_LOGIC;
  signal \minusOp__20_carry__1_n_3\ : STD_LOGIC;
  signal \minusOp__20_carry__1_n_4\ : STD_LOGIC;
  signal \minusOp__20_carry__1_n_5\ : STD_LOGIC;
  signal \minusOp__20_carry__1_n_6\ : STD_LOGIC;
  signal \minusOp__20_carry__1_n_7\ : STD_LOGIC;
  signal \minusOp__20_carry__2_i_1_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__2_i_2_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__2_i_3_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__2_i_4_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__2_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__2_n_1\ : STD_LOGIC;
  signal \minusOp__20_carry__2_n_2\ : STD_LOGIC;
  signal \minusOp__20_carry__2_n_3\ : STD_LOGIC;
  signal \minusOp__20_carry__2_n_4\ : STD_LOGIC;
  signal \minusOp__20_carry__2_n_5\ : STD_LOGIC;
  signal \minusOp__20_carry__2_n_6\ : STD_LOGIC;
  signal \minusOp__20_carry__2_n_7\ : STD_LOGIC;
  signal \minusOp__20_carry__3_i_1_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__3_i_2_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__3_i_3_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__3_i_4_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__3_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__3_n_1\ : STD_LOGIC;
  signal \minusOp__20_carry__3_n_2\ : STD_LOGIC;
  signal \minusOp__20_carry__3_n_3\ : STD_LOGIC;
  signal \minusOp__20_carry__3_n_4\ : STD_LOGIC;
  signal \minusOp__20_carry__3_n_5\ : STD_LOGIC;
  signal \minusOp__20_carry__3_n_6\ : STD_LOGIC;
  signal \minusOp__20_carry__3_n_7\ : STD_LOGIC;
  signal \minusOp__20_carry__4_i_1_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__4_i_2_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__4_i_3_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__4_i_4_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__4_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__4_n_1\ : STD_LOGIC;
  signal \minusOp__20_carry__4_n_2\ : STD_LOGIC;
  signal \minusOp__20_carry__4_n_3\ : STD_LOGIC;
  signal \minusOp__20_carry__4_n_4\ : STD_LOGIC;
  signal \minusOp__20_carry__4_n_5\ : STD_LOGIC;
  signal \minusOp__20_carry__4_n_6\ : STD_LOGIC;
  signal \minusOp__20_carry__4_n_7\ : STD_LOGIC;
  signal \minusOp__20_carry__5_i_1_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__5_i_2_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry__5_n_3\ : STD_LOGIC;
  signal \minusOp__20_carry__5_n_6\ : STD_LOGIC;
  signal \minusOp__20_carry__5_n_7\ : STD_LOGIC;
  signal \minusOp__20_carry_i_1_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry_i_2_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry_i_3_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry_i_4_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry_n_0\ : STD_LOGIC;
  signal \minusOp__20_carry_n_1\ : STD_LOGIC;
  signal \minusOp__20_carry_n_2\ : STD_LOGIC;
  signal \minusOp__20_carry_n_3\ : STD_LOGIC;
  signal \minusOp__20_carry_n_4\ : STD_LOGIC;
  signal \minusOp__20_carry_n_5\ : STD_LOGIC;
  signal \minusOp__20_carry_n_6\ : STD_LOGIC;
  signal \minusOp__20_carry_n_7\ : STD_LOGIC;
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
  signal \minusOp_carry__1_n_2\ : STD_LOGIC;
  signal \minusOp_carry__1_n_3\ : STD_LOGIC;
  signal minusOp_carry_i_1_n_0 : STD_LOGIC;
  signal minusOp_carry_i_2_n_0 : STD_LOGIC;
  signal minusOp_carry_i_3_n_0 : STD_LOGIC;
  signal minusOp_carry_i_4_n_0 : STD_LOGIC;
  signal minusOp_carry_n_0 : STD_LOGIC;
  signal minusOp_carry_n_1 : STD_LOGIC;
  signal minusOp_carry_n_2 : STD_LOGIC;
  signal minusOp_carry_n_3 : STD_LOGIC;
  signal nfft_counter0 : STD_LOGIC;
  signal \nfft_counter[0]_i_1_n_0\ : STD_LOGIC;
  signal \nfft_counter[0]_i_4_n_0\ : STD_LOGIC;
  signal \nfft_counter[0]_i_5_n_0\ : STD_LOGIC;
  signal \nfft_counter[0]_i_6_n_0\ : STD_LOGIC;
  signal \nfft_counter[4]_i_2_n_0\ : STD_LOGIC;
  signal \nfft_counter[4]_i_3_n_0\ : STD_LOGIC;
  signal \nfft_counter[4]_i_4_n_0\ : STD_LOGIC;
  signal \nfft_counter[4]_i_5_n_0\ : STD_LOGIC;
  signal \nfft_counter[8]_i_2_n_0\ : STD_LOGIC;
  signal \nfft_counter[8]_i_3_n_0\ : STD_LOGIC;
  signal \nfft_counter[8]_i_4_n_0\ : STD_LOGIC;
  signal \nfft_counter[8]_i_5_n_0\ : STD_LOGIC;
  signal nfft_counter_reg : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal \nfft_counter_reg[0]_i_3_n_0\ : STD_LOGIC;
  signal \nfft_counter_reg[0]_i_3_n_1\ : STD_LOGIC;
  signal \nfft_counter_reg[0]_i_3_n_2\ : STD_LOGIC;
  signal \nfft_counter_reg[0]_i_3_n_3\ : STD_LOGIC;
  signal \nfft_counter_reg[0]_i_3_n_4\ : STD_LOGIC;
  signal \nfft_counter_reg[0]_i_3_n_5\ : STD_LOGIC;
  signal \nfft_counter_reg[0]_i_3_n_6\ : STD_LOGIC;
  signal \nfft_counter_reg[0]_i_3_n_7\ : STD_LOGIC;
  signal \nfft_counter_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \nfft_counter_reg[4]_i_1_n_1\ : STD_LOGIC;
  signal \nfft_counter_reg[4]_i_1_n_2\ : STD_LOGIC;
  signal \nfft_counter_reg[4]_i_1_n_3\ : STD_LOGIC;
  signal \nfft_counter_reg[4]_i_1_n_4\ : STD_LOGIC;
  signal \nfft_counter_reg[4]_i_1_n_5\ : STD_LOGIC;
  signal \nfft_counter_reg[4]_i_1_n_6\ : STD_LOGIC;
  signal \nfft_counter_reg[4]_i_1_n_7\ : STD_LOGIC;
  signal \nfft_counter_reg[8]_i_1_n_1\ : STD_LOGIC;
  signal \nfft_counter_reg[8]_i_1_n_2\ : STD_LOGIC;
  signal \nfft_counter_reg[8]_i_1_n_3\ : STD_LOGIC;
  signal \nfft_counter_reg[8]_i_1_n_4\ : STD_LOGIC;
  signal \nfft_counter_reg[8]_i_1_n_5\ : STD_LOGIC;
  signal \nfft_counter_reg[8]_i_1_n_6\ : STD_LOGIC;
  signal \nfft_counter_reg[8]_i_1_n_7\ : STD_LOGIC;
  signal out_tlast : STD_LOGIC;
  signal out_tlast_i_1_n_0 : STD_LOGIC;
  signal out_tlast_i_2_n_0 : STD_LOGIC;
  signal out_tvalid : STD_LOGIC;
  signal out_tvalid_i_1_n_0 : STD_LOGIC;
  signal p_0_in : STD_LOGIC;
  signal plusOp : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal quiet_counter0 : STD_LOGIC;
  signal \quiet_counter[0]_i_1_n_0\ : STD_LOGIC;
  signal \quiet_counter[0]_i_4_n_0\ : STD_LOGIC;
  signal quiet_counter_reg : STD_LOGIC_VECTOR ( 26 downto 0 );
  signal \quiet_counter_reg[0]_i_3_n_0\ : STD_LOGIC;
  signal \quiet_counter_reg[0]_i_3_n_1\ : STD_LOGIC;
  signal \quiet_counter_reg[0]_i_3_n_2\ : STD_LOGIC;
  signal \quiet_counter_reg[0]_i_3_n_3\ : STD_LOGIC;
  signal \quiet_counter_reg[0]_i_3_n_4\ : STD_LOGIC;
  signal \quiet_counter_reg[0]_i_3_n_5\ : STD_LOGIC;
  signal \quiet_counter_reg[0]_i_3_n_6\ : STD_LOGIC;
  signal \quiet_counter_reg[0]_i_3_n_7\ : STD_LOGIC;
  signal \quiet_counter_reg[12]_i_1_n_0\ : STD_LOGIC;
  signal \quiet_counter_reg[12]_i_1_n_1\ : STD_LOGIC;
  signal \quiet_counter_reg[12]_i_1_n_2\ : STD_LOGIC;
  signal \quiet_counter_reg[12]_i_1_n_3\ : STD_LOGIC;
  signal \quiet_counter_reg[12]_i_1_n_4\ : STD_LOGIC;
  signal \quiet_counter_reg[12]_i_1_n_5\ : STD_LOGIC;
  signal \quiet_counter_reg[12]_i_1_n_6\ : STD_LOGIC;
  signal \quiet_counter_reg[12]_i_1_n_7\ : STD_LOGIC;
  signal \quiet_counter_reg[16]_i_1_n_0\ : STD_LOGIC;
  signal \quiet_counter_reg[16]_i_1_n_1\ : STD_LOGIC;
  signal \quiet_counter_reg[16]_i_1_n_2\ : STD_LOGIC;
  signal \quiet_counter_reg[16]_i_1_n_3\ : STD_LOGIC;
  signal \quiet_counter_reg[16]_i_1_n_4\ : STD_LOGIC;
  signal \quiet_counter_reg[16]_i_1_n_5\ : STD_LOGIC;
  signal \quiet_counter_reg[16]_i_1_n_6\ : STD_LOGIC;
  signal \quiet_counter_reg[16]_i_1_n_7\ : STD_LOGIC;
  signal \quiet_counter_reg[20]_i_1_n_0\ : STD_LOGIC;
  signal \quiet_counter_reg[20]_i_1_n_1\ : STD_LOGIC;
  signal \quiet_counter_reg[20]_i_1_n_2\ : STD_LOGIC;
  signal \quiet_counter_reg[20]_i_1_n_3\ : STD_LOGIC;
  signal \quiet_counter_reg[20]_i_1_n_4\ : STD_LOGIC;
  signal \quiet_counter_reg[20]_i_1_n_5\ : STD_LOGIC;
  signal \quiet_counter_reg[20]_i_1_n_6\ : STD_LOGIC;
  signal \quiet_counter_reg[20]_i_1_n_7\ : STD_LOGIC;
  signal \quiet_counter_reg[24]_i_1_n_2\ : STD_LOGIC;
  signal \quiet_counter_reg[24]_i_1_n_3\ : STD_LOGIC;
  signal \quiet_counter_reg[24]_i_1_n_5\ : STD_LOGIC;
  signal \quiet_counter_reg[24]_i_1_n_6\ : STD_LOGIC;
  signal \quiet_counter_reg[24]_i_1_n_7\ : STD_LOGIC;
  signal \quiet_counter_reg[4]_i_1_n_0\ : STD_LOGIC;
  signal \quiet_counter_reg[4]_i_1_n_1\ : STD_LOGIC;
  signal \quiet_counter_reg[4]_i_1_n_2\ : STD_LOGIC;
  signal \quiet_counter_reg[4]_i_1_n_3\ : STD_LOGIC;
  signal \quiet_counter_reg[4]_i_1_n_4\ : STD_LOGIC;
  signal \quiet_counter_reg[4]_i_1_n_5\ : STD_LOGIC;
  signal \quiet_counter_reg[4]_i_1_n_6\ : STD_LOGIC;
  signal \quiet_counter_reg[4]_i_1_n_7\ : STD_LOGIC;
  signal \quiet_counter_reg[8]_i_1_n_0\ : STD_LOGIC;
  signal \quiet_counter_reg[8]_i_1_n_1\ : STD_LOGIC;
  signal \quiet_counter_reg[8]_i_1_n_2\ : STD_LOGIC;
  signal \quiet_counter_reg[8]_i_1_n_3\ : STD_LOGIC;
  signal \quiet_counter_reg[8]_i_1_n_4\ : STD_LOGIC;
  signal \quiet_counter_reg[8]_i_1_n_5\ : STD_LOGIC;
  signal \quiet_counter_reg[8]_i_1_n_6\ : STD_LOGIC;
  signal \quiet_counter_reg[8]_i_1_n_7\ : STD_LOGIC;
  signal r_axis_tready : STD_LOGIC;
  signal r_axis_tready_i_1_n_0 : STD_LOGIC;
  signal symbol_counter0 : STD_LOGIC;
  signal \symbol_counter[3]_i_1_n_0\ : STD_LOGIC;
  signal symbol_counter_reg : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_bram_addr_reg[31]_i_3_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  signal \NLW_eqOp__3_carry_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_eqOp__3_carry__0_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_eqOp__3_carry__1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \NLW_eqOp__3_carry__1_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_eqOp_carry_O_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal \NLW_minusOp__20_carry__5_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 1 );
  signal \NLW_minusOp__20_carry__5_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal \NLW_minusOp_carry__1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal \NLW_minusOp_carry__1_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  signal \NLW_nfft_counter_reg[8]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  signal \NLW_quiet_counter_reg[24]_i_1_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal \NLW_quiet_counter_reg[24]_i_1_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of M_AXIS_tvalid_i_1 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \bram_addr[31]_i_9\ : label is "soft_lutpair0";
  attribute x_interface_info : string;
  attribute x_interface_info of \bram_addr_reg[0]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter : string;
  attribute x_interface_parameter of \bram_addr_reg[0]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[10]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[10]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[11]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[11]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute ADDER_THRESHOLD : integer;
  attribute ADDER_THRESHOLD of \bram_addr_reg[11]_i_1\ : label is 11;
  attribute x_interface_info of \bram_addr_reg[12]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[12]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[13]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[13]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[14]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[14]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[15]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[15]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute ADDER_THRESHOLD of \bram_addr_reg[15]_i_1\ : label is 11;
  attribute x_interface_info of \bram_addr_reg[16]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[16]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[17]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[17]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[18]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[18]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[19]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[19]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute ADDER_THRESHOLD of \bram_addr_reg[19]_i_1\ : label is 11;
  attribute x_interface_info of \bram_addr_reg[1]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[1]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[20]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[20]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[21]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[21]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[22]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[22]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[23]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[23]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute ADDER_THRESHOLD of \bram_addr_reg[23]_i_1\ : label is 11;
  attribute x_interface_info of \bram_addr_reg[24]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[24]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[25]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[25]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[26]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[26]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[27]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[27]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute ADDER_THRESHOLD of \bram_addr_reg[27]_i_1\ : label is 11;
  attribute x_interface_info of \bram_addr_reg[28]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[28]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[29]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[29]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[2]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[2]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[30]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[30]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[31]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[31]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute ADDER_THRESHOLD of \bram_addr_reg[31]_i_3\ : label is 11;
  attribute x_interface_info of \bram_addr_reg[3]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[3]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute ADDER_THRESHOLD of \bram_addr_reg[3]_i_1\ : label is 11;
  attribute x_interface_info of \bram_addr_reg[4]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[4]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[5]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[5]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[6]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[6]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[7]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[7]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute ADDER_THRESHOLD of \bram_addr_reg[7]_i_1\ : label is 11;
  attribute x_interface_info of \bram_addr_reg[8]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[8]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute x_interface_info of \bram_addr_reg[9]\ : label is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute x_interface_parameter of \bram_addr_reg[9]\ : label is "MASTER_TYPE BRAM_CTRL";
  attribute ADDER_THRESHOLD of \minusOp__20_carry\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp__20_carry__0\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp__20_carry__1\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp__20_carry__2\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp__20_carry__3\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp__20_carry__4\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp__20_carry__5\ : label is 35;
  attribute ADDER_THRESHOLD of minusOp_carry : label is 35;
  attribute ADDER_THRESHOLD of \minusOp_carry__0\ : label is 35;
  attribute ADDER_THRESHOLD of \minusOp_carry__1\ : label is 35;
  attribute ADDER_THRESHOLD of \nfft_counter_reg[0]_i_3\ : label is 11;
  attribute ADDER_THRESHOLD of \nfft_counter_reg[4]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \nfft_counter_reg[8]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \quiet_counter_reg[0]_i_3\ : label is 11;
  attribute ADDER_THRESHOLD of \quiet_counter_reg[12]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \quiet_counter_reg[16]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \quiet_counter_reg[20]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \quiet_counter_reg[24]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \quiet_counter_reg[4]_i_1\ : label is 11;
  attribute ADDER_THRESHOLD of \quiet_counter_reg[8]_i_1\ : label is 11;
  attribute SOFT_HLUTNM of r_axis_tready_i_1 : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \symbol_counter[1]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \symbol_counter[2]_i_1\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \symbol_counter[3]_i_3\ : label is "soft_lutpair1";
begin
  BRAM_PORT_addr(31 downto 0) <= \^bram_port_addr\(31 downto 0);
  M_AXIS_tlast <= \^m_axis_tlast\;
  M_AXIS_tvalid <= \^m_axis_tvalid\;
\M_AXIS_tdata[31]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => axis_aresetn,
      O => p_0_in
    );
\M_AXIS_tdata_reg[0]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(0),
      Q => M_AXIS_tdata(0)
    );
\M_AXIS_tdata_reg[10]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(10),
      Q => M_AXIS_tdata(10)
    );
\M_AXIS_tdata_reg[11]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(11),
      Q => M_AXIS_tdata(11)
    );
\M_AXIS_tdata_reg[12]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(12),
      Q => M_AXIS_tdata(12)
    );
\M_AXIS_tdata_reg[13]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(13),
      Q => M_AXIS_tdata(13)
    );
\M_AXIS_tdata_reg[14]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(14),
      Q => M_AXIS_tdata(14)
    );
\M_AXIS_tdata_reg[15]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(15),
      Q => M_AXIS_tdata(15)
    );
\M_AXIS_tdata_reg[16]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(16),
      Q => M_AXIS_tdata(16)
    );
\M_AXIS_tdata_reg[17]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(17),
      Q => M_AXIS_tdata(17)
    );
\M_AXIS_tdata_reg[18]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(18),
      Q => M_AXIS_tdata(18)
    );
\M_AXIS_tdata_reg[19]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(19),
      Q => M_AXIS_tdata(19)
    );
\M_AXIS_tdata_reg[1]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(1),
      Q => M_AXIS_tdata(1)
    );
\M_AXIS_tdata_reg[20]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(20),
      Q => M_AXIS_tdata(20)
    );
\M_AXIS_tdata_reg[21]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(21),
      Q => M_AXIS_tdata(21)
    );
\M_AXIS_tdata_reg[22]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(22),
      Q => M_AXIS_tdata(22)
    );
\M_AXIS_tdata_reg[23]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(23),
      Q => M_AXIS_tdata(23)
    );
\M_AXIS_tdata_reg[24]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(24),
      Q => M_AXIS_tdata(24)
    );
\M_AXIS_tdata_reg[25]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(25),
      Q => M_AXIS_tdata(25)
    );
\M_AXIS_tdata_reg[26]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(26),
      Q => M_AXIS_tdata(26)
    );
\M_AXIS_tdata_reg[27]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(27),
      Q => M_AXIS_tdata(27)
    );
\M_AXIS_tdata_reg[28]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(28),
      Q => M_AXIS_tdata(28)
    );
\M_AXIS_tdata_reg[29]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(29),
      Q => M_AXIS_tdata(29)
    );
\M_AXIS_tdata_reg[2]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(2),
      Q => M_AXIS_tdata(2)
    );
\M_AXIS_tdata_reg[30]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(30),
      Q => M_AXIS_tdata(30)
    );
\M_AXIS_tdata_reg[31]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(31),
      Q => M_AXIS_tdata(31)
    );
\M_AXIS_tdata_reg[3]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(3),
      Q => M_AXIS_tdata(3)
    );
\M_AXIS_tdata_reg[4]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(4),
      Q => M_AXIS_tdata(4)
    );
\M_AXIS_tdata_reg[5]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(5),
      Q => M_AXIS_tdata(5)
    );
\M_AXIS_tdata_reg[6]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(6),
      Q => M_AXIS_tdata(6)
    );
\M_AXIS_tdata_reg[7]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(7),
      Q => M_AXIS_tdata(7)
    );
\M_AXIS_tdata_reg[8]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(8),
      Q => M_AXIS_tdata(8)
    );
\M_AXIS_tdata_reg[9]\: unisim.vcomponents.FDCE
     port map (
      C => axis_aclk,
      CE => '1',
      CLR => p_0_in,
      D => BRAM_PORT_dout(9),
      Q => M_AXIS_tdata(9)
    );
M_AXIS_tlast_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => out_tlast,
      I1 => axis_aresetn,
      I2 => \^m_axis_tlast\,
      O => M_AXIS_tlast_i_1_n_0
    );
M_AXIS_tlast_reg: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => M_AXIS_tlast_i_1_n_0,
      Q => \^m_axis_tlast\,
      R => '0'
    );
M_AXIS_tvalid_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => out_tvalid,
      I1 => axis_aresetn,
      I2 => \^m_axis_tvalid\,
      O => M_AXIS_tvalid_i_1_n_0
    );
M_AXIS_tvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => M_AXIS_tvalid_i_1_n_0,
      Q => \^m_axis_tvalid\,
      R => '0'
    );
\bram_addr[11]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(11),
      O => \bram_addr[11]_i_2_n_0\
    );
\bram_addr[11]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(10),
      O => \bram_addr[11]_i_3_n_0\
    );
\bram_addr[11]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(9),
      O => \bram_addr[11]_i_4_n_0\
    );
\bram_addr[11]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(8),
      O => \bram_addr[11]_i_5_n_0\
    );
\bram_addr[15]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(15),
      O => \bram_addr[15]_i_2_n_0\
    );
\bram_addr[15]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(14),
      O => \bram_addr[15]_i_3_n_0\
    );
\bram_addr[15]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(13),
      O => \bram_addr[15]_i_4_n_0\
    );
\bram_addr[15]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(12),
      O => \bram_addr[15]_i_5_n_0\
    );
\bram_addr[19]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(19),
      O => \bram_addr[19]_i_2_n_0\
    );
\bram_addr[19]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(18),
      O => \bram_addr[19]_i_3_n_0\
    );
\bram_addr[19]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(17),
      O => \bram_addr[19]_i_4_n_0\
    );
\bram_addr[19]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(16),
      O => \bram_addr[19]_i_5_n_0\
    );
\bram_addr[23]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(23),
      O => \bram_addr[23]_i_2_n_0\
    );
\bram_addr[23]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(22),
      O => \bram_addr[23]_i_3_n_0\
    );
\bram_addr[23]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(21),
      O => \bram_addr[23]_i_4_n_0\
    );
\bram_addr[23]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(20),
      O => \bram_addr[23]_i_5_n_0\
    );
\bram_addr[27]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(27),
      O => \bram_addr[27]_i_2_n_0\
    );
\bram_addr[27]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(26),
      O => \bram_addr[27]_i_3_n_0\
    );
\bram_addr[27]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(25),
      O => \bram_addr[27]_i_4_n_0\
    );
\bram_addr[27]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(24),
      O => \bram_addr[27]_i_5_n_0\
    );
\bram_addr[31]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"D0"
    )
        port map (
      I0 => playback_en,
      I1 => \bram_addr[31]_i_4_n_0\,
      I2 => axis_aresetn,
      O => \bram_addr[31]_i_1_n_0\
    );
\bram_addr[31]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A808"
    )
        port map (
      I0 => axis_aresetn,
      I1 => r_axis_tready,
      I2 => M_AXIS_tready,
      I3 => eqOp,
      O => bram_addr0
    );
\bram_addr[31]_i_4\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"90090000"
    )
        port map (
      I0 => symbols(3),
      I1 => symbol_counter_reg(3),
      I2 => symbols(2),
      I3 => symbol_counter_reg(2),
      I4 => \bram_addr[31]_i_9_n_0\,
      O => \bram_addr[31]_i_4_n_0\
    );
\bram_addr[31]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => \^bram_port_addr\(31),
      I1 => M_AXIS_tready,
      O => \bram_addr[31]_i_5_n_0\
    );
\bram_addr[31]_i_6\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(30),
      O => \bram_addr[31]_i_6_n_0\
    );
\bram_addr[31]_i_7\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(29),
      O => \bram_addr[31]_i_7_n_0\
    );
\bram_addr[31]_i_8\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(28),
      O => \bram_addr[31]_i_8_n_0\
    );
\bram_addr[31]_i_9\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"9009"
    )
        port map (
      I0 => symbol_counter_reg(0),
      I1 => symbols(0),
      I2 => symbol_counter_reg(1),
      I3 => symbols(1),
      O => \bram_addr[31]_i_9_n_0\
    );
\bram_addr[3]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(3),
      O => \bram_addr[3]_i_2_n_0\
    );
\bram_addr[3]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(2),
      O => \bram_addr[3]_i_3_n_0\
    );
\bram_addr[3]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(1),
      O => \bram_addr[3]_i_4_n_0\
    );
\bram_addr[7]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(7),
      O => \bram_addr[7]_i_2_n_0\
    );
\bram_addr[7]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(6),
      O => \bram_addr[7]_i_3_n_0\
    );
\bram_addr[7]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(5),
      O => \bram_addr[7]_i_4_n_0\
    );
\bram_addr[7]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => \^bram_port_addr\(4),
      O => \bram_addr[7]_i_5_n_0\
    );
\bram_addr_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[3]_i_1_n_7\,
      Q => \^bram_port_addr\(0),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[11]_i_1_n_5\,
      Q => \^bram_port_addr\(10),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[11]_i_1_n_4\,
      Q => \^bram_port_addr\(11),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[11]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bram_addr_reg[7]_i_1_n_0\,
      CO(3) => \bram_addr_reg[11]_i_1_n_0\,
      CO(2) => \bram_addr_reg[11]_i_1_n_1\,
      CO(1) => \bram_addr_reg[11]_i_1_n_2\,
      CO(0) => \bram_addr_reg[11]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => \^bram_port_addr\(11 downto 8),
      O(3) => \bram_addr_reg[11]_i_1_n_4\,
      O(2) => \bram_addr_reg[11]_i_1_n_5\,
      O(1) => \bram_addr_reg[11]_i_1_n_6\,
      O(0) => \bram_addr_reg[11]_i_1_n_7\,
      S(3) => \bram_addr[11]_i_2_n_0\,
      S(2) => \bram_addr[11]_i_3_n_0\,
      S(1) => \bram_addr[11]_i_4_n_0\,
      S(0) => \bram_addr[11]_i_5_n_0\
    );
\bram_addr_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[15]_i_1_n_7\,
      Q => \^bram_port_addr\(12),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[15]_i_1_n_6\,
      Q => \^bram_port_addr\(13),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[15]_i_1_n_5\,
      Q => \^bram_port_addr\(14),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[15]_i_1_n_4\,
      Q => \^bram_port_addr\(15),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[15]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bram_addr_reg[11]_i_1_n_0\,
      CO(3) => \bram_addr_reg[15]_i_1_n_0\,
      CO(2) => \bram_addr_reg[15]_i_1_n_1\,
      CO(1) => \bram_addr_reg[15]_i_1_n_2\,
      CO(0) => \bram_addr_reg[15]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => \^bram_port_addr\(15 downto 12),
      O(3) => \bram_addr_reg[15]_i_1_n_4\,
      O(2) => \bram_addr_reg[15]_i_1_n_5\,
      O(1) => \bram_addr_reg[15]_i_1_n_6\,
      O(0) => \bram_addr_reg[15]_i_1_n_7\,
      S(3) => \bram_addr[15]_i_2_n_0\,
      S(2) => \bram_addr[15]_i_3_n_0\,
      S(1) => \bram_addr[15]_i_4_n_0\,
      S(0) => \bram_addr[15]_i_5_n_0\
    );
\bram_addr_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[19]_i_1_n_7\,
      Q => \^bram_port_addr\(16),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[19]_i_1_n_6\,
      Q => \^bram_port_addr\(17),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[19]_i_1_n_5\,
      Q => \^bram_port_addr\(18),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[19]_i_1_n_4\,
      Q => \^bram_port_addr\(19),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[19]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bram_addr_reg[15]_i_1_n_0\,
      CO(3) => \bram_addr_reg[19]_i_1_n_0\,
      CO(2) => \bram_addr_reg[19]_i_1_n_1\,
      CO(1) => \bram_addr_reg[19]_i_1_n_2\,
      CO(0) => \bram_addr_reg[19]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => \^bram_port_addr\(19 downto 16),
      O(3) => \bram_addr_reg[19]_i_1_n_4\,
      O(2) => \bram_addr_reg[19]_i_1_n_5\,
      O(1) => \bram_addr_reg[19]_i_1_n_6\,
      O(0) => \bram_addr_reg[19]_i_1_n_7\,
      S(3) => \bram_addr[19]_i_2_n_0\,
      S(2) => \bram_addr[19]_i_3_n_0\,
      S(1) => \bram_addr[19]_i_4_n_0\,
      S(0) => \bram_addr[19]_i_5_n_0\
    );
\bram_addr_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[3]_i_1_n_6\,
      Q => \^bram_port_addr\(1),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[23]_i_1_n_7\,
      Q => \^bram_port_addr\(20),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[23]_i_1_n_6\,
      Q => \^bram_port_addr\(21),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[23]_i_1_n_5\,
      Q => \^bram_port_addr\(22),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[23]_i_1_n_4\,
      Q => \^bram_port_addr\(23),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[23]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bram_addr_reg[19]_i_1_n_0\,
      CO(3) => \bram_addr_reg[23]_i_1_n_0\,
      CO(2) => \bram_addr_reg[23]_i_1_n_1\,
      CO(1) => \bram_addr_reg[23]_i_1_n_2\,
      CO(0) => \bram_addr_reg[23]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => \^bram_port_addr\(23 downto 20),
      O(3) => \bram_addr_reg[23]_i_1_n_4\,
      O(2) => \bram_addr_reg[23]_i_1_n_5\,
      O(1) => \bram_addr_reg[23]_i_1_n_6\,
      O(0) => \bram_addr_reg[23]_i_1_n_7\,
      S(3) => \bram_addr[23]_i_2_n_0\,
      S(2) => \bram_addr[23]_i_3_n_0\,
      S(1) => \bram_addr[23]_i_4_n_0\,
      S(0) => \bram_addr[23]_i_5_n_0\
    );
\bram_addr_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[27]_i_1_n_7\,
      Q => \^bram_port_addr\(24),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[27]_i_1_n_6\,
      Q => \^bram_port_addr\(25),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[27]_i_1_n_5\,
      Q => \^bram_port_addr\(26),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[27]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[27]_i_1_n_4\,
      Q => \^bram_port_addr\(27),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[27]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bram_addr_reg[23]_i_1_n_0\,
      CO(3) => \bram_addr_reg[27]_i_1_n_0\,
      CO(2) => \bram_addr_reg[27]_i_1_n_1\,
      CO(1) => \bram_addr_reg[27]_i_1_n_2\,
      CO(0) => \bram_addr_reg[27]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => \^bram_port_addr\(27 downto 24),
      O(3) => \bram_addr_reg[27]_i_1_n_4\,
      O(2) => \bram_addr_reg[27]_i_1_n_5\,
      O(1) => \bram_addr_reg[27]_i_1_n_6\,
      O(0) => \bram_addr_reg[27]_i_1_n_7\,
      S(3) => \bram_addr[27]_i_2_n_0\,
      S(2) => \bram_addr[27]_i_3_n_0\,
      S(1) => \bram_addr[27]_i_4_n_0\,
      S(0) => \bram_addr[27]_i_5_n_0\
    );
\bram_addr_reg[28]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[31]_i_3_n_7\,
      Q => \^bram_port_addr\(28),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[29]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[31]_i_3_n_6\,
      Q => \^bram_port_addr\(29),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[3]_i_1_n_5\,
      Q => \^bram_port_addr\(2),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[30]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[31]_i_3_n_5\,
      Q => \^bram_port_addr\(30),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[31]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[31]_i_3_n_4\,
      Q => \^bram_port_addr\(31),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[31]_i_3\: unisim.vcomponents.CARRY4
     port map (
      CI => \bram_addr_reg[27]_i_1_n_0\,
      CO(3) => \NLW_bram_addr_reg[31]_i_3_CO_UNCONNECTED\(3),
      CO(2) => \bram_addr_reg[31]_i_3_n_1\,
      CO(1) => \bram_addr_reg[31]_i_3_n_2\,
      CO(0) => \bram_addr_reg[31]_i_3_n_3\,
      CYINIT => '0',
      DI(3) => '0',
      DI(2 downto 0) => \^bram_port_addr\(30 downto 28),
      O(3) => \bram_addr_reg[31]_i_3_n_4\,
      O(2) => \bram_addr_reg[31]_i_3_n_5\,
      O(1) => \bram_addr_reg[31]_i_3_n_6\,
      O(0) => \bram_addr_reg[31]_i_3_n_7\,
      S(3) => \bram_addr[31]_i_5_n_0\,
      S(2) => \bram_addr[31]_i_6_n_0\,
      S(1) => \bram_addr[31]_i_7_n_0\,
      S(0) => \bram_addr[31]_i_8_n_0\
    );
\bram_addr_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[3]_i_1_n_4\,
      Q => \^bram_port_addr\(3),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[3]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \bram_addr_reg[3]_i_1_n_0\,
      CO(2) => \bram_addr_reg[3]_i_1_n_1\,
      CO(1) => \bram_addr_reg[3]_i_1_n_2\,
      CO(0) => \bram_addr_reg[3]_i_1_n_3\,
      CYINIT => '1',
      DI(3 downto 1) => \^bram_port_addr\(3 downto 1),
      DI(0) => '0',
      O(3) => \bram_addr_reg[3]_i_1_n_4\,
      O(2) => \bram_addr_reg[3]_i_1_n_5\,
      O(1) => \bram_addr_reg[3]_i_1_n_6\,
      O(0) => \bram_addr_reg[3]_i_1_n_7\,
      S(3) => \bram_addr[3]_i_2_n_0\,
      S(2) => \bram_addr[3]_i_3_n_0\,
      S(1) => \bram_addr[3]_i_4_n_0\,
      S(0) => \^bram_port_addr\(0)
    );
\bram_addr_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[7]_i_1_n_7\,
      Q => \^bram_port_addr\(4),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[7]_i_1_n_6\,
      Q => \^bram_port_addr\(5),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[7]_i_1_n_5\,
      Q => \^bram_port_addr\(6),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[7]_i_1_n_4\,
      Q => \^bram_port_addr\(7),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[7]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \bram_addr_reg[3]_i_1_n_0\,
      CO(3) => \bram_addr_reg[7]_i_1_n_0\,
      CO(2) => \bram_addr_reg[7]_i_1_n_1\,
      CO(1) => \bram_addr_reg[7]_i_1_n_2\,
      CO(0) => \bram_addr_reg[7]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => \^bram_port_addr\(7 downto 4),
      O(3) => \bram_addr_reg[7]_i_1_n_4\,
      O(2) => \bram_addr_reg[7]_i_1_n_5\,
      O(1) => \bram_addr_reg[7]_i_1_n_6\,
      O(0) => \bram_addr_reg[7]_i_1_n_7\,
      S(3) => \bram_addr[7]_i_2_n_0\,
      S(2) => \bram_addr[7]_i_3_n_0\,
      S(1) => \bram_addr[7]_i_4_n_0\,
      S(0) => \bram_addr[7]_i_5_n_0\
    );
\bram_addr_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[11]_i_1_n_7\,
      Q => \^bram_port_addr\(8),
      R => \bram_addr[31]_i_1_n_0\
    );
\bram_addr_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => bram_addr0,
      D => \bram_addr_reg[11]_i_1_n_6\,
      Q => \^bram_port_addr\(9),
      R => \bram_addr[31]_i_1_n_0\
    );
\eqOp__3_carry\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \eqOp__3_carry_n_0\,
      CO(2) => \eqOp__3_carry_n_1\,
      CO(1) => \eqOp__3_carry_n_2\,
      CO(0) => \eqOp__3_carry_n_3\,
      CYINIT => '1',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => \NLW_eqOp__3_carry_O_UNCONNECTED\(3 downto 0),
      S(3) => \eqOp__3_carry_i_1_n_0\,
      S(2) => \eqOp__3_carry_i_2_n_0\,
      S(1) => \eqOp__3_carry_i_3_n_0\,
      S(0) => \eqOp__3_carry_i_4_n_0\
    );
\eqOp__3_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => \eqOp__3_carry_n_0\,
      CO(3) => \eqOp__3_carry__0_n_0\,
      CO(2) => \eqOp__3_carry__0_n_1\,
      CO(1) => \eqOp__3_carry__0_n_2\,
      CO(0) => \eqOp__3_carry__0_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => \NLW_eqOp__3_carry__0_O_UNCONNECTED\(3 downto 0),
      S(3) => \eqOp__3_carry__0_i_1_n_0\,
      S(2) => \eqOp__3_carry__0_i_2_n_0\,
      S(1) => \eqOp__3_carry__0_i_3_n_0\,
      S(0) => \eqOp__3_carry__0_i_4_n_0\
    );
\eqOp__3_carry__0_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => quiet_counter_reg(22),
      I1 => \minusOp__20_carry__4_n_6\,
      I2 => quiet_counter_reg(21),
      I3 => \minusOp__20_carry__4_n_7\,
      I4 => \minusOp__20_carry__4_n_5\,
      I5 => quiet_counter_reg(23),
      O => \eqOp__3_carry__0_i_1_n_0\
    );
\eqOp__3_carry__0_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => quiet_counter_reg(19),
      I1 => \minusOp__20_carry__3_n_5\,
      I2 => quiet_counter_reg(18),
      I3 => \minusOp__20_carry__3_n_6\,
      I4 => \minusOp__20_carry__3_n_4\,
      I5 => quiet_counter_reg(20),
      O => \eqOp__3_carry__0_i_2_n_0\
    );
\eqOp__3_carry__0_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => quiet_counter_reg(16),
      I1 => \minusOp__20_carry__2_n_4\,
      I2 => quiet_counter_reg(15),
      I3 => \minusOp__20_carry__2_n_5\,
      I4 => \minusOp__20_carry__3_n_7\,
      I5 => quiet_counter_reg(17),
      O => \eqOp__3_carry__0_i_3_n_0\
    );
\eqOp__3_carry__0_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => quiet_counter_reg(13),
      I1 => \minusOp__20_carry__2_n_7\,
      I2 => quiet_counter_reg(12),
      I3 => \minusOp__20_carry__1_n_4\,
      I4 => \minusOp__20_carry__2_n_6\,
      I5 => quiet_counter_reg(14),
      O => \eqOp__3_carry__0_i_4_n_0\
    );
\eqOp__3_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \eqOp__3_carry__0_n_0\,
      CO(3 downto 1) => \NLW_eqOp__3_carry__1_CO_UNCONNECTED\(3 downto 1),
      CO(0) => eqOp,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3 downto 0) => \NLW_eqOp__3_carry__1_O_UNCONNECTED\(3 downto 0),
      S(3 downto 1) => B"000",
      S(0) => \eqOp__3_carry__1_i_1_n_0\
    );
\eqOp__3_carry__1_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => quiet_counter_reg(25),
      I1 => \minusOp__20_carry__5_n_7\,
      I2 => quiet_counter_reg(24),
      I3 => \minusOp__20_carry__4_n_4\,
      I4 => \minusOp__20_carry__5_n_6\,
      I5 => quiet_counter_reg(26),
      O => \eqOp__3_carry__1_i_1_n_0\
    );
\eqOp__3_carry_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => quiet_counter_reg(10),
      I1 => \minusOp__20_carry__1_n_6\,
      I2 => quiet_counter_reg(9),
      I3 => \minusOp__20_carry__1_n_7\,
      I4 => \minusOp__20_carry__1_n_5\,
      I5 => quiet_counter_reg(11),
      O => \eqOp__3_carry_i_1_n_0\
    );
\eqOp__3_carry_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => quiet_counter_reg(7),
      I1 => \minusOp__20_carry__0_n_5\,
      I2 => quiet_counter_reg(6),
      I3 => \minusOp__20_carry__0_n_6\,
      I4 => \minusOp__20_carry__0_n_4\,
      I5 => quiet_counter_reg(8),
      O => \eqOp__3_carry_i_2_n_0\
    );
\eqOp__3_carry_i_3\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => quiet_counter_reg(4),
      I1 => \minusOp__20_carry_n_4\,
      I2 => quiet_counter_reg(3),
      I3 => \minusOp__20_carry_n_5\,
      I4 => \minusOp__20_carry__0_n_7\,
      I5 => quiet_counter_reg(5),
      O => \eqOp__3_carry_i_3_n_0\
    );
\eqOp__3_carry_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0990000000000990"
    )
        port map (
      I0 => quiet_counter_reg(1),
      I1 => \minusOp__20_carry_n_7\,
      I2 => fs_cycles(0),
      I3 => quiet_counter_reg(0),
      I4 => \minusOp__20_carry_n_6\,
      I5 => quiet_counter_reg(2),
      O => \eqOp__3_carry_i_4_n_0\
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
eqOp_carry_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => nfft_counter_reg(10),
      I1 => minusOp(10),
      I2 => nfft_counter_reg(9),
      I3 => minusOp(9),
      I4 => nfft_counter_reg(11),
      I5 => minusOp(11),
      O => eqOp_carry_i_1_n_0
    );
eqOp_carry_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => nfft_counter_reg(7),
      I1 => minusOp(7),
      I2 => nfft_counter_reg(6),
      I3 => minusOp(6),
      I4 => minusOp(8),
      I5 => nfft_counter_reg(8),
      O => eqOp_carry_i_2_n_0
    );
eqOp_carry_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"9009000000009009"
    )
        port map (
      I0 => nfft_counter_reg(4),
      I1 => minusOp(4),
      I2 => nfft_counter_reg(3),
      I3 => minusOp(3),
      I4 => minusOp(5),
      I5 => nfft_counter_reg(5),
      O => eqOp_carry_i_3_n_0
    );
eqOp_carry_i_4: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0990000000000990"
    )
        port map (
      I0 => nfft_counter_reg(1),
      I1 => minusOp(1),
      I2 => nfft_scaled(0),
      I3 => nfft_counter_reg(0),
      I4 => minusOp(2),
      I5 => nfft_counter_reg(2),
      O => eqOp_carry_i_4_n_0
    );
\minusOp__20_carry\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \minusOp__20_carry_n_0\,
      CO(2) => \minusOp__20_carry_n_1\,
      CO(1) => \minusOp__20_carry_n_2\,
      CO(0) => \minusOp__20_carry_n_3\,
      CYINIT => fs_cycles(0),
      DI(3 downto 0) => fs_cycles(4 downto 1),
      O(3) => \minusOp__20_carry_n_4\,
      O(2) => \minusOp__20_carry_n_5\,
      O(1) => \minusOp__20_carry_n_6\,
      O(0) => \minusOp__20_carry_n_7\,
      S(3) => \minusOp__20_carry_i_1_n_0\,
      S(2) => \minusOp__20_carry_i_2_n_0\,
      S(1) => \minusOp__20_carry_i_3_n_0\,
      S(0) => \minusOp__20_carry_i_4_n_0\
    );
\minusOp__20_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp__20_carry_n_0\,
      CO(3) => \minusOp__20_carry__0_n_0\,
      CO(2) => \minusOp__20_carry__0_n_1\,
      CO(1) => \minusOp__20_carry__0_n_2\,
      CO(0) => \minusOp__20_carry__0_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(8 downto 5),
      O(3) => \minusOp__20_carry__0_n_4\,
      O(2) => \minusOp__20_carry__0_n_5\,
      O(1) => \minusOp__20_carry__0_n_6\,
      O(0) => \minusOp__20_carry__0_n_7\,
      S(3) => \minusOp__20_carry__0_i_1_n_0\,
      S(2) => \minusOp__20_carry__0_i_2_n_0\,
      S(1) => \minusOp__20_carry__0_i_3_n_0\,
      S(0) => \minusOp__20_carry__0_i_4_n_0\
    );
\minusOp__20_carry__0_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(8),
      O => \minusOp__20_carry__0_i_1_n_0\
    );
\minusOp__20_carry__0_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(7),
      O => \minusOp__20_carry__0_i_2_n_0\
    );
\minusOp__20_carry__0_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(6),
      O => \minusOp__20_carry__0_i_3_n_0\
    );
\minusOp__20_carry__0_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(5),
      O => \minusOp__20_carry__0_i_4_n_0\
    );
\minusOp__20_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp__20_carry__0_n_0\,
      CO(3) => \minusOp__20_carry__1_n_0\,
      CO(2) => \minusOp__20_carry__1_n_1\,
      CO(1) => \minusOp__20_carry__1_n_2\,
      CO(0) => \minusOp__20_carry__1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(12 downto 9),
      O(3) => \minusOp__20_carry__1_n_4\,
      O(2) => \minusOp__20_carry__1_n_5\,
      O(1) => \minusOp__20_carry__1_n_6\,
      O(0) => \minusOp__20_carry__1_n_7\,
      S(3) => \minusOp__20_carry__1_i_1_n_0\,
      S(2) => \minusOp__20_carry__1_i_2_n_0\,
      S(1) => \minusOp__20_carry__1_i_3_n_0\,
      S(0) => \minusOp__20_carry__1_i_4_n_0\
    );
\minusOp__20_carry__1_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(12),
      O => \minusOp__20_carry__1_i_1_n_0\
    );
\minusOp__20_carry__1_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(11),
      O => \minusOp__20_carry__1_i_2_n_0\
    );
\minusOp__20_carry__1_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(10),
      O => \minusOp__20_carry__1_i_3_n_0\
    );
\minusOp__20_carry__1_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(9),
      O => \minusOp__20_carry__1_i_4_n_0\
    );
\minusOp__20_carry__2\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp__20_carry__1_n_0\,
      CO(3) => \minusOp__20_carry__2_n_0\,
      CO(2) => \minusOp__20_carry__2_n_1\,
      CO(1) => \minusOp__20_carry__2_n_2\,
      CO(0) => \minusOp__20_carry__2_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(16 downto 13),
      O(3) => \minusOp__20_carry__2_n_4\,
      O(2) => \minusOp__20_carry__2_n_5\,
      O(1) => \minusOp__20_carry__2_n_6\,
      O(0) => \minusOp__20_carry__2_n_7\,
      S(3) => \minusOp__20_carry__2_i_1_n_0\,
      S(2) => \minusOp__20_carry__2_i_2_n_0\,
      S(1) => \minusOp__20_carry__2_i_3_n_0\,
      S(0) => \minusOp__20_carry__2_i_4_n_0\
    );
\minusOp__20_carry__2_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(16),
      O => \minusOp__20_carry__2_i_1_n_0\
    );
\minusOp__20_carry__2_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(15),
      O => \minusOp__20_carry__2_i_2_n_0\
    );
\minusOp__20_carry__2_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(14),
      O => \minusOp__20_carry__2_i_3_n_0\
    );
\minusOp__20_carry__2_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(13),
      O => \minusOp__20_carry__2_i_4_n_0\
    );
\minusOp__20_carry__3\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp__20_carry__2_n_0\,
      CO(3) => \minusOp__20_carry__3_n_0\,
      CO(2) => \minusOp__20_carry__3_n_1\,
      CO(1) => \minusOp__20_carry__3_n_2\,
      CO(0) => \minusOp__20_carry__3_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(20 downto 17),
      O(3) => \minusOp__20_carry__3_n_4\,
      O(2) => \minusOp__20_carry__3_n_5\,
      O(1) => \minusOp__20_carry__3_n_6\,
      O(0) => \minusOp__20_carry__3_n_7\,
      S(3) => \minusOp__20_carry__3_i_1_n_0\,
      S(2) => \minusOp__20_carry__3_i_2_n_0\,
      S(1) => \minusOp__20_carry__3_i_3_n_0\,
      S(0) => \minusOp__20_carry__3_i_4_n_0\
    );
\minusOp__20_carry__3_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(20),
      O => \minusOp__20_carry__3_i_1_n_0\
    );
\minusOp__20_carry__3_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(19),
      O => \minusOp__20_carry__3_i_2_n_0\
    );
\minusOp__20_carry__3_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(18),
      O => \minusOp__20_carry__3_i_3_n_0\
    );
\minusOp__20_carry__3_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(17),
      O => \minusOp__20_carry__3_i_4_n_0\
    );
\minusOp__20_carry__4\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp__20_carry__3_n_0\,
      CO(3) => \minusOp__20_carry__4_n_0\,
      CO(2) => \minusOp__20_carry__4_n_1\,
      CO(1) => \minusOp__20_carry__4_n_2\,
      CO(0) => \minusOp__20_carry__4_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => fs_cycles(24 downto 21),
      O(3) => \minusOp__20_carry__4_n_4\,
      O(2) => \minusOp__20_carry__4_n_5\,
      O(1) => \minusOp__20_carry__4_n_6\,
      O(0) => \minusOp__20_carry__4_n_7\,
      S(3) => \minusOp__20_carry__4_i_1_n_0\,
      S(2) => \minusOp__20_carry__4_i_2_n_0\,
      S(1) => \minusOp__20_carry__4_i_3_n_0\,
      S(0) => \minusOp__20_carry__4_i_4_n_0\
    );
\minusOp__20_carry__4_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(24),
      O => \minusOp__20_carry__4_i_1_n_0\
    );
\minusOp__20_carry__4_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(23),
      O => \minusOp__20_carry__4_i_2_n_0\
    );
\minusOp__20_carry__4_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(22),
      O => \minusOp__20_carry__4_i_3_n_0\
    );
\minusOp__20_carry__4_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(21),
      O => \minusOp__20_carry__4_i_4_n_0\
    );
\minusOp__20_carry__5\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp__20_carry__4_n_0\,
      CO(3 downto 1) => \NLW_minusOp__20_carry__5_CO_UNCONNECTED\(3 downto 1),
      CO(0) => \minusOp__20_carry__5_n_3\,
      CYINIT => '0',
      DI(3 downto 1) => B"000",
      DI(0) => fs_cycles(25),
      O(3 downto 2) => \NLW_minusOp__20_carry__5_O_UNCONNECTED\(3 downto 2),
      O(1) => \minusOp__20_carry__5_n_6\,
      O(0) => \minusOp__20_carry__5_n_7\,
      S(3 downto 2) => B"00",
      S(1) => \minusOp__20_carry__5_i_1_n_0\,
      S(0) => \minusOp__20_carry__5_i_2_n_0\
    );
\minusOp__20_carry__5_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(26),
      O => \minusOp__20_carry__5_i_1_n_0\
    );
\minusOp__20_carry__5_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(25),
      O => \minusOp__20_carry__5_i_2_n_0\
    );
\minusOp__20_carry_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(4),
      O => \minusOp__20_carry_i_1_n_0\
    );
\minusOp__20_carry_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(3),
      O => \minusOp__20_carry_i_2_n_0\
    );
\minusOp__20_carry_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(2),
      O => \minusOp__20_carry_i_3_n_0\
    );
\minusOp__20_carry_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => fs_cycles(1),
      O => \minusOp__20_carry_i_4_n_0\
    );
minusOp_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => minusOp_carry_n_0,
      CO(2) => minusOp_carry_n_1,
      CO(1) => minusOp_carry_n_2,
      CO(0) => minusOp_carry_n_3,
      CYINIT => nfft_scaled(0),
      DI(3 downto 0) => nfft_scaled(4 downto 1),
      O(3 downto 0) => minusOp(4 downto 1),
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
      DI(3 downto 0) => nfft_scaled(8 downto 5),
      O(3 downto 0) => minusOp(8 downto 5),
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
      I0 => nfft_scaled(8),
      O => \minusOp_carry__0_i_1_n_0\
    );
\minusOp_carry__0_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => nfft_scaled(7),
      O => \minusOp_carry__0_i_2_n_0\
    );
\minusOp_carry__0_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => nfft_scaled(6),
      O => \minusOp_carry__0_i_3_n_0\
    );
\minusOp_carry__0_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => nfft_scaled(5),
      O => \minusOp_carry__0_i_4_n_0\
    );
\minusOp_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \minusOp_carry__0_n_0\,
      CO(3 downto 2) => \NLW_minusOp_carry__1_CO_UNCONNECTED\(3 downto 2),
      CO(1) => \minusOp_carry__1_n_2\,
      CO(0) => \minusOp_carry__1_n_3\,
      CYINIT => '0',
      DI(3 downto 2) => B"00",
      DI(1 downto 0) => nfft_scaled(10 downto 9),
      O(3) => \NLW_minusOp_carry__1_O_UNCONNECTED\(3),
      O(2 downto 0) => minusOp(11 downto 9),
      S(3) => '0',
      S(2) => \minusOp_carry__1_i_1_n_0\,
      S(1) => \minusOp_carry__1_i_2_n_0\,
      S(0) => \minusOp_carry__1_i_3_n_0\
    );
\minusOp_carry__1_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => nfft_scaled(11),
      O => \minusOp_carry__1_i_1_n_0\
    );
\minusOp_carry__1_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => nfft_scaled(10),
      O => \minusOp_carry__1_i_2_n_0\
    );
\minusOp_carry__1_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => nfft_scaled(9),
      O => \minusOp_carry__1_i_3_n_0\
    );
minusOp_carry_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => nfft_scaled(4),
      O => minusOp_carry_i_1_n_0
    );
minusOp_carry_i_2: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => nfft_scaled(3),
      O => minusOp_carry_i_2_n_0
    );
minusOp_carry_i_3: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => nfft_scaled(2),
      O => minusOp_carry_i_3_n_0
    );
minusOp_carry_i_4: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => nfft_scaled(1),
      O => minusOp_carry_i_4_n_0
    );
\nfft_counter[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0080FFFF00000000"
    )
        port map (
      I0 => eqOp_carry_n_0,
      I1 => M_AXIS_tready,
      I2 => eqOp,
      I3 => \bram_addr[31]_i_4_n_0\,
      I4 => playback_en,
      I5 => axis_aresetn,
      O => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter[0]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00008A80"
    )
        port map (
      I0 => axis_aresetn,
      I1 => eqOp,
      I2 => M_AXIS_tready,
      I3 => r_axis_tready,
      I4 => \bram_addr[31]_i_4_n_0\,
      O => nfft_counter0
    );
\nfft_counter[0]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => nfft_counter_reg(3),
      O => \nfft_counter[0]_i_4_n_0\
    );
\nfft_counter[0]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => nfft_counter_reg(2),
      O => \nfft_counter[0]_i_5_n_0\
    );
\nfft_counter[0]_i_6\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => nfft_counter_reg(1),
      O => \nfft_counter[0]_i_6_n_0\
    );
\nfft_counter[4]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => nfft_counter_reg(7),
      O => \nfft_counter[4]_i_2_n_0\
    );
\nfft_counter[4]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => nfft_counter_reg(6),
      O => \nfft_counter[4]_i_3_n_0\
    );
\nfft_counter[4]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => nfft_counter_reg(5),
      O => \nfft_counter[4]_i_4_n_0\
    );
\nfft_counter[4]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => nfft_counter_reg(4),
      O => \nfft_counter[4]_i_5_n_0\
    );
\nfft_counter[8]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => nfft_counter_reg(11),
      I1 => M_AXIS_tready,
      O => \nfft_counter[8]_i_2_n_0\
    );
\nfft_counter[8]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => nfft_counter_reg(10),
      O => \nfft_counter[8]_i_3_n_0\
    );
\nfft_counter[8]_i_4\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => nfft_counter_reg(9),
      O => \nfft_counter[8]_i_4_n_0\
    );
\nfft_counter[8]_i_5\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"9"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => nfft_counter_reg(8),
      O => \nfft_counter[8]_i_5_n_0\
    );
\nfft_counter_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[0]_i_3_n_7\,
      Q => nfft_counter_reg(0),
      R => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter_reg[0]_i_3\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \nfft_counter_reg[0]_i_3_n_0\,
      CO(2) => \nfft_counter_reg[0]_i_3_n_1\,
      CO(1) => \nfft_counter_reg[0]_i_3_n_2\,
      CO(0) => \nfft_counter_reg[0]_i_3_n_3\,
      CYINIT => '1',
      DI(3 downto 1) => nfft_counter_reg(3 downto 1),
      DI(0) => '0',
      O(3) => \nfft_counter_reg[0]_i_3_n_4\,
      O(2) => \nfft_counter_reg[0]_i_3_n_5\,
      O(1) => \nfft_counter_reg[0]_i_3_n_6\,
      O(0) => \nfft_counter_reg[0]_i_3_n_7\,
      S(3) => \nfft_counter[0]_i_4_n_0\,
      S(2) => \nfft_counter[0]_i_5_n_0\,
      S(1) => \nfft_counter[0]_i_6_n_0\,
      S(0) => nfft_counter_reg(0)
    );
\nfft_counter_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[8]_i_1_n_5\,
      Q => nfft_counter_reg(10),
      R => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[8]_i_1_n_4\,
      Q => nfft_counter_reg(11),
      R => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[0]_i_3_n_6\,
      Q => nfft_counter_reg(1),
      R => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[0]_i_3_n_5\,
      Q => nfft_counter_reg(2),
      R => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[0]_i_3_n_4\,
      Q => nfft_counter_reg(3),
      R => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[4]_i_1_n_7\,
      Q => nfft_counter_reg(4),
      R => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter_reg[4]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \nfft_counter_reg[0]_i_3_n_0\,
      CO(3) => \nfft_counter_reg[4]_i_1_n_0\,
      CO(2) => \nfft_counter_reg[4]_i_1_n_1\,
      CO(1) => \nfft_counter_reg[4]_i_1_n_2\,
      CO(0) => \nfft_counter_reg[4]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => nfft_counter_reg(7 downto 4),
      O(3) => \nfft_counter_reg[4]_i_1_n_4\,
      O(2) => \nfft_counter_reg[4]_i_1_n_5\,
      O(1) => \nfft_counter_reg[4]_i_1_n_6\,
      O(0) => \nfft_counter_reg[4]_i_1_n_7\,
      S(3) => \nfft_counter[4]_i_2_n_0\,
      S(2) => \nfft_counter[4]_i_3_n_0\,
      S(1) => \nfft_counter[4]_i_4_n_0\,
      S(0) => \nfft_counter[4]_i_5_n_0\
    );
\nfft_counter_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[4]_i_1_n_6\,
      Q => nfft_counter_reg(5),
      R => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[4]_i_1_n_5\,
      Q => nfft_counter_reg(6),
      R => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[4]_i_1_n_4\,
      Q => nfft_counter_reg(7),
      R => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[8]_i_1_n_7\,
      Q => nfft_counter_reg(8),
      R => \nfft_counter[0]_i_1_n_0\
    );
\nfft_counter_reg[8]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \nfft_counter_reg[4]_i_1_n_0\,
      CO(3) => \NLW_nfft_counter_reg[8]_i_1_CO_UNCONNECTED\(3),
      CO(2) => \nfft_counter_reg[8]_i_1_n_1\,
      CO(1) => \nfft_counter_reg[8]_i_1_n_2\,
      CO(0) => \nfft_counter_reg[8]_i_1_n_3\,
      CYINIT => '0',
      DI(3) => '0',
      DI(2 downto 0) => nfft_counter_reg(10 downto 8),
      O(3) => \nfft_counter_reg[8]_i_1_n_4\,
      O(2) => \nfft_counter_reg[8]_i_1_n_5\,
      O(1) => \nfft_counter_reg[8]_i_1_n_6\,
      O(0) => \nfft_counter_reg[8]_i_1_n_7\,
      S(3) => \nfft_counter[8]_i_2_n_0\,
      S(2) => \nfft_counter[8]_i_3_n_0\,
      S(1) => \nfft_counter[8]_i_4_n_0\,
      S(0) => \nfft_counter[8]_i_5_n_0\
    );
\nfft_counter_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => nfft_counter0,
      D => \nfft_counter_reg[8]_i_1_n_6\,
      Q => nfft_counter_reg(9),
      R => \nfft_counter[0]_i_1_n_0\
    );
out_tlast_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0B03FFFF08000000"
    )
        port map (
      I0 => eqOp,
      I1 => M_AXIS_tready,
      I2 => out_tlast_i_2_n_0,
      I3 => eqOp_carry_n_0,
      I4 => axis_aresetn,
      I5 => out_tlast,
      O => out_tlast_i_1_n_0
    );
out_tlast_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"82000082FFFFFFFF"
    )
        port map (
      I0 => \bram_addr[31]_i_9_n_0\,
      I1 => symbol_counter_reg(2),
      I2 => symbols(2),
      I3 => symbol_counter_reg(3),
      I4 => symbols(3),
      I5 => playback_en,
      O => out_tlast_i_2_n_0
    );
out_tlast_reg: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => out_tlast_i_1_n_0,
      Q => out_tlast,
      R => '0'
    );
out_tvalid_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"40FF00FF40000000"
    )
        port map (
      I0 => \bram_addr[31]_i_4_n_0\,
      I1 => playback_en,
      I2 => M_AXIS_tready,
      I3 => axis_aresetn,
      I4 => eqOp,
      I5 => out_tvalid,
      O => out_tvalid_i_1_n_0
    );
out_tvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => out_tvalid_i_1_n_0,
      Q => out_tvalid,
      R => '0'
    );
\quiet_counter[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"40FF0000"
    )
        port map (
      I0 => \bram_addr[31]_i_4_n_0\,
      I1 => eqOp,
      I2 => M_AXIS_tready,
      I3 => playback_en,
      I4 => axis_aresetn,
      O => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter[0]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"08"
    )
        port map (
      I0 => axis_aresetn,
      I1 => M_AXIS_tready,
      I2 => \bram_addr[31]_i_4_n_0\,
      O => quiet_counter0
    );
\quiet_counter[0]_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => quiet_counter_reg(0),
      O => \quiet_counter[0]_i_4_n_0\
    );
\quiet_counter_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[0]_i_3_n_7\,
      Q => quiet_counter_reg(0),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[0]_i_3\: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => \quiet_counter_reg[0]_i_3_n_0\,
      CO(2) => \quiet_counter_reg[0]_i_3_n_1\,
      CO(1) => \quiet_counter_reg[0]_i_3_n_2\,
      CO(0) => \quiet_counter_reg[0]_i_3_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0001",
      O(3) => \quiet_counter_reg[0]_i_3_n_4\,
      O(2) => \quiet_counter_reg[0]_i_3_n_5\,
      O(1) => \quiet_counter_reg[0]_i_3_n_6\,
      O(0) => \quiet_counter_reg[0]_i_3_n_7\,
      S(3 downto 1) => quiet_counter_reg(3 downto 1),
      S(0) => \quiet_counter[0]_i_4_n_0\
    );
\quiet_counter_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[8]_i_1_n_5\,
      Q => quiet_counter_reg(10),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[8]_i_1_n_4\,
      Q => quiet_counter_reg(11),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[12]_i_1_n_7\,
      Q => quiet_counter_reg(12),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[12]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \quiet_counter_reg[8]_i_1_n_0\,
      CO(3) => \quiet_counter_reg[12]_i_1_n_0\,
      CO(2) => \quiet_counter_reg[12]_i_1_n_1\,
      CO(1) => \quiet_counter_reg[12]_i_1_n_2\,
      CO(0) => \quiet_counter_reg[12]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \quiet_counter_reg[12]_i_1_n_4\,
      O(2) => \quiet_counter_reg[12]_i_1_n_5\,
      O(1) => \quiet_counter_reg[12]_i_1_n_6\,
      O(0) => \quiet_counter_reg[12]_i_1_n_7\,
      S(3 downto 0) => quiet_counter_reg(15 downto 12)
    );
\quiet_counter_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[12]_i_1_n_6\,
      Q => quiet_counter_reg(13),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[12]_i_1_n_5\,
      Q => quiet_counter_reg(14),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[12]_i_1_n_4\,
      Q => quiet_counter_reg(15),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[16]_i_1_n_7\,
      Q => quiet_counter_reg(16),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[16]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \quiet_counter_reg[12]_i_1_n_0\,
      CO(3) => \quiet_counter_reg[16]_i_1_n_0\,
      CO(2) => \quiet_counter_reg[16]_i_1_n_1\,
      CO(1) => \quiet_counter_reg[16]_i_1_n_2\,
      CO(0) => \quiet_counter_reg[16]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \quiet_counter_reg[16]_i_1_n_4\,
      O(2) => \quiet_counter_reg[16]_i_1_n_5\,
      O(1) => \quiet_counter_reg[16]_i_1_n_6\,
      O(0) => \quiet_counter_reg[16]_i_1_n_7\,
      S(3 downto 0) => quiet_counter_reg(19 downto 16)
    );
\quiet_counter_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[16]_i_1_n_6\,
      Q => quiet_counter_reg(17),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[16]_i_1_n_5\,
      Q => quiet_counter_reg(18),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[16]_i_1_n_4\,
      Q => quiet_counter_reg(19),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[0]_i_3_n_6\,
      Q => quiet_counter_reg(1),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[20]_i_1_n_7\,
      Q => quiet_counter_reg(20),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[20]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \quiet_counter_reg[16]_i_1_n_0\,
      CO(3) => \quiet_counter_reg[20]_i_1_n_0\,
      CO(2) => \quiet_counter_reg[20]_i_1_n_1\,
      CO(1) => \quiet_counter_reg[20]_i_1_n_2\,
      CO(0) => \quiet_counter_reg[20]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \quiet_counter_reg[20]_i_1_n_4\,
      O(2) => \quiet_counter_reg[20]_i_1_n_5\,
      O(1) => \quiet_counter_reg[20]_i_1_n_6\,
      O(0) => \quiet_counter_reg[20]_i_1_n_7\,
      S(3 downto 0) => quiet_counter_reg(23 downto 20)
    );
\quiet_counter_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[20]_i_1_n_6\,
      Q => quiet_counter_reg(21),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[20]_i_1_n_5\,
      Q => quiet_counter_reg(22),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[20]_i_1_n_4\,
      Q => quiet_counter_reg(23),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[24]_i_1_n_7\,
      Q => quiet_counter_reg(24),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[24]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \quiet_counter_reg[20]_i_1_n_0\,
      CO(3 downto 2) => \NLW_quiet_counter_reg[24]_i_1_CO_UNCONNECTED\(3 downto 2),
      CO(1) => \quiet_counter_reg[24]_i_1_n_2\,
      CO(0) => \quiet_counter_reg[24]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \NLW_quiet_counter_reg[24]_i_1_O_UNCONNECTED\(3),
      O(2) => \quiet_counter_reg[24]_i_1_n_5\,
      O(1) => \quiet_counter_reg[24]_i_1_n_6\,
      O(0) => \quiet_counter_reg[24]_i_1_n_7\,
      S(3) => '0',
      S(2 downto 0) => quiet_counter_reg(26 downto 24)
    );
\quiet_counter_reg[25]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[24]_i_1_n_6\,
      Q => quiet_counter_reg(25),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[26]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[24]_i_1_n_5\,
      Q => quiet_counter_reg(26),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[0]_i_3_n_5\,
      Q => quiet_counter_reg(2),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[0]_i_3_n_4\,
      Q => quiet_counter_reg(3),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[4]_i_1_n_7\,
      Q => quiet_counter_reg(4),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[4]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \quiet_counter_reg[0]_i_3_n_0\,
      CO(3) => \quiet_counter_reg[4]_i_1_n_0\,
      CO(2) => \quiet_counter_reg[4]_i_1_n_1\,
      CO(1) => \quiet_counter_reg[4]_i_1_n_2\,
      CO(0) => \quiet_counter_reg[4]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \quiet_counter_reg[4]_i_1_n_4\,
      O(2) => \quiet_counter_reg[4]_i_1_n_5\,
      O(1) => \quiet_counter_reg[4]_i_1_n_6\,
      O(0) => \quiet_counter_reg[4]_i_1_n_7\,
      S(3 downto 0) => quiet_counter_reg(7 downto 4)
    );
\quiet_counter_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[4]_i_1_n_6\,
      Q => quiet_counter_reg(5),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[4]_i_1_n_5\,
      Q => quiet_counter_reg(6),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[4]_i_1_n_4\,
      Q => quiet_counter_reg(7),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[8]_i_1_n_7\,
      Q => quiet_counter_reg(8),
      R => \quiet_counter[0]_i_1_n_0\
    );
\quiet_counter_reg[8]_i_1\: unisim.vcomponents.CARRY4
     port map (
      CI => \quiet_counter_reg[4]_i_1_n_0\,
      CO(3) => \quiet_counter_reg[8]_i_1_n_0\,
      CO(2) => \quiet_counter_reg[8]_i_1_n_1\,
      CO(1) => \quiet_counter_reg[8]_i_1_n_2\,
      CO(0) => \quiet_counter_reg[8]_i_1_n_3\,
      CYINIT => '0',
      DI(3 downto 0) => B"0000",
      O(3) => \quiet_counter_reg[8]_i_1_n_4\,
      O(2) => \quiet_counter_reg[8]_i_1_n_5\,
      O(1) => \quiet_counter_reg[8]_i_1_n_6\,
      O(0) => \quiet_counter_reg[8]_i_1_n_7\,
      S(3 downto 0) => quiet_counter_reg(11 downto 8)
    );
\quiet_counter_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => quiet_counter0,
      D => \quiet_counter_reg[8]_i_1_n_6\,
      Q => quiet_counter_reg(9),
      R => \quiet_counter[0]_i_1_n_0\
    );
r_axis_tready_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"B8"
    )
        port map (
      I0 => M_AXIS_tready,
      I1 => axis_aresetn,
      I2 => r_axis_tready,
      O => r_axis_tready_i_1_n_0
    );
r_axis_tready_reg: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => r_axis_tready_i_1_n_0,
      Q => r_axis_tready,
      R => '0'
    );
\symbol_counter[0]_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => symbol_counter_reg(0),
      O => plusOp(0)
    );
\symbol_counter[1]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"6"
    )
        port map (
      I0 => symbol_counter_reg(0),
      I1 => symbol_counter_reg(1),
      O => plusOp(1)
    );
\symbol_counter[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"78"
    )
        port map (
      I0 => symbol_counter_reg(0),
      I1 => symbol_counter_reg(1),
      I2 => symbol_counter_reg(2),
      O => plusOp(2)
    );
\symbol_counter[3]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8F00"
    )
        port map (
      I0 => \bram_addr[31]_i_4_n_0\,
      I1 => continuous,
      I2 => playback_en,
      I3 => axis_aresetn,
      O => \symbol_counter[3]_i_1_n_0\
    );
\symbol_counter[3]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"20000000"
    )
        port map (
      I0 => axis_aresetn,
      I1 => \bram_addr[31]_i_4_n_0\,
      I2 => eqOp,
      I3 => M_AXIS_tready,
      I4 => eqOp_carry_n_0,
      O => symbol_counter0
    );
\symbol_counter[3]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7F80"
    )
        port map (
      I0 => symbol_counter_reg(1),
      I1 => symbol_counter_reg(0),
      I2 => symbol_counter_reg(2),
      I3 => symbol_counter_reg(3),
      O => plusOp(3)
    );
\symbol_counter_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => symbol_counter0,
      D => plusOp(0),
      Q => symbol_counter_reg(0),
      R => \symbol_counter[3]_i_1_n_0\
    );
\symbol_counter_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => symbol_counter0,
      D => plusOp(1),
      Q => symbol_counter_reg(1),
      R => \symbol_counter[3]_i_1_n_0\
    );
\symbol_counter_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => symbol_counter0,
      D => plusOp(2),
      Q => symbol_counter_reg(2),
      R => \symbol_counter[3]_i_1_n_0\
    );
\symbol_counter_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => symbol_counter0,
      D => plusOp(3),
      Q => symbol_counter_reg(3),
      R => \symbol_counter[3]_i_1_n_0\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity Transmit_Chain_inst_0_playback_ctrl_0_0 is
  port (
    axis_aclk : in STD_LOGIC;
    axis_aresetn : in STD_LOGIC;
    playback_en : in STD_LOGIC;
    fs_cycles : in STD_LOGIC_VECTOR ( 26 downto 0 );
    symbols : in STD_LOGIC_VECTOR ( 3 downto 0 );
    nfft_scaled : in STD_LOGIC_VECTOR ( 11 downto 0 );
    continuous : in STD_LOGIC;
    BRAM_PORT_addr : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORT_clk : out STD_LOGIC;
    BRAM_PORT_din : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORT_dout : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORT_en : out STD_LOGIC;
    BRAM_PORT_rst : out STD_LOGIC;
    BRAM_PORT_we : out STD_LOGIC_VECTOR ( 0 to 0 );
    M_AXIS_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_tvalid : out STD_LOGIC;
    M_AXIS_tlast : out STD_LOGIC;
    M_AXIS_tready : in STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of Transmit_Chain_inst_0_playback_ctrl_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of Transmit_Chain_inst_0_playback_ctrl_0_0 : entity is "Transmit_Chain_inst_0_playback_ctrl_0_0,playback_ctrl,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of Transmit_Chain_inst_0_playback_ctrl_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of Transmit_Chain_inst_0_playback_ctrl_0_0 : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of Transmit_Chain_inst_0_playback_ctrl_0_0 : entity is "playback_ctrl,Vivado 2022.1";
end Transmit_Chain_inst_0_playback_ctrl_0_0;

architecture STRUCTURE of Transmit_Chain_inst_0_playback_ctrl_0_0 is
  signal \<const0>\ : STD_LOGIC;
  signal \<const1>\ : STD_LOGIC;
  signal \^axis_aclk\ : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of BRAM_PORT_clk : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT CLK";
  attribute X_INTERFACE_INFO of BRAM_PORT_en : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT EN";
  attribute X_INTERFACE_INFO of BRAM_PORT_rst : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT RST";
  attribute X_INTERFACE_INFO of M_AXIS_tlast : signal is "xilinx.com:interface:axis:1.0 M_AXIS TLAST";
  attribute X_INTERFACE_INFO of M_AXIS_tready : signal is "xilinx.com:interface:axis:1.0 M_AXIS TREADY";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of M_AXIS_tready : signal is "XIL_INTERFACENAME M_AXIS, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of M_AXIS_tvalid : signal is "xilinx.com:interface:axis:1.0 M_AXIS TVALID";
  attribute X_INTERFACE_INFO of axis_aclk : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk : signal is "ASSOCIATED_BUSIF axis_aclk:m_axis, FREQ_HZ 100000000";
  attribute X_INTERFACE_INFO of axis_aresetn : signal is "xilinx.com:signal:reset:1.0 axis_aresetn RST";
  attribute X_INTERFACE_PARAMETER of axis_aresetn : signal is "XIL_INTERFACENAME axis_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of BRAM_PORT_addr : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute X_INTERFACE_INFO of BRAM_PORT_din : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT DIN";
  attribute X_INTERFACE_INFO of BRAM_PORT_dout : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT DOUT";
  attribute X_INTERFACE_PARAMETER of BRAM_PORT_dout : signal is "MASTER_TYPE BRAM_CTRL";
  attribute X_INTERFACE_INFO of BRAM_PORT_we : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT WE";
  attribute X_INTERFACE_PARAMETER of BRAM_PORT_we : signal is "XIL_INTERFACENAME BRAM_PORT, MASTER_TYPE BRAM_CTRL, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, READ_LATENCY 1";
  attribute X_INTERFACE_INFO of M_AXIS_tdata : signal is "xilinx.com:interface:axis:1.0 M_AXIS TDATA";
begin
  BRAM_PORT_clk <= \^axis_aclk\;
  BRAM_PORT_din(31) <= \<const0>\;
  BRAM_PORT_din(30) <= \<const0>\;
  BRAM_PORT_din(29) <= \<const0>\;
  BRAM_PORT_din(28) <= \<const0>\;
  BRAM_PORT_din(27) <= \<const0>\;
  BRAM_PORT_din(26) <= \<const0>\;
  BRAM_PORT_din(25) <= \<const0>\;
  BRAM_PORT_din(24) <= \<const0>\;
  BRAM_PORT_din(23) <= \<const0>\;
  BRAM_PORT_din(22) <= \<const0>\;
  BRAM_PORT_din(21) <= \<const0>\;
  BRAM_PORT_din(20) <= \<const0>\;
  BRAM_PORT_din(19) <= \<const0>\;
  BRAM_PORT_din(18) <= \<const0>\;
  BRAM_PORT_din(17) <= \<const0>\;
  BRAM_PORT_din(16) <= \<const0>\;
  BRAM_PORT_din(15) <= \<const0>\;
  BRAM_PORT_din(14) <= \<const0>\;
  BRAM_PORT_din(13) <= \<const0>\;
  BRAM_PORT_din(12) <= \<const0>\;
  BRAM_PORT_din(11) <= \<const0>\;
  BRAM_PORT_din(10) <= \<const0>\;
  BRAM_PORT_din(9) <= \<const0>\;
  BRAM_PORT_din(8) <= \<const0>\;
  BRAM_PORT_din(7) <= \<const0>\;
  BRAM_PORT_din(6) <= \<const0>\;
  BRAM_PORT_din(5) <= \<const0>\;
  BRAM_PORT_din(4) <= \<const0>\;
  BRAM_PORT_din(3) <= \<const0>\;
  BRAM_PORT_din(2) <= \<const0>\;
  BRAM_PORT_din(1) <= \<const0>\;
  BRAM_PORT_din(0) <= \<const0>\;
  BRAM_PORT_en <= \<const1>\;
  BRAM_PORT_rst <= \<const0>\;
  BRAM_PORT_we(0) <= \<const0>\;
  \^axis_aclk\ <= axis_aclk;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
VCC: unisim.vcomponents.VCC
     port map (
      P => \<const1>\
    );
inst: entity work.Transmit_Chain_inst_0_playback_ctrl_0_0_playback_ctrl
     port map (
      BRAM_PORT_addr(31 downto 0) => BRAM_PORT_addr(31 downto 0),
      BRAM_PORT_dout(31 downto 0) => BRAM_PORT_dout(31 downto 0),
      M_AXIS_tdata(31 downto 0) => M_AXIS_tdata(31 downto 0),
      M_AXIS_tlast => M_AXIS_tlast,
      M_AXIS_tready => M_AXIS_tready,
      M_AXIS_tvalid => M_AXIS_tvalid,
      axis_aclk => \^axis_aclk\,
      axis_aresetn => axis_aresetn,
      continuous => continuous,
      fs_cycles(26 downto 0) => fs_cycles(26 downto 0),
      nfft_scaled(11 downto 0) => nfft_scaled(11 downto 0),
      playback_en => playback_en,
      symbols(3 downto 0) => symbols(3 downto 0)
    );
end STRUCTURE;
