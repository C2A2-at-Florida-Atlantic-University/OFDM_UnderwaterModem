-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Takes peak_sample_40Mugate of input AXIS
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity peak_sample_40M is
  generic(
    g_DATA_WIDTH                  : integer := 16
  );
  port(
    aclk                          : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);
    s_axis_tvalid                 : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
    m_axis_tvalid                 : out std_logic;

    i_trigger                     : in  std_logic;
    o_peak_sample_40M                 : out std_logic_vector(g_DATA_WIDTH-1 downto 0)
  );
end entity peak_sample_40M;
 
architecture RTL of peak_sample_40M is 

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of aclk    : signal is "xilinx.com:signal:clock:1.0 aclk CLK";
  attribute X_INTERFACE_PARAMETER of aclk    : 
    signal is "ASSOCIATED_BUSIF aclk:s_axis:m_axis, FREQ_HZ 40000000";

  signal r_trigger                : std_logic;
  signal r_peak_sample_40M            : std_logic_vector(g_DATA_WIDTH-1 downto 0) := (others => '0');

begin

  process (aclk)
  begin
    if rising_edge(aclk) then
      r_trigger                   <= i_trigger;
    end if;
  end process;

  process (aclk)
  begin
    if rising_edge(aclk) then
      if i_trigger = '1' and r_trigger = '0' then
        r_peak_sample_40M             <= (others => '0');
      elsif abs(signed(s_axis_tdata)) > abs(signed(r_peak_sample_40M)) then
        r_peak_sample_40M             <= std_logic_vector(abs(signed(s_axis_tdata)));
      end if;
    end if;
  end process;

  m_axis_tdata                    <= s_axis_tdata;
  m_axis_tvalid                   <= s_axis_tvalid;

  o_peak_sample_40M                   <= r_peak_sample_40M;

end architecture RTL;
