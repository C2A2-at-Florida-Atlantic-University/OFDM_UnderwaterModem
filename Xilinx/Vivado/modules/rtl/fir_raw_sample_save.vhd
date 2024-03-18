-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Directly save raw ADC samples over DMA
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity fir_raw_sample_save is
  generic(
    g_ILA                         : boolean := false
  );
  port(
    aclk                          : in  std_logic;
    
    s_axis_tdata                  : in  std_logic_vector(15 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tlast                  : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(31 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;

    i_dac_sample_save             : in  std_logic_vector(23 downto 0);
    i_trigger                     : in  std_logic
  );
end entity fir_raw_sample_save;

architecture RTL of fir_raw_sample_save is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of aclk    : signal is "xilinx.com:signal:clock:1.0 aclk CLK";
  attribute X_INTERFACE_PARAMETER of aclk    : 
    signal is "ASSOCIATED_BUSIF aclk:s_axis:m_axis, FREQ_HZ 100000000";

  component ila_0 is
    port(
      clk                         : in  std_logic;
      probe0                      : in  std_logic_vector(69 downto 0)
    );
  end component ila_0;

  signal probe0                   : std_logic_vector(69 downto 0);

  signal r_trigger                : std_logic;
  signal r_axis_tvalid            : std_logic := '0';
  signal r_axis_tdata             : std_logic_vector(31 downto 0);
  signal counter                  : std_logic_vector(23 downto 0) := (others => '0');
  signal i_sample                 : std_logic_vector(15 downto 0) := (others => '0');
  signal r_axis_tlast             : std_logic;

begin

  process(aclk) begin
    if rising_edge(aclk) then 
      r_trigger                   <= i_trigger;
      r_axis_tlast                <= s_axis_tlast;
    end if;
  end process;

  process(aclk) begin
    if rising_edge(aclk) then
      if r_trigger = '0' and i_trigger = '1' then
        counter                   <= (others => '0');
      else
        if s_axis_tvalid = '1' then
          if s_axis_tlast = '1' then
            if counter >= i_dac_sample_save then
              r_axis_tvalid       <= '1';
              r_axis_tdata        <= s_axis_tdata & i_sample;
            else
              counter             <= counter + '1';
            end if;
          else
            if counter >= i_dac_sample_save then
              r_axis_tvalid       <= '0';
              i_sample            <= s_axis_tdata;
            end if;
          end if;
        else
          r_axis_tvalid           <= '0';
          r_axis_tdata            <= (others => '0');
        end if;
      end if;
    end if;
  end process;

  m_axis_tvalid                   <= r_axis_tvalid;
  m_axis_tdata                    <= r_axis_tdata;
  m_axis_tlast                    <= r_axis_tlast;

  ila_gen : if g_ILA generate
  
    probe0                        <= s_axis_tdata & s_axis_tvalid & r_axis_tvalid &
                                     r_axis_tdata & s_axis_tlast & r_axis_tlast & 
                                     i_trigger &
                                     r_trigger & X"0000";

    ila_inst : ila_0
      port map(
        clk                       => aclk,
        probe0                    => probe0
      );

  end generate;

end architecture RTL;
