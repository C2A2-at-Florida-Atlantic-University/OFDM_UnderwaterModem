//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module cic_tb();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  int                               fd;
  int                               fd_write;

  logic                             r_clk;

  logic [15:0]                      m_tdata,s_tdata,s_config_tdata;
  logic                             m_tvalid,s_tvalid,s_config_tvalid;
  logic                             s_tready,s_config_tready;
  logic                             s_tlast,m_tlast;
  logic [15:0]                      m_tuser;

  logic [15:0]                      i_ddc_data, q_ddc_data;
  logic [15:0]                      i_ddc_out, q_ddc_out;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  cic_wrapper DUT (
    .M_AXIS_tdata                   (m_tdata),
    .M_AXIS_tvalid                  (m_tvalid),
    .M_AXIS_tlast                   (m_tlast),
    .M_AXIS_tuser                   (m_tuser),
    
    .S_AXIS_CONFIG_tdata            (s_config_tdata),
    .S_AXIS_CONFIG_tready           (s_config_tready),
    .S_AXIS_CONFIG_tvalid           (s_config_tvalid),

    .S_AXIS_tdata                   (s_tdata),
    .S_AXIS_tready                  (s_tready),
    .S_AXIS_tvalid                  (s_tvalid),
    .S_AXIS_tlast                   (s_tlast),

    .aclk                           (r_clk)
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
// Record CIC output
//---------------------------------------------------------------
  initial begin
    fd_write = $fopen("../../../../../../modules/sim/cic_ddc_test_out.txt","w");
    if (fd_write) $display("File was opened successfully: %0d ",fd_write);
    else begin
      $display("File was NOT opened successfully: %0d",fd_write);
      $stop;
    end

    #(CLOCK_PERIOD*53);

    for (int i = 0; i < 30464; i++) begin
      i_ddc_out                     = m_tdata;
      #(CLOCK_PERIOD*40);
      q_ddc_out                     = m_tdata;
      $fdisplay(fd_write, "%d, %d",$signed(i_ddc_out),$signed(q_ddc_out));
      if (i < 10)
        $display("%d, %d",$signed(i_ddc_out),$signed(q_ddc_out));
      #(CLOCK_PERIOD*360);
    end

    $fclose(fd_write);
  end

//---------------------------------------------------------------
// Stimulate design
//---------------------------------------------------------------
  initial begin
    fd = $fopen("../../../../../../modules/sim/cic_ddc_test_in.txt","r");
    if (fd) $display("File was opened successfully: %0d ",fd);
    else begin
      $display("File was NOT opened successfully: %0d",fd);
      $stop;
    end

    s_tdata                         <= '0;
    s_tvalid                        <= 1'b0;
    s_tlast                         <= 1'b0;
    s_config_tdata                  <= '0;
    s_config_tvalid                 <= 1'b0;

    #(CLOCK_PERIOD*10);
    s_config_tdata                  <= 16'd40;
    s_config_tvalid                 <= 1'b1;
    #CLOCK_PERIOD;
    s_config_tvalid                 <= 1'b0;
    #(CLOCK_PERIOD*19);

    // Configured for 1024 nfft, 250 kHz BW, 256 CP, 16 M, 20% zp, 3 ofdm symbols
    //while (!$feof(fd)) begin
    for (int i = 0; i < 1218560; i++) begin
      $fscanf(fd, "%d, %d", i_ddc_data, q_ddc_data);
      s_tdata                       <= 10*i_ddc_data;
      s_tvalid                      <= 1'b1;
      #CLOCK_PERIOD;
      s_tvalid                      <= 1'b0;
      #(CLOCK_PERIOD*4);
      s_tdata                       <= 10*q_ddc_data;
      s_tlast                       <= 1'b1;
      s_tvalid                      <= 1'b1;
      #CLOCK_PERIOD;
      s_tvalid                      <= 1'b0;
      s_tlast                       <= 1'b0;
      #(CLOCK_PERIOD*4);
    end

    #(CLOCK_PERIOD*1000);
    $fclose(fd);
    $stop;
  end
endmodule
