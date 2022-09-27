library ieee;
use ieee.std_logic_1164.all;

entity test is
end entity test;

architecture BEHAVE of test is

  constant c_CLK_PERIOD       : time := 10 ns;
  signal r_Clk                : std_logic := '1';
  signal r_nRst               : std_logic := '0';

  signal coeff_sel            : std_logic_vector(3 downto 0);
  signal tvalid               : std_logic;
  signal tdata                : std_logic_vector(7 downto 0);
  signal tready               : std_logic;

  component fir_config_v1_0 is
    generic(
      C_M00_AXIS_TDATA_WIDTH  : integer
    );
    port(
      coeff_sel               : in  std_logic_vector(3 downto 0);

      m00_axis_aclk           : in  std_logic;
      m00_axis_aresetn        : in  std_logic;
      m00_axis_tvalid         : out std_logic;
      m00_axis_tdata          : out std_logic_vector(7 downto 0);
      m00_axis_tready         : in  std_logic
    );
  end component fir_config_v1_0;

begin

  DUT : fir_config_v1_0
    generic map(
      C_M00_AXIS_TDATA_WIDTH  => 8
    )
    port map(
      coeff_sel               => coeff_sel,
      m00_axis_aclk           => r_Clk,
      m00_axis_aresetn        => r_nRst,
      m00_axis_tvalid         => tvalid,
      m00_axis_tdata          => tdata,
      m00_axis_tready         => tready
    );

  r_Clk <= not r_Clk after c_CLK_PERIOD / 2;

  process begin
    tready                    <= '0';
    coeff_sel                 <= X"2";
    wait for 5 * c_CLK_PERIOD;
    r_nRst                    <= '1';
    wait for 5 * c_CLK_PERIOD;
    tready                    <= '1';
    wait for 10 * c_CLK_PERIOD;
    assert false report "Test Complete" severity failure;
  end process;

end architecture BEHAVE;
