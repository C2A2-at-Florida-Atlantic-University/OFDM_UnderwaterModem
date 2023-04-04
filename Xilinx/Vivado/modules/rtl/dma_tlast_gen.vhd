-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Tlast gen for use after DMA
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity dma_tlast_gen is
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(31 downto 0);
    s_axis_tvalid                 : in  std_logic;

    o_div                         : out std_logic;

    m_axis_tdata                  : out std_logic_vector(31 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic
  );
end entity dma_tlast_gen;

architecture RTL of dma_tlast_gen is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk      : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk      : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  signal counter                  : std_logic_vector(31 downto 0) := (others => '0');
  signal trigg_counter            : std_logic_vector(4 downto 0) := (others => '0');

begin

  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if trigg_counter = "11111" then -- every 32 cycles
        o_div                     <= '1';
      else
        o_div                     <= '0';
      end if;
    end if;
  end process;

  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if counter = X"00003FFF" then -- 16384 cycles
        counter                   <= (others => '0');
        m_axis_tlast              <= '1';
      else
        counter                   <= counter + '1';
        m_axis_tlast              <= '0';
      end if;
    end if;
  end process;

  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      m_axis_tdata                <= s_axis_tdata;
      m_axis_tvalid               <= s_axis_tvalid;
    end if;
  end process;

end architecture RTL;
