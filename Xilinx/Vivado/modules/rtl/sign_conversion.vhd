-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: signed to unsigned conversion
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity sign_conversion is
  port(
    axis_aclk                     : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(15 downto 0);
    s_axis_tvalid                 : in  std_logic;
     
    m_axis_tdata                  : out std_logic_vector(15 downto 0);
    m_axis_tvalid                 : out std_logic
  );
end entity sign_conversion;

architecture RTL of sign_conversion is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 10000000";

begin

  process(s_axis_tdata)
  begin
    m_axis_tdata                  <= s_axis_tdata + X"2000";
  end process;

  m_axis_tvalid                     <= s_axis_tvalid;

end architecture RTL;
