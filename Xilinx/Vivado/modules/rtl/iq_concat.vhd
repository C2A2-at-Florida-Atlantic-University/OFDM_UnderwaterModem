-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Concat I and Q AXIS Streams into single AXIS
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity iq_concat is
  port(
    axis_aclk                     : in  std_logic;

    s_axis_real_tdata             : in  std_logic_vector(31 downto 0);
    s_axis_real_tvalid            : in  std_logic;

    s_axis_imag_tdata             : in  std_logic_vector(31 downto 0);
    s_axis_imag_tvalid            : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(63 downto 0);
    m_axis_tvalid                 : out std_logic
  );
end entity iq_concat;

architecture RTL of iq_concat is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis_real:s_axis_imag:m_axis, FREQ_HZ 100000000";

begin

  process (axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      m_axis_tdata                <= s_axis_imag_tdata & s_axis_real_tdata;
      m_axis_tvalid               <= s_axis_imag_tvalid and s_axis_real_tvalid;
    end if;
  end process;

end architecture RTL;
