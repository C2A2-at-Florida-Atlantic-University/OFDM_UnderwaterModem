-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: IQ mixer
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity shift_attenuator is
  generic(
    g_TDATA_WIDTH                 : integer := 32
  );
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    i_shift_reg                   : in  std_logic_vector(2 downto 0);

    s_axis_tdata                  : in  std_logic_vector(g_TDATA_WIDTH-1 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tready                 : out std_logic;
     
    m_axis_tdata                  : out std_logic_vector(g_TDATA_WIDTH-1 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tready                 : in  std_logic
  );
end entity shift_attenuator;

architecture RTL of shift_attenuator is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  signal sign                     : std_logic;
  
begin

  sign                            <= s_axis_tdata(g_TDATA_WIDTH-1);

  process(
    s_axis_tdata,
    i_shift_reg,
    sign
  )
  begin
    case i_shift_reg is

      when "000" =>
        m_axis_tdata              <= s_axis_tdata;

      when "001" =>
        m_axis_tdata              <= sign & s_axis_tdata(g_TDATA_WIDTH-1 downto 1);

      when "010" =>
        m_axis_tdata              <= sign & sign & s_axis_tdata(g_TDATA_WIDTH-1 downto 2);

      when "011" =>
        m_axis_tdata              <= sign & sign & sign & s_axis_tdata(g_TDATA_WIDTH-1 downto 3);

      when "100" =>
        m_axis_tdata              <= sign & sign & sign & sign &
                                      s_axis_tdata(g_TDATA_WIDTH-1 downto 4);

      when "101" =>
        m_axis_tdata              <= sign & sign & sign & sign & sign &
                                      s_axis_tdata(g_TDATA_WIDTH-1 downto 5);

      when "110" =>
        m_axis_tdata              <= sign & sign & sign & sign & sign & sign & 
                                      s_axis_tdata(g_TDATA_WIDTH-1 downto 6);

      when "111" =>
        m_axis_tdata              <= sign & sign & sign & sign & sign & sign & sign &
                                  s_axis_tdata(g_TDATA_WIDTH-1 downto 7);
  
      when others =>
        m_axis_tdata              <= s_axis_tdata;

    end case;
  end process;

  s_axis_tready                   <= m_axis_tready;
  m_axis_tvalid                   <= s_axis_tvalid;

end architecture RTL;
