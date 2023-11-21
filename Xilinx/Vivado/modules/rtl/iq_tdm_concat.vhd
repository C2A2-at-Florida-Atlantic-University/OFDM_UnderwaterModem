-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Concat I and Q AXIS Streams into single AXIS
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity iq_tdm_concat is
  generic(
    g_TDATA_WIDTH                 : integer := 32;
    g_ILA                         : boolean := false
  );
  port(
    aclk                          : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(g_TDATA_WIDTH/2-1 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tready                 : out std_logic;
    s_axis_tlast                  : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(g_TDATA_WIDTH-1 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tready                 : in  std_logic;

    i_gain_shift                  : in  std_logic_vector(1 downto 0)
  );
end entity iq_tdm_concat;

architecture RTL of iq_tdm_concat is

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

  constant I_SAMPLE               : std_logic := '0';
  constant Q_SAMPLE               : std_logic := '1';

  signal Current_State            : std_logic := I_SAMPLE;
  signal Next_State               : std_logic := I_SAMPLE;

  signal i_data                   : std_logic_vector(15 downto 0) := (others => '0');

  signal r_axis_tdata             : std_logic_vector(31 downto 0);
  signal r_axis_tvalid            : std_logic;
  signal r_s_axis_tready          : std_logic;

begin

  process (aclk)
  begin
    if rising_edge(aclk) then
      Current_State               <= Next_State;
    end if;
  end process;

  p_CURRENT_STATE: process(aclk)
  begin
    if rising_edge(aclk) then
      case Current_State is
        
        when I_SAMPLE =>
          if s_axis_tvalid = '1' and s_axis_tlast = '0' then
            i_data                <= s_axis_tdata;
          end if;

        when Q_SAMPLE =>
          NULL;

        when others =>
          NULL;

      end case;
    end if;
  end process p_CURRENT_STATE;

  p_NEXT_STATE : process(
    Current_State,
    s_axis_tvalid,
    m_axis_tready
  ) begin
    
    case Current_State is
      
      when I_SAMPLE =>
        if s_axis_tvalid = '1' and s_axis_tlast = '0' then
          Next_State              <= Q_SAMPLE;
        else
          Next_State              <= I_SAMPLE;
        end if;

      when Q_SAMPLE =>
        if m_axis_tready = '1' and s_axis_tvalid = '1' and s_axis_tlast = '1' then
          Next_State              <= I_SAMPLE;
        else
          Next_State              <= Q_SAMPLE;
        end if;

      when others =>
        Next_State                <= I_SAMPLE;

    end case;
  end process;

  p_OUTPUT_SIGNALS : process(
    Current_State,
    m_axis_tready,
    s_axis_tdata,
    s_axis_tvalid,
    i_data
  ) begin
    
    case Current_State is

      when I_SAMPLE =>
        --if m_axis_tready = '1' and s_axis_tvalid = '1' then
          --m_axis_tdata            <= s_axis_tdata(15 downto 0);
        r_axis_tdata              <= (others => '0');
        r_s_axis_tready           <= '0';
        r_axis_tvalid             <= '0';

      when Q_SAMPLE =>
        if m_axis_tready = '1' then
          case i_gain_shift is
            when "00" =>
              r_axis_tdata        <= s_axis_tdata & i_data;
            when "01" =>
              r_axis_tdata        <= s_axis_tdata(14 downto 0) & '0' & i_data(14 downto 0) & '0';
            when "10" =>
              r_axis_tdata        <= s_axis_tdata(13 downto 0) & "00" & i_data(13 downto 0) & "00";
            when "11" =>
              r_axis_tdata        <= s_axis_tdata(12 downto 0) & "000" & i_data(12 downto 0) & "000";
            when others =>
              r_axis_tdata        <= s_axis_tdata & i_data;
          end case;
        else
          r_axis_tdata            <= (others => '0');
        end if;
        r_s_axis_tready           <= '1';
        r_axis_tvalid             <= s_axis_tvalid and m_axis_tready;

      when others =>
        r_s_axis_tready           <= '0';
        r_axis_tdata              <= (others => '0');
        r_axis_tvalid             <= '0';

    end case;
  end process p_OUTPUT_SIGNALS;

  m_axis_tdata                    <= r_axis_tdata;
  m_axis_tvalid                   <= r_axis_tvalid;
  s_axis_tready                   <= r_s_axis_tready;

  ila_gen : if g_ILA generate

    probe0                        <= s_axis_tdata & s_axis_tvalid & s_axis_tlast & 
                                     r_axis_tdata & r_axis_tvalid & r_s_axis_tready &
                                     Current_State & Next_State & X"0000";

    ila_inst : ila_0
      port map(
        clk                         => aclk,
        probe0                      => probe0
      );

  end generate;

end architecture RTL;
