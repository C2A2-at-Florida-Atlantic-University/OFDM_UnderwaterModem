-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Synchronize data based on sync symbol peak
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity synchronizer is
  generic(
    g_ILA                         : boolean := false
  );
  port(
    axis_aclk                     : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(31 downto 0);
    s_axis_tvalid                 : in  std_logic;

    s_axis_abs_ila_tdata          : in  std_logic_vector(63 downto 0);
    s_axis_abs_ila_tvalid         : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(31 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic;
    m_axis_tkeep                  : out std_logic_vector(3 downto 0);

    i_nfft                        : in  std_logic_vector(11 downto 0);
    i_cp_len                      : in  std_logic_vector(11 downto 0);
    i_symbols                     : in  std_logic_vector(3 downto 0);
    i_trig_offset                 : in  std_logic_vector(9 downto 0);
    i_max_sync                    : in  std_logic
  );
end entity synchronizer;

architecture RTL of synchronizer is
  
  constant c_LOGIC_DELAY          : std_logic_vector(11 downto 0) := "000000000001";

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:s_axis_abs_ila:m_axis, FREQ_HZ 100000000";

  component ila_0 is
    port(
      clk                         : in  std_logic;
      probe0                      : in  std_logic_vector(87 downto 0)
    );
  end component ila_0;

  signal probe0                   : std_logic_vector(87 downto 0);

  constant IDLE                   : std_logic_vector(1 downto 0) := "00";
  constant SYNC_PEAK              : std_logic_vector(1 downto 0) := "01";
  constant SYMBOL                 : std_logic_vector(1 downto 0) := "10";
  constant SYMBOL_TRANSITION      : std_logic_vector(1 downto 0) := "11";
  signal Current_State            : std_logic_vector(1 downto 0) := IDLE;
  signal Next_State               : std_logic_vector(1 downto 0) := IDLE;

  signal r_axis_tdata             : std_logic_vector(31 downto 0);
  signal r_axis_tvalid            : std_logic;

  signal symbol_counter           : std_logic_vector(3 downto 0);
  signal initial_counter          : std_logic_vector(12 downto 0);
  signal nfft_cp_counter          : std_logic_vector(13 downto 0);

begin

  -- Process to assign Current_State
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      Current_State                  <= Next_State;
    end if;
  end process;

  -- Process to control state machine
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      case Current_State is
        when IDLE =>
          symbol_counter          <= (others => '0');
          initial_counter         <= (others => '0');
          nfft_cp_counter         <= (others => '0');

        when SYNC_PEAK =>
          if s_axis_tvalid = '1' then
            initial_counter       <= initial_counter + '1';
          end if;

        when SYMBOL =>
          if s_axis_tvalid = '1' then
            nfft_cp_counter       <= nfft_cp_counter + '1';
          end if;

        when SYMBOL_TRANSITION =>
          symbol_counter          <= symbol_counter + '1';
          nfft_cp_counter         <= (others => '0');

        when others =>
          symbol_counter          <= (others => '0');
          initial_counter         <= (others => '0');
          nfft_cp_counter         <= (others => '0');

      end case;
    end if;
  end process;

  -- Process to assign Next State
  process(
    Current_State,
    initial_counter,
    nfft_cp_counter,
    symbol_counter,
    i_symbols,
    i_nfft,
    i_cp_len,
    i_trig_offset,
    i_max_sync
  ) begin
    case Current_State is
      when IDLE =>
        if i_max_sync = '1' then
          Next_State              <= SYNC_PEAK;
        else
          Next_State              <= IDLE;
        end if;

      when SYNC_PEAK =>
        if initial_counter = 
          ('0' & i_cp_len)+(X"00" & i_trig_offset(4 downto 0))-
          (X"00" & i_trig_offset(9 downto 5)) then
          Next_State              <= SYMBOL;
        else
          Next_State              <= SYNC_PEAK;
        end if;

      when SYMBOL =>
        if nfft_cp_counter = (('0' & i_cp_len)+('0' & i_nfft)+"10") then
          Next_State              <= SYMBOL_TRANSITION;
        else
          Next_State              <= SYMBOL;
        end if;

      when SYMBOL_TRANSITION =>
        if symbol_counter = i_symbols then
          Next_State              <= IDLE;
        else
          Next_State              <= SYMBOL;
        end if;

      when others =>
        Next_State                <= IDLE;

    end case;
  end process;

  -- Process to assign state output products
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      case Current_State is
        when IDLE =>
          r_axis_tdata            <= (others => '0');
          r_axis_tvalid           <= '0';

        when SYNC_PEAK =>
          NULL;

        when SYMBOL =>
          r_axis_tdata            <= s_axis_tdata;
          r_axis_tvalid           <= s_axis_tvalid;

        when SYMBOL_TRANSITION =>
          r_axis_tdata            <= s_axis_tdata;
          r_axis_tvalid           <= s_axis_tvalid;

        when others =>
          r_axis_tdata            <= (others => '0');
          r_axis_tvalid           <= '0';

      end case;
    end if;
  end process;

  m_axis_tdata                    <= r_axis_tdata;
  m_axis_tvalid                   <= r_axis_tvalid;
  m_axis_tlast                    <= '1' when nfft_cp_counter = 
                                  (('0' & i_cp_len)+('0' & i_nfft)+"10") 
                                  else '0';
  m_axis_tkeep                    <= X"F";

  ila_gen : if g_ILA generate
  
    probe0                          <= s_axis_abs_ila_tvalid & s_axis_abs_ila_tdata(31 downto 0) &
                                       r_axis_tvalid & Current_State &
                                       symbol_counter & nfft_cp_counter & 
                                       i_max_sync & s_axis_tvalid & s_axis_tdata;

    ila_inst : ila_0
      port map(
        clk                         => axis_aclk,
        probe0                      => probe0
      );

  end generate;

end architecture RTL;
