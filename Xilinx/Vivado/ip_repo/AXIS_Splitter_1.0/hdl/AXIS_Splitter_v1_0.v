
`timescale 1 ns / 1 ps

	module AXIS_Splitter_v1_0 #
	(
		parameter integer AXIS_TDATA_WIDTH	= 32,
		parameter integer M_TREADY_ANDED_TVALID = 0
	)
	(
		input wire  axis_aclk,
		
		input wire tready_select,
		
		output wire  s00_axis_tready,
		input wire [AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid,

		output wire  m01_axis_tvalid,
		output wire [AXIS_TDATA_WIDTH-1 : 0] m01_axis_tdata,
		output wire [(AXIS_TDATA_WIDTH/8)-1 : 0] m01_axis_tstrb,
		output wire  m01_axis_tlast,
		input wire  m01_axis_tready,

		output wire  m00_axis_tvalid,
		output wire [AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready
	);

  // Outputs of AXI Masters:
  assign m00_axis_tvalid = M_TREADY_ANDED_TVALID && tready_select ? s00_axis_tvalid && m01_axis_tready : s00_axis_tvalid;
  assign m00_axis_tdata = s00_axis_tdata;
  assign m00_axis_tstrb = s00_axis_tstrb;
  assign m00_axis_tlast = s00_axis_tlast;

  assign m01_axis_tvalid = M_TREADY_ANDED_TVALID && ~tready_select ? s00_axis_tvalid && m00_axis_tready : s00_axis_tvalid;
  assign m01_axis_tdata = s00_axis_tdata;
  assign m01_axis_tstrb = s00_axis_tstrb;
  assign m01_axis_tlast = s00_axis_tlast;

  assign s00_axis_tready = tready_select ? m01_axis_tready : m00_axis_tready;

endmodule