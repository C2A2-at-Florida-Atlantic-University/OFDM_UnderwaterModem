//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------
`timescale 1 ns / 1 ns

module dac_chain_tb();

  localparam                        FC                = 250000.0;
  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  localparam                        CLOCK_PERIOD_DAC  = 100; // 10 MHz
  localparam                        CLOCK_CYCLE_DAC   = CLOCK_PERIOD_DAC/2;

  localparam                        CLK_FREQ          = 100000000.0;
  localparam                        DT                = 1.0/FC;

  parameter real PI = 3.14159265358979323846;

  int                               fd;
  int                               fd_write;
  int                               i;
  int                               j;


  logic                             r_clk;
  logic                             r_nRst;
  logic                             dac_aclk;
  logic                             dac_aresetn;

  logic [15:0]                      Interp_ratio;
  logic [3:0]                       DAC_control;

  logic [15:0]                      dds_tdata;
  logic                             dds_tvalid;

  logic [31:0]                       i_cosine,i_sine;

  logic [31:0]                      s_tdata;
  logic                             s_tvalid;
  logic                             s_tready;
  logic [3:0]                       s_tkeep;
  logic                             s_tlast;

  logic [13:0]                      DAC_data;
  logic [31:0]                      tmp;

  logic [15:0]                      i_duc_data,q_duc_data;

  real                              time_val;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  DAC_Chain_wrapper DUT (
    .ClockToDAC                     (),
    .DAC_control                    (DAC_control),
    .DAC_data                       (DAC_data),
    .DAC_sleep                      (DAC_sleep),
    .Interp_ratio                   (Interp_ratio),
    .PA_enable                      (PA_enable),

    .aclk                           (r_clk),
    .aresetn                        (r_nRst),
    .aclk_10M                       (dac_aclk),
    .aresetn_10M                    (dac_aresetn),

    .S_AXIS_DDS_tdata               (dds_tdata),
    .S_AXIS_DDS_tvalid              (dds_tvalid),

    .S_AXIS_tdata                   (s_tdata),
    .S_AXIS_tkeep                   (s_tkeep),
    .S_AXIS_tlast                   (s_tlast),
    .S_AXIS_tvalid                  (s_tvalid),
    .S_AXIS_tready                  (s_tready)
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
// Drive DAC Clock
//---------------------------------------------------------------
  initial begin
    dac_aclk                        = 1'b1;
    forever begin
      #CLOCK_CYCLE_DAC dac_aclk     = ~dac_aclk;
    end
  end

//---------------------------------------------------------------
// sin cos function
//---------------------------------------------------------------
  function logic signed [31:0] cosine(input signed [31:0] x);
    localparam N = 12;  // Number of terms in the Taylor series
    logic signed [31:0] numerator;
    logic signed [31:0] denominator;
    logic signed [31:0] term;
    logic sign;
    int i;
    logic signed [31:0] cos_x;

    // Compute the Taylor series approximation of cos(x)
    numerator = 1;
    denominator = 1;
    sign = 1;
    cos_x = 0;
    for (i = 0; i < N; i++) begin
      term = numerator / denominator;
      cos_x += sign * term;
      numerator *= -x * x;
      denominator *= (2 * i + 1) * (2 * i + 2);
      sign *= -1;
    end

    return cos_x;
  endfunction

  function logic signed [31:0] sine(input signed [31:0] x);
    localparam N = 12;  // Number of terms in the Taylor series
    logic signed [31:0] numerator;
    logic signed [31:0] denominator;
    logic signed [31:0] term;
    logic sign;
    int i;
    logic signed [31:0] sin_x;

    // Compute the Taylor series approximation of sin(x)
    numerator = x;
    denominator = 1;
    sign = 1;
    sin_x = 0;
    for (i = 0; i < N-1; i++) begin
      term = numerator / denominator;
      sin_x += sign * term;
      numerator *= -x * x;
      denominator *= (2 * i + 2) * (2 * i + 3);
      sign *= -1;
    end

    return sin_x;
  endfunction

//---------------------------------------------------------------
// Drive cos + jsin
//---------------------------------------------------------------
  initial begin
    for (j = 0; j < 17408000; j++) begin
      time_val = j*DT; // Update time value
      tmp = 2.0*PI*FC*time_val;
      i_sine = -1*sine(tmp);
      i_cosine = cosine(2*PI*FC*time_val);
      dds_tdata = {1'b0,i_sine[31:25],1'b0,i_cosine[31:25]};
      dds_tvalid = 1'b1;
      #CLOCK_PERIOD;
    end
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

    r_nRst                          <= 1'b0;
    dac_aresetn                     <= 1'b0;

    s_tdata                         <= '0;
    s_tvalid                        <= 1'b0;
    s_tlast                         <= 1'b0;
    s_tkeep                         <= 4'b111;
    Interp_ratio                    <= 16'd10;
    DAC_control                     <= 4'b0000;

    // Ignore header information
    $fscanf(fd, "%d,", tmp);
    $fscanf(fd, "%d,", tmp);
    $fscanf(fd, "%d,", tmp);
    
    #(CLOCK_PERIOD_DAC*50);
    r_nRst                          <= 1'b1;
    dac_aresetn                     <= 1'b1;
    #(CLOCK_PERIOD_DAC*5);
    //Interp_ratio                    <= 16'd40;
    #(CLOCK_PERIOD_DAC*10);
    DAC_control                     <= 4'b0011;

    for (i = 0; i < 30464; i++) begin
      $fscanf(fd, "%d, %d", i_duc_data, q_duc_data);
      s_tvalid                      <= 1'b1;
      while (!s_tready) begin
        s_tdata                     <= {q_duc_data,i_duc_data};
        #CLOCK_PERIOD;
      end
      #CLOCK_PERIOD;
    end

    #(CLOCK_PERIOD_DAC*100);
    $fclose(fd);
    $stop;
  end

endmodule
