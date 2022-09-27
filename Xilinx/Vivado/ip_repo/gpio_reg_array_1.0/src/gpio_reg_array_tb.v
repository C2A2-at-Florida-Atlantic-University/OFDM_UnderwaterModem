`timescale 1 ns / 1 ps

module gpio_reg_array_tb();

  parameter               c_CLK_DELAY   = 5;
  parameter               c_CLK_PERIOD  = 10;
  
  parameter               BRAM_WIDTH    = 11;

  wire [BRAM_WIDTH-1 : 0] BRAM_addr;
  wire [31 : 0]           BRAM_wrdata;
  reg  [31 : 0]           BRAM_rddata;
  wire                    BRAM_en;
  wire [3 : 0]            BRAM_we;
  wire                    BRAM_Clk;
  wire                    BRAM_rst;
  reg                     BRAM_busy     = 1'b0;

  reg                     r_Clk         = 1'b1;
  reg                     r_nRst        = 1'b0;

  parameter               WIDTH_00      = 32;
  parameter               WIDTH_01      = 32;
  parameter               WIDTH_02      = 32;
  parameter               WIDTH_03      = 32;
  parameter               WIDTH_04      = 32;
  parameter               WIDTH_05      = 32;
  parameter               WIDTH_06      = 32;
  parameter               WIDTH_07      = 32;
  parameter               WIDTH_08      = 32;
  parameter               WIDTH_09      = 32;
  parameter               WIDTH_10      = 32;
  parameter               WIDTH_11      = 32;
  parameter               WIDTH_12      = 32;
  parameter               WIDTH_13      = 32;
  parameter               WIDTH_14      = 32;
  parameter               WIDTH_15      = 32;
  parameter               WIDTH_16      = 32;
  parameter               WIDTH_17      = 32;
  parameter               WIDTH_18      = 32;
  parameter               WIDTH_19      = 32;

  reg  [WIDTH_00-1 : 0]   in00          = 32'hffff_ffff;
  reg  [WIDTH_01-1 : 0]   in01          = 32'heeee_eeee;
  reg  [WIDTH_02-1 : 0]   in02          = 32'hdddd_dddd;
  reg  [WIDTH_03-1 : 0]   in03          = 32'hcccc_cccc;
  reg  [WIDTH_04-1 : 0]   in04          = 32'hbbbb_bbbb;
  reg  [WIDTH_05-1 : 0]   in05          = 32'haaaa_aaaa;
  reg  [WIDTH_06-1 : 0]   in06          = 32'h9999_9999;
  reg  [WIDTH_07-1 : 0]   in07          = 32'h8888_8888;
  reg  [WIDTH_08-1 : 0]   in08          = 32'h7777_7777;
  reg  [WIDTH_09-1 : 0]   in09          = 32'h6666_6666;
  reg  [WIDTH_10-1 : 0]   in10          = 32'h5555_5555;
  reg  [WIDTH_11-1 : 0]   in11          = 32'h4444_4444;
  reg  [WIDTH_12-1 : 0]   in12          = 32'h3333_3333;
  reg  [WIDTH_13-1 : 0]   in13          = 32'h2222_2222;
  reg  [WIDTH_14-1 : 0]   in14          = 32'h1111_1111;
  reg  [WIDTH_15-1 : 0]   in15          = 32'h0000_0000;
  reg  [WIDTH_16-1 : 0]   in16          = 32'h1122_1122;
  reg  [WIDTH_17-1 : 0]   in17          = 32'h3344_3344;
  reg  [WIDTH_18-1 : 0]   in18          = 32'h5566_5566;
  reg  [WIDTH_19-1 : 0]   in19          = 32'h8899_8899;

  wire [WIDTH_00-1 : 0]   out00;
  wire [WIDTH_01-1 : 0]   out01;
  wire [WIDTH_02-1 : 0]   out02;
  wire [WIDTH_03-1 : 0]   out03;
  wire [WIDTH_04-1 : 0]   out04;
  wire [WIDTH_05-1 : 0]   out05;
  wire [WIDTH_06-1 : 0]   out06;
  wire [WIDTH_07-1 : 0]   out07;
  wire [WIDTH_08-1 : 0]   out08;
  wire [WIDTH_09-1 : 0]   out09;
  wire [WIDTH_10-1 : 0]   out10;
  wire [WIDTH_11-1 : 0]   out11;
  wire [WIDTH_12-1 : 0]   out12;
  wire [WIDTH_13-1 : 0]   out13;
  wire [WIDTH_14-1 : 0]   out14;
  wire [WIDTH_15-1 : 0]   out15;
  wire [WIDTH_16-1 : 0]   out16;
  wire [WIDTH_17-1 : 0]   out17;
  wire [WIDTH_18-1 : 0]   out18;
  wire [WIDTH_19-1 : 0]   out19;
 
  gpio_reg_array
    #(
      .NUM_REGS(20),
      .BRAM_WIDTH(BRAM_WIDTH),
      .OUT00_INPUT(1),  .WIDTH_00(WIDTH_00),
      .OUT01_INPUT(0),  .WIDTH_01(WIDTH_01),
      .OUT02_INPUT(0),  .WIDTH_02(WIDTH_02),
      .OUT03_INPUT(0),  .WIDTH_03(WIDTH_03),
      .OUT04_INPUT(0),  .WIDTH_04(WIDTH_04),
      .OUT05_INPUT(0),  .WIDTH_05(WIDTH_05),
      .OUT06_INPUT(0),  .WIDTH_06(WIDTH_06),
      .OUT07_INPUT(0),  .WIDTH_07(WIDTH_07),
      .OUT08_INPUT(0),  .WIDTH_08(WIDTH_08),
      .OUT09_INPUT(0),  .WIDTH_09(WIDTH_09),
      .OUT10_INPUT(1),  .WIDTH_10(WIDTH_10),
      .OUT11_INPUT(0),  .WIDTH_11(WIDTH_11),
      .OUT12_INPUT(0),  .WIDTH_12(WIDTH_12),
      .OUT13_INPUT(0),  .WIDTH_13(WIDTH_13),
      .OUT14_INPUT(0),  .WIDTH_14(WIDTH_14),
      .OUT15_INPUT(0),  .WIDTH_15(WIDTH_15),
      .OUT16_INPUT(0),  .WIDTH_16(WIDTH_16),
      .OUT17_INPUT(0),  .WIDTH_17(WIDTH_17),
      .OUT18_INPUT(0),  .WIDTH_18(WIDTH_18),
      .OUT19_INPUT(0),  .WIDTH_19(WIDTH_19)
    )
  DUT (
    .BRAM_addr(BRAM_addr),    .BRAM_wrdata(BRAM_wrdata),
    .BRAM_rddata(BRAM_rddata),.BRAM_en(BRAM_en),
    .BRAM_we(BRAM_we),        .BRAM_clk(BRAM_Clk),
    .BRAM_rst(BRAM_rst),      .BRAM_busy(BRAM_busy),

    .aclk(r_Clk),             .aresetn(r_nRst),

    .in00(in00), .in01(in01), .in02(in02), .in03(in03),
    .in04(in04), .in05(in05), .in06(in06), .in07(in07),
    .in08(in08), .in09(in09), .in10(in10), .in11(in11),
    .in12(in12), .in13(in13), .in14(in14), .in15(in15),
    .in16(in16), .in17(in17), .in18(in18), .in19(in19),

    .out00(out00), .out01(out01), .out02(out02), .out03(out03),
    .out04(out04), .out05(out05), .out06(out06), .out07(out07),
    .out08(out08), .out09(out09), .out10(out10), .out11(out11),
    .out12(out12), .out13(out13), .out14(out14), .out15(out15),
    .out16(out16), .out17(out17), .out18(out18), .out19(out19)
  );

  assign #c_CLK_DELAY r_Clk = ~r_Clk;

  always begin
    BRAM_rddata       <= 0;
    #(4*c_CLK_PERIOD);
    BRAM_rddata       <= 32'h1111_1111;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'h2222_2222;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'h3333_3333;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'h4444_4444;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'h5555_5555;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'h6666_6666;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'h7777_7777;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'h8888_8888;
    #c_CLK_PERIOD; 
    BRAM_rddata       <= 32'h9999_9999;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'hAAAA_AAAA;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'hBBBB_BBBB;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'hCCCC_CCCC;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'hDDDD_DDDD;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'hEEEE_EEEE;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'hFFFF_FFFF;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'h1122_3344;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'h5566_7788;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'h99aa_bbcc;
    #c_CLK_PERIOD;
    BRAM_rddata       <= 32'h4433_2211;
    #c_CLK_PERIOD;
  end

  initial begin
    #(3*c_CLK_PERIOD);
    r_nRst            <= 1'b1;
    #(10*c_CLK_PERIOD);
    //BRAM_busy         <= 1'b1;
    #(10*c_CLK_PERIOD);
    BRAM_busy         <= 1'b0;
    #(40*c_CLK_PERIOD);
    $stop();
  end

endmodule
