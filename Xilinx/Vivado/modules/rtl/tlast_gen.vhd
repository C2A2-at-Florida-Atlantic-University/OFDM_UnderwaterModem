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
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    i_start                       : in  std_logic;
    nfft_scaled                   : in  std_logic_vector(11 downto 0);
    symbols                       : in  std_logic_vector(3 downto 0);
    dl_en                         : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(31 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tlast                  : in  std_logic;
    s_axis_tready                 : out std_logic;

    m_axis_tdata                  : out std_logic_vector(31 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic
  );
end entity tlast_gen;

architecture RTL of tlast_gen is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk      : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk      : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  signal counter                  : std_logic_vector(11 downto 0);
  signal symbol_counter           : std_logic_vector(3 downto 0);

  signal in_tdata                 : std_logic_vector(31 downto 0);
  signal in_tvalid                : std_logic;
  signal in_tlast                 : std_logic;
  
  signal out_tlast                : std_logic;
  signal stop                     : std_logic;

begin

  -- Process to assert TLAST on M_AXIS every g_TLAST_CYCLES
  P_TLAST_GEN : process(axis_aclk,axis_aresetn)
  begin
    if axis_aresetn = '0' then
      counter                     <= (others => '0');
      symbol_counter              <= (others => '0');
    elsif rising_edge(axis_aclk) then
      if dl_en = '0' then
        counter                   <= (others => '0');
        symbol_counter            <= (others => '0');
        out_tlast                 <= '0';
      elsif s_axis_tvalid = '1' and m_axis_tready = '1' then
        if counter = nfft_scaled - '1' then
          counter                 <= (others => '0');
          if symbol_counter = symbols-'1' then
            out_tlast             <= '0';
          else
            out_tlast             <= '1';
            symbol_counter        <= symbol_counter + '1';
          end if;
        else
          counter                 <= counter + '1';
          out_tlast               <= '0';
        end if;
      else
        if s_axis_tvalid = '0' then
          counter                 <= (others => '0');
        end if;
        out_tlast                 <= '0';
      end if;
    end if;
  end process P_TLAST_GEN;

  s_axis_tready                   <= i_start and m_axis_tready;
  m_axis_tlast                    <= out_tlast;
  stop                            <= '1' when symbol_counter = symbols-'1' else '0';

  -- Process to register S_AXIS
  P_REGISTER : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      m_axis_tdata                <= s_axis_tdata;
      m_axis_tvalid               <= s_axis_tvalid or stop;
    end if;
  end process P_REGISTER;

end architecture RTL;
