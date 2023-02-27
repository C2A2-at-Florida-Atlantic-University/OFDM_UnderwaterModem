-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Sun Feb 26 20:54:37 2023
-- Host        : DESKTOP-1UDCE0K running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top Transmit_Chain_inst_0_playback_ctrl_0_0 -prefix
--               Transmit_Chain_inst_0_playback_ctrl_0_0_ Transmit_Chain_inst_0_playback_ctrl_0_0_stub.vhdl
-- Design      : Transmit_Chain_inst_0_playback_ctrl_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Transmit_Chain_inst_0_playback_ctrl_0_0 is
  Port ( 
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

end Transmit_Chain_inst_0_playback_ctrl_0_0;

architecture stub of Transmit_Chain_inst_0_playback_ctrl_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "axis_aclk,axis_aresetn,playback_en,fs_cycles[26:0],symbols[3:0],nfft_scaled[11:0],continuous,BRAM_PORT_addr[31:0],BRAM_PORT_clk,BRAM_PORT_din[31:0],BRAM_PORT_dout[31:0],BRAM_PORT_en,BRAM_PORT_rst,BRAM_PORT_we[0:0],M_AXIS_tdata[31:0],M_AXIS_tvalid,M_AXIS_tlast,M_AXIS_tready";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "playback_ctrl,Vivado 2022.1";
begin
end;
