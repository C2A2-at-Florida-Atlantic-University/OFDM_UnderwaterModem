-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Split I and Q into different AXIS streams
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity iq_split is
  port(
    axis_aclk                     : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(31 downto 0);
    s_axis_tvalid                 : in  std_logic;

    m_axis_real_tdata             : out std_logic_vector(15 downto 0);
    m_axis_real_tvalid            : out std_logic;

    m_axis_imag_tdata             : out std_logic_vector(15 downto 0);
    m_axis_imag_tvalid            : out std_logic
  );
end entity iq_split;

architecture RTL of iq_split is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis_real:m_axis_imag, FREQ_HZ 100000000";

begin

  process (axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      m_axis_real_tdata           <= s_axis_tdata(15 downto 0);
      m_axis_real_tvalid          <= s_axis_tvalid;

      m_axis_imag_tdata           <= s_axis_tdata(31 downto 16);
      m_axis_imag_tvalid          <= s_axis_tvalid;
    end if;
  end process;

end architecture RTL;
