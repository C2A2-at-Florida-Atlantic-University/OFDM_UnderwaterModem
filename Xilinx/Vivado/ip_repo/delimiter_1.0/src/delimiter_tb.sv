`timescale 1 ns / 1 ps

module delimiter_tb();

  parameter                       IN0_WIDTH       = 32;
  parameter                       NUM_OUTPUTS     = 4;
  parameter                       OUT0_WIDTH      = 4;
  parameter                       OUT1_WIDTH      = 4;
  parameter                       OUT2_WIDTH      = 4;
  parameter                       OUT3_WIDTH      = 4;
  parameter                       OUT4_WIDTH      = 1;
  parameter                       OUT5_WIDTH      = 1;
  parameter                       OUT6_WIDTH      = 1;
  parameter                       OUT7_WIDTH      = 1;
  
  logic [IN0_WIDTH - 1 : 0]       IN0             = 32'h11223344;
  logic [OUT0_WIDTH - 1 : 0]      OUT0;
  logic [OUT1_WIDTH - 1 : 0]      OUT1;
  logic [OUT2_WIDTH - 1 : 0]      OUT2;
  logic [OUT3_WIDTH - 1 : 0]      OUT3;
  logic [OUT4_WIDTH - 1 : 0]      OUT4;
  logic [OUT5_WIDTH - 1 : 0]      OUT5;
  logic [OUT6_WIDTH - 1 : 0]      OUT6;
  logic [OUT7_WIDTH - 1 : 0]      OUT7;
  
  delimiter 
    #(
      .IN0_WIDTH(IN0_WIDTH),
      .NUM_OUTPUTS(NUM_OUTPUTS),
      .OUT0_WIDTH(OUT0_WIDTH),
      .OUT1_WIDTH(OUT1_WIDTH),
      .OUT2_WIDTH(OUT2_WIDTH),
      .OUT3_WIDTH(OUT3_WIDTH),
      .OUT4_WIDTH(OUT4_WIDTH),
      .OUT5_WIDTH(OUT5_WIDTH),
      .OUT6_WIDTH(OUT6_WIDTH),
      .OUT7_WIDTH(OUT7_WIDTH)
    ) DUT
    (
      .IN0(IN0),
      .OUT0(OUT0),
      .OUT1(OUT1),
      .OUT2(OUT2),
      .OUT3(OUT3),
      .OUT4(OUT4),
      .OUT5(OUT5),
      .OUT6(OUT6),
      .OUT7(OUT7)
    );
      
  initial begin
    #10;
    $stop;
  end

endmodule
