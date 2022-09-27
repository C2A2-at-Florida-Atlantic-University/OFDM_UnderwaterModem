`timescale 1 ns / 1 ps

	module AD9244_to_AXIS_M #
	(
		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32
	)
	(
		// Users to add ports here
        output wire ClockToADC,
        input wire [14:0] ADCdata, //includes OTR bit from ADC
        input wire [3:0] control,
        output wire [31:0] status,  
        
		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);
	
	assign status[15:3] = 13'b0000000000000;
// Instantiation of Axi Bus Interface M00_AXIS
	AD9244_to_AXIS_M_M00_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH)
	) AD9244_to_AXIS_M_M00_AXIS_inst (
	    .ClockToADC(ClockToADC),
	    .ADCdata(ADCdata),
	    .streamEnable(control[0]),
	    .clearOverRun(control[1]),
	    .clearOTR(control[2]),
	    .testMode(control[3]),
	    .streamStatus(status[0]),
	    .overRunStatus(status[1]), //occurs when tvalid is true but tready is not asserted. Indicates a stream overrun and ADC data is no longer contiguous
	    .adcOTRstatus(status[2]),  //indicates an out-of-range analog input of the ADC input.
	    .overRunCount(status[31:16]),
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready)
	);

	endmodule
