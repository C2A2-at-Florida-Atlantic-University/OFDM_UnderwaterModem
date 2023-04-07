-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Reformat TDM stream
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tdm_reformat_tx is
  port(
    axis_aclk                     : in  std_logic;

    -- In order to safely ignore the s_axis_tkeep signal, make sure
    -- the set the AXI DMA TDEST register to 0
    s_axis_tdata                  : in  std_logic_vector(31 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tready                 : out std_logic;
    s_axis_tlast                  : in  std_logic;
    s_axis_tkeep                  : in  std_logic_vector(3 downto 0);
    
    m_axis_tdata                  : out std_logic_vector(15 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic
  );
end entity tdm_reformat_tx;

architecture RTL of tdm_reformat_tx is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  type t_state is (IDLE, GET_DATA, I_SAMPLE, Q_SAMPLE);
  signal Current_State            : t_state := IDLE;
  signal Next_State               : t_state := IDLE;

  signal iq_data                  : std_logic_vector(31 downto 0) := (others => '0');
  
begin

  p_ASSIGN_STATE: process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      Current_State               <= Next_State;
    end if;
  end process p_ASSIGN_STATE;

  p_CURRENT_STATE : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then

      case Current_State is

        when IDLE =>
          iq_data                 <= (others => '0');

        when GET_DATA =>
          iq_data                 <= s_axis_tdata;

        when I_SAMPLE => 
          NULL;

        when Q_SAMPLE =>
          NULL;

        when others =>
          NULL;

      end case;
    end if;
  end process P_CURRENT_STATE;

  p_NEXT_STATE : process(
    Current_State,
    s_axis_tvalid,
    m_axis_tready
  ) begin
    
    case Current_State is
      
      when IDLE =>
        if s_axis_tvalid = '1' then
          Next_State              <= GET_DATA;
        else
          Next_State              <= IDLE;
        end if;

      when GET_DATA =>
        Next_State                <= I_SAMPLE;

      when I_SAMPLE =>
        if m_axis_tready = '1' then
          Next_State              <= Q_SAMPLE;
        else
          Next_State              <= I_SAMPLE;
        end if;

      when Q_SAMPLE =>
        if m_axis_tready = '1' then
          Next_State              <= IDLE;
        else
          Next_State              <= Q_SAMPLE;
        end if;

      when others =>
        Next_State                <= IDLE;

    end case;
  end process;

  p_OUTPUT_SIGNALS : process(
    Current_State,
    m_axis_tready,
    iq_data
  ) begin
    
    case Current_State is
      
      when IDLE =>
        s_axis_tready             <= '0';
        m_axis_tdata              <= (others => '0');
        m_axis_tvalid             <= '0';
        m_axis_tlast              <= '0';

      when GET_DATA =>
        s_axis_tready             <= '1';
        m_axis_tdata              <= (others => '0');
        m_axis_tvalid             <= '0'; 
        m_axis_tlast              <= '0';

      when I_SAMPLE =>
        if m_axis_tready = '1' then
          m_axis_tdata            <= iq_data(15 downto 0);
        else
          m_axis_tdata            <= (others => '0');
        end if;
        s_axis_tready             <= '0';
        m_axis_tvalid             <= m_axis_tready;
        m_axis_tlast              <= '0';

      when Q_SAMPLE =>
        if m_axis_tready = '1' then
          m_axis_tdata            <= iq_data(31 downto 16);
        else
          m_axis_tdata            <= (others => '0');
        end if;
        s_axis_tready             <= '0';
        m_axis_tvalid             <= m_axis_tready;
        m_axis_tlast              <= '1';

      when others =>
        s_axis_tready             <= '0';
        m_axis_tdata              <= (others => '0');
        m_axis_tvalid             <= '0';
        m_axis_tlast              <= '0';

    end case;
  end process p_OUTPUT_SIGNALS;

end architecture RTL;
