-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Read OFDM symbols from BRAM. Configurable
--      cycles per sample

-----------------------------------------------------------------
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

entity playback_ctrl is
  generic(
    g_CLOCK_CYCLES                : natural := 4;     -- Number of clocks between data
    g_SYMBOL_LENGTH               : natural := 1280;  -- Number of samples in symbol
    g_NUM_SYMBOLS                 : natural := 4      -- Number of symbols in frame
  );
  port(
    axis_aclk                     : in  std_logic;
    axis_aresetn                  : in  std_logic;

    playback_en                   : in  std_logic;
    fs_cycles                     : in  std_logic_vector(26 downto 0);
    symbols                       : in  std_logic_vector(3 downto 0);
    nfft_scaled                   : in  std_logic_vector(11 downto 0);
    continuous                    : in  std_logic;
    
    BRAM_PORT_addr                : out std_logic_vector(31 downto 0);
    BRAM_PORT_clk                 : out std_logic;
    BRAM_PORT_din                 : out std_logic_vector(31 downto 0);
    BRAM_PORT_dout                : in  std_logic_vector(31 downto 0);
    BRAM_PORT_en                  : out std_logic;
    BRAM_PORT_rst                 : out std_logic;
    BRAM_PORT_we                  : out std_logic_vector(0 downto 0);

    M_AXIS_tdata                  : out std_logic_vector(31 downto 0);
    M_AXIS_tvalid                 : out std_logic;
    M_AXIS_tlast                  : out std_logic;
    M_AXIS_tready                 : in  std_logic
  );
end entity playback_ctrl;

architecture RTL of playback_ctrl is

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of axis_aclk    : signal is "xilinx.com:signal:clock:1.0 axis_aclk CLK";
  attribute X_INTERFACE_PARAMETER of axis_aclk    : 
    signal is "ASSOCIATED_BUSIF axis_aclk:m_axis, FREQ_HZ 100000000";

  attribute X_INTERFACE_INFO      of BRAM_PORT_addr   : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT ADDR";
  attribute X_INTERFACE_INFO      of BRAM_PORT_clk    : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT CLK";
  attribute X_INTERFACE_INFO      of BRAM_PORT_din    : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT DIN";
  attribute X_INTERFACE_INFO      of BRAM_PORT_dout   : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT DOUT";
  attribute X_INTERFACE_INFO      of BRAM_PORT_en     : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT EN";
  attribute X_INTERFACE_INFO      of BRAM_PORT_rst    : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT RST";
  attribute X_INTERFACE_INFO      of BRAM_PORT_we     : signal is "xilinx.com:interface:bram:1.0 BRAM_PORT WE";

  attribute X_INTERFACE_PARAMETER of BRAM_PORT_addr   : signal is "MASTER_TYPE BRAM_CTRL";
  attribute X_INTERFACE_PARAMETER of BRAM_PORT_clk    : signal is "MASTER_TYPE BRAM_CTRL";
  attribute X_INTERFACE_PARAMETER of BRAM_PORT_din    : signal is "MASTER_TYPE BRAM_CTRL";
  attribute X_INTERFACE_PARAMETER of BRAM_PORT_dout   : signal is "MASTER_TYPE BRAM_CTRL";
  attribute X_INTERFACE_PARAMETER of BRAM_PORT_en     : signal is "MASTER_TYPE BRAM_CTRL";
  attribute X_INTERFACE_PARAMETER of BRAM_PORT_rst    : signal is "MASTER_TYPE BRAM_CTRL";
  attribute X_INTERFACE_PARAMETER of BRAM_PORT_we     : signal is "MASTER_TYPE BRAM_CTRL";

  -- Number of symbols
  signal symbol_counter           : std_logic_vector(3 downto 0);
  -- Max nFFT = 4096, max cp_len = 4096
  signal nfft_counter             : std_logic_vector(11 downto 0);
  -- lowest BW supported: 1000 Hz, highest BW supported: 50 MHz
  signal quiet_counter            : std_logic_vector(26 downto 0);

  signal bram_addr                : std_logic_vector(31 downto 0);
  signal out_tvalid               : std_logic;
  signal out_tlast                : std_logic;
  signal out_tdata                : std_logic_vector(31 downto 0);
  signal r_axis_tready            : std_logic;
  signal tready_falling           : std_logic;

begin

  -- Process to read from BRAM
  P_BRAM_READ : process(axis_aclk, axis_aresetn)
  begin
    if axis_aresetn = '0' then
      NULL;
    elsif rising_edge(axis_aclk) then
      if playback_en = '0' then
        nfft_counter              <= (others => '0');
        quiet_counter             <= (others => '0');
        symbol_counter            <= (others => '0');
        bram_addr                 <= (others => '0');
        out_tvalid                <= '0';
        out_tlast                 <= '0';
      else
        if symbol_counter = symbols then
          if continuous = '1' then
            symbol_counter        <= (others => '0');
          end if;
          bram_addr               <= (others => '0');
          out_tvalid              <= '0';
          out_tlast               <= '0';
        else
          if M_AXIS_tready = '1' then
            if quiet_counter = fs_cycles - '1' then
              quiet_counter         <= (others => '0');
              out_tvalid            <= '1';
              bram_addr             <= bram_addr + '1';
              if nfft_counter = nfft_scaled - '1' then
                nfft_counter        <= (others => '0');
                symbol_counter      <= symbol_counter + '1';
                out_tlast           <= '1';
              else
                nfft_counter        <= nfft_counter + '1';
                out_tlast           <= '0';
              end if;
            else
              quiet_counter         <= quiet_counter + '1';
              out_tvalid            <= '0';
              out_tlast             <= '0';
            end if;
          else
            if tready_falling = '1' then
              bram_addr             <= bram_addr - '1';
              nfft_counter          <= nfft_counter - '1';
            end if;
            out_tvalid              <= '0';
          end if;
        end if;
      end if;
    end if;
  end process P_BRAM_READ;

  BRAM_PORT_addr                  <= bram_addr;
  BRAM_PORT_clk                   <= axis_aclk;
  BRAM_PORT_rst                   <= '0';
  BRAM_PORT_we                    <= (others => '0');
  BRAM_PORT_en                    <= '1';
  BRAM_PORT_din                   <= (others => '0');

  --M_AXIS_tvalid                   <= out_tvalid;
  --M_AXIS_tlast                    <= out_tlast;

  tready_falling                  <= r_axis_tready and not M_AXIS_tready;

  -- Process to send data over AXIS
  P_AXIS_SEND : process(axis_aclk)
  begin
    if axis_aresetn = '0' then
      M_AXIS_tdata                <= (others => '0');
    elsif rising_edge(axis_aclk) then
      r_axis_tready               <= M_AXIS_tready;
      M_AXIS_tdata                <= BRAM_PORT_dout;
      M_AXIS_tvalid               <= out_tvalid;
      M_AXIS_tlast                <= out_tlast;
    end if;
  end process P_AXIS_SEND;

end architecture RTL;
