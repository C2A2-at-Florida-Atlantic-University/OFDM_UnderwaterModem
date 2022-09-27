library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Clock_Divider is
  generic(
    divisor_value             : integer := 5
  );
  port(
    i_Clk                     : in  std_logic;
    i_nRst                    : in  std_logic;
    o_Clk                     : out std_logic
  );
end entity Clock_Divider;

architecture RTL of Clock_Divider is
  
  signal count                : integer := 1;
  signal tmp                  : std_logic := '0';

begin

  process (i_Clk, i_nRst)
  begin
    if i_nRst = '0' then
      count                   <= 1;
      tmp                     <= '0';
    elsif rising_edge(i_Clk) then
      if count = divisor_value then
        tmp                   <= not tmp;
        count                 <= 1;
      else
        count                 <= count + 1;
      end if;
      o_Clk                   <= tmp;
    end if;
  end process;

end architecture RTl;
