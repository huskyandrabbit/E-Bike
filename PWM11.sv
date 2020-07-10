module PWM11(clk, rst_n, duty, PWM_sig);

input clk, rst_n;
input [10:0] duty;
output reg PWM_sig;

wire comp;	//internal signal to store the result of cnt<duty
reg [10:0] cnt;

assign comp = (cnt < duty) ? 1'b1 : 1'b0;

always@ (posedge clk, negedge rst_n)begin
	if(~rst_n)begin
		PWM_sig <= 1'b0;
		cnt <= 11'h000;
	end
	else begin
		cnt <= cnt + 1;
		PWM_sig <= comp;
	end
end

endmodule