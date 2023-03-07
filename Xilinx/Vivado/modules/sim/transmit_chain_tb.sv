//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------
// Steps to run:
//  1. Run Matlab Script "transmit_chain.mlx" until 
//     "Reading Testbench Files"
//  2. Run Vivado sim
//  3. Reformat coe_samples.txt into coe_samples.coe
//  4. Open BRAM IP and re-select coe_samples.coe
//  5. Run Vivado sim again
//  6. Run Matlab Script "transmit_chain.mlx"

`timescale 1 ns / 1 ps

module transmit_chain_tb();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  int                               fd;
  int                               fd_info;
  int                               fd_ifft;
  int                               fd_coe;
  int                               fd_ifft_in;
  
  int                               ofdm_symbols;
  int                               sample_rate;
  int                               nfft;
  int                               fs_cycles;
  int                               count;

  logic                             r_clk;
  logic                             r_nRst;

  logic                             playback_en;
  logic                             config_start;
  logic [15:0]                      cp_len;
  logic                             inv;
  logic [4:0]                       nfft_scale;

  logic [31:0]                      in_axis_tdata     = '0;
  logic                             in_axis_tlast     = 1'b0;
  logic                             in_axis_tvalid    = 1'b0;
  logic                             in_axis_tready;

  logic [15:0]                      input_data_i,input_data_q;

  logic [31:0]                      ifft;
  logic                             ifft_tvalid;
  logic                             ifft_tlast;

  logic                             ifft_in_tvalid;
  logic [31:0]                      ifft_in_tdata;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  Transmit_Chain_wrapper DUT (
    .aclk                           (r_clk),
    .aresetn                        (r_nRst),

    .playback_en                    (playback_en),
    .config_start_0                 (config_start),
    .cp_len_0                       (cp_len),
    .inv_0                          (inv),
    .nfft_0                         (nfft_scale),
    .nfft_scaled_0                  (nfft),
    .i_negative_freq_0              (1'b1),
    .dl_en_0                        (1'b1),
    .fs_cycles_0                    (fs_cycles),
    .symbols_0                      (ofdm_symbols),
    .continuous_0                   (1'b0),

    .S_AXIS_tdata                   (in_axis_tdata),
    .S_AXIS_tlast                   (in_axis_tlast),
    .S_AXIS_tvalid                  (in_axis_tvalid),
    .S_AXIS_tready                  (in_axis_tready),

    .M_AXIS_tdata                   (ifft),
    .M_AXIS_tlast                   (ifft_tlast),
    .M_AXIS_tvalid                  (ifft_tvalid)
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
// Scoreboard IFFT input
//---------------------------------------------------------------
  initial begin
    //fd_ifft_in = $fopen("c:/Projects/FAU-Modem/OFDM/Xilinx/Vivado/modules/sim/transmit_chain_ifft_sim_in.txt","w");
    fd_ifft_in = $fopen("../../../../../../modules/sim/transmit_chain_ifft_sim_in.txt","w");
    if (fd_ifft_in) $display("File was opened successfully: %0d ",fd_ifft_in);
    else begin
      $display("fd_ifft file was NOT opened successfully: %0d",fd_ifft_in);
      $stop;
    end

    #(CLOCK_PERIOD*22);

    for (int i = 0; i < (ofdm_symbols*(nfft)); i++) begin
      ifft_in_tdata                  = DUT.Transmit_Chain_i.ifft.s_axis_data_tdata;
      $fdisplay(fd_ifft_in,"%d, %d",$signed(ifft_in_tdata[15:0]),$signed(ifft_in_tdata[31:16]));
      #CLOCK_PERIOD;
    end
    $display("%d, %d",$signed(ifft_in_tdata[15:0]),$signed(ifft_in_tdata[31:16]));
    $fdisplay(fd_ifft_in,"%d, %d",$signed(ifft_in_tdata[15:0]),$signed(ifft_in_tdata[31:16]));

  end

  assign ifft_in_tvalid               = DUT.Transmit_Chain_i.ifft.s_axis_data_tvalid &&
                                         DUT.Transmit_Chain_i.ifft.s_axis_data_tready;

//---------------------------------------------------------------
// Scoreboard IFFT output
//---------------------------------------------------------------
  initial begin
    //fd_ifft = $fopen("c:/Projects/FAU-Modem/OFDM/Xilinx/Vivado/modules/sim/transmit_chain_ifft_sim_out.txt","w");
    fd_ifft = $fopen("../../../../../../modules/sim/transmit_chain_ifft_sim_out.txt","w");
    if (fd_ifft) $display("File was opened successfully: %0d ",fd_ifft);
    else begin
      $display("fd_ifft file was NOT opened successfully: %0d",fd_ifft);
      $stop;
    end

    #(CLOCK_PERIOD*10);

    if (nfft == 4096 || nfft == 2048 || nfft == 1024)
      #(CLOCK_PERIOD*2000);
    else if (nfft == 512)
      #(CLOCK_PERIOD*1000);
    else if (nfft == 256)
      #(CLOCK_PERIOD*500);
    else if (nfft == 128)
      #(CLOCK_PERIOD*250);

    $display("nfft = %d, cp_len = %d, ofdm_symbols = %d",nfft,cp_len,ofdm_symbols);

    for (int i = 0; i < (ofdm_symbols*(nfft+cp_len)); i++) begin
//    for (int i = 0; i < (ofdm_symbols*(nfft+(cp_len*2)+ nfft)); i++) begin
      while (~ifft_tvalid)
        #CLOCK_PERIOD;
      $fdisplay(fd_ifft,"%d, %d",$signed(ifft[15:0]),$signed(ifft[31:16]));
      //if (i < 5)
      //  $display("i = %d, IFFT out: %d + j%d",i,$signed(ifft[15:0]),$signed(ifft[31:16]));
      #(CLOCK_PERIOD);
    end
  end

//---------------------------------------------------------------
// Stimulate design
//---------------------------------------------------------------
  initial begin
    //fd = $fopen("c:/Projects/FAU-Modem/OFDM/Xilinx/Vivado/modules/sim/transmit_chain_carriers_in_data.txt","r");
    fd = $fopen("../../../../../../modules/sim/transmit_chain_carriers_in_data.txt","r");
    if (fd) $display("File was opened successfully: %0d ",fd);
    else begin
      $display("File was NOT opened successfully: %0d",fd);
      $stop;
    end

    //fd_info = $fopen("c:/Projects/FAU-Modem/OFDM/Xilinx/Vivado/modules/sim/info.txt","r");
    fd_info = $fopen("../../../../../../modules/sim/info.txt","r");
    if (fd_info) $display("File was opened successfully: %0d ",fd_info);
    else begin
      $display("File was NOT opened successfully: %0d",fd_info);
      $stop;
    end

    //fd_coe = $fopen("c:/Projects/FAU-Modem/OFDM/Xilinx/Vivado/modules/sim/transmit_chain_coe_samples.txt","w");
    fd_coe = $fopen("../../../../../../modules/sim/transmit_chain_coe_samples.txt","w");
    if (fd_info) $display("File was opened successfully: %0d ",fd_info);
    else begin
      $display("File was NOT opened successfully: %0d",fd_info);
      $stop;
    end

    $fscanf(fd_info,"%d, %d, %d, %d",ofdm_symbols,sample_rate,nfft,cp_len);
    $display("Number of OFDM symbols: %d",ofdm_symbols);
    fs_cycles                       = $floor(100000000/sample_rate);
    $display("Sample_rate: %dsps = %d 100MHz clock cycles per sample",sample_rate,fs_cycles);
    $display("nFFT = %d",nfft);
    nfft_scale                      = $clog2(nfft);
    $display("nFFT scaled = %d",nfft_scale);
    $display("cp_len = %d",cp_len);

    r_nRst                          <= 1'b0;
    in_axis_tvalid                  <= 1'b0;
    in_axis_tlast                   <= 1'b0;
    inv                             <= 1'b1;
    cp_len                          <= cp_len*4;
    config_start                    <= 1'b0;
    playback_en                     <= 1'b0;
    #(5*CLOCK_PERIOD);
    r_nRst                          <= 1'b1;
    #(5*CLOCK_PERIOD);
    config_start                    <= 1'b1;
    #(5*CLOCK_PERIOD);

    //playback_en                     <= 1'b1;
    count                           <= 0;
    #CLOCK_PERIOD;

    for (int i = 0; i < (ofdm_symbols*nfft); i++) begin
      while (~in_axis_tready) begin
        count                       <= 1;

        in_axis_tvalid              <= 1'b0;
        in_axis_tlast               <= 1'b0;
        #CLOCK_PERIOD;
      end
      if (count == 1) begin
        in_axis_tvalid              <= 1'b1;
        #CLOCK_PERIOD;
      end
      count                         <= 0;
      $fscanf(fd,"%d, %d",input_data_i,input_data_q);
      $fdisplay(fd_coe,"%4h%4h,",$signed(input_data_q),$signed(input_data_i));
      in_axis_tdata                 <= {input_data_q,input_data_i};
      in_axis_tvalid                <= 1'b1;
      //$display("i = %d, %d + j%d",i,$signed(input_data_i),$signed(input_data_q));
      if (!((i+1)%nfft)&&(i!=0)) begin
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
      //  in_axis_tvalid              <= 1'b0;
      //#(CLOCK_PERIOD*(fs_cycles-1));
    end

    in_axis_tlast                   <= 1'b0;
    in_axis_tvalid                  <= 1'b0;
    if (nfft == 4096 || nfft == 2048 || nfft == 1024)
      #(ofdm_symbols*(nfft+cp_len)*fs_cycles*CLOCK_PERIOD);
    else if (nfft == 512)
      #(ofdm_symbols*2*(nfft+cp_len)*fs_cycles*CLOCK_PERIOD);
    else if (nfft == 256)
      #(ofdm_symbols*6*(nfft+cp_len)*fs_cycles*CLOCK_PERIOD);
    else if (nfft == 128)
      #(ofdm_symbols*8*(nfft+cp_len)*fs_cycles*CLOCK_PERIOD);
      //#(CLOCK_PERIOD*30);
    $fclose(fd);
    $fclose(fd_info);
    $fclose(fd_ifft);
    $fclose(fd_coe);
    $fclose(fd_ifft_in);
    $stop;
  end

endmodule
