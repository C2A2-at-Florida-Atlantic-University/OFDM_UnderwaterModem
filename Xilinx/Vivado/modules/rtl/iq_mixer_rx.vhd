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
    g_CYCLES_PER_SAMPLE           : integer := 10
  );
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(15 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tready                 : out std_logic;
    
    s_axis_dds_tdata              : in  std_logic_vector(31 downto 0);
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
      B                           : in  std_logic_vector(15 downto 0);
      P                           : out std_logic_vector(15 downto 0)
    );
  end component mult_gen_0;

  signal toggle                   : std_logic             := '0';
  signal counter                  : std_logic_vector(3 downto 0);
  signal real_sample              : std_logic_vector(15 downto 0);
  signal out_tvalid               : std_logic;
  signal out_tlast                : std_logic;
  signal i_sample                 : std_logic_vector(15 downto 0);
  signal q_sample                 : std_logic_vector(15 downto 0);
  signal i_sample_save            : std_logic_vector(15 downto 0);
  signal q_sample_save            : std_logic_vector(15 downto 0);

begin

  -- Real
  mult_gen_real_inst : mult_gen_0
    port map(
      CLK                         => axis_aclk,
      A                           => real_sample,
      B                           => s_axis_dds_tdata(15 downto 0),
      P                           => i_sample
    );

  -- Imaginary
  mult_gen_imaginary_inst : mult_gen_0
    port map(
      CLK                         => axis_aclk,
      A                           => real_sample,
      B                           => s_axis_dds_tdata(31 downto 16),
      P                           => q_sample
    );

  -- Read 1 sample from FIFO every ADC sample rate
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if counter = std_logic_vector(unsigned(g_CYCLES_PER_SAMPLE-1)) then
        counter                   <= (others => '0');
        s_axis_tready             <= '1';
      else
        s_axis_tready             <= '0';
        counter                   <= counter + '1';
        if counter = X"0" then
          real_sample             <= s_axis_tdata(15 downto 0);
        end if;
      end if;
    end if;
  end process;
        
  -- TDM I and Q
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if m_axis_tready = '1' then
        toggle                    <= not toggle;
        out_tvalid                <= '1';
        if toggle = '1' then
          out_tlast               <= '1';
        else
          out_tlast               <= '0';
        end if;
      end if;
    end if;
  end process;

  i_sample_save <= i_sample when (out_tvalid = '1' and out_tlast = '0') else (others => '0');
  q_sample_save <= q_sample when (out_tvalid = '1' and out_tlast = '0') else (others => '0');
 
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if out_tlast = '0' then
        m_axis_tdata              <= i_sample_save;
      else
        m_axis_tdata              <= q_sample_save;
      end if;
      m_axis_tvalid               <= out_tvalid;
      m_axis_tlast                <= out_tlast;
    end if;
  end process;

end architecture RTL;
