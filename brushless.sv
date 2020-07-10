module brushless(
	input clk,	//50MHz Clock
	input [11:0] drv_mag,//From PID Control. Unsigned motor assist
	//Raw hall effect sensors (asynch)
	input hallGrn,	
	input hallYlw,
	input hallBlu,
	input brake_n,	//If low activated regenerative braking at 75% duty cycle.
	
	output [10:0] duty,
	//2-bit vectors directing how mtr_drv should drive the FETs
	output reg[1:0] selGrn,
	output reg[1:0] selYlw,
	output reg[1:0] selBlu);
	/*
	00 - HIGH
	01 - rev_curr
	10 - forward_curr
	11 - regen_braking
	*/

typedef enum  {HighZ, rev_curr, for_curr, reg_brk} select_states [1:0];

		
reg 	[2:0] rotation_state_stable, rotation_state;	
//reg [2:0]rotation_state;

//Stabilize the asynch inputs from Hall Effect Sensors and save to rotation state.
always @(posedge clk) begin
	rotation_state_stable <= {hallGrn, hallYlw, hallBlu};
	rotation_state <= rotation_state_stable;
	end
/**always@(posedge clk) begin
	rotation_state <= {hallGrn, hallYlw, hallBlu};
end**/

//Set the value of duty as a dataflow function of drv_mag depending on the braking state.
assign duty = brake_n ? (11'h400 + drv_mag[11:2]) :  11'h600 ;

// Set the output for selGrn, selYlw, selBlue based on the input value for rotation state.
always_comb 
	if (~brake_n) begin
		selGrn = reg_brk;
		selYlw = reg_brk;
		selBlu = reg_brk;
		end		
	else  
		case(rotation_state) 
				3'b101: begin
						selGrn = for_curr;
						selYlw = rev_curr;
						selBlu = HighZ;
					end
				3'b100: begin
						selGrn = for_curr;
						selYlw = HighZ;
						selBlu = rev_curr;
					end
				3'b110: begin
						selGrn = HighZ;
						selYlw = for_curr;
						selBlu = rev_curr;
					end
				3'b010: begin
						selGrn = rev_curr;
						selYlw = for_curr;
						selBlu = HighZ;
					end
				3'b011: begin
						selGrn = rev_curr;
						selYlw = HighZ;
						selBlu = for_curr;
					end
				3'b001: begin
						selGrn = HighZ;
						selYlw = rev_curr;
						selBlu = for_curr;
					end

				default: begin
						selGrn = HighZ;
						selYlw = HighZ;
						selBlu = HighZ;
					end
		endcase

endmodule

/**module brushless(
	input clk,	//50MHz Clock
	input [11:0] drv_mag,//From PID Control. Unsigned motor assist
	//Raw hall effect sensors (asynch)
	input hallGrn,	
	input hallYlw,
	input hallBlu,
	input brake_n,	//If low activated regenerative braking at 75% duty cycle.
	
	output [10:0] duty,
	//2-bit vectors directing how mtr_drv should drive the FETs
	output reg[1:0] selGrn,
	output reg[1:0] selYlw,
	output reg[1:0] selBlu);
	/*
	00 - HIGH
	01 - rev_curr
	10 - forward_curr
	11 - regen_braking
	*/
//reg [2:0]rotation_state;

/**typedef enum  {HighZ, rev_curr, for_curr, reg_brk} select_states [1:0];

		
//reg 	[2:0] rotation_state_stable, rotation_state;	

//Stabilize the asynch inputs from Hall Effect Sensors and save to rotation state.
/**always @(posedge clk) begin
	rotation_state_stable <= {hallGrn, hallYlw, hallBlu};
	rotation_state <= rotation_state_stable;
	end**/
/**always@(posedge clk) begin
	rotation_state <= {hallGrn, hallYlw, hallBlu};
end

//Set the value of duty as a dataflow function of drv_mag depending on the braking state.
assign duty = brake_n ? (11'h400 + drv_mag[11:2]) :  11'h600 ;

// Set the output for selGrn, selYlw, selBlue based on the input value for rotation state.
always_comb 
	if (~brake_n) begin
		selGrn = 2'b11;
		selYlw = 2'b11;
		selBlu = 2'b11;
		end		
	else  
		case(rotation_state) 
				3'b101: begin
						selGrn = 2'b10;
						selYlw = 2'b01;
						selBlu = 2'b00;
					end
				3'b100: begin
						selGrn = 2'b10;
						selYlw = 2'b00;
						selBlu = 2'b01;
					end
				3'b110: begin
						selGrn = 2'b00;
						selYlw = 2'b10;
						selBlu = 2'b01;
					end
				3'b010: begin
						selGrn = 2'b01;
						selYlw = 2'b00;
						selBlu = 2'b10;
					end
				3'b011: begin
						selGrn = 2'b01;
						selYlw = 2'b00;
						selBlu = 2'b10;
					end
				3'b001: begin
						selGrn = 2'b00;
						selYlw = 2'b01;
						selBlu = 2'b10;
					end

				default: begin
						selGrn = 2'b00;
						selYlw = 2'b00;
						selBlu = 2'b00;
					end
		endcase

endmodule
**/




































