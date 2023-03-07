-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Sun Feb 26 20:54:35 2023
-- Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top PS_Zynq_inst_0_delimiter_2_0 -prefix
--               PS_Zynq_inst_0_delimiter_2_0_ PS_Zynq_inst_0_delimiter_2_0_sim_netlist.vhdl
-- Design      : PS_Zynq_inst_0_delimiter_2_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity PS_Zynq_inst_0_delimiter_2_0 is
  port (
    IN0 : in STD_LOGIC_VECTOR ( 17 downto 0 );
    OUT0 : out STD_LOGIC_VECTOR ( 0 to 0 );
    OUT1 : out STD_LOGIC_VECTOR ( 0 to 0 );
    OUT2 : out STD_LOGIC_VECTOR ( 0 to 0 );
    OUT3 : out STD_LOGIC_VECTOR ( 4 downto 0 );
    OUT4 : out STD_LOGIC_VECTOR ( 0 to 0 );
    OUT5 : out STD_LOGIC_VECTOR ( 0 to 0 );
    OUT6 : out STD_LOGIC_VECTOR ( 6 downto 0 );
    OUT7 : out STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of PS_Zynq_inst_0_delimiter_2_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of PS_Zynq_inst_0_delimiter_2_0 : entity is "PS_Zynq_inst_0_delimiter_2_0,delimiter,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of PS_Zynq_inst_0_delimiter_2_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of PS_Zynq_inst_0_delimiter_2_0 : entity is "package_project";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of PS_Zynq_inst_0_delimiter_2_0 : entity is "delimiter,Vivado 2022.1";
end PS_Zynq_inst_0_delimiter_2_0;

architecture STRUCTURE of PS_Zynq_inst_0_delimiter_2_0 is
  signal \^in0\ : STD_LOGIC_VECTOR ( 17 downto 0 );
begin
  OUT0(0) <= \^in0\(0);
  OUT1(0) <= \^in0\(1);
  OUT2(0) <= \^in0\(2);
  OUT3(4 downto 0) <= \^in0\(7 downto 3);
  OUT4(0) <= \^in0\(8);
  OUT5(0) <= \^in0\(9);
  OUT6(6 downto 0) <= \^in0\(16 downto 10);
  OUT7(0) <= \^in0\(17);
  \^in0\(17 downto 0) <= IN0(17 downto 0);
end STRUCTURE;
