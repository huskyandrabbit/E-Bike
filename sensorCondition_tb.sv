module sensorCondition_tb();

reg clk, rst_n, cadence;
reg [1:0] setting;
reg [11:0] torque, curr, batt;
reg [12:0] incline;

wire not_pedaling, TX;
wire [12:0] error;

reg [12:0] cadence_cnt;

sensorCondition #(12'h010, 1'b1) DUT(.clk(clk), .rst_n(rst_n), .torque(torque), .cadence(cadence), .curr(curr)
						  , .incline(incline), .setting(setting), .batt(batt), .error(error), .not_pedaling(not_pedaling), .TX(TX));
//generate the cadence signal
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)cadence_cnt <= 12'h000;
	else cadence_cnt <= cadence_cnt + 12'h001;
end
assign cadence = ($unsigned(cadence_cnt) > $unsigned(2048)) ? 1'b0 : 1'b1;

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	setting = 2'b00;
	torque = 12'h000;
	curr = 12'h000;
	batt = 12'h000;
	incline = 13'h0000;
	repeat(5) @(posedge clk);
	rst_n = 1'b1;
	setting = 2'b10;
	torque = 12'habc;
	curr = 12'hdef;
	batt = 12'h873;
	incline = 13'h952;
end

always 
	#1 clk = ~clk;
	
endmodule