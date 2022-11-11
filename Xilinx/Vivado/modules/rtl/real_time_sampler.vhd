-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Re-sample IFFT output to proper cycles per sample
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity real_time_sampler is
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

    dl_en                         : in  std_logic;
    fs_cycles                     : in  std_logic_vector(26 downto 0)
  );
end entity real_time_sampler;
 
architecture RTL of real_time_sampler is 

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  signal cycle_counter            : std_logic_vector(26 downto 0);
  signal w_axis_tready            : std_logic;
  signal in_tdata                 : std_logic_vector(31 downto 0);
  signal in_tvalid                : std_logic;
  signal in_tlast                 : std_logic;

begin

  -- Assert tready once every fs_cycles clock periods
  P_RESAMPLE : process(axis_aclk,axis_aresetn)
  begin
    if axis_aresetn = '0' then
      cycle_counter               <= fs_cycles - '1';
      w_axis_tready               <= '0';
    elsif rising_edge(axis_aclk) then
      if dl_en = '1' then
        if cycle_counter = fs_cycles - '1' then
          cycle_counter           <= (others => '0');
          in_tdata                <= s_axis_tdata;
          in_tvalid               <= s_axis_tvalid;
          in_tlast                <= s_axis_tlast;
          w_axis_tready           <= '0';
        else
          if cycle_counter = (fs_cycles - "10") then
            w_axis_tready         <= '1';
          else
            w_axis_tready         <= '0';
          end if;
          in_tvalid               <= '0';
          in_tlast                <= '0';
          cycle_counter           <= cycle_counter + '1';
        end if;
      else
        cycle_counter             <= fs_cycles;
        w_axis_tready             <= '0';
        in_tdata                  <= (others => '0');
        in_tvalid                 <= '0';
        in_tlast                  <= '0';
      end if;
    end if;
  end process P_RESAMPLE;

  s_axis_tready                   <= w_axis_tready;

  -- Control M_AXIS
  P_AXIS_CTRL : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if dl_en = '1' then
        m_axis_tdata              <= in_tdata;
        m_axis_tvalid             <= in_tvalid;
        m_axis_tlast              <= in_tlast;
      else
        m_axis_tlast              <= '0';
        m_axis_tvalid             <= '0';
        m_axis_tdata              <= (others => '0');
      end if;
    end if;
  end process P_AXIS_CTRL;


end architecture RTL;
