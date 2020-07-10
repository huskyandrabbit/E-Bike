module A2D_intf(clk, rst_n, MISO, batt, curr, brake, torque, SS_n, SCLK, MOSI);

input clk, rst_n, MISO;
output reg [11:0] batt, curr, brake, torque;
output SS_n, SCLK;
output MOSI;

wire done;
reg batt_en, curr_en, brake_en, torque_en, wrt, cnv_cmplt;
reg [1:0] chnnl_cnt;
reg [2:0] chnnl;
wire [15:0] rd_data, cmd;
reg [13:0] cnt;

typedef enum reg [1:0] {IDLE, SEND, READ, STORE} state_t;
state_t state, nxt_state;

SPI_mstr A2D_intf_SPI_mstr(.done(done), .rd_data(rd_data), .SS_n(SS_n),
 .SCLK(SCLK), .MOSI(MOSI), .clk(clk), .rst_n(rst_n), .MISO(MISO), .wrt(wrt), .cmd(cmd));

/***********************************************************
*****	 		generate the cmd for SPI_mstr			****
***********************************************************/ 
always @(*) begin
	case(chnnl_cnt)
	2'b00: chnnl = 3'b000;
	2'b01: chnnl = 3'b001;
	2'b10: chnnl = 3'b011;
	2'b11: chnnl = 3'b100;
	endcase
end
assign cmd = {2'b00, chnnl, 11'h000};

/***************************************
*****	 		delay timer			****
***************************************/ 
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)cnt <= 14'h0000;
	else cnt <= cnt + 1;
end

/***************************************
*****	 channel counter			****
***************************************/
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)chnnl_cnt <= 2'b00;
	else if(cnv_cmplt)chnnl_cnt <= chnnl_cnt + 1;
end

/***************************************
*****	 		batt				****
***************************************/
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)batt <= 12'h000;
	else if(batt_en)batt <= rd_data[11:0];
end

/***************************************
*****	 		curr				****
***************************************/
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)curr <= 12'h000;
	else if(curr_en)curr <= rd_data[11:0];
end

/***************************************
*****	 		brake				****
***************************************/
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)brake <= 12'h000;
	else if(brake_en)brake <= rd_data[11:0];
end

/***************************************
*****	 		torque				****
***************************************/
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)torque <= 12'h000;
	else if(torque_en)torque <= rd_data[11:0];
end
/***************************************************************************
*****	 		state machine to control the transaction				****
***************************************************************************/
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)state <= IDLE;
	else state <= nxt_state;
end

always @(*) begin
	wrt = 0;
	cnv_cmplt = 0;
	
	case(state)
	IDLE: begin
		if(&cnt)begin nxt_state = SEND; wrt = 1;end
		else nxt_state = IDLE;end
	SEND: begin
		if(done)begin nxt_state = READ; wrt = 1;end
		else nxt_state = SEND;end
	READ: begin
		if(done)begin  nxt_state = STORE;end
		else nxt_state = READ;end
	STORE: begin
		cnv_cmplt = 1;
		nxt_state = IDLE;end
	default: nxt_state = IDLE;
	endcase

end

/***********************************************************************************************
*****	 		generate the four enable signal for the four holding registers				****
***********************************************************************************************/
always @(*) begin
	if(cnv_cmplt)begin
		if(chnnl_cnt[0])begin
			batt_en = 0; brake_en = 0;
			if(chnnl_cnt[1])begin torque_en = 1; curr_en = 0;end
			else begin torque_en = 0; curr_en = 1;end
		end
		else begin
			torque_en = 0; curr_en = 0;
			if(chnnl_cnt[1])begin batt_en = 0; brake_en = 1;end
			else begin batt_en = 1; brake_en = 0;end
		end
	end
	else begin batt_en = 0; curr_en = 0; brake_en = 0; torque_en = 0;end
end

endmodule