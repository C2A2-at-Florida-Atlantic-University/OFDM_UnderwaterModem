library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity bit_decision_control_v1_0 is
	generic (
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 32;
		BRAM_addr_width         : integer   := 14;
		Passthrough_num         : integer   := 2
	);
	port (
		passthrough           : in  std_logic_vector(Passthrough_num-1 downto 0);
		overide               : in  std_logic;
    -- If a symbol is 1ms and it is arriving along a 100MHz bus then every symbol is 
    -- 100000 clock cycles.
    symbol_length         : in  std_logic_vector(31 downto 0);
		current_address       : out std_logic_vector(31 downto 0);
		accumulator_nreset    : out std_logic;
		
		BRAM_addr             : out std_logic_vector(BRAM_addr_width-1 downto 0);
		BRAM_wrdata           : out std_logic_vector(31 downto 0);
		BRAM_rddata           : in  std_logic_vector(31 downto 0);
		BRAM_en               : out std_logic;
		BRAM_we               : out std_logic_vector(3 downto 0);
		
		BRAM_clk              : out std_logic;
		BRAM_rst              : out std_logic;

		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tvalid	: in std_logic
	);
end bit_decision_control_v1_0;

architecture arch_imp of bit_decision_control_v1_0 is

    signal Clk                  : std_logic;
    signal Rst                  : std_logic;
    signal counter_rst          : std_logic;
    signal f0_counter           : std_logic_vector(23 downto 0);
    signal f1_counter           : std_logic_vector(23 downto 0);
    signal symbol_counter       : std_logic_vector(31 downto 0);
    signal symbol_select        : std_logic_vector(1 downto 0);
    
    signal w_BRAM_addr          : std_logic_vector(BRAM_addr_width-1 downto 0) := (others => '0');
    signal ones                 : std_logic_vector(BRAM_addr_width-1 downto 0) := (others => '1');
    signal zeros                : std_logic_vector(31-BRAM_addr_width downto 0) := (others => '0');
    signal reset_hold_counter   : std_logic_vector(3 downto 0);
    
    signal r_accumulator_count  : std_logic_vector(3 downto 0);
    --signal r_tvalid             : std_logic;
    --signal r_tvalid_counter     : std_logic_vector(3 downto 0);

begin

    -- AXI slave is connected to a comparator block which outputs a 1 for detecting frequency f1 
    -- is higher and outputs a 0 for detecting frequency f0 is higher. The process counts the number 
    -- of times each frequency is higher durring a symbol.
    p_passthrough : process(Clk, Rst)
    begin
        if Rst = '0' then
        
        elsif rising_edge(Clk) then
            if passthrough > "00" or overide /= '0' then
                if counter_rst = '0' then
                    if s00_axis_tvalid = '1' then
                    --if r_tvalid = '1' then
                        if s00_axis_tdata = X"01" then
                            f1_counter      <= f1_counter + '1';
                        elsif s00_axis_tdata = X"00" then
                            f0_counter      <= f0_counter + '1';
                        end if;
                    end if;
                else
                    f1_counter              <= (others => '0');
                    f0_counter              <= (others => '0');
                end if;
            else
                f1_counter              <= (others => '0');
                f0_counter              <= (others => '0');
            end if;
        end if;
     end process p_passthrough;
     
     -- Process to generate tvalid every 16 clock cycles 
     --p_tvalid : process(Clk, Rst)
     --begin
     --   if Rst = '0' then
     --       r_tvalid                        <= '0';
     --       r_tvalid_counter                <= (others => '0');
     --   elsif rising_edge(Clk) then
     --       if r_tvalid_counter = "1111" then
     --           r_tvalid_counter            <= (others => '0');
     --           r_tvalid                    <= '1';
     --       else
     --           r_tvalid_counter            <= r_tvalid_counter + '1';
     --           r_tvalid                    <= '0';
     --       end if;
     --   end if;
     --end process p_tvalid;
     
     -- Process generates counter_rst for 1 clock cycle every symbol length.
     p_symbol : process(Clk, Rst)
     begin
        if Rst = '0' then
            
        elsif rising_edge(Clk) then
            --if passthrough > "00" then
            if passthrough > "00" or overide /= '0' then
                if symbol_counter = symbol_length then
                    symbol_counter          <= (others => '0');
                    counter_rst             <= '1';
                else
                    symbol_counter          <= symbol_counter + '1';
                    counter_rst             <= '0';
                end if;
            else
                symbol_counter              <= (others => '0');
                counter_rst                 <= '0';
            end if;
        end if;
    end process p_symbol;
    
    -- Process drives symbol_select based on whichever frequency was detected more
    p_count : process(Clk, Rst)
    begin
        if Rst = '0' then
        
        elsif rising_edge(Clk) then
            if f1_counter > f0_counter then
                symbol_select               <= "10";
            elsif f1_counter < f0_counter then
                symbol_select               <= "01";
            elsif f1_counter = f0_counter then
                symbol_select               <= "00";
            else
                symbol_select               <= "11";
            end if;
        end if;
    end process p_count;
    
    -- Process Drives BRAM bus with selected frequency.
    p_BRAM : process(Clk, Rst)
    begin   
        if Rst = '0' then
            --w_BRAM_addr                     <= (others => '0');
        elsif rising_edge(Clk) then
            if counter_rst = '1' then
                if w_BRAM_addr >= "01111111111000" then
                    w_BRAM_addr             <= (others => '0');
                else
                    w_BRAM_addr             <= w_BRAM_addr + "100";
                end if;
                BRAM_en                     <= '1';
                BRAM_we                     <= "1111";
                BRAM_wrdata                 <= X"0000000" & "00" & symbol_select;
            else
                BRAM_en                     <= '0';
                BRAM_we                     <= (others => '0');
                BRAM_wrdata                 <= (others => '0');
            end if;
        end if;
    end process p_BRAM;

    -- Process generates reset for accululator blocks after every symbol length
    p_nRst : process(Clk, Rst)
    begin
        if Rst = '0' then
            accumulator_nreset              <= '0';
            reset_hold_counter              <= (others => '0');
            r_accumulator_count             <= (others => '0');
        elsif rising_edge(Clk) then
            if counter_rst = '1' or reset_hold_counter /= "0000" or r_accumulator_count = "1111" then
                accumulator_nreset          <= '0';
                r_accumulator_count         <= (others => '0');
                if reset_hold_counter = "1111" then
                    reset_hold_counter      <= (others => '0');
                else
                    reset_hold_counter      <= reset_hold_counter + '1';
                end if;
            else
                reset_hold_counter          <= (others => '0');
                accumulator_nreset          <= '1';
                if s00_axis_tvalid = '1' then
                    r_accumulator_count         <= r_accumulator_count + '1';
                end if;
            end if;
        end if;
    end process p_nRst;

    BRAM_clk                    <= s00_axis_aclk;
    BRAM_rst                    <= s00_axis_aresetn;
    BRAM_addr                   <= w_BRAM_addr;
    s00_axis_tready             <= '1';
    Clk                         <= s00_axis_aclk;
    Rst                         <= s00_axis_aresetn;
    current_address             <= zeros & w_BRAM_addr;
    
end arch_imp;
