-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: output signal when threshold has been passed
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity max_thresh is
  port(
    axis_aclk                     : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(63 downto 0);
    s_axis_tvalid                 : in  std_logic;

    i_threshold                   : in  std_logic_vector(31 downto 0);

    o_max_detected                : out std_logic
  );
end entity max_thresh;

architecture RTL of max_thresh is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis, FREQ_HZ 100000000";

begin

  process (axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if s_axis_tdata(31 downto 0) >= i_threshold then
        o_max_detected            <= '1';
      else
        o_max_detected            <= '0';
      end if;
    end if;
  end process;

end architecture RTL;
