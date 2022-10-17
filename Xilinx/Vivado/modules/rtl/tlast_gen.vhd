-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Tlast gen for use after DMA
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

entity tlast_gen is
  generic(
    g_TLAST_CYCLES                : integer := 320;
    g_TDATA_BITS                  : integer := 128
  );
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    i_start                       : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(g_TDATA_BITS-1 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tready                 : out std_logic;

    m_axis_tdata                  : out std_logic_vector(g_TDATA_BITS-1 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic
  );
end entity tlast_gen;

architecture RTL of tlast_gen is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk      : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk      : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  signal counter                  : std_logic_vector(integer(ceil(log2(real(g_TLAST_CYCLES-1)))) downto 0);

begin

  -- Process to assert TLAST on M_AXIS every g_TLAST_CYCLES
  P_TLAST_GEN : process(axis_aclk,axis_aresetn)
  begin
    if axis_aresetn = '0' then
      counter                     <= (others => '0');
    elsif rising_edge(axis_aclk) then
      if s_axis_tvalid = '1' then
        if counter = g_TLAST_CYCLES-1 then
          counter                 <= (others => '0');
          m_axis_tlast            <= '1';
        else
          counter                 <= counter + '1';
          m_axis_tlast            <= '0';
        end if;
      else
        counter                   <= (others => '0');
        m_axis_tlast              <= '0';
      end if;
    end if;
  end process P_TLAST_GEN;

  s_axis_tready                   <= i_start;

  -- Process to register S_AXIS
  P_REGISTER : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      m_axis_tdata                <= s_axis_tdata;
      m_axis_tvalid               <= s_axis_tvalid and i_start;
    end if;
  end process P_REGISTER;

end architecture RTL;
