-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Re-sample for 10 sps DAC using 100MHz clock
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity dac_resampler is
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
    interp_cycles                 : in  std_logic_vector(23 downto 0)
  );
end entity dac_resampler;

architecture RTL of dac_resampler is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  signal in_axis_tdata            : std_logic_vector(31 downto 0);
  signal in_axis_tvalid           : std_logic;
  signal in_axis_tlast            : std_logic;

  signal in_axis_tdata2           : std_logic_vector(31 downto 0);
  signal in_axis_tvalid2          : std_logic;
  signal in_axis_tlast2           : std_logic;

  signal dac_counter              : std_logic_vector(3 downto 0);
  signal dl_start                 : std_logic;

  signal interp_counter           : std_logic_vector(23 downto 0);

begin

  -- Align with first s_axis_tvalid
  -- Reset when dl_en goes low
  P_SYNC : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if dl_en = '0' then
        dac_counter               <= "1001";
        dl_start                  <= '0';
      else
        if s_axis_tvalid = '1' then
          dl_start                <= '1';
        end if;

        if dl_start = '1' then
          -- Count every 10 Clocks for 10 MSPS DAC using 100Mhz clock
          if dac_counter = "1001" then
            dac_counter           <= (others => '0');
          else
            dac_counter           <= dac_counter + '1';
          end if;
        end if;
      end if;
    end if;
  end process P_SYNC;

  -- Calculate interpolation factor
  P_INTERP : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if dl_en = '0' then
        interp_counter            <= interp_cycles-'1';
        m_axis_tdata              <= (others => '0');
        m_axis_tvalid             <= '0';
        m_axis_tlast              <= '0';
      else
        if dac_counter = "0000" then
          if interp_counter = interp_cycles-'1' then
            interp_counter        <= (others => '0');
            m_axis_tdata          <= in_axis_tdata2;
            m_axis_tvalid         <= in_axis_tvalid2;
            m_axis_tlast          <= in_axis_tlast2;
          -- Upsample by placing zeros between samples
          else
            interp_counter        <= interp_counter + '1';
            m_axis_tdata          <= (others => '0');
            m_axis_tvalid         <= '1';
            m_axis_tlast          <= '0';
          end if;
        else
          m_axis_tdata            <= (others => '0');
          m_axis_tvalid           <= '0';
          m_axis_tlast            <= '0';
        end if;
      end if;
    end if;
  end process P_INTERP;



  P_AXIS_PIPELINE : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      in_axis_tdata               <= s_axis_tdata;
      in_axis_tvalid              <= s_axis_tvalid;
      in_axis_tlast               <= s_axis_tlast;

      in_axis_tdata2              <= in_axis_tdata;
      in_axis_tvalid2             <= in_axis_tvalid;
      in_axis_tlast2              <= in_axis_tlast;
    end if;
  end process P_AXIS_PIPELINE;

  s_axis_tready                   <= '1';

end architecture RTL;
