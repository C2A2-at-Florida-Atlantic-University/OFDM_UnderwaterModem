library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity AXIS_threshold_v1_0 is
	generic (
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 32
	);
	port (
    threshold       : in  std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
    timeout         : in  std_logic_vector(3 downto 0);
    override        : in  std_logic;
    passthrough     : out std_logic;
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tvalid	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0)
	);
end AXIS_threshold_v1_0; 

architecture arch_imp of AXIS_threshold_v1_0 is

    signal Clk              : std_logic;
    signal nRst             : std_logic;
    signal passthrough_reg  : std_logic;
    signal timeout_counter  : std_logic_vector(4 downto 0);
    signal neg_threshold    : std_logic_vector(31 downto 0);

    signal tvalid_counter   : std_logic_vector(6 downto 0);

begin

    -- Process to assert passthrough_reg when input AXI stream data is greater than
    -- threshold at least once per timeout data valids.
    p_Passthrough : process (Clk, nRst)
    begin   
        if nRst = '0' then
            passthrough_reg             <= '0';
            timeout_counter             <= (others => '0');
        elsif rising_edge(Clk) then
            if (s00_axis_tdata >= threshold and s00_axis_tdata <= neg_threshold) then
                timeout_counter         <= (others => '0');
                passthrough_reg         <= '1';
            else
                if s00_axis_tvalid = '1' then
                    if timeout_counter < timeout then
                        timeout_counter <= timeout_counter + '1';
                    else
                        passthrough_reg <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process p_Passthrough;
               
    -- Process to disable master AXI stream if passthrough_reg is not active.
    -- Instead of disabling completely, just send zeros and toggle data valid
    -- to mimic 0V at 1Msps. This should probably be configurable and set by
    -- a port in the future.
    p_AXIS : process(Clk, nRst)
    begin   
        if nRst = '0' then
            tvalid_counter              <= (others => '0');
        elsif rising_edge(Clk) then 
            if passthrough_reg = '1' or override = '1' then
                m00_axis_tvalid         <= s00_axis_tvalid;
                m00_axis_tdata          <= s00_axis_tdata;
            else
                if tvalid_counter = "1100011" then -- toggle tvalid every 100 clock cycles
                    tvalid_counter      <= (others => '0');
                    m00_axis_tvalid     <= '1';
                else
                    tvalid_counter      <= tvalid_counter + '1';
                    m00_axis_tvalid     <= '0';
                end if;
                m00_axis_tdata          <= (others => '0');
            end if;
        end if;
    end process p_AXIS;

    Clk                     <= s00_axis_aclk;
    nRst                    <= s00_axis_aresetn;
    passthrough             <= passthrough_reg or override;
    neg_threshold           <= X"FFFFFFFF" - threshold;

end arch_imp;
