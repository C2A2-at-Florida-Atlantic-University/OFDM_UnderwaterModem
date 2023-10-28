-----------------------------------------------------------------
-- Jared Hermans
--
-- Description: Wrapper to Xilinx FIR compiler IP. There are 
--              some limitations when the IP is instantiated 
--              directly in the bd.
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity duc_fir_compiler_wrapper is
  port(
    aclk                          : in  std_logic;

    s_axis_tdata                  : in  std_logic_vector(15 downto 0);
    s_axis_tvalid                 : in  std_logic;
    s_axis_tready                 : out std_logic;
    s_axis_tlast                  : in  std_logic;

    m_axis_tdata                  : out std_logic_vector(15 downto 0);
    m_axis_tvalid                 : out std_logic;
    m_axis_tlast                  : out std_logic
  );
end entity duc_fir_compiler_wrapper;
 
architecture RTL of duc_fir_compiler_wrapper is 

  attribute X_INTERFACE_INFO      : string;
  attribute X_INTERFACE_PARAMETER : string;
  
  attribute X_INTERFACE_INFO      of aclk    : signal is "xilinx.com:signal:clock:1.0 aclk CLK";
  attribute X_INTERFACE_PARAMETER of aclk    : 
    signal is "ASSOCIATED_BUSIF aclk:s_axis:m_axis, FREQ_HZ 100000000";
  
  component duc_fir_compiler
    port(
      aclk                        : in  std_logic;
      s_axis_data_tvalid          : in  std_logic;
      s_axis_data_tready          : out std_logic;
      s_axis_data_tdata           : in  std_logic_vector(15 downto 0);
      s_axis_data_tlast           : in  std_logic;
      m_axis_data_tvalid          : out std_logic;
      m_axis_data_tdata           : out std_logic_vector(15 downto 0);
      m_axis_data_tlast           : out std_logic
    );
  end component duc_fir_compiler;

begin

  duc_fir_compiler_inst : duc_fir_compiler
    port map(
      aclk                        => aclk,

      s_axis_data_tvalid          => s_axis_tvalid,
      s_axis_data_tready          => s_axis_tready,
      s_axis_data_tdata           => s_axis_tdata,
      s_axis_data_tlast           => s_axis_tlast,

      m_axis_data_tvalid          => m_axis_tvalid,
      m_axis_data_tdata           => m_axis_tdata,
      m_axis_data_tlast           => m_axis_tlast
    );

end architecture RTL;
