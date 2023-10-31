-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: IQ mixer
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity iq_mixer_rx_40M is
  generic(
    g_CYCLES_PER_SAMPLE           : std_logic_vector(3 downto 0) := "1010"
  );
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(15 downto 0);
    s_axis_tvalid                 : in  std_logic;
     
    s_axis_dds_tdata              : in  std_logic_vector(31 downto 0);
    s_axis_dds_tvalid             : in  std_logic;

    m_axis_real_tdata             : out std_logic_vector(15 downto 0);
    m_axis_real_tvalid            : out std_logic;

    m_axis_imag_tdata             : out std_logic_vector(15  downto 0);
    m_axis_imag_tvalid            : out std_logic;

    i_gain_shift                  : in  std_logic_vector(2 downto 0)
  );
end entity iq_mixer_rx_40M;

architecture RTL of iq_mixer_rx_40M is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:s_axis_dds:m_axis_real:m_axis_imag, FREQ_HZ 40000000";

  component mult_gen_0 is
    port(
      CLK                         : in  std_logic;
      A                           : in  std_logic_vector(15 downto 0);
      B                           : in  std_logic_vector(15 downto 0);
      P                           : out std_logic_vector(31 downto 0)
    );
  end component mult_gen_0;

  signal i_sample                 : std_logic_vector(31 downto 0) := (others => '0');
  signal q_sample                 : std_logic_vector(31 downto 0) := (others => '0');
  signal cos_sample               : std_logic_vector(15 downto 0) := (others => '0');
  signal sin_sample               : std_logic_vector(15 downto 0) := (others => '0');
  signal real_sample              : std_logic_vector(15 downto 0) := (others => '0');

  signal w_tvalid                 : std_logic := '0';
  signal w_tvalid1                : std_logic := '0';

begin

  -- Real
  mult_gen_real_inst : mult_gen_0
    port map(
      CLK                         => axis_aclk,
      A                           => real_sample,
      B                           => cos_sample,
      P                           => i_sample
    );

  -- Imaginary
  mult_gen_imaginary_inst : mult_gen_0
    port map(
      CLK                         => axis_aclk,
      A                           => real_sample,
      B                           => sin_sample,
      P                           => q_sample
    );

  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      real_sample                 <= s_axis_tdata;
      cos_sample                  <= s_axis_dds_tdata(15 downto 0);
      sin_sample                  <= s_axis_dds_tdata(31 downto 16);
      w_tvalid                    <= s_axis_tvalid and s_axis_dds_tvalid;
      w_tvalid1                   <= w_tvalid;
    end if;
  end process;

  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      m_axis_real_tdata           <= 
        i_sample(31-to_integer(unsigned(i_gain_shift)) downto 16-to_integer(unsigned(i_gain_shift)));
      m_axis_imag_tdata           <= 
        q_sample(31-to_integer(unsigned(i_gain_shift)) downto 16-to_integer(unsigned(i_gain_shift)));
      m_axis_real_tvalid          <= w_tvalid1;
      m_axis_imag_tvalid          <= w_tvalid1;
    end if;
  end process;

end architecture RTL;
