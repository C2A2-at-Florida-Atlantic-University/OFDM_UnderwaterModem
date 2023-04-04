-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: IQ mixer
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity iq_mixer_rx is
  generic(
    g_CYCLES_PER_SAMPLE           : std_logic_vector(3 downto 0) := "1010"
  );
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(15 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tready                 : out std_logic;
     
    s_axis_dds_tdata              : in  std_logic_vector(15 downto 0);
    s_axis_dds_tvalid             : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(15 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic
  );
end entity iq_mixer_rx;

architecture RTL of iq_mixer_rx is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:s_axis_dds:m_axis, FREQ_HZ 100000000";

  component mult_gen_0 is
    port(
      CLK                         : in  std_logic;
      A                           : in  std_logic_vector(15 downto 0);
      B                           : in  std_logic_vector(6 downto 0);
      P                           : out std_logic_vector(15 downto 0)
    );
  end component mult_gen_0;

  constant c_ONES_MASK            : std_logic_vector(5 downto 0) := (others => '1');
  constant c_ZEROS_MASK           : std_logic_vector(5 downto 0) := (others => '0');

  signal toggle                   : std_logic                    := '0';
  signal counter                  : std_logic_vector(3 downto 0) := (others => '0');
  signal real_sample              : std_logic_vector(15 downto 0);
  signal out_tvalid               : std_logic;
  signal out_tlast                : std_logic;
  signal out_tdata                : std_logic_vector(15 downto 0);
  signal i_sample                 : std_logic_vector(15 downto 0);
  signal q_sample                 : std_logic_vector(15 downto 0);
  signal cos_sample               : std_logic_vector(6 downto 0);
  signal sin_sample               : std_logic_vector(6 downto 0);

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

  -- Read 1 sample from FIFO every ADC sample rate
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if counter = g_CYCLES_PER_SAMPLE-'1' then
        counter                   <= (others => '0');
        s_axis_tready             <= '1';
      else
        s_axis_tready             <= '0';
        counter                   <= counter + '1';
        if counter = g_CYCLES_PER_SAMPLE-"111" then
          real_sample             <= s_axis_tdata(15 downto 0);
          cos_sample              <= s_axis_dds_tdata(6 downto 0);
          sin_sample              <= s_axis_dds_tdata(14 downto 8);
        end if;
      end if;
    end if;
  end process;
        
  -- TDM I and Q
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if counter = g_CYCLES_PER_SAMPLE-"110" then
        out_tvalid                <= '1';
        out_tlast                 <= '0';
        out_tdata                 <= i_sample;
      elsif counter = g_CYCLES_PER_SAMPLE-'1' then
        out_tvalid                <= '1';
        out_tlast                 <= '1';
        out_tdata                 <= q_sample;
      else
        out_tvalid                <= '0';
        out_tlast                 <= '0';
        out_tdata                 <= (others => '0');
      end if;
    end if;
  end process;

  m_axis_tlast                    <= out_tlast;
  m_axis_tvalid                   <= out_tvalid;
  m_axis_tdata                    <= out_tdata;

end architecture RTL;
