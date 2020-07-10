module rst_synch(rst_n, RST_n, clk);

input RST_n, clk;
output reg rst_n;
reg ff1;

always @(negedge clk, negedge RST_n)begin
	if(~RST_n)ff1 <= 1'b0;
	else ff1 <= 1'b1;
end

always @(negedge clk, negedge RST_n)begin
	if(~RST_n)rst_n <= 1'b0;
	else rst_n <= ff1;
end

endmodule