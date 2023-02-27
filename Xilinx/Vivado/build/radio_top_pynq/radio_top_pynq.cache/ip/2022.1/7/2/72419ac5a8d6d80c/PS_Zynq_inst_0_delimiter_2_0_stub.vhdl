-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Sun Feb 26 20:54:35 2023
-- Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
--               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ PS_Zynq_inst_0_delimiter_2_0_stub.vhdl
-- Design      : PS_Zynq_inst_0_delimiter_2_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
  Port ( 
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

end decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix;

architecture stub of decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "IN0[17:0],OUT0[0:0],OUT1[0:0],OUT2[0:0],OUT3[4:0],OUT4[0:0],OUT5[0:0],OUT6[6:0],OUT7[0:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "delimiter,Vivado 2022.1";
begin
end;
