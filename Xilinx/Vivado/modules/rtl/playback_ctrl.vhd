-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Select between AXIS_0 and AXIS_1 based on 
--  the value of i_select
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
    
    BRAM_PORT_addr                : out std_logic_vector(31 downto 0);
    BRAM_PORT_clk                 : out std_logic;
    BRAM_PORT_din                 : out std_logic_vector(31 downto 0);
    BRAM_PORT_dout                : in  std_logic_vector(31 downto 0);
    BRAM_PORT_en                  : out std_logic;
    BRAM_PORT_rst                 : out std_logic;
    BRAM_PORT_we                  : out std_logic;

    M_AXIS_tdata                  : out std_logic_vector(31 downto 0);
    M_AXIS_tvalid                 : out std_logic;
    M_AXIS_tlast                  : out std_logic
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

  signal quiet_counter            : std_logic_vector(integer(ceil(log2(real(g_CLOCK_CYCLES-1)))) downto 0);
  signal total_counter            : std_logic_vector(integer(ceil(log2(real(g_SYMBOL_LENGTH-1)))) downto 0);
  signal symbol_counter           : std_logic_vector(integer(ceil(log2(real(g_NUM_SYMBOLS-1)))) downto 0);

  signal bram_addr                : std_logic_vector(31 downto 0);
  signal read_en                  : std_logic;
  signal r_read_en                : std_logic;

begin

  -- Process to read from BRAM
  P_BRAM_READ : process(axis_aclk, axis_aresetn)
  begin
    if axis_aresetn = '0' then
      NULL;
    elsif rising_edge(axis_aclk) then
      if playback_en = '0' then
        quiet_counter             <= (others => '0');
        total_counter             <= (others => '0');
        symbol_counter            <= (others => '0');
        bram_addr                 <= (others => '0');
        read_en                   <= '0';
      else
        if quiet_counter = g_CLOCK_CYCLES-1 then
          if total_counter = g_SYMBOL_LENGTH-1 then
            if symbol_counter = g_NUM_SYMBOLS-1 then
              bram_addr           <= (others => '0');
              symbol_counter      <= (others => '0');
            else
              symbol_counter      <= symbol_counter + '1';
            end if;
            total_counter         <= (others => '0');
          else
            total_counter         <= total_counter + '1';
          end if;
          bram_addr               <= bram_addr + '1';
          quiet_counter           <= (others => '0');
          read_en                 <= '1';
        else
          quiet_counter           <= quiet_counter + '1';
          read_en                 <= '0';
        end if;
      end if;
    end if;
  end process P_BRAM_READ;

  BRAM_PORT_addr                  <= bram_addr;
  BRAM_PORT_clk                   <= axis_aclk;
  BRAM_PORT_rst                   <= '0';
  BRAM_PORT_we                    <= '0';
  BRAM_PORT_en                    <= '1';
  BRAM_PORT_din                   <= (others => '0');

  -- Process to send data over AXIS
  P_AXIS_SEND : process(axis_aclk)
  begin
    if rising_edge(axis_aclk) then
      r_read_en                   <= read_en;
      if r_read_en = '1' then
        M_AXIS_tdata              <= BRAM_PORT_dout;
        M_AXIS_tvalid             <= '1';
      else
        M_AXIS_tdata              <= (others => '0');
        M_AXIS_tvalid             <= '0';
        M_AXIS_tlast              <= '0';
      end if;
    end if;
  end process P_AXIS_SEND;

end architecture RTL;
