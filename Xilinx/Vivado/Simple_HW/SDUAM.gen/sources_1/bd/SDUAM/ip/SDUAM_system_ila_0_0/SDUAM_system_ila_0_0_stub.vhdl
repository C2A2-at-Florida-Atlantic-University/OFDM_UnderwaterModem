-- Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2021.2 (lin64) Build 3367213 Tue Oct 19 02:47:39 MDT 2021
-- Date        : Mon Nov 15 10:11:46 2021
-- Host        : saad-17Z90N-R-AAC8U1 running 64-bit Linux Mint 20.1
-- Command     : write_vhdl -force -mode synth_stub
--               /home/saad/Xilinx/UnderwaterModem/Updated_MyXilinx/3Vivado_HW/SDUAM.gen/sources_1/bd/SDUAM/ip/SDUAM_system_ila_0_0/SDUAM_system_ila_0_0_stub.vhdl
-- Design      : SDUAM_system_ila_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SDUAM_system_ila_0_0 is
  Port ( 
    clk : in STD_LOGIC;
    probe0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
    probe1 : in STD_LOGIC_VECTOR ( 31 downto 0 )
  );

end SDUAM_system_ila_0_0;

architecture stub of SDUAM_system_ila_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,probe0[31:0],probe1[31:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "bd_880d,Vivado 2021.2";
begin
end;
