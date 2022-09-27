module delimiter
  #(
    parameter                       IN0_WIDTH       = 4,
    parameter                       NUM_OUTPUTS     = 2,
    parameter                       OUT0_WIDTH      = 3,
    parameter                       OUT1_WIDTH      = 1,
    parameter                       OUT2_WIDTH      = 0,
    parameter                       OUT3_WIDTH      = 0,
    parameter                       OUT4_WIDTH      = 0,
    parameter                       OUT5_WIDTH      = 0,
    parameter                       OUT6_WIDTH      = 0,
    parameter                       OUT7_WIDTH      = 0
  )
  (
    input  [IN0_WIDTH - 1 : 0]      IN0,
    output [OUT0_WIDTH - 1 : 0]     OUT0,
    output [OUT1_WIDTH - 1 : 0]     OUT1,
    output [OUT2_WIDTH - 1 : 0]     OUT2,
    output [OUT3_WIDTH - 1 : 0]     OUT3,
    output [OUT4_WIDTH - 1 : 0]     OUT4,
    output [OUT5_WIDTH - 1 : 0]     OUT5,
    output [OUT6_WIDTH - 1 : 0]     OUT6,
    output [OUT7_WIDTH - 1 : 0]     OUT7
  );

  generate if (NUM_OUTPUTS == 1) begin
    assign OUT0 = IN0;
  end 
  endgenerate;

  generate if (NUM_OUTPUTS == 2) begin
    assign OUT0 = IN0[OUT0_WIDTH - 1 : 0];
    assign OUT1 = IN0[IN0_WIDTH - 1 : OUT0_WIDTH];
  end
  endgenerate;

  generate if (NUM_OUTPUTS == 3) begin
    assign OUT0 = IN0[OUT0_WIDTH - 1 : 0];
    assign OUT1 = IN0[OUT0_WIDTH + OUT1_WIDTH - 1 : OUT0_WIDTH];
    assign OUT2 = IN0[IN0_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH];
  end 
  endgenerate;

  generate if (NUM_OUTPUTS == 4) begin
    assign OUT0 = IN0[OUT0_WIDTH - 1 : 0];
    assign OUT1 = IN0[OUT0_WIDTH + OUT1_WIDTH - 1 : OUT0_WIDTH];
    assign OUT2 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH];
    assign OUT3 = IN0[IN0_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH];
  end
  endgenerate;

  generate if (NUM_OUTPUTS == 5) begin
    assign OUT0 = IN0[OUT0_WIDTH - 1 : 0];
    assign OUT1 = IN0[OUT0_WIDTH + OUT1_WIDTH - 1 : OUT0_WIDTH];
    assign OUT2 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH];
    assign OUT3 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH];
    assign OUT4 = IN0[IN0_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH];
  end
  endgenerate;

  generate if (NUM_OUTPUTS == 6) begin
    assign OUT0 = IN0[OUT0_WIDTH - 1 : 0];
    assign OUT1 = IN0[OUT0_WIDTH + OUT1_WIDTH - 1 : OUT0_WIDTH];
    assign OUT2 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH];
    assign OUT3 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH];
    assign OUT4 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH];
    assign OUT5 = IN0[IN0_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH];
  end
  endgenerate

  generate if (NUM_OUTPUTS == 7) begin
    assign OUT0 = IN0[OUT0_WIDTH - 1 : 0];
    assign OUT1 = IN0[OUT0_WIDTH + OUT1_WIDTH - 1 : OUT0_WIDTH];
    assign OUT2 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH];
    assign OUT3 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH];
    assign OUT4 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH];
    assign OUT5 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH + OUT5_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH];
    assign OUT6 = IN0[IN0_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH + OUT5_WIDTH];
  end
  endgenerate

  generate if (NUM_OUTPUTS == 8) begin
    assign OUT0 = IN0[OUT0_WIDTH - 1 : 0];
    assign OUT1 = IN0[OUT0_WIDTH + OUT1_WIDTH - 1 : OUT0_WIDTH];
    assign OUT2 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH];
    assign OUT3 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH];
    assign OUT4 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH];
    assign OUT5 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH + OUT5_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH];
    assign OUT6 = IN0[OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH + OUT5_WIDTH + OUT6_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH + OUT5_WIDTH];
    assign OUT7 = IN0[IN0_WIDTH - 1 : OUT0_WIDTH + OUT1_WIDTH + OUT2_WIDTH + OUT3_WIDTH + OUT4_WIDTH + OUT5_WIDTH + OUT6_WIDTH]; 
  end
  endgenerate

endmodule
