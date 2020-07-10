
module eBike_tb();

  reg clk,RST_n;
  reg [11:0] BATT;				// analog values you apply to AnalogModel
  reg [11:0] BRAKE,TORQUE;		// analog values
  reg cadence;					// you have to have some way of applying a cadence signal
  reg tgglMd;	
  reg [15:0] YAW_RT;			// models angular rate of incline
  
  wire A2D_SS_n,A2D_MOSI,A2D_SCLK,A2D_MISO;		// A2D SPI interface
  wire highGrn,lowGrn,highYlw;					// FET control
  wire lowYlw,highBlu,lowBlu;					//   PWM signals
  wire hallGrn,hallBlu,hallYlw;					// hall sensor outputs
  wire inertSS_n,inertSCLK,inertMISO,inertMOSI,inertINT;	// Inert sensor SPI bus
  
  wire [1:0] setting;		// drive LEDs on real design
  wire [11:0] curr;			// comes from eBikePhysics back to AnalogModel
  logic [7:0] rx_data;
  logic rdy;
  logic [11:0] cnt;

  
  //////////////////////////////////////////////////
  // Instantiate model of analog input circuitry //
  ////////////////////////////////////////////////
  AnalogModel iANLG(.clk(clk),.rst_n(RST_n),.SS_n(A2D_SS_n),.SCLK(A2D_SCLK),
                    .MISO(A2D_MISO),.MOSI(A2D_MOSI),.BATT(BATT),
		            .CURR(curr),.BRAKE(BRAKE),.TORQUE(TORQUE));

  ////////////////////////////////////////////////////////////////
  // Instantiate model inertial sensor used to measure incline //
  //////////////////////////////////////////////////////////////
  eBikePhysics iPHYS(.clk(clk),.RST_n(RST_n),.SS_n(inertSS_n),.SCLK(inertSCLK),
	             .MISO(inertMISO),.MOSI(inertMOSI),.INT(inertINT),
		     .yaw_rt(YAW_RT),.highGrn(highGrn),.lowGrn(lowGrn),
		     .highYlw(highYlw),.lowYlw(lowYlw),.highBlu(highBlu),
		     .lowBlu(lowBlu),.hallGrn(hallGrn),.hallYlw(hallYlw),
		     .hallBlu(hallBlu),.avg_curr(curr));

  //////////////////////
  // Instantiate DUT //
  ////////////////////
  eBike iDUT(.clk(clk),.RST_n(RST_n),.A2D_SS_n(A2D_SS_n),.A2D_MOSI(A2D_MOSI),
             .A2D_SCLK(A2D_SCLK),.A2D_MISO(A2D_MISO),.hallGrn(hallGrn),
			 .hallYlw(hallYlw),.hallBlu(hallBlu),.highGrn(highGrn),
			 .lowGrn(lowGrn),.highYlw(highYlw),.lowYlw(lowYlw),
			 .highBlu(highBlu),.lowBlu(lowBlu),.inertSS_n(inertSS_n),
			 .inertSCLK(inertSCLK),.inertMOSI(inertMOSI),
			 .inertMISO(inertMISO),.inertINT(inertINT),
			 .cadence(cadence),.tgglMd(tgglMd),.TX(TX),
			 .setting(setting));
	
  ///////////////////////////////////////////////////////////
  // Instantiate Something to monitor telemetry output??? //
  /////////////////////////////////////////////////////////
	UART_rcv iUART(.clk(clk),.rst_n(RST_n),.RX(TX),.rdy(rdy),.rx_data(rx_data),.clr_rdy(rdy));

  initial begin
      RST_n = 0;
	  clk = 0;
	  cadence = 0;
	  tgglMd = 0;
	  YAW_RT = 0;
	  BATT = 0;
	  BRAKE = 0;
	  TORQUE = 0;
	  repeat(50) @(posedge clk);
	  RST_n = 1;
	  YAW_RT = 16'h0;
	  BATT = 12'hBBB;
	  BRAKE = 12'h801;
	  TORQUE = 12'hBCD;
	  tgglMd = 1;
	  repeat(3000000) @(posedge inertINT);
	  BRAKE = 12'h0AA;
	  repeat(3000000) @(posedge inertINT);
	  BRAKE = 12'h8ff;
	  BATT = 12'h888;
  	  TORQUE = 12'h789;
          YAW_RT = 16'h0200;
	  repeat(3000000) @(posedge inertINT);
	  YAW_RT = 16'h8200;
	  repeat(3000000) @(posedge inertINT);
	  $stop;
	
  end
  
  always #10 clk = ~clk;
	
always@(posedge cnt[11]) cadence = ~cadence;

 always@(posedge clk, negedge RST_n) begin
	if(!RST_n)
	    cnt <= 12'b0;
	else
	    cnt <= cnt + 1'b1;
end
	
endmodule
