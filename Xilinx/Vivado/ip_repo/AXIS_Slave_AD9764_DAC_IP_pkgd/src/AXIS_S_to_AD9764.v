
`timescale 1 ns / 1 ps

	module AXIS_S_to_AD9764 #
	(
		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32,
    parameter integer C_S00_AXIS_TDATA_START = 0
  )
	(
		// Users to add ports here
        output wire ClockToDAC,
        output wire [13:0] DAC_data,
        output wire DAC_sleep,
        output wire PA_enable,
        output wire [2:0] state,
        //control inputs bit0: stream enable, bit1: PA enable, bit2: DACsleep, bit3: test enable      
        input wire [3:0] control,

		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid
	);

//assign control bits to signals
	assign PA_enable = control[1];
	assign DAC_sleep = control[2];
 	
// Instantiation of Axi Bus Interface S00_AXIS
	AXIS_S_to_AD9764_S00_AXIS # ( 
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH),
	  .C_S_AXIS_TDATA_START(C_S00_AXIS_TDATA_START)
  ) AXIS_S_to_AD9764_S00_AXIS_inst (
	    .streamEnable(control[0]),
	    .testMode(control[3]),
	    .DAC_data(DAC_data),
	    .ClockToDAC(ClockToDAC),
		.S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESETN(s00_axis_aresetn),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TSTRB(s00_axis_tstrb),
		.S_AXIS_TLAST(s00_axis_tlast),
		.S_AXIS_TVALID(s00_axis_tvalid),
		.state(state)
	);


	endmodule

