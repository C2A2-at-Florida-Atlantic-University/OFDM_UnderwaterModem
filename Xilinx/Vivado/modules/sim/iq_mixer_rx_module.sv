//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module iq_mixer_rx_module();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  logic                             r_clk;
  logic                             r_nRst;

  logic [15:0]                      m_tdata_real,m_tvalid_imag;
  logic                             m_tvalid_real,m_tvalid_imag;
  
  logic [15:0]                      s_tdata;
  logic [31:0]                      s_tdata_dds;
  logic                             s_tvalid,s_tvalid_dds;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  iq_mixer_rx_100M DUT (
    .axis_aclk                      (r_clk),
    .axis_aresetn                   (r_nRst),

    .s_axis_tdata                   (s_tdata),
    .s_axis_tvalid                  (s_tvalid),

    .s_axis_dds_tdata               (s_tdata_dds),
    .s_axis_dds_tvalid              (s_tvalid),
    
    .m_axis_real_tdata              (m_tdata_real),
    .m_axis_real_tvalid             (m_tvalid_real),

    .m_axis_imag_tdata              (m_tdata_imag),
    .m_axis_imag_tvalid             (m_tvalid_imag),

    .i_gain_shift                   (3'd000)
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
    r_nRst                          = 1'b0;
    s_tdata                         = '0;
    s_tdata_dds                     = '0;
    s_tvalid                        = 1'b0;
    s_tvalid_dds                    = 1'b0;

    #(CLOCK_PERIOD*10);

    s_tdata                         = 16'd2;
    s_tdata_dds                     = {16'd99,16'd132};

    #CLOCK_PERIOD;

    for (int i = 0; i < 20; i++) begin
      s_tdata                       = s_tdata + 1'b1;
      s_tvalid                      = 1'b1;
      s_tdata_dds                   = s_tdata_dds - {16'b1,16'b1};
      s_tvalid_dds                  = 1'b1;
      #CLOCK_PERIOD;
      s_tdata                       = '0;
      s_tvalid                      = 1'b0;
      s_tdata_dds                   = '0;
      s_tvalid_dds                  = 1'b0;
      #(CLOCK_PERIOD*9);
    end

    $stop;
  end
endmodule
