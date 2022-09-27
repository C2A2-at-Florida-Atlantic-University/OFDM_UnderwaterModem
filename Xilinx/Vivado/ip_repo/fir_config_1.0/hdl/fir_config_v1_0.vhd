library ieee;
use ieee.std_logic_1164.all;

entity fir_config_v1_0 is
  generic(
    C_M00_AXIS_TDATA_WIDTH              : integer := 8
  );
  port(
    coeff_sel                           : in  std_logic_vector(3 downto 0);

    m00_axis_aclk                       : in  std_logic;
    m00_axis_aresetn                    : in  std_logic;
    
    m00_axis_tvalid                     : out std_logic;
    m00_axis_tdata                      : out std_logic_vector(C_M00_AXIS_TDATA_WIDTH - 1 downto 0);
    m00_axis_tready                     : in  std_logic
  );
end entity fir_config_v1_0;

architecture RTL of fir_config_v1_0 is

  signal Clk                            : std_logic;
  signal nRst                           : std_logic;
  signal r_coeff_sel                    : std_logic_vector(3 downto 0);
  signal tvalid                         : std_logic; 
  signal tdata                          : std_logic_vector(7 downto 0);

begin

  process (Clk, nRst) 
  begin
    if nRst = '0' then
      r_coeff_sel                       <= (others => '0');
      tdata                             <= (others => '0');
    elsif rising_edge(Clk) then
      if (not(r_coeff_sel = coeff_sel) and (m00_axis_tready = '1')) then
        tdata                           <= X"0" & coeff_sel;
        r_coeff_sel                     <= coeff_sel;
        tvalid                          <= '1';
      else
        tvalid                          <= '0';
        tdata                           <= (others => '0');
      end if;
    end if;
  end process;

  Clk                                   <= m00_axis_aclk;
  nRst                                  <= m00_axis_aresetn;
  m00_axis_tdata                        <= tdata;
  m00_axis_tvalid                       <= tvalid;

end architecture RTL;
