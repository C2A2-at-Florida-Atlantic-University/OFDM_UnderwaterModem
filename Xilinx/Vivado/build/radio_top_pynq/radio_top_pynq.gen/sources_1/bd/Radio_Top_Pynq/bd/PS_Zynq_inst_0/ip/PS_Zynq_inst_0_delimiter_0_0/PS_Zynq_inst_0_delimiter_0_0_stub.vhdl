-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Sun Feb 26 20:55:29 2023
-- Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top PS_Zynq_inst_0_delimiter_0_0 -prefix
--               PS_Zynq_inst_0_delimiter_0_0_ PS_Zynq_inst_0_delimiter_0_0_stub.vhdl
-- Design      : PS_Zynq_inst_0_delimiter_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PS_Zynq_inst_0_delimiter_0_0 is
  Port ( 
    IN0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    OUT0 : out STD_LOGIC_VECTOR ( 26 downto 0 );
    OUT1 : out STD_LOGIC_VECTOR ( 4 downto 0 )
  );

end PS_Zynq_inst_0_delimiter_0_0;

architecture stub of PS_Zynq_inst_0_delimiter_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "IN0[31:0],OUT0[26:0],OUT1[4:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "delimiter,Vivado 2022.1";
begin
end;
