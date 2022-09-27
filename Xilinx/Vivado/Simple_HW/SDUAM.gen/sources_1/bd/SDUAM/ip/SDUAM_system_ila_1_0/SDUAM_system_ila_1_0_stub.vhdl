-- Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2021.2 (lin64) Build 3367213 Tue Oct 19 02:47:39 MDT 2021
-- Date        : Mon Nov 15 10:13:01 2021
-- Host        : saad-17Z90N-R-AAC8U1 running 64-bit Linux Mint 20.1
-- Command     : write_vhdl -force -mode synth_stub
--               /home/saad/Xilinx/UnderwaterModem/Updated_MyXilinx/3Vivado_HW/SDUAM.gen/sources_1/bd/SDUAM/ip/SDUAM_system_ila_1_0/SDUAM_system_ila_1_0_stub.vhdl
-- Design      : SDUAM_system_ila_1_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SDUAM_system_ila_1_0 is
  Port ( 
    clk : in STD_LOGIC;
    SLOT_0_AXIS_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    SLOT_0_AXIS_tstrb : in STD_LOGIC_VECTOR ( 3 downto 0 );
    SLOT_0_AXIS_tlast : in STD_LOGIC;
    SLOT_0_AXIS_tvalid : in STD_LOGIC;
    SLOT_0_AXIS_tready : in STD_LOGIC;
    resetn : in STD_LOGIC
  );

end SDUAM_system_ila_1_0;

architecture stub of SDUAM_system_ila_1_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk,SLOT_0_AXIS_tdata[31:0],SLOT_0_AXIS_tstrb[3:0],SLOT_0_AXIS_tlast,SLOT_0_AXIS_tvalid,SLOT_0_AXIS_tready,resetn";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "bd_485c,Vivado 2021.2";
begin
end;
