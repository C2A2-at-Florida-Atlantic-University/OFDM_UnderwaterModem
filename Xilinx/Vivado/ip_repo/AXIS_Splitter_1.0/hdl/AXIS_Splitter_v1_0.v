
`timescale 1 ns / 1 ps

	module AXIS_Splitter_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  axis_aclk,
		//input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		// Ports of Axi Master Bus Interface M01_AXIS
		//input wire  m01_axis_aclk,
		//input wire  m01_axis_aresetn,
		output wire  m01_axis_tvalid,
		output wire [AXIS_TDATA_WIDTH-1 : 0] m01_axis_tdata,
		output wire [(AXIS_TDATA_WIDTH/8)-1 : 0] m01_axis_tstrb,
		output wire  m01_axis_tlast,
		input wire  m01_axis_tready,

		// Ports of Axi Master Bus Interface M00_AXIS
		//input wire  m00_axis_aclk,
		//input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);

  // Outputs of AXI Masters:
  assign m00_axis_tvalid = s00_axis_tvalid;
  assign m00_axis_tdata = s00_axis_tdata;
  assign m00_axis_tstrb = s00_axis_tstrb;
  assign m00_axis_tlast = s00_axis_tlast;

  assign m01_axis_tvalid = s00_axis_tvalid;
  assign m01_axis_tdata = s00_axis_tdata;
  assign m01_axis_tstrb = s00_axis_tstrb;
  assign m01_axis_tlast = s00_axis_tlast;

  // Outputs of AXI Slave:
  assign s00_axis_tready = m00_axis_tready || m01_axis_tready;

// Instantiation of Axi Bus Interface S00_AXIS
//	AXIS_Splitter_v1_0_S00_AXIS # ( 
//		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
//	) AXIS_Splitter_v1_0_S00_AXIS_inst (
//		.S_AXIS_ACLK(s00_axis_aclk),
//		.S_AXIS_ARESETN(s00_axis_aresetn),
//		.S_AXIS_TREADY(s00_axis_tready),
//		.S_AXIS_TDATA(s00_axis_tdata),
//		.S_AXIS_TSTRB(s00_axis_tstrb),
//		.S_AXIS_TLAST(s00_axis_tlast),
//		.S_AXIS_TVALID(s00_axis_tvalid)
//	);

//// Instantiation of Axi Bus Interface M01_AXIS
//	AXIS_Splitter_v1_0_M01_AXIS # ( 
//		.C_M_AXIS_TDATA_WIDTH(C_M01_AXIS_TDATA_WIDTH),
//		.C_M_START_COUNT(C_M01_AXIS_START_COUNT)
//	) AXIS_Splitter_v1_0_M01_AXIS_inst (
//		.M_AXIS_ACLK(m01_axis_aclk),
//		.M_AXIS_ARESETN(m01_axis_aresetn),
//		.M_AXIS_TVALID(m01_axis_tvalid),
//		.M_AXIS_TDATA(m01_axis_tdata),
//		.M_AXIS_TSTRB(m01_axis_tstrb),
//		.M_AXIS_TLAST(m01_axis_tlast),
//		.M_AXIS_TREADY(m01_axis_tready)
//	);

//// Instantiation of Axi Bus Interface M00_AXIS
//	AXIS_Splitter_v1_0_M00_AXIS # ( 
//		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
//		.C_M_START_COUNT(C_M00_AXIS_START_COUNT)
//	) AXIS_Splitter_v1_0_M00_AXIS_inst (
//		.M_AXIS_ACLK(m00_axis_aclk),
//		.M_AXIS_ARESETN(m00_axis_aresetn),
//		.M_AXIS_TVALID(m00_axis_tvalid),
//		.M_AXIS_TDATA(m00_axis_tdata),
//		.M_AXIS_TSTRB(m00_axis_tstrb),
//		.M_AXIS_TLAST(m00_axis_tlast),
//		.M_AXIS_TREADY(m00_axis_tready)
//	);

	endmodule