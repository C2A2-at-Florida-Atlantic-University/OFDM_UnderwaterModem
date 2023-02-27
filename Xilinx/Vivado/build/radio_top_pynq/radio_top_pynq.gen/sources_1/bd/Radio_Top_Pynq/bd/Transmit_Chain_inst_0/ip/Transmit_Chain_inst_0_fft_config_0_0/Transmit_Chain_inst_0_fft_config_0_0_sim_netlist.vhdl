-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Sun Feb 26 20:54:35 2023
-- Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top Transmit_Chain_inst_0_fft_config_0_0 -prefix
--               Transmit_Chain_inst_0_fft_config_0_0_ Transmit_Chain_inst_0_fft_config_0_0_sim_netlist.vhdl
-- Design      : Transmit_Chain_inst_0_fft_config_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity Transmit_Chain_inst_0_fft_config_0_0_fft_config is
  port (
    m_axis_tdata : out STD_LOGIC_VECTOR ( 21 downto 0 );
    m_axis_tvalid : out STD_LOGIC;
    config_start : in STD_LOGIC;
    axis_aclk : in STD_LOGIC;
    cp_len : in STD_LOGIC_VECTOR ( 15 downto 0 );
    nfft : in STD_LOGIC_VECTOR ( 4 downto 0 );
    inv : in STD_LOGIC
  );
end Transmit_Chain_inst_0_fft_config_0_0_fft_config;

architecture STRUCTURE of Transmit_Chain_inst_0_fft_config_0_0_fft_config is
  signal config_rising : STD_LOGIC;
  signal \m_axis_tdata[24]_i_1_n_0\ : STD_LOGIC;
  signal p_0_out : STD_LOGIC_VECTOR ( 24 to 24 );
  signal r_config_start : STD_LOGIC;
begin
\m_axis_tdata[24]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"B"
    )
        port map (
      I0 => r_config_start,
      I1 => config_start,
      O => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata[24]_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => inv,
      O => p_0_out(24)
    );
\m_axis_tdata_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => nfft(0),
      Q => m_axis_tdata(0),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(2),
      Q => m_axis_tdata(7),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(3),
      Q => m_axis_tdata(8),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(4),
      Q => m_axis_tdata(9),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(5),
      Q => m_axis_tdata(10),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(6),
      Q => m_axis_tdata(11),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(7),
      Q => m_axis_tdata(12),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[16]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(8),
      Q => m_axis_tdata(13),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[17]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(9),
      Q => m_axis_tdata(14),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[18]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(10),
      Q => m_axis_tdata(15),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[19]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(11),
      Q => m_axis_tdata(16),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => nfft(1),
      Q => m_axis_tdata(1),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[20]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(12),
      Q => m_axis_tdata(17),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[21]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(13),
      Q => m_axis_tdata(18),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[22]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(14),
      Q => m_axis_tdata(19),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[23]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(15),
      Q => m_axis_tdata(20),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[24]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => p_0_out(24),
      Q => m_axis_tdata(21),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => nfft(2),
      Q => m_axis_tdata(2),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => nfft(3),
      Q => m_axis_tdata(3),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => nfft(4),
      Q => m_axis_tdata(4),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(0),
      Q => m_axis_tdata(5),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
\m_axis_tdata_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => cp_len(1),
      Q => m_axis_tdata(6),
      R => \m_axis_tdata[24]_i_1_n_0\
    );
m_axis_tvalid_i_1: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => config_start,
      I1 => r_config_start,
      O => config_rising
    );
m_axis_tvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => config_rising,
      Q => m_axis_tvalid,
      R => '0'
    );
r_config_start_reg: unisim.vcomponents.FDRE
     port map (
      C => axis_aclk,
      CE => '1',
      D => config_start,
      Q => r_config_start,
      R => '0'
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity Transmit_Chain_inst_0_fft_config_0_0 is
  port (
    axis_aclk : in STD_LOGIC;
    axis_aresetn : in STD_LOGIC;
    config_start : in STD_LOGIC;
    nfft : in STD_LOGIC_VECTOR ( 4 downto 0 );
    cp_len : in STD_LOGIC_VECTOR ( 15 downto 0 );
    inv : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 39 downto 0 );
    m_axis_tvalid : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of Transmit_Chain_inst_0_fft_config_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of Transmit_Chain_inst_0_fft_config_0_0 : entity is "Transmit_Chain_inst_0_fft_config_0_0,fft_config,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of Transmit_Chain_inst_0_fft_config_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of Transmit_Chain_inst_0_fft_config_0_0 : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of Transmit_Chain_inst_0_fft_config_0_0 : entity is "fft_config,Vivado 2022.1";
end Transmit_Chain_inst_0_fft_config_0_0;

architecture STRUCTURE of Transmit_Chain_inst_0_fft_config_0_0 is
  signal \<const0>\ : STD_LOGIC;
  signal \^m_axis_tdata\ : STD_LOGIC_VECTOR ( 24 downto 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of axis_aclk : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of axis_aclk : signal is "ASSOCIATED_BUSIF axis_aclk:m_axis, FREQ_HZ 100000000";
  attribute X_INTERFACE_INFO of axis_aresetn : signal is "xilinx.com:signal:reset:1.0 axis_aresetn RST";
  attribute X_INTERFACE_PARAMETER of axis_aresetn : signal is "XIL_INTERFACENAME axis_aresetn, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of m_axis_tvalid : signal is "xilinx.com:interface:axis:1.0 m_axis TVALID";
  attribute X_INTERFACE_PARAMETER of m_axis_tvalid : signal is "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 5, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 0, HAS_TSTRB 0, HAS_TKEEP 0, HAS_TLAST 0, FREQ_HZ 100000000, PHASE 0.0, CLK_DOMAIN PS_Zynq_inst_0_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of m_axis_tdata : signal is "xilinx.com:interface:axis:1.0 m_axis TDATA";
begin
  m_axis_tdata(39) <= \<const0>\;
  m_axis_tdata(38) <= \<const0>\;
  m_axis_tdata(37) <= \<const0>\;
  m_axis_tdata(36) <= \<const0>\;
  m_axis_tdata(35) <= \<const0>\;
  m_axis_tdata(34) <= \<const0>\;
  m_axis_tdata(33) <= \<const0>\;
  m_axis_tdata(32) <= \<const0>\;
  m_axis_tdata(31) <= \<const0>\;
  m_axis_tdata(30) <= \<const0>\;
  m_axis_tdata(29) <= \<const0>\;
  m_axis_tdata(28) <= \<const0>\;
  m_axis_tdata(27) <= \<const0>\;
  m_axis_tdata(26) <= \<const0>\;
  m_axis_tdata(25) <= \<const0>\;
  m_axis_tdata(24 downto 8) <= \^m_axis_tdata\(24 downto 8);
  m_axis_tdata(7) <= \<const0>\;
  m_axis_tdata(6) <= \<const0>\;
  m_axis_tdata(5) <= \<const0>\;
  m_axis_tdata(4 downto 0) <= \^m_axis_tdata\(4 downto 0);
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
inst: entity work.Transmit_Chain_inst_0_fft_config_0_0_fft_config
     port map (
      axis_aclk => axis_aclk,
      config_start => config_start,
      cp_len(15 downto 0) => cp_len(15 downto 0),
      inv => inv,
      m_axis_tdata(21 downto 5) => \^m_axis_tdata\(24 downto 8),
      m_axis_tdata(4 downto 0) => \^m_axis_tdata\(4 downto 0),
      m_axis_tvalid => m_axis_tvalid,
      nfft(4 downto 0) => nfft(4 downto 0)
    );
end STRUCTURE;
