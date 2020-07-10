module shift_rotator_tb();
wire [15:0] res;
reg [16:0] src;
reg rotate;
reg [4:0] amt;
//instantiate DUT
shift_rotator iDUT(.res(res), .src(src[15:0]), .rotate(rotate), .amt(amt[3:0]));

initial begin
	rotate = 0;
	for(amt = 5'b00000; amt < 16; amt = amt + 1)
		for(src = 17'h00000; src < 17'h10000; src = src + 5)#5;
	rotate = 1;
	for(amt = 5'b00000; amt < 16; amt = amt + 1)
		for(src = 17'h00000; src < 17'h10000; src = src + 5)#5;
	$stop;
end
endmodule