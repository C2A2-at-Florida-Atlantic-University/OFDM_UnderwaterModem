//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module synchronizer_tb();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  int                               fd;
  int                               i;

  logic                             r_clk;

  logic [11:0]                      cp_len = 12'd256;
  logic [11:0]                      nfft = 12'd4096;
  logic [3:0]                       symbols = 4'd10;
  logic [31:0]                      threshold = 32'h0001FFFF;

  logic [31:0]                      m_tdata;
  logic                             m_tvalid,m_tlast,m_tready;

  logic [31:0]                      s_tdata;
  logic                             s_tvalid;

  logic [15:0]                      i_ddc,q_ddc;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  Ofdm_Sync_250k_wrapper DUT(
    .M_AXIS_tdata                   (m_tdata),
    .M_AXIS_tvalid                  (m_tvalid),
    .M_AXIS_tlast                   (m_tlast),
    .M_AXIS_tkeep                   (),
    .M_AXIS_tready                  (m_tready),

    .S_AXIS_tdata                   (s_tdata),
    .S_AXIS_tvalid                  (s_tvalid),

    .aclk                           (r_clk),

    .i_cp_len                       (cp_len),
    .i_nfft                         (nfft),
    .i_symbols                      (symbols),
    .i_threshold                    (threshold)
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
    fd = $fopen("../../../../../../modules/sim/ddc_ch_signal.txt","r");
    if (fd) $display("File was opened successfully: %0d ",fd);
    else begin
      $display("File was NOT opened successfully: %0d",fd);
      $stop;
    end

    m_tready                        = 1'b0;
    s_tdata                         = '0;
    s_tvalid                        = 1'b0;
    #(CLOCK_PERIOD*50);
    for (i = 0; i < 51968; i++) begin
      $fscanf(fd, "%d, %d", i_ddc, q_ddc);
      s_tdata                       = {q_ddc,i_ddc};
      s_tvalid                      = 1'b1;
      #CLOCK_PERIOD;
      s_tvalid                      = 1'b0;
      #(CLOCK_PERIOD*399);
    end

    #(CLOCK_PERIOD*3000)
    $fclose(fd);
    $stop;
  end
endmodule
