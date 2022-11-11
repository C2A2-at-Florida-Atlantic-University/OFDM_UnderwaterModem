//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------
`timescale 1 ns / 1 ps

module cfo_correction_top_tb();

  localparam                        CLOCK_PERIOD      = 4;
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;
  localparam                        c_PRECISION       = 32;

  int                               fd;
  int                               fd_info;
  int                               fd_mult1;
  int                               fd_mult2;
  int                               fd_mult_out;
  int                               fd_mult_out_verif;
  int                               fd_sum;
  int                               fd_angle;
  int                               fd_dds;
  int                               fd_dds_out;
  int                               fd_mixer;
  int                               fd_mixer_out;
  int                               fd_mixer_in_out;

  int                               ofdm_symbols;

  logic [15:0]                      i_data1,q_data1;
  logic [15:0]                      i_data2,q_data2;
  logic [15:0]                      i_data3,q_data3;
  logic [15:0]                      i_data4,q_data4;

  logic                             r_clk;
  logic                             r_nRst;

  logic [127:0]                     in_axis_tdata     = '0;
  logic [7:0]                       in_axis_tid       = '0;
  logic                             in_axis_tlast     = 1'b0;
  logic [7:0]                       in_axis_tuser     = '0;
  logic                             in_axis_tvalid    = 1'b0;

  logic [15:0]                      mult0_i_data1,mult0_q_data1,mult0_i_actual1,mult0_q_actual1;
  logic [15:0]                      mult0_i_data2,mult0_q_data2,mult0_i_actual2,mult0_q_actual2;
  logic [15:0]                      mult0_i_data3,mult0_q_data3,mult0_i_actual3,mult0_q_actual3;
  logic [15:0]                      mult0_i_data4,mult0_q_data4,mult0_i_actual4,mult0_q_actual4;

  logic [15:0]                      mult1_i_data1,mult1_q_data1,mult1_i_actual1,mult1_q_actual1;
  logic [15:0]                      mult1_i_data2,mult1_q_data2,mult1_i_actual2,mult1_q_actual2;
  logic [15:0]                      mult1_i_data3,mult1_q_data3,mult1_i_actual3,mult1_q_actual3;
  logic [15:0]                      mult1_i_data4,mult1_q_data4,mult1_i_actual4,mult1_q_actual4;

  logic [31:0]                      mult_out_i_data1,mult_out_q_data1,mult_out_i_print1,mult_out_q_print1;
  logic [31:0]                      mult_out_i_data2,mult_out_q_data2,mult_out_i_print2,mult_out_q_print2;
  logic [31:0]                      mult_out_i_data3,mult_out_q_data3,mult_out_i_print3,mult_out_q_print3;
  logic [31:0]                      mult_out_i_data4,mult_out_q_data4,mult_out_i_print4,mult_out_q_print4;

  logic [31:0]                      sum_i, sum_q, actual_sum_i, actual_sum_q;

  real                              angle,actual_angle,cordic_out_print,cfo;
  logic [31:0]                      actual_angle_val;
  real                              scs;
  logic [31:0]                      scs_hex = 32'h00EE_6B28; // 976,562.5 Hz = 0xEE6B2.8
  logic [31:0]                      clk_freq = 32'h0EE6_B280; // Clock frequency
  logic [31:0]                      phase_width = 32'hFFFF_FFFF; // 2^phase_width

  logic [15:0]                      dds_sample_i_1,dds_sample_q_1,dds_actual_i_1,dds_actual_q_1;
  logic [15:0]                      dds_sample_i_2,dds_sample_q_2,dds_actual_i_2,dds_actual_q_2;
  logic [15:0]                      dds_sample_i_3,dds_sample_q_3,dds_actual_i_3,dds_actual_q_3;
  logic [15:0]                      dds_sample_i_4,dds_sample_q_4,dds_actual_i_4,dds_actual_q_4;

  logic [15:0]                      mix_in_i_1,mix_in_q_1;
  logic [15:0]                      mix_in_i_2,mix_in_q_2;
  logic [15:0]                      mix_in_i_3,mix_in_q_3;
  logic [15:0]                      mix_in_i_4,mix_in_q_4;
  
//  logic [31:0]                      mixer_sample_i_1,mixer_sample_q_1,mixer_actual_i_1,mixer_actual_q_1;
//  logic [31:0]                      mixer_sample_i_2,mixer_sample_q_2,mixer_actual_i_2,mixer_actual_q_2;
//  logic [31:0]                      mixer_sample_i_3,mixer_sample_q_3,mixer_actual_i_3,mixer_actual_q_3;
//  logic [31:0]                      mixer_sample_i_4,mixer_sample_q_4,mixer_actual_i_4,mixer_actual_q_4;

  logic [15:0]                      mixer_sample_i_1,mixer_sample_q_1,mixer_actual_i_1,mixer_actual_q_1;
  logic [15:0]                      mixer_sample_i_2,mixer_sample_q_2,mixer_actual_i_2,mixer_actual_q_2;
  logic [15:0]                      mixer_sample_i_3,mixer_sample_q_3,mixer_actual_i_3,mixer_actual_q_3;
  logic [15:0]                      mixer_sample_i_4,mixer_sample_q_4,mixer_actual_i_4,mixer_actual_q_4;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
//  design_1_wrapper DUT (
  cfo_correction_wrapper DUT (
    .axis_aclk                      (r_clk),
    .axis_aresetn                   (r_nRst),
    
    .bypass                         (1'b0),

    .m_axis_tdata                   (),
    .m_axis_tlast                   (),
    .m_axis_tvalid                  (),
    .m_axis_tstrb                   (),
    .m_axis_tready                  (1'b1),

    .s_axis_tdata                   (in_axis_tdata),
    .s_axis_tid                     (in_axis_tid),
    .s_axis_tlast                   (in_axis_tlast),
    .s_axis_tuser                   (in_axis_tuser),
    .s_axis_tvalid                  (in_axis_tvalid)
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
// Function to convert FIX data type of cordic output
//---------------------------------------------------------------
  function real read_cordic_out;
    input logic [c_PRECISION:0] cordic_out;
    real cordic_print = 0;
    bit negative = 0;
    if (cordic_out[c_PRECISION-1]) begin
      negative                      <= 1;
      cordic_out                    <= ~cordic_out + 1;
    end

    for (int i = 0; i < c_PRECISION-2; i++) begin
      if (cordic_out[i])
        cordic_print                <= cordic_print + $pow(2,-c_PRECISION+3+i);
    end
    
    if (negative)
      read_cordic_out               <= -1*cordic_print;
    else
      read_cordic_out               <= cordic_print;
  endfunction

//---------------------------------------------------------------
// Scoreboard multiplier input
//---------------------------------------------------------------
  initial begin
    //fd_mult1 = $fopen("../../../../../../modules/sim/cp_conj_samples.txt","r");
    fd_mult1 = $fopen("c:/Projects/pi-radio/HW/modules/sim/cp_conj_samples.txt","r");
    //fd_mult2 = $fopen("../../../../../../modules/sim/cp_end_samples.txt","r");
    fd_mult2 = $fopen("c:/Projects/pi-radio/HW/modules/sim/cp_end_samples.txt","r");
    if (fd_mult1) $display("File was opened successfully: %0d ",fd_mult1);
    else begin
      $display("File was NOT opened successfully: %d",fd_mult1);
      $stop;
    end
    if (fd_mult2) $display("File was opened successfully: %0d ",fd_mult2);
    else begin
      $display("File was NOT opened successfully: %d",fd_mult2);
      $stop;
    end

    #(267*CLOCK_PERIOD);

    // Check every IQ sample of multiplier input
    for (int i = 0; i < (ofdm_symbols*64); i++) begin

      if (!(i%64)&&(i!=0))
        #(CLOCK_PERIOD*257);
      else
        #CLOCK_PERIOD;

      $fscanf(fd_mult1,"%d, %d\n%d, %d\n%d, %d\n%d, %d\n",mult0_i_data1,mult0_q_data1,mult0_i_data2,mult0_q_data2,
                              mult0_i_data3,mult0_q_data3,mult0_i_data4,mult0_q_data4);

      mult0_i_actual1 = DUT.cfo_correction_i.complex_mult_0.s_axis0_tdata[15:0];
      mult0_q_actual1 = DUT.cfo_correction_i.complex_mult_0.s_axis0_tdata[31:16];
      mult0_i_actual2 = DUT.cfo_correction_i.complex_mult_0.s_axis0_tdata[47:32];
      mult0_q_actual2 = DUT.cfo_correction_i.complex_mult_0.s_axis0_tdata[63:48];
      mult0_i_actual3 = DUT.cfo_correction_i.complex_mult_0.s_axis0_tdata[79:64];
      mult0_q_actual3 = DUT.cfo_correction_i.complex_mult_0.s_axis0_tdata[95:80];
      mult0_i_actual4 = DUT.cfo_correction_i.complex_mult_0.s_axis0_tdata[111:96];
      mult0_q_actual4 = DUT.cfo_correction_i.complex_mult_0.s_axis0_tdata[127:112];

      if (mult0_i_actual1 != mult0_i_data1) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in A I0: %d", $signed(mult0_i_actual1));
        $display("Expected: %d", $signed(mult0_i_data1));
      end
      if (mult0_q_actual1 != mult0_q_data1) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in A Q0: %d", $signed(mult0_q_actual1));
        $display("Expected: %d", $signed(mult0_q_data1));
      end
      if (mult0_i_actual2 != mult0_i_data2) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in A I1: %d", $signed(mult0_i_actual2));
        $display("Expected: %d", $signed(mult0_i_data2));
      end
      if (mult0_q_actual2 != mult0_q_data2) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in A Q1: %d", $signed(mult0_q_actual2));
        $display("Expected: %d", $signed(mult0_q_data2));
      end
      if (mult0_i_actual3 != mult0_i_data3) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in A I2: %d", $signed(mult0_i_actual3));
        $display("Expected: %d", $signed(mult0_i_data3));
      end
      if (mult0_q_actual3 != mult0_q_data3) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in A Q2: %d", $signed(mult0_q_actual3));
        $display("Expected: %d", $signed(mult0_q_data3));
      end
      if (mult0_i_actual4 != mult0_i_data4) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in A I3: %d", $signed(mult0_i_actual4));
        $display("Expected: %d", $signed(mult0_i_data4));
      end
      if (mult0_q_actual4 != mult0_q_data4) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in A Q3: %d", $signed(mult0_q_actual4));
        $display("Expected: %d", $signed(mult0_q_data4));
        $display(" ");
      end


      $fscanf(fd_mult2,"%d, %d\n%d, %d\n%d, %d\n%d, %d\n",mult1_i_data1,mult1_q_data1,mult1_i_data2,mult1_q_data2,
                              mult1_i_data3,mult1_q_data3,mult1_i_data4,mult1_q_data4);

      mult1_i_actual1 = DUT.cfo_correction_i.complex_mult_0.s_axis1_tdata[15:0];
      mult1_q_actual1 = DUT.cfo_correction_i.complex_mult_0.s_axis1_tdata[31:16];
      mult1_i_actual2 = DUT.cfo_correction_i.complex_mult_0.s_axis1_tdata[47:32];
      mult1_q_actual2 = DUT.cfo_correction_i.complex_mult_0.s_axis1_tdata[63:48];
      mult1_i_actual3 = DUT.cfo_correction_i.complex_mult_0.s_axis1_tdata[79:64];
      mult1_q_actual3 = DUT.cfo_correction_i.complex_mult_0.s_axis1_tdata[95:80];
      mult1_i_actual4 = DUT.cfo_correction_i.complex_mult_0.s_axis1_tdata[111:96];
      mult1_q_actual4 = DUT.cfo_correction_i.complex_mult_0.s_axis1_tdata[127:112];
  
      if (mult1_i_actual1 != mult1_i_data1) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in B I0: %d", $signed(mult1_i_actual1));
        $display("Expected: %d", $signed(mult1_i_data1));
      end
      if (mult1_q_actual1 != mult1_q_data1) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in B Q0: %d", $signed(mult1_q_actual1));
        $display("Expected: %d", $signed(mult1_q_data1));
      end
      if (mult1_i_actual2 != mult1_i_data2) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in B I1: %d", $signed(mult1_i_actual2));
        $display("Expected: %d", $signed(mult1_i_data2));
      end
      if (mult1_q_actual2 != mult1_q_data2) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in B Q1: %d", $signed(mult1_q_actual2));
        $display("Expected: %d", $signed(mult1_q_data2));
      end
      if (mult1_i_actual3 != mult1_i_data3) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in B I2: %d", $signed(mult1_i_actual3));
        $display("Expected: %d", $signed(mult1_i_data3));
      end
      if (mult1_q_actual3 != mult1_q_data3) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in B Q2: %d", $signed(mult1_q_actual3));
        $display("Expected: %d", $signed(mult1_q_data3));
      end
      if (mult1_i_actual4 != mult1_i_data4) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in B I3: %d", $signed(mult1_i_actual4));
        $display("Expected: %d", $signed(mult1_i_data4));
      end
      if (mult1_q_actual4 != mult1_q_data4) begin
        $display("ERROR: mult sum input sample %d",i);
        $display("Mult in B Q3: %d", $signed(mult1_q_actual4));
        $display("Expected: %d", $signed(mult1_q_data4));
        $display(" ");
      end
    end
    $fclose(fd_mult1);
    $fclose(fd_mult2);
  end

//---------------------------------------------------------------
// Scoreboard multiplier output
//---------------------------------------------------------------
  initial begin
    //fd_mult_out = $fopen("../../../../../../modules/sim/mult_samples.txt","r");
    fd_mult_out = $fopen("c:/Projects/pi-radio/HW/modules/sim/mult_samples.txt","r");
    //fd_mult_out_verif = $fopen("../../../../../../modules/sim/mult_verif_samples.txt","w");
    fd_mult_out_verif = $fopen("c:/Projects/pi-radio/HW/modules/sim/mult_verif_samples.txt","w");
    if (fd_mult_out) $display("File was opened successfully: %0d ",fd_mult_out);
    else begin
      $display("File was NOT opened successfully: %0d",fd_mult_out);
      $stop;
    end
    if (fd_mult_out_verif) $display("File was opened successfully: %0d ",fd_mult_out_verif);
    else begin
      $display("File was NOT opened successfully: %0d", fd_mult_out_verif);
      $stop;
    end

    #(273*CLOCK_PERIOD);
    for (int i = 0; i < (ofdm_symbols*64); i++) begin

      if (!(i%64)&&(i!=0))
        #(CLOCK_PERIOD*257);
      else
        #CLOCK_PERIOD;

      $fscanf(fd_mult_out,"%d, %d\n%d, %d\n%d, %d\n%d, %d\n",mult_out_i_data1,mult_out_q_data1,
              mult_out_i_data2,mult_out_q_data2,mult_out_i_data3,mult_out_q_data3,
              mult_out_i_data4,mult_out_q_data4);
      
      mult_out_i_print1 = DUT.cfo_correction_i.complex_mult_0.m_axis_tdata[31:0];
      mult_out_q_print1 = DUT.cfo_correction_i.complex_mult_0.m_axis_tdata[63:32];
      mult_out_i_print2 = DUT.cfo_correction_i.complex_mult_0.m_axis_tdata[95:64];
      mult_out_q_print2 = DUT.cfo_correction_i.complex_mult_0.m_axis_tdata[127:96];
      mult_out_i_print3 = DUT.cfo_correction_i.complex_mult_0.m_axis_tdata[159:128];
      mult_out_q_print3 = DUT.cfo_correction_i.complex_mult_0.m_axis_tdata[191:160];
      mult_out_i_print4 = DUT.cfo_correction_i.complex_mult_0.m_axis_tdata[223:192];
      mult_out_q_print4 = DUT.cfo_correction_i.complex_mult_0.m_axis_tdata[255:224];

      $fdisplay(fd_mult_out_verif,"%d, %d\n%d, %d\n%d, %d\n%d, %d",
        $signed(mult_out_i_print1),
        $signed(mult_out_q_print1),
        $signed(mult_out_i_print2),
        $signed(mult_out_q_print2),
        $signed(mult_out_i_print3),
        $signed(mult_out_q_print3),
        $signed(mult_out_i_print4),
        $signed(mult_out_q_print4));

      if (mult_out_i_print1 != mult_out_i_data1) begin
        $display("ERROR: mult output sample %d",i);
        $display("Mult out I0: %d", $signed(mult_out_i_print1));
        $display("Expected: %d", $signed(mult_out_i_data1));
      end
      if (mult_out_q_print1 != mult_out_q_data1) begin
        $display("ERROR: mult output sample %d",i);
        $display("Mult out Q0: %d", $signed(mult_out_q_print1));
        $display("Expected: %d", $signed(mult_out_q_data1));
      end
      if (mult_out_i_print2 != mult_out_i_data2) begin
        $display("ERROR: mult output sample %d",i);
        $display("Mult out I1: %d", $signed(mult_out_i_print2));
        $display("Expected: %d", $signed(mult_out_i_data2));
      end
      if (mult_out_q_print2 != mult_out_q_data2) begin
        $display("ERROR: mult output sample %d",i);
        $display("Mult out Q1: %d", $signed(mult_out_q_print2));
        $display("Expected: %d", $signed(mult_out_q_data2));
      end
      if (mult_out_i_print3 != mult_out_i_data3) begin
        $display("ERROR: mult output sample %d",i);
        $display("Mult out I2: %d", $signed(mult_out_i_print3));
        $display("Expected: %d", $signed(mult_out_i_data3));
      end
      if (mult_out_q_print3 != mult_out_q_data3) begin
        $display("ERROR: mult output sample %d",i);
        $display("Mult out Q2: %d", $signed(mult_out_q_print3));
        $display("Expected: %d", $signed(mult_out_q_data3));
      end
      if (mult_out_i_print4 != mult_out_i_data4) begin
        $display("ERROR: mult output sample %d",i);
        $display("Mult out I3: %d", $signed(mult_out_i_print4));
        $display("Expected: %d", $signed(mult_out_i_data3));
      end
      if (mult_out_q_print4 != mult_out_q_data4) begin
        $display("ERROR: mult output sample %d",i);
        $display("Mult out Q3: %d", $signed(mult_out_q_print4));
        $display("Expected: %d", $signed(mult_out_q_data4));
        $display(" ");
      end
    end

    $fclose(fd_mult_out);
    $fclose(fd_mult_out_verif);
    
  end

//---------------------------------------------------------------
// Scoreboard summation output
//---------------------------------------------------------------
  initial begin
    //fd_sum = $fopen("../../../../../../modules/sim/sum_samples.txt","r");
    fd_sum = $fopen("c:/Projects/pi-radio/HW/modules/sim/sum_samples.txt","r");
    if (fd_sum) $display("File was opened successfully: %0d ",fd_sum);
    else begin
      $display("File was NOT opened successfully: %0d",fd_sum);
      $stop;
    end

    #(CLOCK_PERIOD*340);

    for (int i = 0; i < ofdm_symbols; i++) begin

      $fscanf(fd_sum,"%d, %d\n",sum_i,sum_q);

      actual_sum_i = DUT.cfo_correction_i.sum_0.m_axis_tdata[31:0];
      actual_sum_q = DUT.cfo_correction_i.sum_0.m_axis_tdata[63:32];

      if (actual_sum_i != sum_i) begin
        $display("------------------------OFDM SYMBOL %0d------------------------",i);
        $display("ERROR: summation real expected: %d",$signed(sum_i));
        $display("Actual: %d",$signed(actual_sum_i));
      end
      if (actual_sum_q != sum_q) begin
        $display("ERROR: summation imaginary expected: %d",$signed(sum_q));
        $display("Actual: %d",$signed(actual_sum_q));
      end

      #(CLOCK_PERIOD*320);

    end

    $fclose(fd_sum);

  end

//---------------------------------------------------------------
// Scoreboard cordic output
//---------------------------------------------------------------
  initial begin
    //fd_angle = $fopen("../../../../../../modules/sim/angle_samples.txt","r");
    fd_angle = $fopen("c:/Projects/pi-radio/HW/modules/sim/angle_samples.txt","r");
    if (fd_angle) $display("File was opened successfully: %0d ",fd_angle);
    else begin
      $display("File was NOT opened successfully: %0d",fd_angle);
      $stop;
    end

    #(CLOCK_PERIOD*(c_PRECISION+345));

    for (int i = 0; i < ofdm_symbols; i++) begin
      $display("------------------------OFDM SYMBOL %0d------------------------",i);
      $fscanf(fd_angle,"%f\n",angle);
      $display("Expected angle value: %f",angle);

      actual_angle = DUT.cfo_correction_i.angle_0.m_axis_tdata[c_PRECISION-1:0];
      actual_angle_val = DUT.cfo_correction_i.angle_0.m_axis_tdata[c_PRECISION-1:0];
      
      $display("Actual angle value (signed): %H",actual_angle_val);
      if (actual_angle_val[c_PRECISION-1])
        $display("Actual angle value (unsigned): %H",-actual_angle_val);
      $display("Actual angle value: %b",actual_angle_val);
    
      cordic_out_print = read_cordic_out(actual_angle);
    
      $display("Actual angle value (converted): %f",cordic_out_print);
      $display(" ");
    
      $display("Expected cfo: %0f",angle*scs);
      $display("scs * angle = %H",scs_hex*(-actual_angle_val));
      $display("Actual phase increment = %0H",(angle*scs*phase_width)/clk_freq);
      $display("------------------------------------------------------------");
      $display(" ");
      $display(" ");

      #(CLOCK_PERIOD*320);

    end

    $fclose(fd_angle);

  end

//---------------------------------------------------------------
// Scoreboard dds
//---------------------------------------------------------------
  initial begin
    //fd_dds = $fopen("../../../../../../modules/sim/dds_samples.txt","r");
    fd_dds = $fopen("c:/Projects/pi-radio/HW/modules/sim/dds_samples.txt","r");
    if (fd_dds) $display("File was opened successfully: %0d ",fd_dds);
    else begin
      $display("File was NOT opened successfully: %0d",fd_dds);
      $stop;
    end
    //fd_dds_out = $fopen("../../../../../../modules/sim/dds_vivado_samples.txt","w");
    fd_dds_out = $fopen("c:/Projects/pi-radio/HW/modules/sim/dds_vivado_samples.txt","w");
    if (fd_dds_out) $display("File was opened successfully: %0d ",fd_dds_out);
    else begin
      $display("File was NOT opened successfully: %0d",fd_dds_out);
      $stop;
    end

    #(CLOCK_PERIOD*(c_PRECISION+357)); //351

    for (int i = 0; i < (ofdm_symbols*256); i++) begin
      
      if (!(i%256)&&(i!=0))
        #(CLOCK_PERIOD*65);
      else
        #CLOCK_PERIOD;

      $fscanf(fd_dds,"%d, %d\n%d, %d\n%d, %d\n%d, %d\n",dds_sample_i_1,
        dds_sample_q_1,dds_sample_i_2,dds_sample_q_2,dds_sample_i_3,
        dds_sample_q_3,dds_sample_i_4,dds_sample_q_4);

//      dds_actual_i_1 = DUT.cfo_correction_i.Mixer.dds_top_0.m_axis_tdata[15:0];
//      dds_actual_q_1 = DUT.cfo_correction_i.Mixer.dds_top_0.m_axis_tdata[31:16];
//      dds_actual_i_2 = DUT.cfo_correction_i.Mixer.dds_top_0.m_axis_tdata[47:32];
//      dds_actual_q_2 = DUT.cfo_correction_i.Mixer.dds_top_0.m_axis_tdata[63:48];
//      dds_actual_i_3 = DUT.cfo_correction_i.Mixer.dds_top_0.m_axis_tdata[79:64];
//      dds_actual_q_3 = DUT.cfo_correction_i.Mixer.dds_top_0.m_axis_tdata[95:80];
//      dds_actual_i_4 = DUT.cfo_correction_i.Mixer.dds_top_0.m_axis_tdata[111:96];
//      dds_actual_q_4 = DUT.cfo_correction_i.Mixer.dds_top_0.m_axis_tdata[127:112];

      dds_actual_i_1 = DUT.cfo_correction_i.Mixer.conj_0.m_axis_tdata[15:0];
      dds_actual_q_1 = DUT.cfo_correction_i.Mixer.conj_0.m_axis_tdata[31:16];
      dds_actual_i_2 = DUT.cfo_correction_i.Mixer.conj_0.m_axis_tdata[47:32];
      dds_actual_q_2 = DUT.cfo_correction_i.Mixer.conj_0.m_axis_tdata[63:48];
      dds_actual_i_3 = DUT.cfo_correction_i.Mixer.conj_0.m_axis_tdata[79:64];
      dds_actual_q_3 = DUT.cfo_correction_i.Mixer.conj_0.m_axis_tdata[95:80];
      dds_actual_i_4 = DUT.cfo_correction_i.Mixer.conj_0.m_axis_tdata[111:96];
      dds_actual_q_4 = DUT.cfo_correction_i.Mixer.conj_0.m_axis_tdata[127:112];

      $fdisplay(fd_dds_out,"%d, %d\n%d, %d\n%d, %d\n%d, %d",$signed(dds_actual_i_1),
        $signed(dds_actual_q_1),$signed(dds_actual_i_2),$signed(dds_actual_q_2),
        $signed(dds_actual_i_3),$signed(dds_actual_q_3),$signed(dds_actual_i_4),
        $signed(dds_actual_q_4));

//      if (dds_actual_i_1 != dds_sample_i_1) begin
//        $display("ERROR: DDS output sample %d",i);
//        $display("DDS out I0: %d",$signed(dds_actual_i_1));
//        $display("Expected: %d",$signed(dds_sample_i_1));

//        $display("DDS out I1: %d",$signed(dds_actual_i_2));
//        $display("Expected: %d",$signed(dds_sample_i_2));

//        $display("DDS out I2: %d",$signed(dds_actual_i_3));
//        $display("Expected: %d",$signed(dds_sample_i_3));

//        $display("DDS out I3: %d",$signed(dds_actual_i_4));
//        $display("Expected: %d",$signed(dds_sample_i_4));
//        $display(" ");
//      end
//      if (dds_actual_q_1 != dds_sample_q_1) begin
//        $display("ERROR: DDS output sample %d",i);
//        $display("DDS out Q0: %d",$signed(dds_actual_q_1));
//        $display("Expected: %d",$signed(dds_sample_q_1));

//        $display("DDS out Q1: %d",$signed(dds_actual_q_2));
//        $display("Expected: %d",$signed(dds_sample_q_2));

//        $display("DDS out Q2: %d",$signed(dds_actual_q_3));
//        $display("Expected: %d",$signed(dds_sample_q_3));

//        $display("DDS out Q3: %d",$signed(dds_actual_q_4));
//        $display("Expected: %d",$signed(dds_sample_q_4));
//        $display(" ");
//      end
    end

    $fclose(fd_dds);
    $fclose(fd_dds_out);

  end

//---------------------------------------------------------------
// Scoreboard mixer input
//---------------------------------------------------------------
  initial begin
    //fd_mixer_in_out = $fopen("../../../../../../modules/sim/mixer_out_samples.txt","w");
    fd_mixer_in_out = $fopen("c:/Projects/pi-radio/HW/modules/sim/mixer_out_samples.txt","w");
    if (fd_mixer_in_out) $display("File was opened successfully: %0d ",fd_mixer_in_out);
    else begin
      $display("File was NOT opened successfully: %0d",fd_mixer_in_out);
      $stop;
    end

    #(CLOCK_PERIOD*(c_PRECISION+357));

    for (int i = 0; i < (ofdm_symbols*256); i++) begin

      if (!(i%256)&&(i!=0))
        #(CLOCK_PERIOD*64);

      #CLOCK_PERIOD;

      mix_in_i_1 = DUT.cfo_correction_i.Mixer.mixer_0.s_axis0_tdata[15:0];
      mix_in_q_1 = DUT.cfo_correction_i.Mixer.mixer_0.s_axis0_tdata[31:16];
      mix_in_i_2 = DUT.cfo_correction_i.Mixer.mixer_0.s_axis0_tdata[47:32];
      mix_in_q_2 = DUT.cfo_correction_i.Mixer.mixer_0.s_axis0_tdata[63:48];
      mix_in_i_3 = DUT.cfo_correction_i.Mixer.mixer_0.s_axis0_tdata[79:64];
      mix_in_q_3 = DUT.cfo_correction_i.Mixer.mixer_0.s_axis0_tdata[95:80];
      mix_in_i_4 = DUT.cfo_correction_i.Mixer.mixer_0.s_axis0_tdata[111:96];
      mix_in_q_4 = DUT.cfo_correction_i.Mixer.mixer_0.s_axis0_tdata[127:112];

      $fdisplay(fd_mixer_in_out,"%d, %d\n%d, %d\n%d, %d\n%d, %d",$signed(mix_in_i_1),
        $signed(mix_in_q_1),$signed(mix_in_i_2),$signed(mix_in_q_2),$signed(mix_in_i_3),
        $signed(mix_in_q_3),$signed(mix_in_i_4),$signed(mix_in_q_4));

    end

    $fclose(fd_mixer_in_out);

  end

//---------------------------------------------------------------
// Scoreboard mixer output
//---------------------------------------------------------------
  initial begin
    //fd_mixer = $fopen("../../../../../../modules/sim/mixer_samples.txt","r");
    fd_mixer = $fopen("c:/Projects/pi-radio/HW/modules/sim/mixer_samples.txt","r");
    if (fd_mixer) $display("File was opened successfully: %0d ",fd_mixer);
    else begin
      $display("File was NOT opened successfully: %0d",fd_mixer);
      $stop;
    end
    fd_mixer_out = $fopen("c:/Projects/pi-radio/HW/modules/sim/mixer_vivado_samples.txt","w");
    //fd_mixer_out = $fopen("../../../../../../modules/sim/mixer_vivado_samples.txt","w");
    if (fd_mixer_out) $display("File was opened successfully: %0d ",fd_mixer_out);
    else begin
      $display("File was NOT opened successfully: %0d",fd_mixer_out);
      $stop;
    end
    
    #(CLOCK_PERIOD*(c_PRECISION+365));
    
    for (int i = 0; i < (ofdm_symbols*256); i++) begin

      if (!(i%256)&&(i!=0))
        #(CLOCK_PERIOD*64);

      #CLOCK_PERIOD;

      $fscanf(fd_mixer,"%f, %f\n%f, %f\n%f, %f\n%f, %f\n",mixer_sample_i_1,
        mixer_sample_q_1,mixer_sample_i_2,mixer_sample_q_2,mixer_sample_i_3,
        mixer_sample_q_3,mixer_sample_i_4,mixer_sample_q_4);

      mixer_actual_i_1 = DUT.cfo_correction_i.mux_0.m_axis_tdata[15:0];
      mixer_actual_q_1 = DUT.cfo_correction_i.mux_0.m_axis_tdata[31:16];
      mixer_actual_i_2 = DUT.cfo_correction_i.mux_0.m_axis_tdata[47:32];
      mixer_actual_q_2 = DUT.cfo_correction_i.mux_0.m_axis_tdata[63:48];
      mixer_actual_i_3 = DUT.cfo_correction_i.mux_0.m_axis_tdata[79:64];
      mixer_actual_q_3 = DUT.cfo_correction_i.mux_0.m_axis_tdata[95:80];
      mixer_actual_i_4 = DUT.cfo_correction_i.mux_0.m_axis_tdata[111:96];
      mixer_actual_q_4 = DUT.cfo_correction_i.mux_0.m_axis_tdata[127:112];

      $fdisplay(fd_mixer_out,"%d, %d\n%d, %d\n%d, %d\n%d, %d",$signed(mixer_actual_i_1),
        $signed(mixer_actual_q_1),$signed(mixer_actual_i_2),$signed(mixer_actual_q_2),
        $signed(mixer_actual_i_3),$signed(mixer_actual_q_3),$signed(mixer_actual_i_4),
        $signed(mixer_actual_q_4));

    end
    
    #(579*CLOCK_PERIOD);

    for (int i = 0; i < (ofdm_symbols*256); i++) begin

      if (!(i%256)&&(i!=0))
        #(CLOCK_PERIOD*64);

      #CLOCK_PERIOD;

      $fscanf(fd_mixer,"%f, %f\n%f, %f\n%f, %f\n%f, %f\n",mixer_sample_i_1,
        mixer_sample_q_1,mixer_sample_i_2,mixer_sample_q_2,mixer_sample_i_3,
        mixer_sample_q_3,mixer_sample_i_4,mixer_sample_q_4);
      
      mixer_actual_i_1 = DUT.cfo_correction_i.mux_0.m_axis_tdata[15:0];
      mixer_actual_q_1 = DUT.cfo_correction_i.mux_0.m_axis_tdata[31:16];
      mixer_actual_i_2 = DUT.cfo_correction_i.mux_0.m_axis_tdata[47:32];
      mixer_actual_q_2 = DUT.cfo_correction_i.mux_0.m_axis_tdata[63:48];
      mixer_actual_i_3 = DUT.cfo_correction_i.mux_0.m_axis_tdata[79:64];
      mixer_actual_q_3 = DUT.cfo_correction_i.mux_0.m_axis_tdata[95:80];
      mixer_actual_i_4 = DUT.cfo_correction_i.mux_0.m_axis_tdata[111:96];
      mixer_actual_q_4 = DUT.cfo_correction_i.mux_0.m_axis_tdata[127:112];

      $fdisplay(fd_mixer_out,"%d, %d\n%d, %d\n%d, %d\n%d, %d",$signed(mixer_actual_i_1),
        $signed(mixer_actual_q_1),$signed(mixer_actual_i_2),$signed(mixer_actual_q_2),
        $signed(mixer_actual_i_3),$signed(mixer_actual_q_3),$signed(mixer_actual_i_4),
        $signed(mixer_actual_q_4));

    end
    $fclose(fd_mixer);
    $fclose(fd_mixer_out);
  end

//---------------------------------------------------------------
// Control tlast/tvalid
//---------------------------------------------------------------
  initial begin
    r_nRst                          <= 1'b0;
    #CLOCK_PERIOD;
    r_nRst                          <= 1'b1;
    #(4*CLOCK_PERIOD);
    #CLOCK_PERIOD;
    in_axis_tvalid                  <= 1'b1;
    in_axis_tuser                   <= '0;
    in_axis_tid                     <= '0;
    for (int i = 0; i < (ofdm_symbols*320); i++) begin
      if (!((i+1)%320)&&(i!=0))
        in_axis_tlast               <= 1'b1;
      if (!(i%320)&&(i!=0))
        in_axis_tlast               <= 1'b0;
      #CLOCK_PERIOD;
    end
    in_axis_tlast                   <= 1'b0;
    in_axis_tvalid                  <= 1'b0;

    #(2000+((ofdm_symbols-1)*CLOCK_PERIOD));

    #CLOCK_PERIOD;
    r_nRst                          <= 1'b1;
    #(4*CLOCK_PERIOD);
    #CLOCK_PERIOD;
    in_axis_tvalid                  <= 1'b1;
    in_axis_tuser                   <= '0;
    in_axis_tid                     <= '0;
    for (int i = 0; i < (ofdm_symbols*320); i++) begin
      if (!((i+1)%320)&&(i!=0))
        in_axis_tlast               <= 1'b1;
      if (!(i%320)&&(i!=0))
        in_axis_tlast               <= 1'b0;
      #CLOCK_PERIOD;
    end
    in_axis_tlast                   <= 1'b0;
    in_axis_tvalid                  <= 1'b0;
  end
//---------------------------------------------------------------
// Stimulate design
//---------------------------------------------------------------
  initial begin
    //fd = $fopen("../../../../../modules/sim/cw_input_samples.txt","r");
    //fd = $fopen("../../../../../../modules/sim/equalizer_input_samples.txt","r");
    fd = $fopen("c:/Projects/pi-radio/HW/modules/sim/equalizer_input_samples.txt","r");
    if (fd) $display("File was opened successfully: %0d ",fd);
    else begin   
      $display("File was NOT opened successfully: %0d",fd);
      $stop;
    end
    //fd_info = $fopen("../../../../../../modules/sim/info.txt","r");
    fd_info = $fopen("c:/Projects/pi-radio/HW/modules/sim/info.txt","r");
    if (fd_info) $display("File was opened successfully: %0d ",fd_info);
    else begin
      $display("File was NOT opened successfully: %0d",fd_info);
      $stop;
    end

    $fscanf(fd_info,"%d",ofdm_symbols);
    $display("Number of OFDM symbols: %d",ofdm_symbols);
    
    #(CLOCK_PERIOD*6);

    for (int i = 0; i < (ofdm_symbols*320); i++) begin
      $fscanf(fd,"%d, %d",i_data1,q_data1);
      $fscanf(fd,"%d, %d",i_data2,q_data2);
      $fscanf(fd,"%d, %d",i_data3,q_data3);
      $fscanf(fd,"%d, %d",i_data4,q_data4);
      if (i == 0) begin
        $display("Printing Samples");
        $display("%D + i%D",$signed(i_data1),$signed(q_data1));
        $display("%D + i%D",$signed(i_data2),$signed(q_data2));
        $display("%D + i%D",$signed(i_data3),$signed(q_data3));
        $display("%D + i%D",$signed(i_data4),$signed(q_data4));
      end
      in_axis_tdata                 <= {q_data4,i_data4,q_data3,i_data3,
                                       q_data2,i_data2,q_data1,i_data1};
      #CLOCK_PERIOD;
    end
    $fclose(fd);
    #(2000+((ofdm_symbols-1)*CLOCK_PERIOD));
    fd = $fopen("c:/Projects/pi-radio/HW/modules/sim/equalizer_input_samples.txt","r");
    //fd = $fopen("../../../../../../modules/sim/equalizer_input_samples.txt","r");
    if (fd) $display("File was opened successfully: %0d ",fd);
    else begin   
      $display("File was NOT opened successfully: %0d",fd);
      $stop;
    end

    #(CLOCK_PERIOD*6);

    for (int i = 0; i < (ofdm_symbols*320); i++) begin
      $fscanf(fd,"%d, %d",i_data1,q_data1);
      $fscanf(fd,"%d, %d",i_data2,q_data2);
      $fscanf(fd,"%d, %d",i_data3,q_data3);
      $fscanf(fd,"%d, %d",i_data4,q_data4);
      if (i == 0) begin
        $display("Printing Samples");
        $display("%D + i%D",$signed(i_data1),$signed(q_data1));
        $display("%D + i%D",$signed(i_data2),$signed(q_data2));
        $display("%D + i%D",$signed(i_data3),$signed(q_data3));
        $display("%D + i%D",$signed(i_data4),$signed(q_data4));
      end
      in_axis_tdata                 <= {q_data4,i_data4,q_data3,i_data3,
                                       q_data2,i_data2,q_data1,i_data1};
      #CLOCK_PERIOD;
    end
    $fclose(fd);
    $fclose(fd_info);
    #(2000+((ofdm_symbols-1)*CLOCK_PERIOD)); $stop;

  end

endmodule
