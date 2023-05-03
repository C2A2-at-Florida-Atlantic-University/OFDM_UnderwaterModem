-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: IQ mixer
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity iq_mixer_tx is
  generic(
    g_CYCLES_PER_SAMPLE           : std_logic_vector(3 downto 0) := "1010"
  );
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(15 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tlast                  : in  std_logic;
     
    s_axis_dds_tdata              : in  std_logic_vector(31 downto 0);
    s_axis_dds_tvalid             : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(15 downto 0);
    m_axis_tvalid                 : out std_logic
  );
end entity iq_mixer_tx;

architecture RTL of iq_mixer_tx is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:s_axis_dds:m_axis, FREQ_HZ 100000000";

  component mult_gen_0 is
    port(
      CLK                         : in  std_logic;
      A                           : in  std_logic_vector(15 downto 0);
      B                           : in  std_logic_vector(15 downto 0);
      P                           : out std_logic_vector(31 downto 0)
    );
  end component mult_gen_0;

  constant c_ONES_MASK            : std_logic_vector(5 downto 0) := (others => '1');
  constant c_ZEROS_MASK           : std_logic_vector(5 downto 0) := (others => '0');

  signal i_sample                 : std_logic_vector(15 downto 0);
  signal q_sample                 : std_logic_vector(15 downto 0);
  signal i_sample_out             : std_logic_vector(31 downto 0);
  signal q_sample_out             : std_logic_vector(31 downto 0);
  signal i_sample_out_reg         : std_logic_vector(15 downto 0);
  signal q_sample_out_reg         : std_logic_vector(15 downto 0);
  signal cos_sample               : std_logic_vector(15 downto 0);
  signal sin_sample               : std_logic_vector(15 downto 0);
  signal i_trigg                  : std_logic;
  signal i_trigg1                 : std_logic;
  signal q_trigg                  : std_logic;
  signal q_trigg1                 : std_logic;
  signal q_trigg2                 : std_logic;

begin

  -- Real
  mult_gen_real_inst : mult_gen_0
    port map(
      CLK                         => axis_aclk,
      A                           => i_sample,
      B                           => cos_sample,
      P                           => i_sample_out
    );

  -- Imaginary
  mult_gen_imaginary_inst : mult_gen_0
    port map(
      CLK                         => axis_aclk,
      A                           => q_sample,
      B                           => sin_sample,
      P                           => q_sample_out
    );

  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if s_axis_tvalid = '1' and s_axis_dds_tvalid = '1' then
        if s_axis_tlast = '1' then
          q_sample                <= s_axis_tdata;
          q_trigg                 <= '1';
        else
          cos_sample              <= s_axis_dds_tdata(15 downto 0);
          sin_sample              <= s_axis_dds_tdata(31 downto 16);
          i_sample                <= s_axis_tdata;
          i_trigg                 <= '1';
        end if;
      else
        i_trigg                   <= '0';
        q_trigg                   <= '0';
      end if;
    end if;
  end process;

  process(axis_aclk) 
  begin
    if rising_edge(axis_aclk) then
      i_trigg1                    <= i_trigg;
      q_trigg1                    <= q_trigg;
      q_trigg2                    <= q_trigg1;
      if i_trigg1 = '1' then
        i_sample_out_reg          <= i_sample_out(31 downto 16);
      end if;
      if q_trigg1 = '1' then
        q_sample_out_reg          <= q_sample_out(31 downto 16);
      end if;
      if q_trigg2 = '1' then
        m_axis_tdata              <= q_sample_out_reg + i_sample_out_reg;
        m_axis_tvalid             <= '1';
      else
        m_axis_tdata              <= (others => '0');
        m_axis_tvalid             <= '0';
      end if;
    end if;
  end process;

end architecture RTL;
