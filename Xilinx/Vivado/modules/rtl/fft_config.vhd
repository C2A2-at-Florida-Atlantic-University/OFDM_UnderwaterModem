-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Send config packet to FFT IP core
--    nfft - set to nfft = 2^(val)
--    cp_len - 
--    inv - 0 for FFT, 1 for IFFT
-----------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;

entity fft_config is
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    config_start                  : in  std_logic;
    nfft                          : in  std_logic_vector(4 downto 0);
    cp_len                        : in  std_logic_vector(15 downto 0);
    inv                           : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(39 downto 0);
    m_axis_tvalid                 : out std_logic
  );
end entity fft_config;

architecture RTL of fft_config is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:m_axis, FREQ_HZ 100000000";

  signal config_rising            : std_logic;
  signal r_config_start           : std_logic;

begin

  -- Process to send config packet to FFT IP
  P_CONFIG : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      r_config_start              <= config_start;
      if config_rising = '1' then
        m_axis_tvalid             <= '1';
        m_axis_tdata              <= X"000" & "000" & not inv & cp_len & "000" & nfft;
      else
        m_axis_tvalid             <= '0';
        m_axis_tdata              <= (others => '0');
      end if;
    end if;
  end process P_CONFIG;

  -- Initiate config on rising edge of config_start register
  config_rising                   <= config_start and not r_config_start;

end architecture RTL;
