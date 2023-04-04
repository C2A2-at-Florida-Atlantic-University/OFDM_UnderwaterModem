-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Reformat TDM stream
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tdm_reformat is
  port(
    axis_aclk                     : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(15 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tready                 : out std_logic;
    s_axis_tlast                  : in  std_logic;
    s_axis_tuser                  : in  std_logic_vector(15 downto 0);
    
    m_axis_tdata                  : out std_logic_vector(31 downto 0);
    m_axis_tvalid                 : out std_logic
  );
end entity tdm_reformat;

architecture RTL of tdm_reformat is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  signal i_data                   : std_logic_vector(15 downto 0) := (others => '0');
  
begin

  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if s_axis_tvalid = '1' and s_axis_tuser(8) = '1' then -- Real sample
        i_data                    <= s_axis_tdata;
        m_axis_tdata              <= (others => '0');
        m_axis_tvalid             <= '0';
      elsif s_axis_tvalid = '1' and s_axis_tuser(0) = '1' then -- Imaginary sample
        m_axis_tdata              <= s_axis_tdata & i_data;
        m_axis_tvalid             <= '1';
      else
        m_axis_tdata              <= (others => '0');
        m_axis_tvalid             <= '0';
      end if;
    end if;
  end process;

  s_axis_tready                   <= '1';

end architecture RTL;
