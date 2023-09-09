//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module adc_chain_fir_tb();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  //localparam                        CLOCK_PERIOD_ADC  = 100; // 10 MHz
  localparam                        CLOCK_PERIOD_ADC  = 24; // 40 MHz
  localparam                        CLOCK_CYCLE_ADC   = CLOCK_PERIOD_ADC/2;

  logic                             select_10M = 1'b0;

  int                               fd;
  int                               fd_write;
  int                               fd_mix;
  int                               fd_mix_dds;
  int                               fd_mix_in;

  logic                             r_clk;
  logic                             r_nRst;
  logic                             adc_aclk;
  logic                             adc_aresetn;

  logic [31:0]                      Fc_scaled;
  logic [15:0]                      decimate_ratio;
  logic [31:0]                      adc_status;
  logic                             ClockToADC;
  logic [15:0]                      ADCdata,data;
  logic [3:0]                       ADC_control;

  logic [31:0]                      m_tdata;
  logic                             m_tvalid;

  logic [15:0]                      i_ddc_out,q_ddc_out;
  logic [15:0]                      iq_mix_out_i,iq_mix_out_q;
  logic [15:0]                      iq_mix_tmp_in;

  logic [15:0]                      dds_i,dds_q;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  ADC_Chain_FIR_wrapper DUT (
    .ADC_control                    (ADC_control),
    .ADCdata                        (ADCdata),
    .ClockToADC                     (ClockToADC),
    .Fc_scaled                      (Fc_scaled),

    .M_AXIS_tdata                   (m_tdata),
    .M_AXIS_tvalid                  (m_tvalid),
    .M_AXIS_tready                  (1'b1),

    .aclk                           (r_clk),
//    .aresetn                        (r_nRst),
    
    .aclk_40M                       (adc_aclk),
    .aresetn_40M                    (adc_aresetn),

    .status                         (adc_status)
  //  .select_40M_10M                 (select_10M)
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
// Record IQ mixer input
//---------------------------------------------------------------
  initial begin
    fd_mix_in = $fopen("../../../../../../modules/sim/iq_mix_tmp_in.txt","w");
    if (fd_mix_in) $display("File was opened successfully: %0d ",fd_mix_in);
    else begin
      $display("File was NOT opened successfully: %0d",fd_mix_in);
      $stop;
    end
    fd_mix_dds = $fopen("../../../../../../modules/sim/iq_dds.txt","w");
    if (fd_mix_dds) $display("File was opened successfully: %0d ",fd_mix_dds);
    else begin
      $display("File was NOT opened successfully: %0d",fd_mix_dds);
      $stop;
    end

    #(CLOCK_PERIOD*119);
    #(CLOCK_PERIOD*326);

    for (int i = 0; i < 1392640; i++) begin
      while (~DUT.ADC_Chain_FIR_i.DDC_Mixer.iq_mixer_rx_40M_0.s_axis_tvalid)
        #CLOCK_PERIOD_ADC;
      iq_mix_tmp_in = DUT.ADC_Chain_FIR_i.DDC_Mixer.iq_mixer_rx_40M_0.s_axis_tdata;
      dds_i = DUT.ADC_Chain_FIR_i.DDC_Mixer.iq_mixer_rx_40M_0.s_axis_dds_tdata[15:0];
      dds_q = DUT.ADC_Chain_FIR_i.DDC_Mixer.iq_mixer_rx_40M_0.s_axis_dds_tdata[31:16];
      $fdisplay(fd_mix_in,"%d",$signed(iq_mix_tmp_in));
      $fdisplay(fd_mix_dds, "%d, %d",$signed(dds_i),$signed(dds_q));
      #CLOCK_PERIOD_ADC;
    end
    
    $fclose(fd_mix_in);

  end

//---------------------------------------------------------------
// Record IQ mixer output
//---------------------------------------------------------------
  initial begin
    fd_mix = $fopen("../../../../../../modules/sim/iq_mix_out.txt","w");
    if (fd_mix) $display("File was opened successfully: %0d ",fd_mix);
    else begin
      $display("File was NOT opened successfully: %0d",fd_mix);
      $stop;
    end

    #(CLOCK_PERIOD*119);
    #(CLOCK_PERIOD*327);

    for (int i = 0; i < 1392640; i++) begin
      while (~DUT.ADC_Chain_FIR_i.DDC_Mixer.iq_mixer_rx_40M_0.m_axis_real_tvalid)
        #CLOCK_PERIOD_ADC;
      iq_mix_out_i = DUT.ADC_Chain_FIR_i.DDC_Mixer.iq_mixer_rx_40M_0.m_axis_real_tdata;
      iq_mix_out_q = DUT.ADC_Chain_FIR_i.DDC_Mixer.iq_mixer_rx_40M_0.m_axis_imag_tdata;
      $fdisplay(fd_mix,"%d, %d",$signed(iq_mix_out_i),$signed(iq_mix_out_q));
      if (i < 10)
        $display("%d, %d",$signed(iq_mix_out_i),$signed(iq_mix_out_q));
      #CLOCK_PERIOD_ADC;
    end

    $fclose(fd_mix);

  end 

//---------------------------------------------------------------
// Record DDC output
//---------------------------------------------------------------
  initial begin
    fd_write = $fopen("../../../../../../modules/sim/iq_mix_test_out.txt","w");
    if (fd_write) $display("File was opened successfully: %0d ",fd_write);
    else begin
      $display("File was NOT opened successfully: %0d",fd_write);
      $stop;
    end

    #(CLOCK_PERIOD*464);
    #(CLOCK_PERIOD*327);

    for (int i = 0; i < 8704; i++) begin
      while (~m_tvalid) 
        #(CLOCK_PERIOD);
      i_ddc_out                     = m_tdata[15:0];
      q_ddc_out                     = m_tdata[31:16];
      $fdisplay(fd_write, "%d, %d",$signed(m_tdata[15:0]),
        $signed(m_tdata[31:16]));
      if (i < 10)
        $display("%d, %d",$signed(m_tdata[15:0]),
          $signed(m_tdata[31:16]));
      #(CLOCK_PERIOD*380);
    end

    $fclose(fd_write);
  end

//---------------------------------------------------------------
// Stimulate design
//---------------------------------------------------------------
  initial begin
    //fd = $fopen("../../../../../../modules/sim/iq_mix_test_in.txt","r");
    fd = $fopen("../../../../../../modules/sim/ddc_40M_input.txt","r");
    if (fd) $display("File was opened successfully: %0d ",fd);
    else begin
      $display("File was NOT opened successfully: %0d",fd);
      $stop;
    end
    r_nRst                          = 1'b0;
    adc_aresetn                     = 1'b0;
    ADC_control                     = '0;
    ADCdata                         = '0;
    Fc_scaled                       = '0;
    decimate_ratio                  = 16'd160;
    #(CLOCK_PERIOD*20);
    r_nRst                          = 1'b1;
    adc_aresetn                     = 1'b1;
    #(CLOCK_PERIOD*20);
    //ADC_control                     = 4'b0001;
    Fc_scaled                       = 32'd26_843_546;//250000 Hz 40MHz clock
    //Fc_scaled                       = 32'd11179799; // 260300 Hz
    //Fc_scaled                       = 32'd11181947; // 260350 Hz
    //Fc_scaled                       = 32'd11184868; // 260418 Hz
    //Fc_scaled                       = 32'd4_702_156_911;
    //decimate_ratio                  = 16'd160;
    #(CLOCK_PERIOD_ADC*30);
    #(CLOCK_PERIOD*327);
    ADC_control                     = 4'b0001;

    for (int i = 0; i < 1392640; i++) begin
      $fscanf(fd, "%d", data);
      ADCdata                      <= data;
      #CLOCK_PERIOD_ADC;
    end

    #(CLOCK_PERIOD_ADC*1000);
    $fclose(fd);
    $stop;
  end
endmodule
