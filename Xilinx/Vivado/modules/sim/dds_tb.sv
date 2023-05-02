//---------------------------------------------------------------
// Jared Hermans
//---------------------------------------------------------------

`timescale 1 ns / 1 ps

module dds_tb();

  localparam                        CLOCK_PERIOD      = 10; // 100 MHz
  localparam                        CLOCK_CYCLE       = CLOCK_PERIOD/2;

  int                               fd_mix_dds;

  logic [31:0]                      Fc_scaled = 32'd10737418;

  logic [31:0]                      m_tdata;
  logic                             m_tvalid;

  logic                             r_clk;

  logic [15:0]                      dds_i,dds_q;

//---------------------------------------------------------------
// DUT
//---------------------------------------------------------------
  dds_compiler_0 DUT(
    .aclk(r_clk),
    .s_axis_phase_tvalid(1'b1),
    .s_axis_phase_tdata(Fc_scaled),
    .m_axis_data_tvalid(m_tvalid),
    .m_axis_data_tdata(m_tdata)
  );

//---------------------------------------------------------------
// Drive 100M Clock
//---------------------------------------------------------------
  initial begin
    r_clk                           = 1'b1;
    forever begin
      #CLOCK_CYCLE r_clk            = ~r_clk;
    end
  end

//---------------------------------------------------------------
// Record IQ mixer output
//---------------------------------------------------------------
  initial begin
    fd_mix_dds = $fopen("../../../../../../modules/sim/iq_dds.txt","w");
    if (fd_mix_dds) $display("File was opened successfully: %0d ",fd_mix_dds);
    else begin
      $display("File was NOT opened successfully: %0d",fd_mix_dds);
      $stop;
    end

    #(CLOCK_PERIOD*10);

    for (int i = 0; i < 1392640; i++) begin
      dds_i = m_tdata[15:0];
      dds_q = m_tdata[31:16];
      $fdisplay(fd_mix_dds, "%d, %d",$signed(dds_i),$signed(dds_q));
      #CLOCK_PERIOD;
    end

    #(CLOCK_PERIOD*100);
    $fclose(fd_mix_dds);
    $stop;

  end
endmodule
