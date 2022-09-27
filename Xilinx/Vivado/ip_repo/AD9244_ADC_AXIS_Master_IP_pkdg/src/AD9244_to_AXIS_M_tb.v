`timescale 1ns / 1ps

module testbench;

//inputs
reg clock;
reg reset;
reg [14:0] ADCdata;
reg [3:0] control;
reg tready;

//outputs
wire ADCclock;
wire [31:0] tdata;
wire tvalid;
wire tlast;
wire [3:0] tstrb;
wire [31:0] status;


//uut

AD9244_to_AXIS_M uut (
        .ClockToADC(),
        .ADCdata(),
        .control(),
        .status(),  
		.m00_axis_aclk(),
		.m00_axis_aresetn(),
		.m00_axis_tvalid(),
		.m00_axis_tdata(),
		.m00_axis_tstrb(),
		.m00_axis_tlast(),
		.m00_axis_tready()
	);


endmodule

`timescale 1ns / 1ps

module testbench;

//inputs
reg clock;
reg reset;
reg [14:0] ADCdata;
reg [3:0] control;
reg tready;

//outputs
wire ADCclock;
wire [31:0] tdata;
wire tvalid;
wire tlast;
wire [3:0] tstrb;
wire [31:0] status;


//uut

AD9244_to_AXIS_M uut (
        .ClockToADC(ADCclock),
        .ADCdata(ADCdata),
        .control(control),
        .status(status),  
		.m00_axis_aclk(clock),
		.m00_axis_aresetn(reset),
		.m00_axis_tvalid(tvalid),
		.m00_axis_tdata(tdata),
		.m00_axis_tstrb(tstrb),
		.m00_axis_tlast(tlast),
		.m00_axis_tready(tready)
	);

initial begin
    clock = 0;
    reset = 0;
    ADCdata = 0;
    control = 4'b0000;
    tready = 0;
end

always #12.5 clock = ~clock;

always @(posedge ADCclock)
begin
    #10
    ADCdata <= ADCdata + 1;
end


initial begin 
    #40 reset = 1;
    #20 control[3] = 0;
    #20 control[0] = 1;
    #1000 tready = 1;
    #1000 tready = 0;
    #200 tready = 1;
end


endmodule

