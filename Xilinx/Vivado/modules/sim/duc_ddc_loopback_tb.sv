//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module duc_ddc_loopback_tb();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  localparam                        CLOCK_PERIOD_ADC  = 100; // 10 MHz
  //localparam                        CLOCK_PERIOD_ADC  = 24; // 40 MHz
  localparam                        CLOCK_CYCLE_ADC   = CLOCK_PERIOD_ADC/2;

  logic                             select_10M = 1'b1;

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
  logic                             r_nRst;
  logic                             adc_aclk;
  logic                             adc_aresetn;

  logic [31:0]                      Fc_scaled;
  logic [15:0]                      Interp_ratio,decimate_ratio,tmp_duc,tmp_duc_q;

  logic [31:0]                      m_tdata;
  logic                             m_tvalid;
  logic                             m_tready;

  logic [31:0]                      s_tdata;
  logic                             s_tvalid,s_tready,s_tlast;
  logic [3:0]                       s_tkeep;

  logic [15:0]                      i_ddc_out,q_ddc_out;
  logic [15:0]                      iq_mix_out_i,iq_mix_out_q;

  logic [2:0]                       i_gain_shift_reg;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  DUC_DDC_Loopback_Sim_wrapper DUT (
    .Fc_scaled      (Fc_scaled),
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
    .aclk_10M       (adc_aclk),
    .aresetn        (r_nRst),
    .aresetn_10M    (adc_aresetn),

    .decimate_ratio (decimate_ratio),
    .i_shift_reg(i_gain_shift_reg),
    .i_select_40M_10M(select_10M)
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
// Drive ADC Clock
//---------------------------------------------------------------
  initial begin
    adc_aclk                        = 1'b1;
    forever begin
      #CLOCK_CYCLE_ADC adc_aclk     = ~adc_aclk;
    end
  end

//---------------------------------------------------------------
// Record CIC output
//---------------------------------------------------------------
  initial begin
    fd_cic = $fopen("../../../../../../modules/sim/cic_loop.txt","w");
    if (fd_cic) $display("File was opened successfully: %0d ",fd_cic);
    else begin
      $display("File was NOT opened successfully: %0d",fd_cic);
      $stop;
    end

    #(CLOCK_PERIOD*800);

    for (m = 0; m < (ofdm_symbols+1)*(nfft+cp_len)*40; m++) begin
      while(!DUT.DUC_DDC_Loopback_Sim_i.DAC_Chain_0.cic_compiler.m_axis_data_tvalid ||
        DUT.DUC_DDC_Loopback_Sim_i.DAC_Chain_0.cic_compiler.m_axis_data_tlast) begin
        #CLOCK_PERIOD;
      end
      tmp_duc = DUT.DUC_DDC_Loopback_Sim_i.DAC_Chain_0.cic_compiler.m_axis_data_tdata;
      while(!DUT.DUC_DDC_Loopback_Sim_i.DAC_Chain_0.cic_compiler.m_axis_data_tvalid ||
        !DUT.DUC_DDC_Loopback_Sim_i.DAC_Chain_0.cic_compiler.m_axis_data_tlast) begin
        #CLOCK_PERIOD;
      end
      tmp_duc_q = DUT.DUC_DDC_Loopback_Sim_i.DAC_Chain_0.cic_compiler.m_axis_data_tdata;
      $fdisplay(fd_cic, "%d, %d", $signed(tmp_duc), $signed(tmp_duc_q));
      #CLOCK_PERIOD;
    end

    $fclose(fd_cic);
  end

//---------------------------------------------------------------
// Record DUC output
//---------------------------------------------------------------
  initial begin
    fd_duc = $fopen("../../../../../../modules/sim/duc_loop.txt","w");
    if (fd_duc) $display("File was opened successfully: %0d ",fd_duc);
    else begin
      $display("File was NOT opened successfully: %0d",fd_duc);
      $stop;
    end

    #(CLOCK_PERIOD*800);

    for (k = 0; k < (ofdm_symbols+1)*(nfft+cp_len)*40; k++) begin
      while(!DUT.DUC_DDC_Loopback_Sim_i.DAC_Chain_0.axis_data_fifo.m_axis_tvalid ||
        !DUT.DUC_DDC_Loopback_Sim_i.DAC_Chain_0.axis_data_fifo.m_axis_tready) begin
        #CLOCK_PERIOD_ADC;
      end
      $fdisplay(fd_duc, "%d", 
        $signed(DUT.DUC_DDC_Loopback_Sim_i.DAC_Chain_0.axis_data_fifo.m_axis_tdata));
      #CLOCK_PERIOD_ADC;
    end

    $fclose(fd_duc);
  end

//---------------------------------------------------------------
// Record DDC output
//---------------------------------------------------------------
  initial begin
    fd_write = $fopen("../../../../../../modules/sim/duc_ddc_loop.txt","w");
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
    Fc_scaled = 32'd10737418;
    Interp_ratio = 16'd40;
    decimate_ratio = 16'd40;

    r_nRst = 1'b0;
    adc_aresetn = 1'b0;

    s_tdata = '0;
    s_tkeep = '0;
    s_tlast = 1'b0;
    s_tvalid = 1'b0;
    i_gain_shift_reg = 3'd2;
    // Throw away header
    $fscanf(fd, "%d,\n", tmp);
    $fscanf(fd, "%d,\n", tmp);
    $fscanf(fd, "%d,\n", tmp);

    #(CLOCK_PERIOD_ADC*20);
    r_nRst = 1'b1;
    adc_aresetn = 1'b1;
    i_gain_shift_reg = 3'd3;
    #(CLOCK_PERIOD_ADC*20);
    s_tkeep = 4'b1111;
    #(CLOCK_PERIOD_ADC*20);

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

    #(CLOCK_PERIOD_ADC*nfft);
    $fclose(fd);
    $stop;
  end
endmodule
