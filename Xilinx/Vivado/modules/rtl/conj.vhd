-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Takes conjugate of input AXIS
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity conj is
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(31 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tlast                  : in  std_logic;
    s_axis_tready                 : out std_logic;

    m_axis_tdata                  : out std_logic_vector(31 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic;

    i_negative_freq               : in  std_logic
  );
end entity conj;
 
architecture RTL of conj is 

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  signal i_data1                  : std_logic_vector(15 downto 0);
  signal q_data1_conj             : std_logic_vector(15 downto 0);
  signal q_data1                  : std_logic_vector(15 downto 0);

begin

  -- Flip quadrature bits
  i_data1                         <= s_axis_tdata(15 downto 0);
  q_data1_conj                    <= X"00" - s_axis_tdata(31 downto 16);
  q_data1                         <= s_axis_tdata(31 downto 16);

  P_CONJ : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if i_negative_freq = '0' then
        m_axis_tdata              <= q_data1_conj & i_data1;
      else
        m_axis_tdata              <= q_data1 & i_data1;
      end if;
      m_axis_tvalid               <= s_axis_tvalid;
      m_axis_tlast                <= s_axis_tlast;
    end if;
  end process P_CONJ;

  s_axis_tready                   <= m_axis_tready;

end architecture RTL;
