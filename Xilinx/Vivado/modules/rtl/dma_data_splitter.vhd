-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: IQ mixer
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity dma_data_splitter is
  port(
    axis_aclk                     : in  std_logic;

    i_select                      : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(15 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tready                 : out std_logic;
    s_axis_tkeep                  : in  std_logic_vector(1 downto 0);
    s_axis_tlast                  : in  std_logic;

    m_axis0_tdata                 : out std_logic_vector(15 downto 0);
    m_axis0_tvalid                : out std_logic;
    m_axis0_tlast                 : out std_logic;

    m_axis1_tdata                 : out std_logic_vector(15 downto 0);
    m_axis1_tvalid                : out std_logic;
    m_axis1_tlast                 : out std_logic
  );
end entity dma_data_splitter;

architecture RTL of dma_data_splitter is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis0:m_axis1, FREQ_HZ 100000000";

begin

  s_axis_tready                   <= '1';

  process(
    s_axis_tdata,
    s_axis_tvalid,
    s_axis_tlast,
    i_select
  )
  begin
    if i_select = '1' then
      m_axis1_tdata               <= s_axis_tdata;
      m_axis1_tvalid              <= s_axis_tvalid;
      m_axis1_tlast               <= s_axis_tlast;
      m_axis0_tdata               <= (others => '0');
      m_axis0_tvalid              <= '0';
      m_axis0_tlast               <= '0';
    else
      m_axis0_tdata               <= s_axis_tdata;
      m_axis0_tvalid              <= s_axis_tvalid;
      m_axis0_tlast               <= s_axis_tlast;
      m_axis1_tdata               <= (others => '0');
      m_axis1_tvalid              <= '0';
      m_axis1_tlast               <= '0';
    end if;
  end process;


end architecture RTL;
