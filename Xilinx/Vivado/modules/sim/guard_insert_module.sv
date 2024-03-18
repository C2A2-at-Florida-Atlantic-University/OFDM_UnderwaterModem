//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module guard_insert_module();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  localparam                        OFDM_SYMBOLS = 3;

  logic                             r_clk;
  logic                             r_nRst;

  int                               i, j;

  logic [31:0]                      s_tdata,  m_tdata;
  logic                             s_tvalid, m_tvalid;
  logic                             s_tlast,  m_tlast;
  logic                             s_tready, m_tready;

  logic [31:0]                      guard_cycles = 32'd10; // 10
  logic [13:0]                      nfft = 14'd31; // 32
  logic [11:0]                      cp_len = 12'd7; // 8
  //logic [11:0]                      cp_len = '0;

  int                               countval;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  guard_insert #(
    .g_ILA                          (0)
  ) DUT (
    .aclk                           (r_clk),
    .aresetn                        (r_nRst),

    .s_axis_tdata                   (s_tdata),
    .s_axis_tvalid                  (s_tvalid),
    .s_axis_tlast                   (s_tlast),
    .s_axis_tready                  (s_tready),

    .m_axis_tdata                   (m_tdata),
    .m_axis_tvalid                  (m_tvalid),
    .m_axis_tlast                   (m_tlast),
    .m_axis_tready                  (m_tready),

    .i_guard_cycles                 (guard_cycles),
    .i_nfft                         (nfft),
    .i_cp_len                       (cp_len)
  );

//---------------------------------------------------------------
// Drive Clock
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
    s_tvalid                        = 1'b0;
    s_tlast                         = 1'b0;
    m_tready                        = 1'b0;

    #(CLOCK_PERIOD*4);

    r_nRst                          = 1'b1;

    #(CLOCK_PERIOD*4);

    m_tready                        = 1'b1;
    if (cp_len == '0)
      countval                      = nfft+1;
    else
      countval                      = nfft+cp_len+2;

    for (i = 0; i < OFDM_SYMBOLS; i ++) begin
      if (i == 0) begin
        for (j = 0; j < 4096; j++) begin
          while (~s_tready)
            #CLOCK_PERIOD;
          s_tdata                   = j + 1;
          s_tvalid                  = 1'b1;
          s_tlast                   = 1'b0;
          #CLOCK_PERIOD;
        end
        if (cp_len != '0) begin
          for (j = 0; j < cp_len+1; j++) begin
            while (~s_tready)
              #CLOCK_PERIOD;
            s_tdata                 = j + 1;
            s_tvalid                = 1'b1;
            s_tlast                 = 1'b0;
            #CLOCK_PERIOD;
          end
        end
      end
      else begin
        for (j = 0; j < countval; j++) begin
          while (~s_tready)
            #CLOCK_PERIOD;
          s_tdata                   = j + 1;
          s_tvalid                  = 1'b1;
          if (j == countval-1 && i == OFDM_SYMBOLS-1)
            s_tlast                 = 1'b1;
          else
            s_tlast                 = 1'b0;
          #CLOCK_PERIOD;
        end
      end
    end
    s_tdata                         = 1'b0;
    s_tvalid                        = 1'b0;
    s_tlast                         = 1'b0;
  
    #(CLOCK_PERIOD*100);

    $stop;
  end
endmodule
