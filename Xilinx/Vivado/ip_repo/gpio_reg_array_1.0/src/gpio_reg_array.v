module gpio_reg_array (
  BRAM_addr, BRAM_wrdata, BRAM_rddata, BRAM_en, BRAM_we, BRAM_clk, BRAM_rst, BRAM_busy,

  aclk,
  aresetn,

  in00, in01, in02, in03, in04, in05, in06, in07, in08, in09,
  in10, in11, in12, in13, in14, in15, in16, in17, in18, in19,

  out00, out01, out02, out03, out04, out05, out06, out07, out08, out09,
  out10, out11, out12, out13, out14, out15, out16, out17, out18, out19
);

  parameter NUM_REGS        = 20;
  parameter BRAM_WIDTH      = 11;

  output [BRAM_WIDTH-1 : 0] BRAM_addr;
  output [31 : 0]           BRAM_wrdata;
  input  [31 : 0]           BRAM_rddata;
  output                    BRAM_en;
  output [3 : 0]            BRAM_we;
  output                    BRAM_clk;
  output                    BRAM_rst;
  input                     BRAM_busy;

  input                     aclk;
  input                     aresetn;

  parameter OUT00_INPUT     = 0;
  parameter WIDTH_00        = 32;
  output [WIDTH_00-1 : 0]   out00;
  input  [WIDTH_00-1 : 0]   in00;
  
  parameter OUT01_INPUT     = 0;
  parameter WIDTH_01        = 32;
  output [WIDTH_01-1 : 0]   out01;
  input  [WIDTH_01-1 : 0]   in01;
   
  parameter OUT02_INPUT     = 0;
  parameter WIDTH_02        = 32;
  output [WIDTH_02-1 : 0]   out02;
  input  [WIDTH_02-1 : 0]   in02;
 
  parameter OUT03_INPUT     = 0;
  parameter WIDTH_03        = 32;
  output [WIDTH_03-1 : 0]   out03;
  input  [WIDTH_03-1 : 0]   in03;
 
  parameter OUT04_INPUT     = 0;
  parameter WIDTH_04        = 32;
  output [WIDTH_04-1 : 0]   out04;
  input  [WIDTH_04-1 : 0]   in04;
 
  parameter OUT05_INPUT     = 0;
  parameter WIDTH_05        = 32;
  output [WIDTH_05-1 : 0]   out05;
  input  [WIDTH_05-1 : 0]   in05;
 
  parameter OUT06_INPUT     = 0;
  parameter WIDTH_06        = 32;
  output [WIDTH_06-1 : 0]   out06;
  input  [WIDTH_06-1 : 0]   in06;
  
  parameter OUT07_INPUT     = 0;
  parameter WIDTH_07        = 32;
  output [WIDTH_07-1 : 0]   out07;
  input  [WIDTH_07-1 : 0]   in07;
  
  parameter OUT08_INPUT     = 0;
  parameter WIDTH_08        = 32;
  output [WIDTH_08-1 : 0]   out08;
  input  [WIDTH_08-1 : 0]   in08;
  
  parameter OUT09_INPUT     = 0;
  parameter WIDTH_09        = 32;
  output [WIDTH_09-1 : 0]   out09;
  input  [WIDTH_09-1 : 0]   in09;
  
  parameter OUT10_INPUT     = 0;
  parameter WIDTH_10        = 32;
  output [WIDTH_10-1 : 0]   out10;
  input  [WIDTH_10-1 : 0]   in10;
   
  parameter OUT11_INPUT     = 0;
  parameter WIDTH_11        = 32;
  output [WIDTH_11-1 : 0]   out11;
  input  [WIDTH_11-1 : 0]   in11;
   
  parameter OUT12_INPUT     = 0;
  parameter WIDTH_12        = 32;
  output [WIDTH_12-1 : 0]   out12;
  input  [WIDTH_12-1 : 0]   in12;
   
  parameter OUT13_INPUT     = 0;
  parameter WIDTH_13        = 32;
  output [WIDTH_13-1 : 0]   out13;
  input  [WIDTH_13-1 : 0]   in13;
   
  parameter OUT14_INPUT     = 0;
  parameter WIDTH_14        = 32;
  output [WIDTH_14-1 : 0]   out14;
  input  [WIDTH_14-1 : 0]   in14;
   
  parameter OUT15_INPUT     = 0;
  parameter WIDTH_15        = 32;
  output [WIDTH_15-1 : 0]   out15;
  input  [WIDTH_15-1 : 0]   in15;
   
  parameter OUT16_INPUT     = 0;
  parameter WIDTH_16        = 32;
  output [WIDTH_16-1 : 0]   out16;
  input  [WIDTH_16-1 : 0]   in16;
   
  parameter OUT17_INPUT     = 0;
  parameter WIDTH_17        = 32;
  output [WIDTH_17-1 : 0]   out17;
  input  [WIDTH_17-1 : 0]   in17;
    
  parameter OUT18_INPUT     = 0;
  parameter WIDTH_18        = 32;
  output [WIDTH_18-1 : 0]   out18;
  input  [WIDTH_18-1 : 0]   in18;
    
  parameter OUT19_INPUT     = 0;
  parameter WIDTH_19        = 32;
  output [WIDTH_19-1 : 0]   out19;
  input  [WIDTH_19-1 : 0]   in19;

  reg    [7 : 0]            r_BRAM_Counter    = 8'h00;
  reg    [31 : 0]           r_BRAM_wrdata;
  reg    [3 : 0]            r_BRAM_we;
  reg                       r_BRAM_en;

  reg    [31 : 0]           r_in    [NUM_REGS-1 : 0];
  
  reg [31 : 0] r_out        [NUM_REGS-1 : 0];
  
  integer                   i                 = 0;

  localparam                INPUT_ARRAY       =
  {OUT19_INPUT[0],OUT18_INPUT[0],OUT17_INPUT[0],OUT16_INPUT[0],
   OUT15_INPUT[0],OUT14_INPUT[0],OUT13_INPUT[0],OUT12_INPUT[0],
   OUT11_INPUT[0],OUT10_INPUT[0],OUT09_INPUT[0],OUT08_INPUT[0],
   OUT07_INPUT[0],OUT06_INPUT[0],OUT05_INPUT[0],OUT04_INPUT[0],
   OUT03_INPUT[0],OUT02_INPUT[0],OUT01_INPUT[0],OUT00_INPUT[0]};

  reg                       Flag              = 1'b0;
  reg                       r_Flag;
  reg  [1 : 0]              r_Delay_Counter   = 0;

/////////////////////////////////////////////////////////
// Process to initialize array
////////////////////////////////////////////////////////
  always @* begin
    r_in[0]                   = in00;
    r_in[1]                   = in01;
    if (NUM_REGS > 2)
      r_in[2]                 = in02;
    if (NUM_REGS > 3)
      r_in[3]                 = in03;
    if (NUM_REGS > 4)
      r_in[4]                 = in04;
    if (NUM_REGS > 5)
      r_in[5]                 = in05;
    if (NUM_REGS > 6)
      r_in[6]                 = in06;
    if (NUM_REGS > 7)
      r_in[7]                 = in07;
    if (NUM_REGS > 8)
      r_in[8]                 = in08;
    if (NUM_REGS > 9)
      r_in[9]                 = in09;
    if (NUM_REGS > 10)
      r_in[10]                = in10;
    if (NUM_REGS > 11)
      r_in[11]                = in11;
    if (NUM_REGS > 12)
      r_in[12]                = in12;
    if (NUM_REGS > 13)
      r_in[13]                = in13;
    if (NUM_REGS > 14)
      r_in[14]                = in14;
    if (NUM_REGS > 15)
      r_in[15]                = in15;
    if (NUM_REGS > 16)
      r_in[16]                = in16;
    if (NUM_REGS > 17)
      r_in[17]                = in17;
    if (NUM_REGS > 18)
      r_in[18]                = in18;
    if (NUM_REGS > 19)
      r_in[19]                = in19;
  end

/////////////////////////////////////////////////////////
// Process to generate a BRAM address counter which
// counts all registers
////////////////////////////////////////////////////////
  always @(posedge aclk) begin
    if (~aresetn) begin
      r_BRAM_Counter              <= 8'h00;
    end
    else begin
      if (~BRAM_busy) begin
        if (r_Delay_Counter == 3) begin
          Flag                    <= 1'b0;
          r_Delay_Counter         <= 0;
          if (r_BRAM_Counter == NUM_REGS-1) begin
            r_BRAM_Counter        <= 8'h00;
          end
          else
            r_BRAM_Counter        <= r_BRAM_Counter + 1'b1;
        end
        else begin
          r_Delay_Counter         <= r_Delay_Counter + 1'b1;
          Flag                    <= 1'b1;
        end
      end
      else
        r_BRAM_Counter            <= 1;
    end
  end

  assign BRAM_clk                 = aclk;
  assign BRAM_rst                 = ~aresetn;
  assign BRAM_addr                = (r_BRAM_Counter == 0) ? NUM_REGS-1 : r_BRAM_Counter - 1'b1;

/////////////////////////////////////////////////////////
// Delay Flag 1 clock cycle
////////////////////////////////////////////////////////
  always @(posedge aclk)
    r_Flag                        <= Flag;

/////////////////////////////////////////////////////////
// Process to read from BRAM
////////////////////////////////////////////////////////
  always @(posedge aclk) begin
    if (~aresetn) begin
      for (i = 0; i < NUM_REGS; i = i + 1)
        r_out[i]              <= 32'h0000_0000;
    end
    else begin
      if (~BRAM_busy && ~r_Flag) begin
        if (~(INPUT_ARRAY[BRAM_addr]))
          r_out[BRAM_addr]        <= BRAM_rddata;
      end
    end
  end

/////////////////////////////////////////////////////////
// Process to write to BRAM
////////////////////////////////////////////////////////
  always @* begin
    if (BRAM_en) begin 
      if (INPUT_ARRAY[BRAM_addr]) begin
        r_BRAM_we                   <= 4'hF;
        r_BRAM_wrdata               <= r_in[BRAM_addr];
      end
      else begin
        r_BRAM_we                   <= 4'h0;
        r_BRAM_wrdata               <= 0;
      end
    end
    else begin
      r_BRAM_we                     <= 4'h0;
      r_BRAM_wrdata                 <= 0;
    end
  end

/////////////////////////////////////////////////////////
// Generate BRAM enable
////////////////////////////////////////////////////////
  always @(posedge aclk)
    r_BRAM_en                     <= ~BRAM_busy & aresetn;

  assign BRAM_en                  = r_BRAM_en && ~Flag;

/////////////////////////////////////////////////////////
// Synthesis use only
////////////////////////////////////////////////////////
  // translate_off
  always @(posedge aclk) begin
    //$display("INPUT_ARRAY[%d] = %d", r_BRAM_Counter, INPUT_ARRAY[r_BRAM_Counter]);
    $display("r_out[%d] = %X", r_BRAM_Counter, r_out[r_BRAM_Counter]);
    $display("w_in[%d] = %X", r_BRAM_Counter, r_in[r_BRAM_Counter]);
  end
  // translate_on

  assign BRAM_we            = r_BRAM_we;
  assign BRAM_wrdata        = r_BRAM_wrdata;

  assign out00              = r_out[0];
  assign out01              = r_out[1];
  assign out02              = r_out[2];
  assign out03              = r_out[3];
  assign out04              = r_out[4];
  assign out05              = r_out[5];
  assign out06              = r_out[6];
  assign out07              = r_out[7];
  assign out08              = r_out[8];
  assign out09              = r_out[9];
  assign out10              = r_out[10];
  assign out11              = r_out[11];
  assign out12              = r_out[12];
  assign out13              = r_out[13];
  assign out14              = r_out[14];
  assign out15              = r_out[15];
  assign out16              = r_out[16];
  assign out17              = r_out[17];
  assign out18              = r_out[18];
  assign out19              = r_out[19];
 
endmodule
