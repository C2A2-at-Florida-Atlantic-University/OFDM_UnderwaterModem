`timescale 1 ns / 1 ps

module fir_reconfig_v1_0_tb();

  localparam    C_CLOCK_PERIOD  = 10;
  reg           r_nRst          = 1'b0;
  reg           r_Clk           = 1'b1;
 
  reg  [3 : 0]  coeff_sel       = 4'b0010;

  reg           m00_tvalid      = 1'b0;
  reg  [15 : 0] m00_tdata       = 0;
  reg           m00_tlast       = 1'b0;
  wire          m00_tready;

  reg           s00_tready      = 1'b1;
  wire [15 : 0] s00_tdata;
  wire          s00_tvalid;
  wire          s00_tlast;

  reg           s01_tready      = 1'b1;
  wire [7 : 0]  s01_tdata;
  wire          s01_tvalid;

  fir_reconfig_v1_0 
    #(
      .C_00_AXIS_TDATA_WIDTH(16),
      .C_M01_AXIS_TDATA_WIDTH(8),
      .COEFF_SEL_WIDTH(4)
    )
  DUT
    (
      .aclk(r_Clk),
      .aresetn(r_nRst),
      
      .coeff_sel(coeff_sel),
      
      .s00_axis_tready(m00_tready),
      .s00_axis_tdata(m00_tdata),
      .s00_axis_tlast(m00_tlast),
      .s00_axis_tvalid(m00_tvalid),
      
      .m00_axis_tvalid(s00_tvalid),
      .m00_axis_tdata(s00_tdata),
      .m00_axis_tlast(s00_tlast),
      .m00_axis_tready(s00_tready),

      .m01_axis_tvalid(s01_tvalid),
      .m01_axis_tdata(s01_tdata),
      .m01_axis_tready(s01_tready)
    );


  always #(C_CLOCK_PERIOD/2) r_Clk <= !r_Clk;

  initial begin
    #(2*C_CLOCK_PERIOD);
    r_nRst              <= 1'b1;
    #(2*C_CLOCK_PERIOD);
    m00_tvalid          <= 1'b1;
    m00_tdata           <= 32'h1111;
    #C_CLOCK_PERIOD;
    m00_tdata           <= 32'h2222;
    #C_CLOCK_PERIOD;
    m00_tdata           <= 32'h3333;
    #C_CLOCK_PERIOD;
    m00_tdata           <= 32'h4444;
    m00_tlast           <= 1'b1;
    #C_CLOCK_PERIOD;
    m00_tdata           <= 0;
    m00_tlast           <= 1'b0;
    m00_tvalid          <= 1'b0;
    #(5*C_CLOCK_PERIOD);
    $finish;
  end
endmodule
