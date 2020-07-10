module nonoverlap(highout, lowout, highin, lowin, clk, rst_n);

typedef enum reg [1:0] {IDLE, FORCE_LOW} state_t;

input highin, lowin, clk, rst_n;
output reg highout, lowout;

state_t state, nxt_state;
reg [4:0] cnt;
wire eg_dect;	//when highin or lowin change, it is set to 1
reg highin_1, lowin_1;	//used for edge-detection
reg h_in, l_in;

//flips used to capture the change of highin and lowin
always @(posedge clk)begin
	highin_1 <= highin;
	lowin_1 <= lowin;
end

assign eg_dect = (highin_1 ^ highin) & (lowin ^ lowin_1);

//synchronized highin and lowin go through fipflops to get the final output
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)begin
		highout <= 1'b0;
		lowout <= 1'b0;end
	else begin
		highout <= h_in;
		lowout <= l_in;end
end

//state machine
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)state <= FORCE_LOW;
	else state <= nxt_state;
end

always @(posedge clk, negedge rst_n)begin
	if(~rst_n)cnt <= 5'b0_0000;
	else if(eg_dect)cnt <= 5'b0_0000;
	else cnt <= cnt + 1;
end

always @(eg_dect, state, cnt)begin
	case(state)
		IDLE: begin
			h_in = eg_dect ? 1'b0 : highin;
			l_in = eg_dect ? 1'b0 : lowin;
			if(eg_dect)nxt_state = FORCE_LOW;
			else nxt_state = IDLE; end
		FORCE_LOW: begin
			if(~(&cnt))begin
				h_in = 1'b0;
				l_in = 1'b0; 
				nxt_state = FORCE_LOW;end
			else begin 
				nxt_state = IDLE; 
				h_in = eg_dect ? 1'b0 : highin;
				l_in = eg_dect ? 1'b0 : lowin;end end
		default: nxt_state = FORCE_LOW;
	endcase		
end

endmodule