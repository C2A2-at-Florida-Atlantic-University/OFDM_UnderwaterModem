-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Delete beginning i_num_delete samples. Reset 
--              with trigger on i_trigger
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity sample_delete is
  generic(
    g_DATA_WIDTH                  : integer := 32
  );
  port(
    axis_aclk                     : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tready                 : out std_logic;
    s_axis_tlast                  : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic;

    i_trigger                     : in  std_logic;
    i_num_delete                  : in  std_logic_vector(11 downto 0)
  );
end entity sample_delete;

architecture RTL of sample_delete is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk      : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk      : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  signal counter                  : std_logic_vector(11 downto 0) := (others => '0');
  signal r_trigger                : std_logic;

begin

  -- Register trigger to detect rising edge
  process (axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      r_trigger                   <= i_trigger;
    end if;
  end process;

  -- Create counter based off valid data
  process (axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if i_trigger = '1' and r_trigger = '0' then
        counter                   <= (others => '0');
      elsif s_axis_tvalid = '1' and m_axis_tready = '1' then
        if counter < i_num_delete then
          counter                 <= counter + '1';
        end if;
      end if;
    end if;
  end process;

  process (
    s_axis_tdata,
    s_axis_tvalid,
    s_axis_tlast,
    m_axis_tready
  )
  begin
    if counter < i_num_delete then
      m_axis_tdata                <= (others => '0');
      m_axis_tvalid               <= '0';
      m_axis_tlast                <= '0';
      s_axis_tready               <= '0';
    else
      m_axis_tdata                <= s_axis_tdata;
      m_axis_tvalid               <= s_axis_tvalid;
      m_axis_tlast                <= s_axis_tlast;
      s_axis_tready               <= m_axis_tready;
    end if;
  end process;

end architecture RTL;
