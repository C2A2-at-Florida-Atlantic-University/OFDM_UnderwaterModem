-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Directly save raw ADC samples over DMA
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity adc_raw_sample_save is
  generic(
    g_ILA                         : boolean := false
  );
  port(
    aclk                          : in  std_logic;
    
    s_axis_tdata                  : in  std_logic_vector(15 downto 0);
    s_axis_tvalid                 : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(31 downto 0);
    m_axis_tvalid                 : out std_logic;

    i_trigger                     : in  std_logic;
    i_max_sync                    : in  std_logic
  );
end entity adc_raw_sample_save;

architecture RTL of adc_raw_sample_save is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of aclk    : signal is "xilinx.com:signal:clock:1.0 aclk CLK";
  attribute X_INTERFACE_PARAMETER of aclk    : 
    signal is "ASSOCIATED_BUSIF aclk:s_axis:m_axis, FREQ_HZ 40000000";

  component ila_0 is
    port(
      clk                         : in  std_logic;
      probe0                      : in  std_logic_vector(69 downto 0)
    );
  end component ila_0;

  signal probe0                   : std_logic_vector(69 downto 0);

  signal r_max_sync               : std_logic;
  signal r_trigger                : std_logic;
  signal r_saving_samples         : std_logic := '0';

  signal r_flag                   : std_logic := '0';
  signal sample_1                 : std_logic_vector(15 downto 0) := (others => '0');
  signal r_axis_tvalid            : std_logic := '0';
  signal r_axis_tdata             : std_logic_vector(31 downto 0) := (others => '0');

begin

  process(aclk) begin
    if rising_edge(aclk) then
      r_trigger                   <= i_trigger;
      r_max_sync                  <= i_max_sync;
    end if;
  end process;

  process(aclk) begin
    if rising_edge(aclk) then
      if r_trigger = '0' and i_trigger = '1' then
        r_saving_samples          <= '0';
      elsif r_max_sync = '0' and i_max_sync = '1' then
        r_saving_samples          <= '1';
      end if;
    end if;
  end process;

  process(aclk) begin
    if rising_edge(aclk) then
      if r_saving_samples = '1' then
        if r_flag = '0' and s_axis_tvalid = '1' then
          sample_1                <= s_axis_tdata;
          r_axis_tvalid           <= '0';
          r_flag                  <= '1';
        elsif r_flag = '1' and s_axis_tvalid = '1' then
          r_axis_tdata            <= s_axis_tdata & sample_1;
          r_axis_tvalid           <= '1';
          r_flag                  <= '0';
        else
          r_axis_tvalid           <= '0';
        end if;
      else
        r_axis_tvalid             <= '0';
      end if;
    end if;
  end process;

  m_axis_tvalid                   <= r_axis_tvalid;
  m_axis_tdata                    <= r_axis_tdata;

  ila_gen : if g_ILA generate
  
    probe0                        <= s_axis_tdata & s_axis_tvalid & r_axis_tvalid & r_axis_tdata &
                                     r_flag & r_saving_samples & i_max_sync & i_trigger &
                                     r_max_sync & r_trigger & X"000" & "00";

    ila_inst : ila_0
      port map(
        clk                       => aclk,
        probe0                    => probe0
      );

  end generate;

end architecture RTL;
