-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Concat I and Q AXIS Streams into single AXIS
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity iq_tdm_concat is
  generic(
    g_TDATA_WIDTH                 : integer := 32
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

  type t_state is (I_SAMPLE, Q_SAMPLE);
  signal Current_State            : t_state := I_SAMPLE;
  signal Next_State               : t_state := I_SAMPLE;

  signal i_data                   : std_logic_vector(15 downto 0) := (others => '0');

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
        m_axis_tdata              <= (others => '0');
        s_axis_tready             <= '0';
        m_axis_tvalid             <= '0';

      when Q_SAMPLE =>
        if m_axis_tready = '1' then
          case i_gain_shift is
            when "00" =>
              m_axis_tdata        <= s_axis_tdata & i_data;
            when "01" =>
              m_axis_tdata        <= s_axis_tdata(14 downto 0) & '0' & i_data(14 downto 0) & '0';
            when "10" =>
              m_axis_tdata        <= s_axis_tdata(13 downto 0) & "00" & i_data(13 downto 0) & "00";
            when "11" =>
              m_axis_tdata        <= s_axis_tdata(12 downto 0) & "000" & i_data(12 downto 0) & "000";
            when others =>
              m_axis_tdata        <= s_axis_tdata & i_data;
          end case;
        else
          m_axis_tdata            <= (others => '0');
        end if;
        s_axis_tready             <= '1';
        m_axis_tvalid             <= s_axis_tvalid and m_axis_tready;

      when others =>
        s_axis_tready             <= '0';
        m_axis_tdata              <= (others => '0');
        m_axis_tvalid             <= '0';

    end case;
  end process p_OUTPUT_SIGNALS;

end architecture RTL;
