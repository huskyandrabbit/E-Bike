module desiredDrive_tb();

reg clk, rst_n;
reg [1:0] setting;
reg [12:0] incline;
reg [4:0] cadence_vec;
reg [11:0] avg_torque;
wire [11:0] target_curr;

desiredDrive iDUT(.clk(clk), .rst_n(rst_n), .target_curr(target_curr), .setting(setting), .incline(incline), .cadence_vec(cadence_vec), .avg_torque(avg_torque));

initial begin 
	//initialize
	avg_torque = 12'h000;
	cadence_vec = 5'h00;
	incline = 13'h0000;
	setting = 2'b00;
	clk = 1'b0;
	rst_n = 1'b0;
	repeat(20) @(negedge clk);
	//test1
	rst_n = 1'b1;
	avg_torque = 12'h800;
	cadence_vec = 5'h10;
	incline = 13'h0150;
	setting = 2'b10;
	repeat(20) @(negedge clk);
	//test2
	avg_torque = 12'h800;
	cadence_vec = 5'h10;
	incline = 13'h1f22;
	setting = 2'b11;
	repeat(20) @(negedge clk);
	//test3
	avg_torque = 12'h360;
	cadence_vec = 5'h10;
	incline = 13'h0c0;
	setting = 2'b11;
	repeat(20) @(negedge clk);
	//test4
	avg_torque = 12'h800;
	cadence_vec = 5'h18;
	incline = 13'h1ef0;
	setting = 2'b11;
	repeat(20) @(negedge clk);
	//test5
	avg_torque = 12'h7e0;
	cadence_vec = 5'h18;
	incline = 13'h0000;
	setting = 2'b11;
	repeat(20) @(negedge clk);
	//test6
	avg_torque = 12'h7e0;
	cadence_vec = 5'h18;
	incline = 13'h0080;
	setting = 2'b11;
	repeat(20) @(negedge clk);
	$stop;
end

always
	#5 clk = ~clk;
	
endmodule