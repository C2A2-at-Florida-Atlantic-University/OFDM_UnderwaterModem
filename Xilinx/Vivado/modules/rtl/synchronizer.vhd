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

    m_axis_tdata                  : out std_logic_vector(31 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;
    m_axis_tready                 : in  std_logic;
    m_axis_tkeep                  : out std_logic_vector(3 downto 0);

    i_nfft                        : in  std_logic_vector(11 downto 0);
    i_cp_len                      : in  std_logic_vector(11 downto 0);
    i_symbols                     : in  std_logic_vector(3 downto 0);
    i_max_sync                    : in  std_logic
  );
end entity synchronizer;

architecture RTL of synchronizer is
  
  constant c_LOGIC_DELAY          : std_logic_vector(11 downto 0) := "000000000001";

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:s_axis:m_axis, FREQ_HZ 100000000";

  component ila_0 is
    port(
      clk                         : in  std_logic;
      probe0                      : in  std_logic_vector(54 downto 0)
    );
  end component ila_0;

  signal initial_counter          : std_logic_vector(11 downto 0):= (others => '0');
  signal nfft_cp_counter          : std_logic_vector(12 downto 0):= (others => '0');
  signal symbol_counter           : std_logic_vector(3 downto 0) := (others => '0');
  signal r_max_sync               : std_logic := '0';
  signal r_frame_done             : std_logic := '0';

  signal w_axis_tdata             : std_logic_vector(31 downto 0);
  signal w_axis_tlast             : std_logic;
  signal w_axis_tvalid            : std_logic;

  signal probe0                   : std_logic_vector(54 downto 0);

begin

  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if i_max_sync = '1' then
        r_max_sync                <= '1';
      elsif r_frame_done = '1' then
        r_max_sync                <= '0';
      end if;
    end if;
  end process;

  -- Delay cp_len samples after peak detected
  process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      if r_max_sync = '1' then
        if initial_counter = i_cp_len then
          NULL;
        else
          initial_counter           <= initial_counter + '1';
        end if;
      else
        initial_counter             <= (others => '0');
      end if;
    end if;
  end process;

  process(axis_aclk)
  begin 
    if rising_edge(axis_aclk) then
      if initial_counter = i_cp_len then
        w_axis_tdata                <= s_axis_tdata;
        w_axis_tvalid               <= s_axis_tvalid;
        if (s_axis_tvalid = '1') and nfft_cp_counter = (('0' & i_cp_len)+('0' & i_nfft)) then
          nfft_cp_counter           <= (others => '0');
          if symbol_counter = i_symbols then
            symbol_counter          <= (others => '0');
            r_frame_done            <= '1';
            w_axis_tlast            <= '0';
          else
            symbol_counter          <= symbol_counter + '1';
            w_axis_tlast            <= '0';
          end if; -- symbol_counter
        else
          nfft_cp_counter           <= nfft_cp_counter + '1';
        end if; -- nfft_cp_counter
      else
        r_frame_done                <= '0';
        w_axis_tdata                <= (others => '0');
        w_axis_tvalid               <= '0';
        w_axis_tlast                <= '0';
      end if; -- initial_counter
    end if; -- rising_edge
  end process;

  m_axis_tkeep                      <= X"F";
  m_axis_tdata                      <= w_axis_tdata;
  m_axis_tvalid                     <= w_axis_tvalid;
  m_axis_tlast                      <= w_axis_tlast;

  ila_gan : if g_ILA generate
  
    probe0                          <= w_axis_tlast & w_axis_tvalid &
                                       symbol_counter & nfft_cp_counter & r_frame_done & 
                                       r_max_sync & i_max_sync & s_axis_tvalid & s_axis_tdata;

    ila_inst : ila_0
      port map(
        clk                         => axis_aclk,
        probe0                      => probe0
      );
  end generate;

end architecture RTL;
