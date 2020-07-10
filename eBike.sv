 module eBike(clk,RST_n,A2D_SS_n,A2D_MOSI,A2D_SCLK,
             A2D_MISO,hallGrn,hallYlw,hallBlu,highGrn,
			 lowGrn,highYlw,lowYlw,highBlu,lowBlu,
			 inertSS_n,inertSCLK,inertMOSI,inertMISO,
			 inertINT,cadence,TX,tgglMd,setting);
			 
  input clk;				// 50MHz clk
  input RST_n;				// active low RST_n from push button
  output A2D_SS_n;			// Slave select to A2D on DE0
  output A2D_SCLK;			// SPI clock to A2D on DE0
  output A2D_MOSI;			// serial output to A2D (what channel to read)
  input A2D_MISO;			// serial input from A2D
  input hallGrn;			// hall position input for "Green" phase
  input hallYlw;			// hall position input for "Yellow" phase
  input hallBlu;			// hall position input for "Blue" phase
  output highGrn;			// high side gate drive for "Green" phase
  output lowGrn;			// low side gate drive for "Green" phase
  output highYlw;			// high side gate drive for "Yellow" phase
  output lowYlw;			// low side gate drive for "Yellow" phas
  output highBlu;			// high side gate drive for "Blue" phase
  output lowBlu;			// low side gate drive for "Blue" phase
  output inertSS_n;			// Slave select to inertial (tilt) sensor
  output inertSCLK;			// SCLK signal to inertial (tilt) sensor
  output inertMOSI;			// Serial out to inertial (tilt) sensor  
  input inertMISO;			// Serial in from inertial (tilt) sensor
  input inertINT;			// Alerts when inertial sensor has new reading
  input cadence;			// pulse input from pedal cadence sensor
  input tgglMd;				// used to select setting[1:0] (from PB switch)
  output reg [1:0] setting;	// 11 => easy, 10 => normal, 01 => hard, 00 => off
  output TX;				// serial output of measured batt,curr,torque
  
  ///////////////////////////////////////////////
  // Declare any needed internal signals here //
  /////////////////////////////////////////////
  wire rst_n;									// global reset from reset_synch
  wire not_pedaling;
  wire vld;										//indicate the data from inertial sensor has been ready to be written into registers
  wire brake_n;									//indicates braking when low
  wire [1:0] selGrn, selYlw, selBlu;			//used to control the current direction of three coils
  wire [10:0] duty;								//how long the switch is on to provide current
  wire [11:0] drv_mag;
  wire [11:0] brake, torque, curr, batt_v;
  wire [12:0] incline, error;
  
  ///////// Any needed macros follow /////////
  localparam FAST_SIM = 1'b1;
  localparam LOW_BATT_THRES = 12'ha98;
  
  /////////////////////////////////////
  // Instantiate reset synchronizer //
  ///////////////////////////////////
  rst_synch eBike_rst_synch(.rst_n(rst_n), .RST_n(RST_n), .clk(clk));
  
  ///////////////////////////////////////////////////////
  // Instantiate A2D_intf to read torque & batt level //
  /////////////////////////////////////////////////////
  A2D_intf eBike_A2D_intf(.clk(clk), .rst_n(rst_n), .MISO(A2D_MISO), .batt(batt_v)
	   , .curr(curr), .brake(brake), .torque(torque)
	   , .SS_n(A2D_SS_n), .SCLK(A2D_SCLK), .MOSI(A2D_MOSI));
				 
  ////////////////////////////////////////////////////////////
  // Instantiate SensorCondition block to filter & average //
  // readings and provide cadence_vec, and zero_cadence   //
  // Don't forget to pass FAST_SIM parameter!!           //
  ////////////////////////////////////////////////////////
  sensorCondition #(LOW_BATT_THRES, FAST_SIM) eBike_sensorCondition(.clk(clk), .rst_n(rst_n), .torque(torque)
		   , .cadence(cadence), .curr(curr), .incline(incline), .setting(setting)
		   , .batt(batt_v), .error(error), .not_pedaling(not_pedaling), .TX(TX));

  ///////////////////////////////////////////////////
  // Instantiate PID to determine drive magnitude //
  // Don't forget to pass FAST_SIM parameter!!   //
  ////////////////////////////////////////////////	
  PID #(FAST_SIM) eBike_PID(.clk(clk), .rst_n(rst_n), .error(error), .not_pedaling(not_pedaling), .drv_mag(drv_mag));
  
  ////////////////////////////////////////////////
  // Instantiate brushless DC motor controller //
  //////////////////////////////////////////////
   brushless eBike_brushless(.clk(clk), .drv_mag(drv_mag), .hallGrn(hallGrn), .hallYlw(hallYlw)
   , .hallBlu(hallBlu), .brake_n(brake_n), .duty(duty), .selGrn(selGrn), .selYlw(selYlw), .selBlu(selBlu));

  ///////////////////////////////
  // Instantiate motor driver //
  /////////////////////////////
  mtr_drv eBike_mtr_drv(.clk(clk), .rst_n(rst_n), .duty(duty), .selGrn(selGrn), .selYlw(selYlw)
			 , .selBlu(selBlu), .highGrn(highGrn), .lowGrn(lowGrn)
			 , .highYlw(highYlw), .lowYlw(lowYlw), .highBlu(highBlu), .lowBlu(lowBlu));


  /////////////////////////////////////////////////////////////
  // Instantiate inertial sensor to measure incline (pitch) //
  ///////////////////////////////////////////////////////////
  inert_intf eBike_inert_intf(.incline(incline), .vld(vld), .SS_n(inertSS_n), .SCLK(inertSCLK)
						    , .MOSI(inertMOSI), .MISO(inertMISO), .INT(inertINT), .clk(clk), .rst_n(rst_n));
					
  ////////////////////////////////////////////////////////
  // Instantiate (or infer) tggleMd/setting[1:0] logic //
  //////////////////////////////////////////////////////
  PB_intf eBike_PB_intf(.tgglMd(tgglMd), .rst_n(rst_n), .clk(clk), .setting(setting));
  
  ///////////////////////////////////////////////////////////////////////
  // brake_n should be asserted if brake A2D reading lower than 0x800 //
  /////////////////////////////////////////////////////////////////////
  assign brake_n = brake[11];

endmodule
