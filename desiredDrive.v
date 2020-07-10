
module  desiredDrive (clk, avg_torque, cadence_vec, incline, setting, target_curr);
input clk;
input [11:0] avg_torque;
input [4:0] cadence_vec;
input [12:0] incline;   //signed number
input [1:0] setting; //level of assists. 11 is the most assist.
output [11:0] target_curr;

//for saturation
wire [9:0] incline_sat;
wire  [10:0]incline_factor ; 
wire [8:0] incline_lim;


//for cadence
wire [5:0] cadence_factor;


//for avg_torque
wire [12:0] torque_off;
localparam TORQUE_MIN = 12'h380;
wire [11:0] torque_pos;

//for assist motor
reg [28: 0] assist_prod;

reg [7:0] p1;
reg [16:0] p2;

//if the 13 bit number  is greater than the max number 10 bit can represent. saturate to the most positive.
assign incline_sat = (~incline [12] & |incline [11 : 9]) ? {10'h1FF}:
//more negative than 10 bits, saturate to the most negative
( incline [12] & ~& incline [11 : 9]) ? {10'b1000000000 }:
//positive in the range
{incline};

assign incline_factor = {incline_sat[9],incline_sat} + 11'h0100;


assign incline_lim = ( incline_factor [10]) ? 9'h000 : //if it the negative, saturate to zero.
		     ( incline_factor [9] ) ? 9'h1FF: //if difference is positive, saturate to d'551
		     incline_factor [8:0]; //if less than 551, keep the lest significant 10 bits.
		      

//for cadence

//if the difference is positve, plus 32. Otherwise, saturate to zero.
assign cadence_factor = (|cadence_vec [4:1] ) ? ( cadence_vec + 6'h20) : 6'h00;

//for torque
assign torque_off = {1'b0, avg_torque} - { 1'b0,TORQUE_MIN};
assign torque_pos = ( torque_off [12] ) ?  12'h0 : torque_off [11:0] ; //zero clipped

//for assist motor
//assign assist_prod = setting * cadence_factor * incline_lim * torque_pos; //a product of 4 elements.
assign target_curr = ( |assist_prod [28:26]  ) ? 12'hFFF : assist_prod [25:14];

always @(posedge clk) begin
  p1 <= setting * cadence_factor;
  p2 <= p1 * incline_lim;
  assist_prod <= p2 * torque_pos;
end

endmodule
