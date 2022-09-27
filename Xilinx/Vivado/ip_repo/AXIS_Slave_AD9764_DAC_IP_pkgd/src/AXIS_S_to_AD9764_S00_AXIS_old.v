`timescale 1 ns / 1 ps

	module AXIS_S_to_AD9764_S00_AXIS #
	(
		parameter integer C_S_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here
		input wire streamEnable,
		input wire testMode,
		output reg [13:0] DAC_data,
		output wire ClockToDAC,
		output wire [1:0] state,

		// AXI Stream Slave interface
		input wire  S_AXIS_ACLK,
		input wire  S_AXIS_ARESETN,
		output wire  S_AXIS_TREADY,
		input wire [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA,
		input wire [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB,
		input wire  S_AXIS_TLAST,
		input wire  S_AXIS_TVALID
	);
	
	//this value is output to the DAC when IDLE. This is zero volts out of DAC.
	localparam DAC_OutputZeroVolts = 14'h1FFF;
	
	// Define the states of state machine
	localparam  IDLE = 2'b00,
	            STORE_TDATA  = 2'b01,
	            PAUSE = 2'b10,
	            TEST = 2'b11;
 
	// State variable
	reg [1:0] myState;
	reg [1:0] myStateDelayed; //this drives the data mux before the DAC output register
	reg [C_S_AXIS_TDATA_WIDTH-1 : 0] tdata;
	reg [13:0] testCounter;  

	assign S_AXIS_TREADY = (myState == STORE_TDATA);
	assign state = myState;
 
	// Control state machine: 
	always @(posedge S_AXIS_ACLK) 
	begin  
	  if (!S_AXIS_ARESETN) 
	      myState <= IDLE;
	  else
	    case (myState)
	      IDLE: 
	           if (testMode)
	               myState <= TEST;
	           else if (streamEnable && S_AXIS_TVALID)
	               myState <= STORE_TDATA;
	           else
	               myState <= IDLE;	               
	      STORE_TDATA:
	           myState <= PAUSE;    //this state stores TDATA the moves to PAUSE
	      PAUSE:
	           if (S_AXIS_TVALID)
	               myState <= STORE_TDATA; //more to store
               else
                    myState <= IDLE;    //data stream done. for now...
	      TEST:
	           if (testMode)
	               myState <= TEST;
	           else
	               myState <= IDLE;
	    endcase
	end
	
//store TDATA in buffer
	always @(posedge S_AXIS_ACLK) 
	begin  
	  if (!S_AXIS_ARESETN) 
	      tdata <= {2'b00, DAC_OutputZeroVolts, 2'b00, DAC_OutputZeroVolts};
	  else
	       if (myState == STORE_TDATA)
	           tdata <= S_AXIS_TDATA;
     end	  

//delay state machine signals one clock to align data muxed into DAC output register
    always@(posedge S_AXIS_ACLK)
	begin  
	  if (!S_AXIS_ARESETN) 
	      myStateDelayed <= IDLE;
	  else
	      myStateDelayed <= myState;
   end
    
//mux and latch data into DAC output register
	always@(posedge S_AXIS_ACLK)
	begin
	  if(!S_AXIS_ARESETN)
	       DAC_data <= DAC_OutputZeroVolts;
	  else
	    case (myStateDelayed)
	      IDLE:
	           DAC_data <= DAC_OutputZeroVolts; 
	      STORE_TDATA:
	           DAC_data <= tdata[13:0];    //first half of stream transfer, only 14 bits
	      PAUSE:
	           DAC_data <= tdata[29:16];   //second half of stream
	      TEST:
	           DAC_data <= testCounter;
	    endcase
	end

//test counter
	always@(posedge S_AXIS_ACLK)
	begin
	  if(!S_AXIS_ARESETN)
	       testCounter <= DAC_OutputZeroVolts;
	  else
	       if (testMode)
	           testCounter <= testCounter + 1; //count continuously and roll over
	       else
	           testCounter <= DAC_OutputZeroVolts;
	 end

   // Clock forwarding circuit using the double data-rate register
   // Aligns DAC Clock to output pin with DAC data
   // Xilinx HDL Language Template, version 2020.1
   ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) clock_forward_inst (
      .Q(ClockToDAC),   // 1-bit DDR output
      .C(S_AXIS_ACLK), // 1-bit clock input
      .CE(1'b1),    // 1-bit clock enable input
      .D1(1'b0), // 1-bit data input (positive edge)
      .D2(1'b1), // 1-bit data input (negative edge)
      .R(1'b0), // 1-bit reset: active high
      .S(1'b0) // 1-bit set: active high
   ); // End of clock_forward_inst instantiation


	endmodule
