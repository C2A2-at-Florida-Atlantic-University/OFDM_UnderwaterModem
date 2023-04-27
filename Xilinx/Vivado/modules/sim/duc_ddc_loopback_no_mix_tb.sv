//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module duc_ddc_loopback_no_mix_tb();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  int                               tmp;
  int                               i,j,k,m;

  int                               fd;
  int                               fd_write;
  int                               fd_duc;
  int                               fd_cic;

  int ofdm_symbols = 1;
  int nfft = 4096;
  int cp_len = 256;

  logic                             r_clk;

  logic [15:0]                      Interp_ratio,decimate_ratio,tmp_duc,tmp_duc_q;

  logic [31:0]                      m_tdata;
  logic                             m_tvalid;
  logic                             m_tready;

  logic [31:0]                      s_tdata;
  logic                             s_tvalid,s_tready,s_tlast;
  logic [3:0]                       s_tkeep;

  logic [15:0]                      i_ddc_out,q_ddc_out;
  logic [15:0]                      iq_mix_out_i,iq_mix_out_q;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  DUC_DDC_Loopback_Sim_wrapper DUT (
    .Interp_ratio   (Interp_ratio),
    
    .M_AXIS_tdata   (m_tdata),
    .M_AXIS_tready  (m_tready),
    .M_AXIS_tvalid  (m_tvalid),

    .S_AXIS_tdata   (s_tdata),
    .S_AXIS_tkeep   (s_tkeep),
    .S_AXIS_tlast   (s_tlast),
    .S_AXIS_tready  (s_tready),
    .S_AXIS_tvalid  (s_tvalid),

    .aclk           (r_clk),

    .decimate_ratio (decimate_ratio)
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
// Record DDC output
//---------------------------------------------------------------
  initial begin
    fd_write = $fopen("../../../../../../modules/sim/duc_ddc_no_mix_loop.txt","w");
    if (fd_write) $display("File was opened successfully: %0d ",fd_write);
    else begin
      $display("File was NOT opened successfully: %0d",fd_write);
      $stop;
    end

    m_tready = 1'b0;
    #(CLOCK_PERIOD*900);
    m_tready = 1'b1;
    for (j = 0; j < (ofdm_symbols+1)*(nfft+cp_len); j++) begin
      while(!m_tvalid)
        #CLOCK_PERIOD;
      $fdisplay(fd_write, "%d, %d", $signed(m_tdata[15:0]),
        $signed(m_tdata[31:16]));
      #CLOCK_PERIOD;
    end

    $fclose(fd_write);
  end

//---------------------------------------------------------------
// Stimulate design
//---------------------------------------------------------------
  initial begin
    fd = $fopen("../../../../../../../SW_Source/ofdm/files/TxIfftSamples1.txt","r");
    if (fd) $display("File was opened successfully: %0d ",fd);
    else begin
      $display("File was NOT opened successfully: %0d",fd);
      $stop;
    end

    //Fc_scaled = 250000*(2<<32/100000000);
    Interp_ratio = 16'd40;
    decimate_ratio = 16'd40;


    s_tdata = '0;
    s_tkeep = '0;
    s_tlast = 1'b0;
    s_tvalid = 1'b0;
    // Throw away header
    $fscanf(fd, "%d,\n", tmp);
    $fscanf(fd, "%d,\n", tmp);
    $fscanf(fd, "%d,\n", tmp);

    #(CLOCK_PERIOD*50);
    #(CLOCK_PERIOD*50);
    s_tkeep = 4'b1111;

    for (i = 0; i < (ofdm_symbols+1)*(nfft+cp_len); i++) begin
      $fscanf(fd, "%d, %d", s_tdata[15:0], s_tdata[31:16]);
      s_tvalid = 1'b1;
      if (i == (ofdm_symbols+1)*(nfft+cp_len)-1)
        s_tlast = 1'b1;
      while (!s_tready)
        #CLOCK_PERIOD;
      #CLOCK_PERIOD;
    end
    s_tvalid = 1'b0;
    s_tlast = 1'b0;

    #(CLOCK_PERIOD*50);
    $fclose(fd);
     $stop;
  end
endmodule
