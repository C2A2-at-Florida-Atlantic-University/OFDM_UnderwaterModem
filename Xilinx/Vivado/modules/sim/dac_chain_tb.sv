//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------
`timescale 1 ns / 1 ps

module dac_chain_tb();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  int                               fd;
  int                               fd_info;
  int                               fd_filt_in;

  logic                             r_clk;
  logic                             r_nRst;

  int                               ofdm_symbols;
  int                               sample_rate;
  int                               nfft;
  logic [15:0]                      cp_len;
  int                               fs_cycles;
  int                               interp_cycles;
  logic [4:0]                       nfft_scale;
  logic                             dl_en;

  logic [31:0]                      in_axis_tdata     = '0;
  logic                             in_axis_tlast     = 1'b0;
  logic                             in_axis_tvalid    = 1'b0;
  logic                             in_axis_tready;

  logic [15:0]                      input_data_i,input_data_q;
  logic [15:0]                      filt_in_tdata_i,filt_in_tdata_q;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  DAC_Chain_wrapper DUT (
    .aclk                           (r_clk),
    .aresetn                        (r_nRst),

    .dl_en_0                        (dl_en),
    .interp_cycles_0                (interp_cycles),

    .S_AXIS_tdata                   (in_axis_tdata),
    .S_AXIS_tlast                   (in_axis_tlast),
    .S_AXIS_tvalid                  (in_axis_tvalid),
    .S_AXIS_tready                  (in_axis_tready)
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
// Scoreboard Interpolation filter input
//---------------------------------------------------------------
  initial begin
    fd_filt_in = $fopen("c:/Projects/FAU-Modem/OFDM/Xilinx/Vivado/modules/sim/filt_in.txt","w");
    if (fd_filt_in) $display("File was opened successfully: %0d ",fd_filt_in);
    else begin
      $display("File was NOT opened successfully: %0d",fd_filt_in);
      $stop;
    end

    #(CLOCK_CYCLE*9);
    filt_in_tdata_i                 <= DUT.DAC_Chain_i.dac_resampler_0.m_axis_tdata[15:0];
    filt_in_tdata_q                 <= DUT.DAC_Chain_i.dac_resampler_0.m_axis_tdata[31:16];
    #CLOCK_CYCLE;
    filt_in_tdata_i                 <= DUT.DAC_Chain_i.dac_resampler_0.m_axis_tdata[15:0];
    filt_in_tdata_q                 <= DUT.DAC_Chain_i.dac_resampler_0.m_axis_tdata[31:16];
    #CLOCK_CYCLE;
    for (int i = 0; i < (ofdm_symbols*interp_cycles*(nfft+cp_len)); i++) begin
      while (~filt_in_tvalid) begin
        #CLOCK_CYCLE;
      end
      filt_in_tdata_i               = DUT.DAC_Chain_i.dac_resampler_0.m_axis_tdata[15:0];
      filt_in_tdata_q               = DUT.DAC_Chain_i.dac_resampler_0.m_axis_tdata[31:16];
      $fdisplay(fd_filt_in,"%d, %d",$signed(filt_in_tdata_i),$signed(filt_in_tdata_q));
      #(CLOCK_CYCLE*2);
    end

  end

  assign filt_in_tvalid             = DUT.DAC_Chain_i.dac_resampler_0.m_axis_tvalid;

//---------------------------------------------------------------
// Stimulate design
//---------------------------------------------------------------
  initial begin
    fd = $fopen("c:/Projects/FAU-Modem/OFDM/Xilinx/Vivado/modules/sim/ifft_sim_out.txt","r");
    //fd = $fopen("c:/Projects/FAU-Modem/OFDM/Xilinx/Vivado/modules/sim/ifft_matlab_out.txt","r");
    if (fd) $display("File was opened successfully: %0d ",fd);
    else begin
      $display("File was NOT opened successfully: %0d",fd);
      $stop;
    end

    fd_info = $fopen("c:/Projects/FAU-Modem/OFDM/Xilinx/Vivado/modules/sim/info.txt","r");
    if (fd_info) $display("File was opened successfully: %0d ",fd_info);
    else begin
      $display("File was NOT opened successfully: %0d",fd_info);
      $stop;
    end

    $fscanf(fd_info,"%d, %d, %d, %d, %d",ofdm_symbols,sample_rate,nfft,cp_len,interp_cycles);
    $display("Number of OFDM symbols: %d",ofdm_symbols);
    fs_cycles                       = $floor(100000000/sample_rate);
    $display("Sample_rate: %dsps = %d 100MHz clock cycles per sample",sample_rate,fs_cycles);
    $display("nFFT = %d",nfft);
    nfft_scale                      = $clog2(nfft);
    $display("nFFT scaled = %d",nfft_scale);
    $display("cp_len = %d",cp_len);
    $display("Interpolation factor = %d",interp_cycles);

    r_nRst                          <= 1'b0;
    in_axis_tvalid                  <= 1'b0;
    in_axis_tlast                   <= 1'b0;
    dl_en                           <= 1'b0;
    #(5*CLOCK_PERIOD);
    r_nRst                          <= 1'b1;
    #(5*CLOCK_PERIOD);
    dl_en                           <= 1'b1;
    #(5*CLOCK_PERIOD);

    #CLOCK_PERIOD;

    for (int i = 0; i < (ofdm_symbols*(nfft+cp_len)); i++) begin
      $fscanf(fd,"%d, %d",input_data_i,input_data_q);
      in_axis_tdata                 <= {input_data_q,input_data_i};
      in_axis_tvalid                <= 1'b1;
      //$display("i = %d, %d + j%d",i,$signed(input_data_i),$signed(input_data_q));
      if (!((i+1)%(nfft+cp_len))&&(i!=0)) begin
        in_axis_tlast               <= 1'b1;
        //#CLOCK_PERIOD;
        //in_axis_tlast               <= 1'b0;
        //in_axis_tvalid              <= 1'b0;
        //#(CLOCK_PERIOD*499);
        //#CLOCK_PERIOD;
      end
      if (!(i%nfft)&&(i!=0))
        in_axis_tlast               <= 1'b0;
      #(CLOCK_PERIOD);
      in_axis_tlast                 <= 1'b0;
      in_axis_tvalid                <= 1'b0;
      #(CLOCK_PERIOD*(fs_cycles-1));
    end

    in_axis_tlast                   <= 1'b0;
    in_axis_tvalid                  <= 1'b0;

    #(7*nfft*fs_cycles*CLOCK_PERIOD);
    $fclose(fd);
    $fclose(fd_info);
    $fclose(fd_filt_in);
    $stop;
  end

endmodule
