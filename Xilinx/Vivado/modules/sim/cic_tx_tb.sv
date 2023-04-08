//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module cic_tx_tb();

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

  logic [15:0]                      i_duc_data, q_duc_data;
  logic [15:0]                      i_duc_out, q_duc_out;

  logic [31:0]                      tmp;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  cic_tx_wrapper DUT (
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
    fd_write = $fopen("../../../../../../modules/sim/cic_duc_test_out.txt","w");
    if (fd_write) $display("File was opened successfully: %0d ",fd_write);
    else begin
      $display("File was NOT opened successfully: %0d",fd_write);
      $stop;
    end

    #(CLOCK_PERIOD*255);

    for (int i = 0; i < 1218560; i++) begin
      i_duc_out                     = m_tdata;
      #(CLOCK_PERIOD*5);
      q_duc_out                     = m_tdata;
      $fdisplay(fd_write, "%d, %d",$signed(i_duc_out),$signed(q_duc_out));
      if (i < 10)
        $display("%d, %d",$signed(i_duc_out),$signed(q_duc_out));
      #(CLOCK_PERIOD*5);
    end

    $fclose(fd_write);
  end

//---------------------------------------------------------------
// Stimulate design
//---------------------------------------------------------------
  initial begin
    fd = $fopen("../../../../../../../SW_Source/ofdm/files/TxIfftSamplesInt1.txt","r");
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

    // Ignore header information
    $fscanf(fd, "%d,", tmp);
    $fscanf(fd, "%d,", tmp);
    $fscanf(fd, "%d,", tmp);

    #(CLOCK_PERIOD*10);
    s_config_tdata                  <= 16'd40;
    s_config_tvalid                 <= 1'b1;
    #CLOCK_PERIOD;
    s_config_tvalid                 <= 1'b0;
    #(CLOCK_PERIOD*19)
    #(CLOCK_PERIOD*10);

    for (int i = 0; i < 30464; i++) begin
      $fscanf(fd, "%d, %d", i_duc_data, q_duc_data);
      s_tdata                       <= i_duc_data;
      s_tvalid                      <= 1'b1;
      #CLOCK_PERIOD;
      s_tvalid                      <= 1'b0;
      #(CLOCK_PERIOD*199);
      s_tdata                       <= q_duc_data;
      s_tvalid                      <= 1'b1;
      #CLOCK_PERIOD;
      s_tvalid                      <= 1'b0;
      #(CLOCK_PERIOD*199);
    end

    #(CLOCK_PERIOD*1000);
    $fclose(fd);
    $stop;
  end
endmodule
