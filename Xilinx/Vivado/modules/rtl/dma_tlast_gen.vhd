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
    s_axis_tready                 : out std_logic;

    m_axis_tdata                  : out std_logic_vector(31 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic;

    i_dma_tlast_count             : in  std_logic_vector(31 downto 0)
  );
end entity dma_tlast_gen;

architecture RTL of dma_tlast_gen is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk      : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk      : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  signal counter                  : std_logic_vector(31 downto 0) := (others => '0');

begin

  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if s_axis_tvalid = '1' then
        if counter = i_dma_tlast_count-'1' then 
          counter                   <= (others => '0');
        else
          counter                   <= counter + '1';
        end if;
      end if;
    end if;
  end process;

  process(
    s_axis_tvalid,
    counter,
    i_dma_tlast_count
  ) begin
    if s_axis_tvalid = '1' and counter = i_dma_tlast_count-'1' then
      m_axis_tlast                <= '1';
    else
      m_axis_tlast                <= '0';
    end if;
  end process;

  m_axis_tdata                    <= s_axis_tdata;
  m_axis_tvalid                   <= s_axis_tvalid;
  s_axis_tready                   <= m_axis_tready;

end architecture RTL;
