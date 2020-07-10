module shift_rotator(res, src, rotate, amt);
input [15:0] src;
input rotate;
input [3:0] amt;
output [15:0] res;
wire [15:0] shft_stg1, shft_stg2, shft_stg3;
wire [14:0] insert;	//to store the digits that will be inserted into the right
// assign insert[0] = rotate ? src[0] : 0;
// assign insert[2:1] = rotate ? stg1[1:0] : 2'b00;
// assign insert[6:3] = rotate ? stg2[3:0] : 4'b0000;
// assign insert[14:7] = rotate ? stg3[7:0] : 8'h00;
assign insert = rotate ? {shft_stg3[15:8], shft_stg2[15:12], shft_stg1[15:14], src[15]} : 15'h0000;

assign shft_stg1 = amt[0] ? {src[14:0], insert[0]} : src;
assign shft_stg2 = amt[1] ? {shft_stg1[13:0], insert[2:1]} : shft_stg1;
assign shft_stg3 = amt[2] ? {shft_stg2[11:0], insert[6:3]} : shft_stg2;
assign res = amt[3] ? {shft_stg3[7:0], insert[14:7]} : shft_stg3;

endmodule