-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Bit shift scaling
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity scaling is
  generic(
    g_S_DATA_WIDTH                : integer := 24;
    g_M_DATA_WIDTH                : integer := 16;
    g_SCALE_WIDTH                 : integer := 2
  );
  port(
    aclk                          : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(g_S_DATA_WIDTH-1 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tlast                  : in  std_logic;
    s_axis_tready                 : out std_logic;

    m_axis_tdata                  : out std_logic_vector(g_M_DATA_WIDTH-1 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic;

    i_gain_shift                  : in  std_logic_vector(g_SCALE_WIDTH-1 downto 0)
  );
end entity scaling;

architecture RTL of scaling is 

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of aclk    : signal is "xilinx.com:signal:clock:1.0 aclk CLK";
  attribute X_INTERFACE_PARAMETER of aclk    : 
    signal is "ASSOCIATED_BUSIF aclk:s_axis:m_axis, FREQ_HZ 100000000";

begin

  process(
    s_axis_tdata,
    i_gain_shift
  )
  begin
    m_axis_tdata <= s_axis_tdata(19-to_integer(unsigned(i_gain_shift)) downto
                                 4 -to_integer(unsigned(i_gain_shift)));
  end process;

  m_axis_tvalid                   <= s_axis_tvalid;
  m_axis_tlast                    <= s_axis_tlast;
  s_axis_tready                   <= m_axis_tready;

end architecture RTL;
