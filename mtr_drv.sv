
module mtr_drv( 
		input clk,
		input rst_n,
		input [10:0] duty,
		input [1:0] selGrn,
		input [1:0] selYlw,
		input [1:0] selBlu,
		
		output highGrn,
		output lowGrn,
		output highYlw,
		output lowYlw,
		output highBlu,
		output lowBlu);


reg PWM;
reg GrnH, GrnL, YlwH, YlwL, BluH, BluL;


//Instantiate PWM
PWM11	mDrive (.clk(clk), .rst_n(rst_n), .duty(duty), .PWM_sig(PWM));


//Instantiate three non_overlap modules
nonoverlap mDGrn (.clk(clk), .rst_n(rst_n), .highin(GrnH), .lowin(GrnL), .highout(highGrn), .lowout(lowGrn));
nonoverlap mDYlw (.clk(clk), .rst_n(rst_n), .highin(YlwH), .lowin(YlwL), .highout(highYlw), .lowout(lowYlw));
nonoverlap mDBlu (.clk(clk), .rst_n(rst_n), .highin(BluH), .lowin(BluL), .highout(highBlu), .lowout(lowBlu));

/*always_comb begin
	GrnH = 1'b0;
	GrnL = 1'b0;
	YlwH = 1'b0;
	YlwL = 1'b0;
	BluH = 1'b0;
	BluL = 1'b0;

	//Green High and Low Muxes
	case(selGrn)
		2'b00:	begin
			GrnH = 1'b0;
			GrnL = 1'b0;
			end
		2'b01:	begin
			GrnH = ~PWM;
			GrnL = PWM;
			end
		2'b10:	begin
			GrnH = PWM;
			GrnL = ~PWM;
			end
		2'b11:	begin
			GrnH = 1'b0;
			GrnL = PWM;
			end
	endcase

	//Yellow High and Low Muxes
	case(selYlw)
		2'b00:	begin
			YlwH = 1'b0;
			YlwL = 1'b0;
			end
		2'b01:	begin
			YlwH = ~PWM;
			YlwL = PWM;
			end
		2'b10:	begin
			YlwH = PWM;
			YlwL = ~PWM;
			end
		2'b11:	begin
			YlwH = 1'b0;
			YlwL = PWM;
			end
	endcase

	//Blue High and Low Muxes
	case(selBlu)
		2'b00:	begin
			BluH = 1'b0;
			BluL = 1'b0;
			end
		2'b01:	begin
			BluH = ~PWM;
			BluL = PWM;
			end
		2'b10:	begin
			BluH = PWM;
			BluL = ~PWM;
			end
		2'b11:	begin
			BluH = 1'b0;
			BluL = PWM;
			end
	endcase
end
**/
always_comb begin
	//Green High and Low Muxes
	case(selGrn)
		2'b00:	begin
			GrnH = 1'b0;
			GrnL = 1'b0;
			end
		2'b01:	begin
			GrnH = ~PWM;
			GrnL = PWM;
			end
		2'b10:	begin
			GrnH = PWM;
			GrnL = ~PWM;
			end
		2'b11:	begin
			GrnH = 1'b0;
			GrnL = PWM;
			end
	endcase
end

always_comb begin
	//Yellow High and Low Muxes
	case(selYlw)
		2'b00:	begin
			YlwH = 1'b0;
			YlwL = 1'b0;
			end
		2'b01:	begin
			YlwH = ~PWM;
			YlwL = PWM;
			end
		2'b10:	begin
			YlwH = PWM;
			YlwL = ~PWM;
			end
		2'b11:	begin
			YlwH = 1'b0;
			YlwL = PWM;
			end
	endcase
end

always_comb begin
	//Blue High and Low Muxes
	case(selBlu)
		2'b00:	begin
			BluH = 1'b0;
			BluL = 1'b0;
			end
		2'b01:	begin
			BluH = ~PWM;
			BluL = PWM;
			end
		2'b10:	begin
			BluH = PWM;
			BluL = ~PWM;
			end
		2'b11:	begin
			BluH = 1'b0;
			BluL = PWM;
			end
	endcase
end

endmodule
