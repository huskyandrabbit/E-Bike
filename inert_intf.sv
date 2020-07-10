module inert_intf(incline, vld, SS_n, SCLK, MOSI, MISO, INT, clk, rst_n);
  output logic vld, SS_n, SCLK, MOSI;
  output [12:0] incline;
  input logic clk, rst_n, MISO, INT;

  // internal signals
  logic [15:0] rd_data;
  logic [15:0] cmd;
  logic [15:0] init_cnt;
  logic [7:0] rollL, rollH, yawL, yawH, AYL, AYH, AZL ,AZH;
  logic INT_ff1, INT_ff2, wrt, done;
  logic C_R_H, C_R_L,C_Y_H, C_Y_L, C_AY_H, C_AY_L, C_AZ_H, C_AZ_L; 
  logic [15:0] roll_rt, yaw_rt, AY, AZ;

  typedef enum reg [3:0] {IDLE, WRT1, WRT2, WRT3, WRT4, WAIT, READ1, READ2, READ3, READ4, READ5, READ6, READ7, READ8} state_t;
  state_t state, nxt_state;
  SPI_mstr SPI_mstr16(.done(done), .rd_data(rd_data), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI), .clk(clk), .rst_n(rst_n), .MISO(MISO), .wrt(wrt), .cmd(cmd));
  inertial_integrator ini_int1(.clk(clk), .rst_n(rst_n), .roll_rt(roll_rt), .yaw_rt(yaw_rt), .AY(AY), .AZ(AZ), .vld(vld), .incline(incline));
  
  assign roll_rt = {rollH, rollL};
  assign yaw_rt = {yawH, yawL};
  assign AY = {AYH, AYL};
  assign AZ = {AZH, AZL};
  
  always @(posedge clk, negedge rst_n)begin
    if(~rst_n)init_cnt <= 16'h0000;
    else init_cnt <= init_cnt + 1'b1;
  end

  // double flop INT_ff2
  always @(posedge clk, negedge rst_n) begin
    if(~rst_n)INT_ff1 <= 1'b0;
	else INT_ff1 <= INT; 
  end
  always @(posedge clk, negedge rst_n) begin
    if(~rst_n)INT_ff2 <= 1'b0;
	else INT_ff2 <= INT_ff1;
  end

  // state machine
  always @(posedge clk, negedge rst_n)begin
	if(~rst_n)state <= IDLE;
	else state <= nxt_state;
  end
  
  always @(*)begin
    wrt = 1'b0;
    cmd = 16'h0000;
    C_R_H = 1'b0;
    C_R_L = 1'b0;
    C_Y_H = 1'b0;
    C_Y_L = 1'b0;
    C_AY_H = 1'b0;
    C_AY_L = 1'b0;
    C_AZ_H = 1'b0;
    C_AZ_L = 1'b0;
	vld = 1'b0;
    case(state)
      IDLE: begin
				if(&init_cnt)begin
				  nxt_state = WRT1;
				  wrt = 1'b1;
				  cmd = 16'h0D02;
				end
				else
				  nxt_state = IDLE;
			 end
      WRT1: begin
				
				if(done) begin
				  nxt_state = WRT2;
				  wrt = 1'b1;
				  cmd = 16'h1053;
				end
				else nxt_state = WRT1;
			end
      WRT2: begin
				
				if(done) begin
				  nxt_state = WRT3;
				  wrt = 1'b1;
				  cmd = 16'h1150;
				end
				else nxt_state = WRT2;
		  end
      WRT3: begin
				
				if(done) begin
				  nxt_state = WRT4;
				  wrt = 1'b1;
				  cmd = 16'h1460;
				end
				else nxt_state = WRT3;
		  end
      WRT4: begin
				
				if(done) begin
				  nxt_state = WAIT;
				  wrt = 1'b0;
				end
				else nxt_state = WRT4;
			end
			
      WAIT: begin
				if(INT_ff2)begin
				  nxt_state = READ1;
				  wrt = 1'b1;
				  cmd = 16'ha400;
				end
				else nxt_state = WAIT;
			end
//reading begins			
      READ1: begin
				
				if(done) begin
				  C_R_L = 1'b1;
				  wrt = 1'b1;
				  nxt_state = READ2;
				  cmd = 16'ha500;
				end
				else nxt_state = READ1;
			end
      READ2: begin
				
				if(done) begin
				  wrt = 1'b1;
				  C_R_H = 1'b1;
				  nxt_state = READ3;
				  cmd = 16'ha600;
				end
				else nxt_state = READ2;
			  end
      READ3: begin
				
				if(done) begin
				  wrt = 1'b1;
				  C_Y_L = 1'b1;
				  nxt_state = READ4;
				  cmd = 16'ha700;
				end
				else nxt_state = READ3;
			end
      READ4: begin
				
				if(done) begin
				  wrt = 1'b1;
				  C_Y_H = 1'b1;
				  nxt_state = READ5;
				  cmd = 16'haa00;
				end
				else nxt_state = READ4;
			end
      READ5: begin
				
				if(done) begin
				  wrt = 1'b1;
				  C_AY_L = 1'b1;
				  nxt_state = READ6;
				  cmd = 16'hab00;
				end
				else nxt_state = READ5;
			end
      READ6: begin
				
				if(done) begin
				  wrt = 1'b1;
				  C_AY_H = 1'b1;
				  nxt_state = READ7;
				  cmd = 16'hac00;
				end
				else nxt_state = READ6;
			end
      READ7: begin
				
				if(done) begin
				  wrt = 1'b1;
				  C_AZ_L = 1'b1;
				  nxt_state = READ8;
				  cmd = 16'had00;
				end
				else nxt_state = READ7;
			end
      READ8: begin
				
				if(done) begin
				  wrt = 1'b0;
				  C_AZ_H = 1'b1;
				  nxt_state = WAIT;
				  vld = 1'b1;
				end
				else nxt_state = READ8;
			end
	  default: nxt_state = IDLE;
    endcase
  end
 //holding registers
 //roll
 always @(posedge clk, negedge rst_n)begin
	if(~rst_n)rollL <= 8'h00;
	else if(C_R_L)rollL <= rd_data[7:0];
 end
 
 always @(posedge clk, negedge rst_n)begin
	if(~rst_n)rollH <= 8'h00;
	else if(C_R_H)rollH <= rd_data[7:0];
 end
 //yaw
 always @(posedge clk, negedge rst_n)begin
	if(~rst_n)yawL <= 8'h00;
	else if(C_Y_L)yawL <= rd_data[7:0];
 end
 
 always @(posedge clk, negedge rst_n)begin
	if(~rst_n)yawH <= 8'h00;
	else if(C_Y_H)yawH <= rd_data[7:0];
 end
 //AY
 always @(posedge clk, negedge rst_n)begin
	if(~rst_n)AYL <= 8'h00;
	else if(C_AY_L)AYL <= rd_data[7:0];
 end
 
 always @(posedge clk, negedge rst_n)begin
	if(~rst_n)AYH <= 8'h00;
	else if(C_AY_H)AYH <= rd_data[7:0];
 end
 //AZ
 always @(posedge clk, negedge rst_n)begin
	if(~rst_n)AZL <= 8'h00;
	else if(C_AZ_L)AZL <= rd_data[7:0];
 end
 
 always @(posedge clk, negedge rst_n)begin
	if(~rst_n)AZH <= 8'h00;
	else if(C_AZ_H)AZH <= rd_data[7:0];
 end
 
endmodule