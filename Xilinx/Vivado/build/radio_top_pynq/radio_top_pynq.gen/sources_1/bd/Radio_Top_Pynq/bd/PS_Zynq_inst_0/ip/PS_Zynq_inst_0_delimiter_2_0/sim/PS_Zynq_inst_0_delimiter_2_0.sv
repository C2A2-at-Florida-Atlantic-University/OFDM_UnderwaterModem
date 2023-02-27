// (c) Copyright 1995-2023 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: user.org:user:delimiter:1.0
// IP Revision: 3

`timescale 1ns/1ps

(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module PS_Zynq_inst_0_delimiter_2_0 (
  IN0,
  OUT0,
  OUT1,
  OUT2,
  OUT3,
  OUT4,
  OUT5,
  OUT6,
  OUT7
);

input wire [17 : 0] IN0;
output wire [0 : 0] OUT0;
output wire [0 : 0] OUT1;
output wire [0 : 0] OUT2;
output wire [4 : 0] OUT3;
output wire [0 : 0] OUT4;
output wire [0 : 0] OUT5;
output wire [6 : 0] OUT6;
output wire [0 : 0] OUT7;

  delimiter #(
    .IN0_WIDTH(18),
    .NUM_OUTPUTS(8),
    .OUT0_WIDTH(1),
    .OUT1_WIDTH(1),
    .OUT2_WIDTH(1),
    .OUT3_WIDTH(5),
    .OUT4_WIDTH(1),
    .OUT5_WIDTH(1),
    .OUT6_WIDTH(7),
    .OUT7_WIDTH(1)
  ) inst (
    .IN0(IN0),
    .OUT0(OUT0),
    .OUT1(OUT1),
    .OUT2(OUT2),
    .OUT3(OUT3),
    .OUT4(OUT4),
    .OUT5(OUT5),
    .OUT6(OUT6),
    .OUT7(OUT7)
  );
endmodule
