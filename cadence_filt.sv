module cadence_filt(clk, rst_n, cadence, cadence_filt);

parameter FAST_SIM = 1'b0;

input clk, rst_n, cadence;
output reg cadence_filt;

reg ff1, ff2, ff3;
reg [15:0] stbl_cnt;

wire chngd_n;
wire [15:0] d;
wire [15:0] stbl_plus1;
wire stable;

assign d = chngd_n ? stbl_plus1 : 16'h0000;
assign	chngd_n = ff2 ~^ ff3;
assign stbl_plus1 = stable ? stbl_cnt : (stbl_cnt + 1'b1);

//used just to accelerate the simulation
generate
	if(FAST_SIM)assign stable = & stbl_cnt[8:0];
	else assign stable = & stbl_cnt;
endgenerate

always @(posedge clk)begin
	ff1 <= cadence;
	ff2 <= ff1;
	ff3 <= ff2;
end

 always @(posedge clk, negedge rst_n)begin
	if(~rst_n) stbl_cnt <= 16'h0000;
	else stbl_cnt <= d;
 end
 
 always @(posedge clk, negedge rst_n)begin
	if(~rst_n)cadence_filt <= 1'b0;
	else if(stable) cadence_filt <= ff3;
	else cadence_filt <= cadence_filt;
 end
 
 endmodule