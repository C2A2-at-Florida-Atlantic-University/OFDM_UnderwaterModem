//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module peak_sample_duc_module_tb();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  localparam                        SAMPLES           = 256;

  int                               i, fd;
  
  logic                             r_clk;

  logic [15:0]                      s_tdata = '0;
  logic [15:0]                      s_tdata1 = '0;
  logic [15:0]                      s_tdata2 = '0;
  logic                             s_tvalid = 1'b0;
  logic                             s_tlast = 1'b0;

  logic [15:0]                      m_axis_tdata;
  logic                             m_axis_tvalid;
  logic                             m_axis_tlast;

  logic                             r_trigger = 1'b0;
  logic [31:0]                      iq_square;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  peak_sample_duc #(
    .g_DATA_WIDTH                   (16)
  ) DUT (
    .aclk                           (r_clk),

    .s_axis_tdata                   (s_tdata),
    .s_axis_tvalid                  (s_tvalid),
    .s_axis_tlast                   (s_tlast),

    .m_axis_tdata                   (m_axis_tdata),
    .m_axis_tvalid                  (m_axis_tvalid),
    .m_axis_tlast                   (m_axis_tlast),

    .i_trigger                      (r_trigger),
    .o_iq_square                    (iq_square)
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
// Inject data
//---------------------------------------------------------------

//---------------------------------------------------------------
// Stimulate design
//---------------------------------------------------------------
  initial begin
    fd = $fopen("C:/O2/SW/sims/ddc_board_test/files/output_data1.txt","r");
    if (fd) $display("File was opened successfully: %0d ",fd);
    else begin
      $display("File was NOT opened successfully: %0d ",fd);
      $stop;
    end

    #(CLOCK_PERIOD*10);
    r_trigger                       = 1'b1;
    #(CLOCK_PERIOD*10);

    for (i = 0; i < SAMPLES; i++) begin
      $fscanf(fd, "%d, %d", s_tdata1, s_tdata2);
      s_tdata                       = s_tdata1;
      s_tvalid                      = 1'b1;
      s_tlast                       = 1'b0;
      #CLOCK_PERIOD;
      s_tvalid                      = 1'b0;
      #CLOCK_PERIOD;
      s_tdata                       = s_tdata2;
      s_tvalid                      = 1'b1;
      s_tlast                       = 1'b1;
      #CLOCK_PERIOD;
      s_tvalid                      = 1'b0;
      s_tlast                       = 1'b0;
      #CLOCK_PERIOD;
    end

    #(CLOCK_PERIOD*10)
    $stop;
  end
endmodule
