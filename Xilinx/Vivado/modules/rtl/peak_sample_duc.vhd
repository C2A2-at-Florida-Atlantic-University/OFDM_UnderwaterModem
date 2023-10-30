-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Takes peak_sampleugate of input AXIS
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
Library UNISIM;
use UNISIM.vcomponents.all;
Library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity peak_sample_duc is
  generic(
    g_DATA_WIDTH                  : integer := 16
  );
  port(
    aclk                          : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(g_DATA_WIDTH-1 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tlast                  : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(g_DATA_WIDTH-1 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic;

    i_trigger                     : in  std_logic;
    o_iq_square                   : out std_logic_vector(g_DATA_WIDTH*2-1 downto 0)
  );
end entity peak_sample_duc;
 
architecture RTL of peak_sample_duc is 

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of aclk    : signal is "xilinx.com:signal:clock:1.0 aclk CLK";
  attribute X_INTERFACE_PARAMETER of aclk    : 
    signal is "ASSOCIATED_BUSIF aclk:s_axis:m_axis, FREQ_HZ 100000000";

  signal r_trigger                : std_logic;
  signal r_sample                 : std_logic_vector(g_DATA_WIDTH-1 downto 0) := (others => '0');
  signal r_valid_mult             : std_logic;
  signal r_valid                  : std_logic;
  signal r_valid2                 : std_logic;
  signal r_valid_1d               : std_logic;
  signal r_valid2_1d              : std_logic;
  signal iq_mult                  : std_logic_vector(31 downto 0);
  signal iq_mult_sum              : std_logic_vector(31 downto 0);
  signal r_iq_mult                : std_logic_vector(31 downto 0) := (others => '0');

begin

  process (aclk)
  begin
    if rising_edge(aclk) then
      r_trigger                   <= i_trigger;
    end if;
  end process;

  process (aclk)
  begin
    if rising_edge(aclk) then
      r_valid                     <= '0';
      r_valid2                    <= '0';
      if i_trigger = '1' and r_trigger = '0' then
        r_sample                  <= (others => '0');
      else
        if s_axis_tvalid = '1' then
          if s_axis_tlast = '0' then -- sample i
            r_sample              <= s_axis_tdata;
            r_valid               <= '1';
          else -- sample q
            r_sample              <= s_axis_tdata;
            r_valid2              <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;

  r_valid_mult                    <= r_valid or r_valid2;

  MULT_MACRO_inst : MULT_MACRO
    generic map (
      DEVICE => "7SERIES",    -- Target Device: "VIRTEX5", "7SERIES", "SPARTAN6"
      LATENCY => 1,           -- Desired clock cycle latency, 0-4
      WIDTH_A => 16,          -- Multiplier A-input bus width, 1-25
      WIDTH_B => 16)          -- Multiplier B-input bus width, 1-18
    port map (
      P => iq_mult,           -- Multiplier ouput bus, width determined by WIDTH_P generic
      A => r_sample,          -- Multiplier input A bus, width determined by WIDTH_A generic
      B => r_sample,          -- Multiplier input B bus, width determined by WIDTH_B generic
      CE => r_valid_mult,     -- 1-bit active high input clock enable
      CLK => aclk,            -- 1-bit positive edge clock input
      RST => '0'              -- 1-bit input active high reset
    );

  process(aclk)
  begin
    if rising_edge(aclk) then
      r_valid2_1d                 <= r_valid2;
      r_valid_1d                  <= r_valid;
      if r_valid_1d = '1' then
        iq_mult_sum               <= iq_mult;
      elsif r_valid2_1d = '1' then
        iq_mult_sum               <= iq_mult_sum + iq_mult;
      end if;
    end if;
  end process;

  process(aclk)
  begin
    if rising_edge(aclk) then
      if i_trigger = '1' and r_trigger = '0' then
        r_iq_mult                 <= (others => '0');
      else
        if abs(signed(iq_mult_sum)) > abs(signed(r_iq_mult)) then
          r_iq_mult               <= iq_mult_sum;
        end if;
      end if;
    end if;
  end process;

  m_axis_tdata                    <= s_axis_tdata;
  m_axis_tvalid                   <= s_axis_tvalid;
  m_axis_tlast                    <= s_axis_tlast;

  o_iq_square                     <= r_iq_mult;

end architecture RTL;
