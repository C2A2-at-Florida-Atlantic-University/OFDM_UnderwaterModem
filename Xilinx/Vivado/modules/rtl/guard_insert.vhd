-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Insert a guard period between symbols
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity guard_insert is
  generic(
    g_ILA                         : boolean := false
  );
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(31 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tlast                  : in  std_logic;
    s_axis_tready                 : out std_logic;

    m_axis_tdata                  : out std_logic_vector(31 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic;

    i_guard_cycles                : in  std_logic_vector(31 downto 0);
    i_nfft                        : in  std_logic_vector(13 downto 0);
    i_cp_len                      : in  std_logic_vector(11 downto 0)
  );
end entity guard_insert;
 
architecture RTL of guard_insert is 

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  component ila_0 is
    port(
      clk                         : in  std_logic;
      probe0                      : in  std_logic_vector(87 downto 0)
    );
  end component ila_0;

  signal probe0                   : std_logic_vector(87 downto 0);

  signal Guard_Counter            : std_logic_vector(31 downto 0);
  signal CP_Counter               : std_logic_vector(11 downto 0);
  signal Nfft_Counter             : std_logic_vector(13 downto 0);

  constant IDLE                   : std_logic_vector(1 downto 0) := "00";
  constant CP                     : std_logic_vector(1 downto 0) := "01";
  constant SYMBOL                 : std_logic_vector(1 downto 0) := "10";
  constant GUARD                  : std_logic_vector(1 downto 0) := "11";

  signal Current_State            : std_logic_vector(1 downto 0) := IDLE;
  signal Next_State               : std_logic_vector(1 downto 0) := IDLE;

  signal w_axis_tdata             : std_logic_vector(31 downto 0);
  signal w_axis_tvalid            : std_logic;

begin

  -- Process to assign Current_State
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      Current_State                <= Next_State;
    end if;
  end process;

  -- Process to control state machine
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      case Current_State is
        when IDLE =>
          Guard_Counter             <= (others => '0');
          CP_Counter                <= (others => '0');
          Nfft_Counter              <= (others => '0');

        when CP =>
          if m_axis_tready = '1' and s_axis_tvalid = '1' then
            CP_Counter              <= CP_Counter + '1';
          end if;
          Nfft_Counter              <= (others => '0');

        when SYMBOL =>
          if m_axis_tready = '1' and s_axis_tvalid = '1' then
            Nfft_Counter            <= Nfft_Counter + '1';
          end if;
          CP_Counter                <= (others => '0');
          Guard_Counter             <= (others => '0');

        when GUARD =>
          Guard_Counter             <= Guard_Counter + '1';
          Nfft_Counter              <= (others => '0');
          CP_Counter                <= (others => '0');

        when others =>
          NULL;

      end case;
    end if;
  end process;

  -- Process to assign Next State
  process(
    Current_State,
    Nfft_Counter,
    CP_Counter,
    Guard_Counter,
    i_nfft,
    i_cp_len,
    i_guard_cycles,
    s_axis_tvalid,
    s_axis_tlast
  ) begin
    case Current_State is
      when IDLE =>
        if s_axis_tvalid = '1' then
          if i_cp_len = "000000000000" then
            Next_State              <= SYMBOL;
          else
            Next_State              <= CP;
          end if;
        else
          Next_State                <= IDLE;
        end if;

      when CP =>
        if s_axis_tlast = '0' then
          if CP_Counter = i_cp_len then
            Next_State              <= SYMBOL;
          else
            Next_State              <= CP;
          end if;
        else
          Next_State                <= IDLE;
        end if;

      when SYMBOL =>
        if s_axis_tlast = '0' then
          if Nfft_Counter = i_nfft then
            if i_guard_cycles = X"00000000" then
              Next_State            <= CP;
            else
              Next_State            <= GUARD;
            end if;
          else
            Next_State              <= SYMBOL;
          end if;
        else
          Next_State                <= IDLE;
        end if;

      when GUARD =>
        if s_axis_tlast = '0' then
          if Guard_Counter = i_guard_cycles then
            Next_State              <= CP;
          else
            Next_State              <= GUARD;
          end if;
        else
          Next_State                <= IDLE;
        end if;

      when others =>
        Next_State                  <= IDLE;

    end case;
  end process;

  -- Process to assign state machine output products
  process(
    Current_State, 
    m_axis_tready,
    s_axis_tvalid,
    s_axis_tdata,
    s_axis_tlast
  ) 
  begin
    case Current_State is
      when IDLE =>
        s_axis_tready               <= m_axis_tready;
        w_axis_tvalid               <= s_axis_tvalid;
        w_axis_tdata                <= s_axis_tdata;
        m_axis_tlast                <= s_axis_tlast;

      when CP =>
        s_axis_tready               <= m_axis_tready;
        w_axis_tvalid               <= s_axis_tvalid;
        w_axis_tdata                <= s_axis_tdata;
        m_axis_tlast                <= s_axis_tlast;

      when SYMBOL =>
        s_axis_tready               <= m_axis_tready;
        w_axis_tvalid               <= s_axis_tvalid;
        w_axis_tdata                <= s_axis_tdata;
        m_axis_tlast                <= s_axis_tlast;

      when GUARD =>
        s_axis_tready               <= '0';
        w_axis_tvalid               <= '0';
        w_axis_tdata                <= (others => '0');
        m_axis_tlast                <= '0';

      when others =>
        s_axis_tready               <= m_axis_tready;
        w_axis_tvalid               <= s_axis_tvalid;
        w_axis_tdata                <= s_axis_tdata;
        m_axis_tlast                <= s_axis_tlast;

    end case;
  end process;

  m_axis_tdata                      <= w_axis_tdata;
  m_axis_tvalid                     <= w_axis_tvalid;
  
  ila_gen : if g_ILA generate

    probe0                          <= s_axis_tdata & s_axis_tvalid & w_axis_tdata & w_axis_tvalid &
                                       m_axis_tready & Current_State & Guard_Counter(18 downto 0);
  
    ila_inst : ila_0
      port map(
        clk                         => axis_aclk,
        probe0                      => probe0
      );

  end generate;

end architecture RTL;
