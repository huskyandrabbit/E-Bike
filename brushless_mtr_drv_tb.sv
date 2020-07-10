module brushless_mtr_drv_tb();

reg [11:0] drv_mag;
reg hallGrn, hallYlw, hallBlu;
reg brake_n;
wire [10:0] duty;
wire [1:0] selGrn, selYlw, selBlu;
wire highGrn, highYlw, highBlu, lowGrn, lowYlw, lowBlu;
reg rst_n, clk;

brushless brushless_DUT(.clk(clk), .drv_mag(drv_mag), .hallGrn(hallGrn), .hallYlw(hallYlw),
 .hallBlu(hallBlu), .brake_n(brake_n), .duty(duty), .selGrn(selGrn), .selYlw(selYlw), .selBlu(selBlu));
 
mtr_drv mtr_drv_DUT(.clk(clk), .rst_n(rst_n), .duty(duty), .selGrn(selGrn), .selYlw(selYlw), .selBlu(selBlu),
 .highGrn(highGrn), .lowGrn(lowGrn), .highYlw(highYlw), .lowYlw(lowYlw), .highBlu(highBlu), .lowBlu(lowBlu));
 
initial begin
	clk = 0;
	rst_n = 0;
	hallGrn = 1; hallYlw = 0; hallBlu = 1;
	drv_mag = 12'hbcd;
	brake_n = 1;
	repeat(3) @(negedge clk);
	rst_n = 1;
	repeat(3000) @(negedge clk);
	hallGrn = 1; hallYlw = 0; hallBlu = 1;
	repeat(3000) @(negedge clk);
	hallGrn = 1; hallYlw = 0; hallBlu = 0;
	repeat(3000) @(negedge clk);
	hallGrn = 1; hallYlw = 1; hallBlu = 0;
	repeat(3000) @(negedge clk);
	hallGrn = 0; hallYlw = 1; hallBlu = 0;
	repeat(3000) @(negedge clk);
	hallGrn = 0; hallYlw = 1; hallBlu = 1;
	repeat(3000) @(negedge clk);
	hallGrn = 0; hallYlw = 0; hallBlu = 1;
	repeat(3000) @(negedge clk);
	hallGrn = 0; hallYlw = 0; hallBlu = 0;
	repeat(3000) @(negedge clk);
	hallGrn = 1; hallYlw = 1; hallBlu = 1;
	repeat(3000) @(negedge clk);
	brake_n = 0;
	repeat(3000) @(negedge clk);
	$stop;
end

always
	#10 clk = ~clk;

endmodule