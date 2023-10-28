-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Turn off data
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity tx_off is
  generic(
    g_DATA_WIDTH                  : integer := 16
  );
  port(
    aclk                          : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);
    s_axis_tvalid                 : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
    m_axis_tvalid                 : out std_logic;

    i_on                          : in  std_logic
  );
end entity tx_off;
 
architecture RTL of tx_off is 

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of aclk    : signal is "xilinx.com:signal:clock:1.0 aclk CLK";
  attribute X_INTERFACE_PARAMETER of aclk    : 
    signal is "ASSOCIATED_BUSIF aclk:s_axis:m_axis, FREQ_HZ 10000000";

begin

  m_axis_tdata <= (others => '0') when i_on = '0' else s_axis_tdata;
  m_axis_tvalid <= '0' when i_on = '0' else s_axis_tvalid;

end architecture RTL;
