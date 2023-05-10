-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Program frequency to CIC core
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity decimator_config2 is
  generic(
    g_PRECISION                   : integer := 16;
    g_DEFAULT_RATE                : std_logic_vector(15 downto 0) := X"0028"
  );
  port(
    axis_aclk                     : in  std_logic;

    i_decimate_ratio              : in  std_logic_vector(g_PRECISION-1 downto 0);

    m_axis_tdata                  : out std_logic_vector(15 downto 0) := (others => '0');
    m_axis_tvalid                 : out std_logic := '0';
    m_axis_tready                 : in  std_logic
  );
end entity decimator_config2;

architecture RTL of decimator_config2 is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:m_axis, FREQ_HZ 40000000";

  signal r_decimate_ratio            : std_logic_vector(g_PRECISION-1 downto 0) := g_DEFAULT_RATE;

begin

  -- Register input frequency value
  P_REG_FREQ : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if m_axis_tready = '1' then
        r_decimate_ratio            <= i_decimate_ratio;
      end if;
    end if;
  end process P_REG_FREQ;

  -- If change detected on register issue a configuration packet
  P_CONFIG : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if r_decimate_ratio /= i_decimate_ratio then
        m_axis_tdata              <= i_decimate_ratio;
        m_axis_tvalid             <= '1';
      else
        m_axis_tdata              <= (others => '0');
        m_axis_tvalid             <= '0';
      end if;
    end if;
  end process P_CONFIG;

end architecture RTL;
