library ieee;
use ieee.std_logic_1164.all;

entity clock_divider_tb is
end entity clock_divider_tb;

architecture BEHAVE of clock_divider_tb is

    constant c_CLK_PERIOD           : time := 10 ns;    -- 100MHz clock
    signal r_Clk                    : std_logic := '1';
    signal r_nRst                   : std_logic := '0';
    signal w_Clk                    : std_logic;
    
    component clock_divider is
        generic(
            divisor_value           : integer
        );
        port(
            i_Clk                   : in  std_logic;
            i_nRst                  : in  std_logic;
            o_Clk                   : out std_logic
        );
    end component clock_divider;
    
begin
    
    clock_divider_Inst : clock_divider
        generic map(
            divisor_value           => 1
        )
        port map(
            i_clk                   => r_Clk,
            i_nRst                  => r_nRst,
            o_Clk                   => w_Clk
        );
    
    r_Clk <= not r_Clk after c_CLK_PERIOD / 2;
    
    process begin
        wait for c_CLk_PERIOD;
        r_nRst                      <= '1';
        wait for 100 * c_CLK_PERIOD;
        assert false report "Test Complete" severity failure;
    end process;
end architecture BEHAVE;