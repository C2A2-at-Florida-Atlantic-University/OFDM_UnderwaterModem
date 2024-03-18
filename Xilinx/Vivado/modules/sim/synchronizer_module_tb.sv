//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module synchronizer_module_tb();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  int                               i;
  
  logic                             r_clk;

  logic [11:0]                      cp_len = 12'd7; 
  //logic [10:0]                      trigg_offset = 11'b11111111110;
  logic [10:0]                      trigg_offset = 11'b00000000000;
  logic [13:0]                      nfft = 14'd31; // 
  logic [3:0]                       symbols = 4'd3; // 
  logic [31:0]                      guard = 32'd10; // 
  logic                             max = 1'b0;

  logic [31:0]                      s_tdata = '0;
  logic                             s_tvalid = 1'b0;

  logic [31:0]                      m_axis_tdata;
  logic                             m_axis_tvalid;
  logic                             m_axis_tlast;
  logic                             m_axis_tready = 1'b0;
  logic [3:0]                       m_axis_tkeep;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  synchronizer #(
    .g_ILA                          (1'b1)
  ) DUT (
    .axis_aclk                      (r_clk),

    .s_axis_tdata                   (s_tdata),
    .s_axis_tvalid                  (s_tvalid),
    
    .s_axis_abs_ila_tdata           ('0),
    .s_axis_abs_ila_tvalid          (1'b0),

    .m_axis_tdata                   (m_axis_tdata),
    .m_axis_tvalid                  (m_axis_tvalid),
    .m_axis_tlast                   (m_axis_tlast),
    .m_axis_tready                  (m_axis_tready),
    .m_axis_tkeep                   (m_axis_tkeep),

    .i_nfft                         (nfft),
    .i_cp_len                       (cp_len),
    .i_symbols                      (symbols),
    .i_trig_offset                  (trigg_offset),
    .i_max_sync                     (max),
    .i_guard_cycles                 (guard)
  );

//---------------------------------------------------------------
// Drive 100M Clock
//---------------------------------------------------------------
  initial begin
    r_clk                           = 1'b1;
    forever begin
      #CLOCK_CYCLE r_clk            = ~r_clk;
    end
  end

  initial begin
    forever begin
      #(CLOCK_PERIOD*5)
      s_tdata                       = s_tdata + 1'b1;
      s_tvalid                      = 1'b1;
      #CLOCK_PERIOD
      s_tvalid                      = 1'b0;
    end
  end

//---------------------------------------------------------------
// Stimulate design
//---------------------------------------------------------------
  initial begin
    #(CLOCK_PERIOD*90)
    m_axis_tready                   = 1'b1;
    #(CLOCK_PERIOD*100)
    max                             = 1'b1;
    #CLOCK_PERIOD;
    max                             = 1'b0;
    #CLOCK_PERIOD;
    #(CLOCK_PERIOD*7*(symbols+1)*(nfft+cp_len));
    #(CLOCK_PERIOD*100);
    $stop;
  end
endmodule
