`timescale 1 ns / 1 ps

module fir_reconfig_v1_0 #
  (
    // Parameters of Axi Slave Bus Interface S00_AXIS and AXI Master M00_AXIS
    // Reload Stream
    parameter integer C_00_AXIS_TDATA_WIDTH = 16,

    // Parameters of Axi Master Bus Interface M01_AXIS
    // Config Stream
    parameter integer C_M01_AXIS_TDATA_WIDTH = 8,

    // Coefficient register width
    parameter integer COEFF_SEL_WIDTH = 4
  )
  (
    // AXI Clock and nReset
    input wire  aclk,
    input wire  aresetn,

    // Input register to control config select of FIR Compiler
    input wire [COEFF_SEL_WIDTH-1: 0] coeff_sel,

    // Ports of Axi Slave Bus Interface S00_AXIS
    output wire  s00_axis_tready,
    input wire [C_00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
    input wire  s00_axis_tlast,
    input wire  s00_axis_tvalid,

    // Ports of Axi Master Bus Interface M00_AXIS
    output wire  m00_axis_tvalid,
    output wire [C_00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
    output wire  m00_axis_tlast,
    input wire  m00_axis_tready,

    // Ports of Axi Master Bus Interface M01_AXIS
    output reg  m01_axis_tvalid,
    output reg [C_M01_AXIS_TDATA_WIDTH-1 : 0] m01_axis_tdata,
    input wire  m01_axis_tready
);

  reg  [COEFF_SEL_WIDTH-1 : 0]    r_coeff_sel   = 0;
  reg  [7-COEFF_SEL_WIDTH : 0]    sig           = 0;

  reg  [C_M01_AXIS_TDATA_WIDTH-1 : 0] tdata;
  reg                             tvalid;

  // S00_AXIS is a passthrough to M00_AXIS
  assign s00_axis_tready          = m00_axis_tready;
  assign m00_axis_tvalid          = s00_axis_tvalid;
  assign m00_axis_tdata           = s00_axis_tdata;
  assign m00_axis_tlast           = s00_axis_tlast;

  // Create Config Packet
  always @(posedge aclk, negedge aresetn) begin
    if(!aresetn) begin
      r_coeff_sel                 <= 0;
      tdata                       <= 0;
      tvalid                      <= 0;
    end
    else begin
      if (m00_axis_tready) begin
        // If coeff_sel register changes or reload stream finished 
        // then send config packet
        if (!(r_coeff_sel == coeff_sel) || (s00_axis_tlast)) begin
          tdata                   <= {sig,coeff_sel};
          r_coeff_sel             <= coeff_sel;
          tvalid                  <= 1'b1;
        end
        else begin
          tvalid                  <= 1'b0;
          tdata                   <= 0;
        end
      end
      else begin
        tvalid                    <= 1'b0;
        tdata                     <= 0;
      end
    end
  end

  // Assign AXI-S Config Packet
  always @(posedge aclk) begin
    m01_axis_tvalid               <= tvalid;
    m01_axis_tdata                <= tdata;
  end
  //assign m01_axis_tvalid          = tvalid;
  //assign m01_axis_tdata           = tdata;

endmodule
