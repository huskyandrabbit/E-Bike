module PB_intf(tgglMd, rst_n, clk, setting);

input tgglMd, rst_n, clk;
output reg [1:0] setting;

wire rise;
reg Md1, Md2, Md3;

//rise edge detection
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)begin
		Md1 <= 1'b1;
		Md2 <= 1'b1;
		Md3 <= 1'b1;
	end
	else begin
		Md1 <= tgglMd;
		Md2 <= Md1;
		Md3 <= Md2;
	end 
end 

assign rise = Md2 & ~Md3;

//setting counter
always @(posedge clk, negedge rst_n)begin
	if(~rst_n)setting <= 2'b10;
	else if(rise)setting <= setting + 1'b1;
end

endmodule