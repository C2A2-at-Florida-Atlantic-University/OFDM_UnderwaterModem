`timescale 1ns / 1ps

module justTestMode;

//inputs
reg clock_in;
reg reset;
reg tvalid;
reg [31:0] tdata;
reg [3:0] control;

//outputs
wire ready;
wire [2:0] state;
wire [13:0] DAC_data;
wire ClockToDAC;
wire DAC_sleep;
wire PA_enable;

//uut
AXIS_S_to_AD9764 uutJustTestMode (
        .ClockToDAC(ClockToDAC),
        .DAC_data(DAC_data),
        .DAC_sleep(DAC_sleep),
        .PA_enable(PA_enable),
        .control(control),
		.s00_axis_aclk(clock_in),
		.s00_axis_aresetn(reset),
		.s00_axis_tready(ready),
		.s00_axis_tdata(tdata),
		.s00_axis_tstrb(4'b0000),
		.s00_axis_tlast(1'b0),
		.s00_axis_tvalid(tvalid),
		.state(state)
		);
		
initial begin
    clock_in = 0;
    reset = 0;
    control = 4'b1000;
    tvalid = 0;
    tdata = 32'h00000000;
    end		
always #10 clock_in = ~clock_in; //module is designed to run at 50MHz max, 20ns period

initial
    begin
        #25 reset = 1;                   
    end

endmodule
