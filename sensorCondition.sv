module sensorCondition(clk, rst_n, torque, cadence, curr, incline, setting, batt, error, not_pedaling, TX);

parameter LOW_BATT_THRES = 12'ha98;
parameter FAST_SIM = 1'b0;	

input clk, rst_n, cadence;
input [1:0] setting;
input [11:0] torque, curr, batt;
input [12:0] incline;

output not_pedaling, TX;
output [12:0] error;

wire include_curr, cadence_filt, include_torque, clr;
wire [11:0] avg_curr, avg_torque, target_curr;
wire [15:0] mltply_curr;
wire [21:0] mltply_torque;

reg dff_cadence_filt;
reg [24:0] cadence_per;
reg [21:0] cnt_curr;
reg [16:0] accum_torque;
reg [13:0] accum_curr;
reg [4:0] cadence_vec, cadence_cnt;
reg dff_not_pedaling;


// instantiation of telemetry, cadence_filt and desiredDrive
telemetry sensorCondition_telemetry(.TX(TX), .batt_v(batt), .avg_curr(avg_curr), .avg_torque(avg_torque), .clk(clk), .rst_n(rst_n) );

cadence_filt #(FAST_SIM) sensorCondition_cadence_filt(.clk(clk), .rst_n(rst_n), .cadence(cadence), .cadence_filt(cadence_filt));

desiredDrive sensorCondition_desiredDrive(.clk(clk), .target_curr(target_curr), .setting(setting)
					  , .incline(incline), .cadence_vec(cadence_vec), .avg_torque(avg_torque)); 
	

// calculation of cadence_cnt
always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	cadence_cnt <= 5'h00;
    else if(clr) 
	cadence_cnt <= 5'h00;
    else if(include_torque)
	cadence_cnt <= &cadence_cnt ? 5'h1f : (cadence_cnt + 5'h01);
end

always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	cadence_vec <= 5'h00;
    else if(clr)
	cadence_vec <= cadence_cnt;
end
									
// calculation of cadence_per
always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	cadence_per <= 25'h000_0000;
    else 
	cadence_per <= cadence_per + 25'h000_0001;
end

// speed up simulation
generate if(FAST_SIM) 
  assign clr = &cadence_per[15:0];
else
  assign clr = &cadence_per;
endgenerate

//get the not_pedaling signal
assign not_pedaling = ~(|cadence_vec[4:1]);

//22-bit timer sampling of curr
always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	cnt_curr <= 22'h00_0000;
    else 
	cnt_curr <= cnt_curr + 22'h00_0001;
end

// speed up simulation
generate if(FAST_SIM)
  assign include_curr = &cnt_curr[15:0];
else
  assign include_curr = &cnt_curr;
endgenerate

//exponential average of curr
assign mltply_curr = 2'd3 * accum_curr;
always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	accum_curr <= 14'h0000;
    else if(include_curr)
	accum_curr <= mltply_curr[15:2] + curr;
end

// get avg_curr
assign avg_curr = accum_curr[13:2];

// cadence_filt rise edge detection
always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	dff_cadence_filt <= 1'b0;
    else 
	dff_cadence_filt <= cadence_filt;
end

//enable the sampling of torque to form avg_torque
assign include_torque =  ~dff_cadence_filt & cadence_filt;

//exponential average of torque with weight 32
assign mltply_torque = {accum_torque, 5'b00000} - accum_torque;

//falling edge of not_pedaling
always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	dff_not_pedaling <= 1'b0;
    else 
	dff_not_pedaling <= not_pedaling;
end

assign fall_not_pedaling = ~not_pedaling & dff_not_pedaling;


always @(posedge clk, negedge rst_n)begin
    if(~rst_n)
	accum_torque <= 17'h0_0000;
    else if(fall_not_pedaling)
	accum_torque <= {1'b0, torque, 4'b0000};
    else if(include_torque)
	accum_torque <= mltply_torque[21:5] + torque;
end

// get chunk of avg_torque
assign avg_torque = accum_torque[16:5];

// calcuate error
assign error = (not_pedaling | (batt < LOW_BATT_THRES)) ? 13'h0000 : ({1'b0, target_curr} - {1'b0, avg_curr});

endmodule