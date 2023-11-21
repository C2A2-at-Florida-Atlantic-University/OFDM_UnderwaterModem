//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module adc_raw_sample_save_tb();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  int                               i;
  
  logic                             r_clk;

  logic [15:0]                      s_axis_tdata = '0;
  logic                             s_axis_tvalid = 1'b0;

  logic [31:0]                      m_axis_tdata;
  logic                             m_axis_tvalid;

  logic                             i_trigger = 1'b0;
  logic                             i_max_sync = 1'b0;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  adc_raw_sample_save #(
    .g_ILA                          (1'b0)
  ) DUT (
    .aclk                           (r_clk),

    .s_axis_tdata                   (s_axis_tdata),
    .s_axis_tvalid                  (s_axis_tvalid),

    .m_axis_tdata                   (m_axis_tdata),
    .m_axis_tvalid                  (m_axis_tvalid),

    .i_trigger                      (i_trigger),
    .i_max_sync                     (i_max_sync)
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

//---------------------------------------------------------------
// Stimulate design
//---------------------------------------------------------------
  initial begin
    #(CLOCK_PERIOD*10);
    i_trigger                       = 1'b1;
    #(CLOCK_PERIOD*10);
    i_max_sync                      = 1'b1;
    #CLOCK_PERIOD;
    i_max_sync                      = 1'b0;
    s_axis_tvalid                   = 1'b1;
    for (i = 0; i < 20; i++) begin
      s_axis_tdata                  = s_axis_tdata + 1'b1;
      #CLOCK_PERIOD;
    end
    s_axis_tvalid                   = 1'b0;
    #(CLOCK_PERIOD*10);
    i_trigger                       = 1'b0;

    // Repeat

    #(CLOCK_PERIOD*10);
    i_trigger                       = 1'b1;
    #(CLOCK_PERIOD*10);
    i_max_sync                      = 1'b1;
    #CLOCK_PERIOD;
    i_max_sync                      = 1'b0;
    s_axis_tvalid                   = 1'b1;
    for (i = 0; i < 20; i++) begin
      s_axis_tdata                  = s_axis_tdata + 1'b1;
      #CLOCK_PERIOD;
    end
    s_axis_tvalid                   = 1'b0;
    #(CLOCK_PERIOD*10);
    $stop;
  end
endmodule
