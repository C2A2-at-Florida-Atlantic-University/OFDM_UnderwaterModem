-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: IQ mixer
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity iq_mixer_10M is
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
end entity iq_mixer_10M;

architecture RTL of iq_mixer_10M is

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

  signal i_sample                 : std_logic_vector(15 downto 0) := (others => '0');
  signal q_sample                 : std_logic_vector(15 downto 0) := (others => '0');
  signal cos_sample               : std_logic_vector(6 downto 0)  := (others => '0');
  signal sin_sample               : std_logic_vector(6 downto 0)  := (others => '0');
  signal real_sample              : std_logic_vector(15 downto 0) := (others => '0');

  constant READY                  : std_logic_vector(1 downto 0)  := "00";
  constant MIX_I                  : std_logic_vector(1 downto 0)  := "01";
  constant SAMPLE_I               : std_logic_vector(1 downto 0)  := "10";
  constant SAMPLE_Q               : std_logic_vector(1 downto 0)  := "11";

  signal Current_State            : std_logic_vector(1 downto 0)  := READY;
  signal Next_State               : std_logic_vector(1 downto 0)  := READY;

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

  -- Process to assign Current State
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      Current_State               <= Next_State;
    end if;
  end process;

  -- Process describing State machine
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then

      case Current_State is

        when READY =>
          if s_axis_tvalid = '1' then
            real_sample           <= s_axis_tdata;
            cos_sample            <= s_axis_dds_tdata(6 downto 0);
            sin_sample            <= s_axis_dds_tdata(14 downto 8);
          end if;

        when others =>
          NULL;

      end case;
    end if;
  end process;

  -- Process describing next state
  process(
    Current_State,
    s_axis_tvalid,
    m_axis_tready
  ) begin

    case Current_State is 

      when READY => 
        if s_axis_tvalid = '1' then
          Next_State              <= MIX_I;
        else
          Next_State              <= READY;
        end if;

      when MIX_I =>
        Next_State                <= SAMPLE_I;

      when SAMPLE_I =>
        if m_axis_tready = '1' then
          Next_State              <= SAMPLE_Q;
        else
          Next_State              <= SAMPLE_I;
        end if;

      when SAMPLE_Q =>
        if m_axis_tready = '1' then
          Next_State              <= READY;
        else
          Next_State              <= SAMPLE_Q;
        end if;

      when others =>
        Next_State                <= SAMPLE_Q;

    end case;
  end process;

  -- Process assigning output products
  process(
    Current_State,
    i_sample,
    q_sample
  ) begin
    
    case Current_State is

      when READY =>
        s_axis_tready             <= '1';
        m_axis_tdata              <= (others => '0');
        m_axis_tlast              <= '0';
        m_axis_tvalid             <= '0';
      
      when MIX_I =>
        s_axis_tready             <= '0';
        m_axis_tvalid             <= '0';
        m_axis_tlast              <= '0';
        m_axis_tdata              <= (others => '0');

      when SAMPLE_I =>
        s_axis_tready             <= '0';
        m_axis_tvalid             <= '1';
        m_axis_tlast              <= '0';
        m_axis_tdata              <= i_sample;

      when SAMPLE_Q =>
        s_axis_tready             <= '1';
        m_axis_tvalid             <= '1';
        m_axis_tlast              <= '1';
        m_axis_tdata              <= q_sample;

      when others =>
        s_axis_tready             <= '0';
        m_axis_tdata              <= (others => '0');
        m_axis_tlast              <= '0';
        m_axis_tvalid             <= '0';

    end case;
  end process;

end architecture RTL;
