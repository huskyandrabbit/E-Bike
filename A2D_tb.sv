module A2D_tb();

reg clk, rst_n;
wire MISO, SS_n, SCLK, MOSI;
wire [11:0] batt, curr, brake, torque;

A2D_intf DUT(.clk(clk), .rst_n(rst_n), .MISO(MISO), .batt(batt),
 .curr(curr), .brake(brake), .torque(torque), .SS_n(SS_n), .SCLK(SCLK), .MOSI(MOSI));

ADC128S A2D_tb_ADC128S(.clk(clk),.rst_n(rst_n),
.SS_n(SS_n),.SCLK(SCLK),.MISO(MISO),.MOSI(MOSI));

initial begin
	clk = 0;
	rst_n = 0;
	repeat(5) @(negedge clk);
	rst_n = 1;
	force DUT.cnt = 14'h3ffa;
	@(negedge clk);
	release DUT.cnt;
end

initial
	$monitor("batt: %h, curr: %h, brake: %h, torque: %h", batt, curr, brake, torque);

always
	#1 clk = ~clk;

endmodule