library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std;
use ieee.std_logic_unsigned.all;

entity test is
end entity test;

architecture BEHAVE of test is

    constant c_CLK_PERIOD                   : time := 10 ns;
    
    signal r_Clk                            : std_logic := '1';
    signal r_nRst                           : std_logic := '0';
    
    signal M_AXIS_tdata                     : std_logic_vector(31 downto 0);
    signal M_AXIS_tvalid                    : std_logic;
    signal S_AXIS_tdata                     : std_logic_vector(31 downto 0) := (others => '0');
    signal S_AXIS_tvalid                    : std_logic := '0';
    
    signal threshold                        : std_logic_vector(31 downto 0) := X"00000032";
    signal timeout                          : std_logic_vector(3 downto 0) := "0011";
    signal passthrough                      : std_logic;

    component AXIS_threshold_v1_0 is
        generic (
            C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;
            C_M00_AXIS_TDATA_WIDTH	: integer	:= 32
        );
        port (
            threshold       : in  std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
            timeout         : in  std_logic_vector(3 downto 0);
            passthrough     : out std_logic;
            s00_axis_aclk	: in std_logic;
            s00_axis_aresetn	: in std_logic;
            s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
            s00_axis_tvalid	: in std_logic;
            m00_axis_tvalid	: out std_logic;
            m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0)
        );
    end component AXIS_threshold_v1_0; 
    
begin

    DUT : AXIS_threshold_v1_0
        generic map(
            C_S00_AXIS_TDATA_WIDTH          => 32,
            C_M00_AXIS_TDATA_WIDTH          => 32 
        )
        port map(
            threshold                       => threshold,
            timeout                         => timeout,
            passthrough                     => passthrough,
            s00_axis_aclk                   => r_Clk,
            s00_axis_aresetn                => r_nRst,
            s00_axis_tdata                  => S_AXIS_tdata,
            s00_axis_tvalid                 => S_AXIS_tvalid,
            m00_axis_tdata                  => M_AXIS_tdata,
            m00_axis_tvalid                 => M_AXIS_tvalid
        );
        
    r_Clk <= not r_Clk after c_CLK_PERIOD / 2;
    
    p_AXI : process
    begin
        wait for 5 * c_CLK_PERIOD;
        r_nRst                              <= '1';
        wait for 5 * c_CLK_PERIOD;
        for ii in 0 to 200 loop
            S_AXIS_tdata                    <= S_AXIS_tdata + '1';
            S_AXIS_tvalid                   <= '1';
            wait for 10 ns;
            wait for 10 ns;
        end loop;
        
        wait for 5 * c_CLK_PERIOD;
        for ii in 0 to 200 loop
            S_AXIS_tdata                    <= S_AXIS_tdata - '1';
            S_AXIS_tvalid                   <= '1';
            wait for 10 ns;
            wait for 10 ns;
        end loop;
        
        wait for 50 * c_CLK_PERIOD;
        for ii in 0 to 200 loop
            S_AXIS_tdata                    <= S_AXIS_tdata - '1';
            S_AXIS_tvalid                   <= '1';
            wait for 10 ns;
            wait for 10 ns;
        end loop;
        
        assert false report "Test Complete" severity failure;
    end process p_AXI;
end architecture BEHAVE;