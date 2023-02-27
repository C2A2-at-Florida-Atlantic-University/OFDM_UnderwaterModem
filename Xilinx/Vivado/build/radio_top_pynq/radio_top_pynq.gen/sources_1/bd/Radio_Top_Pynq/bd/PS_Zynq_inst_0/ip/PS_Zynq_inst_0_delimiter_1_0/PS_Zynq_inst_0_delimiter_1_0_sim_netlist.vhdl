-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Sun Feb 26 20:55:30 2023
-- Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim
--               c:/Projects/FAU-Modem/OFDM/Xilinx/Vivado/build/radio_top_pynq/radio_top_pynq.gen/sources_1/bd/Radio_Top_Pynq/bd/PS_Zynq_inst_0/ip/PS_Zynq_inst_0_delimiter_1_0/PS_Zynq_inst_0_delimiter_1_0_sim_netlist.vhdl
-- Design      : PS_Zynq_inst_0_delimiter_1_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity PS_Zynq_inst_0_delimiter_1_0 is
  port (
    IN0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    OUT0 : out STD_LOGIC_VECTOR ( 15 downto 0 );
    OUT1 : out STD_LOGIC_VECTOR ( 11 downto 0 );
    OUT2 : out STD_LOGIC_VECTOR ( 3 downto 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of PS_Zynq_inst_0_delimiter_1_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of PS_Zynq_inst_0_delimiter_1_0 : entity is "PS_Zynq_inst_0_delimiter_1_0,delimiter,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of PS_Zynq_inst_0_delimiter_1_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of PS_Zynq_inst_0_delimiter_1_0 : entity is "package_project";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of PS_Zynq_inst_0_delimiter_1_0 : entity is "delimiter,Vivado 2022.1";
end PS_Zynq_inst_0_delimiter_1_0;

architecture STRUCTURE of PS_Zynq_inst_0_delimiter_1_0 is
  signal \^in0\ : STD_LOGIC_VECTOR ( 31 downto 0 );
begin
  OUT0(15 downto 0) <= \^in0\(15 downto 0);
  OUT1(11 downto 0) <= \^in0\(27 downto 16);
  OUT2(3 downto 0) <= \^in0\(31 downto 28);
  \^in0\(31 downto 0) <= IN0(31 downto 0);
end STRUCTURE;
