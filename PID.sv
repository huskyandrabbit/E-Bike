module PID(clk, rst_n, error, not_pedaling, drv_mag);

parameter FAST_SIM = 1'b0;	

input clk, rst_n;
input not_pedaling; // Asserted if rider is not pedaling
input [12:0] error; //13-bit signed error
output [11:0] drv_mag; // Unsigned output that determines motor drive
reg [17:0] integrator;
wire [9:0] D_multiply;
wire [13:0] P_term;
wire [13:0] I_term;
wire [13:0] D_term;
reg [13:0] PID; 
reg [13:0] sum;
wire decimator_full;
reg [1:0] cnt; // counter used to add I_term, D_term and P_term
wire [13:0] final_out; 
reg[12:0] error_flop; 

///////////////////////////////////////////////
// deal with I_term
wire [17:0] sign_ext_error;
wire [17:0] temp_sum;
wire [12:0] D_diff;
wire [8:0] D_diff_sat;
wire pos_ov;
wire [17:0] sig1,sig2,sig3,sig4;
reg [19:0] decimator;
///////////////////////////////////////////////

reg [12:0] ff1,ff2,prev_err; // D_term ff toggle

assign I_term = {2'b00,integrator[16:5]};     //zero extended to 14-bits to get I term
assign D_term = {{4{D_multiply[9]}},D_multiply};  //sign extended to 14-bits
assign P_term = {error_flop[12],error_flop};  //sign extended to 14-bits to get P term

//20-bit counter
always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	decimator <= 20'h00000;
    else 
	decimator <= decimator + 1;
end

always @(posedge clk, negedge rst_n)begin
    if(~rst_n) 
	error_flop <= 13'h0000;
    else 
        error_flop <= error;
end

// PID = I_term + P_term + D_term;
always @(posedge clk, negedge rst_n)begin
    if(~rst_n) 
	cnt <= 2'b00;
    else if
        (cnt[1])cnt <= 2'b00;
    else 
	cnt <= cnt + 1'b1;
end


always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	sum <= 13'h0000;
    else 
	sum <= |cnt ? (sum + in) : in;
end


always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
        PID <= 13'h0000;
    else if
	(~(|cnt))PID <= sum;
end 

assign final_out = cnt[1] ? D_term : (cnt[0] ? I_term : P_term);

assign drv_mag = PID[13] ? 12'h000 : (PID[12] ? 12'hFFF : PID[11:0]); // combine to make output driving motor



//speed up the simulation
generate if(FAST_SIM) 
  assign decimator_full = &decimator[14:0];
else 		 
  assign decimator_full = &decimator;
endgenerate


//I term calculation
assign sig1 = temp_sum[17] ? 18'h00000 : temp_sum;
assign sig2 = pos_ov ? 18'h1FFFF : sig1;
assign sig3 = decimator_full ? sig2 : integrator;
assign sig4 = not_pedaling ? 18'h00000 : sig3;

assign sign_ext_error = {{5{error_flop[12]}},error_flop}; 
assign temp_sum = sign_ext_error + integrator;
assign pos_ov = temp_sum[17] & integrator[16];


always @(posedge clk, negedge rst_n) begin
    if (~rst_n) 
	integrator <= 18'h00000;
    else 
	integrator <= sig4;
end


//D term flip flops
always @(posedge clk, negedge rst_n) begin
    if (~rst_n) 
	ff1 <= 18'h00000;
    else if(decimator_full)
	ff1 <= error_flop;  
end

always @(posedge clk, negedge rst_n) begin
    if (~rst_n)
	 ff2 <= 18'h00000;
    else if(decimator_full)
	ff2 <= ff1;
end

always @(posedge clk, negedge rst_n) begin
    if (~rst_n) 
	prev_err <= 18'h00000;
    else if(decimator_full) 
	prev_err <= ff2;
end

// deal with D_diff
assign D_diff = error_flop - prev_err; 

// saturate D_diff to 9-bit D_diff_sat
assign D_diff_sat = D_diff[12] ? (&D_diff[12:8] ? D_diff[8:0] : 9'h100) : (~(|D_diff[12:8]) ? D_diff[8:0] : 9'h0ff);

// multiply D_diff_sat by 2
assign D_multiply = {D_diff_sat, 1'b0};

endmodule