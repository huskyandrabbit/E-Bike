module telemetry(TX, batt_v, avg_curr, avg_torque, clk, rst_n );

input [11:0] batt_v, avg_curr, avg_torque;
input clk, rst_n;
output TX;

typedef enum reg {IDLE, TRMT} state_t;
state_t state, nxt_state;

//internal signals
reg [7:0] tx_data;
reg trmt,  tx_done, cntr_enable;
reg [19:0] time_cntr;	//record the time elapsed when transmission begins
reg [2:0] cntr;	//record how many bytes has been sent

//instantiate module UART_tx for serial transmission
UART_tx UART_Transmitter(.clk(clk),.rst_n(rst_n),.TX(TX),.trmt(trmt),.tx_data(tx_data),.tx_done(tx_done));

//3-bit counter
always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	cntr <= 3'b000;
    else if(cntr_enable)
	cntr <= cntr + 1;
end

//time recording from 20'b00000 at the beginning of the transmission
always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	time_cntr <= 20'h00000;
    else 
	time_cntr <= time_cntr + 1;
end

//state machine
always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	state <= IDLE;
    else 
	state <= nxt_state;
end

always_comb begin
	cntr_enable = 0;
	trmt = 0;
	tx_data = 8'h00;

	case(state)

		IDLE: begin 
			if(~(|time_cntr))begin 
				nxt_state = TRMT; 
				trmt = 1;
			        tx_data = 8'haa;
			end
			else begin
				 nxt_state = IDLE; 
				 tx_data = 8'h00;
			end 
		      end

		TRMT: begin
			if(tx_done & (cntr == 3'b000))begin 
			    nxt_state = TRMT; 
		            trmt = 1; 
			    cntr_enable = 1; 
			    tx_data = 8'h55;
			end

			if(tx_done &(cntr == 3'b001))begin 
			    nxt_state = TRMT; 
			    trmt = 1; 
			    cntr_enable = 1; 
			    tx_data = {4'b0, batt_v[11:8]};
			end

			if(tx_done &(cntr == 3'b010))begin 
			    nxt_state = TRMT; 
		    	    trmt = 1; 
			    cntr_enable = 1; 
			    tx_data = batt_v[7:0];
			end

			if(tx_done &(cntr == 3'b011))begin 
			    nxt_state = TRMT; 
			    trmt = 1; 
			    cntr_enable = 1; 
			    tx_data = {4'b0, avg_curr[11:8]};
			end
			
			if(tx_done &(cntr == 3'b100))begin 
			    nxt_state = TRMT; 
			    trmt = 1; 
			    cntr_enable = 1; 
	   	   	    tx_data = avg_curr[7:0];
			end

			if(tx_done &(cntr == 3'b101))begin
			     nxt_state = TRMT;
			     trmt = 1; 
			     cntr_enable = 1; 
			     tx_data = {4'b0, avg_torque[11:8]};
			end

			if(tx_done &(cntr == 3'b110))begin 
			    nxt_state = TRMT; trmt = 1; cntr_enable = 1; tx_data =avg_torque[7:0];end
			if(tx_done &(cntr == 3'b111))begin nxt_state = IDLE; trmt = 0; cntr_enable = 1;end
			end
		default: begin nxt_state = IDLE; tx_data = 8'h00;end
	endcase
end
	
endmodule