module SPI_mstr(done, rd_data, SS_n, SCLK, MOSI, clk, rst_n, MISO, wrt, cmd);

input clk, rst_n, MISO, wrt;
input [15:0] cmd;
output reg done, SS_n, SCLK, MOSI;
output [15:0] rd_data;

//internal signals
reg [5:0] sclk_div;
reg [3:0] bit_cntr;
reg [15:0] shft_reg;
reg MISO_sampl, set_done, shft, sampl, init, ld_SCLK;

typedef enum reg [1:0] {IDLE, FIRST, WAIT, LAST} state_t;
state_t state, nxt_state;

// sclk_div generate
always @(posedge clk)begin
	if(ld_SCLK)sclk_div <= 6'b11_0000;
	else sclk_div <= sclk_div + 1'b1;
end

assign SCLK = sclk_div[5];

// sample of MISO
always @(posedge clk)begin
	if(sampl)MISO_sampl <= MISO;
end

// shft_reg generate
always @(posedge clk)begin
	if(init)shft_reg <= cmd;
	else if(shft)shft_reg <= {shft_reg[14:0], MISO_sampl};
end


assign MOSI = shft_reg[15];
assign rd_data = shft_reg;

// 4 bit counter to shift
always @(posedge clk)begin
	if(init)bit_cntr <= 4'b0000;
	else if(shft)bit_cntr <= bit_cntr + 1'b1;
end

// state machine begin
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)state <= IDLE;
	else state <= nxt_state;
end

always_comb begin

	init = wrt;
	shft = 1'b0;
	sampl = 1'b0;

	case(state)
		IDLE: begin
			ld_SCLK = 1'b1;
			SS_n = 1'b1;
			set_done = 1'b0;

			if(wrt)
			    nxt_state = FIRST;
			else 
	    		    nxt_state = IDLE;
		end

		FIRST:begin
			set_done = 1'b1;
			SS_n = 1'b0;
			ld_SCLK = 1'b0;
			if(&sclk_div)
			    nxt_state = WAIT;
			else 
			    nxt_state = FIRST;
	        end

		WAIT: begin
			SS_n = 1'b0;
			set_done = 1'b1;
			ld_SCLK = 1'b0;

		        //set sampl signal
			if((&bit_cntr) & (sclk_div == 6'b01_1111))begin
			    sampl = 1'b1;
    			    nxt_state = LAST;
			end
			else if(sclk_div == 6'b01_1111)begin 
			    sampl = 1'b1;
			    nxt_state = WAIT;
			end

		        //set shft signal
			else if(sclk_div == 6'b11_1111)begin 
			    shft = 1'b1;
		     	    nxt_state = WAIT;
			end
			else begin 
			    shft = 1'b0; 
			    sampl = 1'b0; 
	    	    	    nxt_state = WAIT;
			end
		      end
		LAST: begin
			SS_n = 1'b0;
			set_done = 1'b1;
			if(sclk_div == 6'b11_1111)begin 
			    shft = 1'b1; 
			    ld_SCLK = 1'b1;
			    nxt_state = IDLE;
			end
			else begin 
			    shft = 1'b0; 
			    nxt_state = LAST; 
			    ld_SCLK = 1'b0;
			end 
		      end

		default: nxt_state = IDLE;
	endcase
end

// done is generated
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)done <= 1'b1;
	else done <= ~(init | set_done);	
end

endmodule