`timescale 1 ns / 1 ps

	module AD9244_to_AXIS_M_M00_AXIS #
	(
		parameter integer C_M_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here
		output wire ClockToADC,
		input wire [14:0] ADCdata,        //includes OTR bit from ADC
		input wire streamEnable,          //set to enable stream      
		input wire clearOverRun,          //set to clear any overrun errors and reset overrun count          
		input wire clearOTR,              //set to clear OTR detector
		input wire testMode,              //set to enable test mode, data output to stream is a 16-bit counter that increments each clk
		output wire streamStatus,         //'1' when stream is enabled and first data has been pushed out the stream
		output wire overRunStatus,        //'1' indicates overrun has occurred, this means ADC data is not contiguous, problem!
		output wire adcOTRstatus,         //'1' indicated ADC OTR bit has been set at some point
		output wire [15:0] overRunCount,  //number of overrun errors since stream was enabled or last clear
		// AXIS ports
		input wire  M_AXIS_ACLK,
		input wire  M_AXIS_ARESETN,
		output wire  M_AXIS_TVALID,
		output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
		output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
		output wire  M_AXIS_TLAST,
		input wire  M_AXIS_TREADY
	);

wire [14:0] inputData; //14 bits of data + ADC OTR (bit 14)
reg [31:0] testCounter; 
reg [7:0] startupDelayCounter;
reg moduleEnableReg;
reg tValidReg = 1'b0;

reg testModeReg;
reg overRunReg;
reg [15:0] overRunCounter;
reg overRunLatch;
reg adcOTRlatch;

assign M_AXIS_TSTRB = 4'b1111; //all output bytes are always valid
//mux data to output, sign extend ADC data to fill 32 bits
assign M_AXIS_TDATA = (testModeReg) ? testCounter : {{18{inputData[13]}}, inputData[13:0]};
// Edited by jared
//assign M_AXIS_TDATA = (testModeReg) ? testCounter : {{18{0}}, inputData[13:0]};
assign M_AXIS_TVALID = tValidReg;

    //delay startup of module after reset
    always @(posedge M_AXIS_ACLK)
	begin
	  if(!M_AXIS_ARESETN) begin
	       startupDelayCounter <= 0;
	       moduleEnableReg <= 0;
	  end
	  else begin
           startupDelayCounter <= startupDelayCounter + 1;
           if (startupDelayCounter == C_M00_AXIS_START_COUNT)
                moduleEnableReg <= 1;            
           end           
	 end

    //generate TVALID
    always @(posedge M_AXIS_ACLK)
	begin
	  if(!M_AXIS_ARESETN)
	       tValidReg <= 0;
      else begin
           if (!streamEnable) 
                tValidReg <= 0;
           else if (moduleEnableReg)
                tValidReg <= 1;
           end  
	end     
    
  //generate TLAST every 2^16 (65536) transfers if stream is enabled, set streamStatus bit active
  // Edited by Jared
  // Generate TLAST every 2^13 (8192) transfers if stream is enabled
  //reg [12:0] packetCounter;
  reg [15:0] packetCounter;
  reg streamStatusReg;
  always @(posedge M_AXIS_ACLK) begin
	  if(!M_AXIS_ARESETN || !streamEnable) begin
	    packetCounter <= 0;
	    streamStatusReg <= 0;
	  end
    else begin
      if (M_AXIS_TVALID && M_AXIS_TREADY) begin
        packetCounter <= packetCounter + 1;
        streamStatusReg <= 1;                       //streamStatus transistions high after first data word is output to stream after stream is enabled
      end
    end  
	end
	
  //assign M_AXIS_TLAST = (packetCounter == 13'b1_1111_1111_1111) ? 1 : 0;
	assign M_AXIS_TLAST = (packetCounter == 16'hFFFF) ? 1 : 0;
	assign streamStatus = streamStatusReg;    
        
    //detect overrun error which will occur if the ADC data is ready to be picked up
    //by the stream interface (TVALID asserted) but TREADY is not asserted for some reason.
    //This results in non-contiguous data in the stream, i.e. dropped input samples, not good...
    //The condition is latched and must be reset by processor.
	always@(posedge M_AXIS_ACLK)
	begin
	  if(!M_AXIS_ARESETN  || !streamEnable) begin
	       overRunReg <= 0;
	       overRunCounter <= 0;
	  end
	  else if (M_AXIS_TVALID && !M_AXIS_TREADY && streamStatusReg) begin
	           overRunReg <= 1;
	           overRunCounter <= overRunCounter + 1;
	       end
	       else
	           overRunReg <= 0;
	 end
    //latch overrun condition 
    assign overRunStatus = overRunLatch;
    assign overRunCount = overRunCounter;
    
	always@(posedge M_AXIS_ACLK)
	begin
	  if(!M_AXIS_ARESETN || clearOverRun) begin	  
	       overRunLatch <= 0;
//	       overRunCounter <= 0;
	  end
	  else if (overRunLatch)
	           overRunLatch <= 1;
	       else
	           overRunLatch <= overRunReg;
	 end

    //latch ADC OTR condition
    assign adcOTRstatus = adcOTRlatch;
	always@(posedge M_AXIS_ACLK)
	begin
	  if((!M_AXIS_ARESETN) || (clearOTR))
	       adcOTRlatch <= 0;
	  else if (adcOTRstatus)
	           adcOTRlatch <= 1;
	       else
	           adcOTRlatch <= inputData[14];
	 end

    //register testMode
    always @(posedge M_AXIS_ACLK)
	begin
	  if(!M_AXIS_ARESETN)begin
	       testModeReg <= 0;
	  end
      else begin
            testModeReg <= testMode;
      end
    end      
     //testCounter...
	always@(posedge M_AXIS_ACLK)
	begin
	  if(!M_AXIS_ARESETN)
	       testCounter <= 0;
	  else if (testModeReg)
	           testCounter <= testCounter + 1; //count continuously and roll over
	       else
	           testCounter <= 0;
	 end   
    
//IDDR instantation for input registers. This forces the input registers to be in ILOGIC blocks near the input pads to minimize routing delays  
genvar i;
generate
    for (i=0; i < 15; i = i + 1)
    begin:  inputRegisters
       IDDR #(
          .DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                          //    or "SAME_EDGE_PIPELINED" 
          .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
          .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
          .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
       ) IDDR_inst (
          .Q1(inputData[i]), // 1-bit output for positive edge of clock
          .Q2(), // 1-bit output for negative edge of clock
          .C(M_AXIS_ACLK),   // 1-bit clock input
          .CE(1'b1), // 1-bit clock enable input
          .D(ADCdata[i]),   // 1-bit DDR data input
          .R(1'b0),   // 1-bit reset: active high
          .S(1'b0)    // 1-bit set: active high
       );
   end
endgenerate
   
   // Clock forwarding to generate ClockToADC circuit using the double data-rate register. Minimizes routing delays to output pin that drives ADC clock.
   ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) clock_forward_inst (
      .Q(ClockToADC),   // 1-bit DDR output
      .C(M_AXIS_ACLK), // 1-bit clock input
      .CE(1'b1),    // 1-bit clock enable input
      .D1(1'b1), // 1-bit data input (positive edge)
      .D2(1'b0), // 1-bit data input (negative edge)
      .R(1'b0), // 1-bit reset: active high
      .S(1'b0) // 1-bit set: active high
   ); // End of clock_forward_inst instantiation

	endmodule
