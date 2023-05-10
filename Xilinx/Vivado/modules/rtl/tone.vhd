-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Generate sine wave if placed before DUC Mixer
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tone is
  port(
    axis_aclk                     : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(31 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tlast                  : in  std_logic;
    s_axis_tready                 : out std_logic;
    s_axis_tkeep                  : in  std_logic_vector(3 downto 0);

    m_axis_tdata                  : out std_logic_vector(31 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic;
    m_axis_tkeep                  : out std_logic_vector(3 downto 0);

    i_tone_amplitude              : in  std_logic_vector(31 downto 0)
  );
end entity tone;

architecture RTL of tone is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

begin

  s_axis_tready                   <= m_axis_tready;
  m_axis_tvalid                   <= s_axis_tvalid when i_tone_amplitude = X"00000000" else
                                     '1';
  m_axis_tlast                    <= s_axis_tlast;
  m_axis_tkeep                    <= s_axis_tkeep;

  m_axis_tdata                    <= s_axis_tdata when i_tone_amplitude = X"00000000" else
                                     i_tone_amplitude;

end architecture RTL;
