-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Select between AXIS_0 and AXIS_1 based on 
--  the value of i_select
-----------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;

entity mux is
  generic(
    g_TDATA_WIDTH                 : integer := 32
  );
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    s_axis0_tdata                 : in  std_logic_vector(g_TDATA_WIDTH-1 downto 0);
    s_axis0_tvalid                : in  std_logic;
    s_axis0_tlast                 : in  std_logic;
    s_axis0_tready                : out std_logic;
    
    s_axis1_tdata                 : in  std_logic_vector(g_TDATA_WIDTH-1 downto 0);
    s_axis1_tvalid                : in  std_logic;
    s_axis1_tlast                 : in  std_logic;
    s_axis1_tready                : out std_logic;

    m_axis_tdata                  : out std_logic_vector(g_TDATA_WIDTH-1 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic;
    
    i_select                      : in  std_logic
  );
end entity mux;

architecture RTL of mux is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis1:s_axis0:m_axis, FREQ_HZ 100000000";

begin

  -- Drop 16 bits of IQ data
 -- in_tdata                        <= s_axis0_tdata(239 downto 224) & s_axis0_tdata(207 downto 192) &
 --                                    s_axis0_tdata(175 downto 160) & s_axis0_tdata(143 downto 128) &
 --                                    s_axis0_tdata(111 downto 96 ) & s_axis0_tdata(79  downto 64 ) &
 --                                    s_axis0_tdata(47  downto 32 ) & s_axis0_tdata(15  downto 0  );
 
  P_MUX : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if i_select = '0' then
        m_axis_tdata              <= s_axis0_tdata;
        m_axis_tvalid             <= s_axis0_tvalid;
        m_axis_tlast              <= s_axis0_tlast;
      else
        m_axis_tdata              <= s_axis1_tdata;
        m_axis_tvalid             <= s_axis1_tvalid;
        m_axis_tlast              <= s_axis1_tlast;
      end if;
    end if;
  end process P_MUX;

  s_axis0_tready                  <= m_axis_tready;
  s_axis1_tready                  <= m_axis_tready;

end architecture RTL;
