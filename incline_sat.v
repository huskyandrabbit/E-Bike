module incline_sat(incline_sat, incline);
 input [12:0] incline;
 output [9:0] incline_sat;
 wire [9:0] neg, pos;
 assign neg = (&incline[11:9]) ? incline[9:0] : 10'h200;
 assign pos = (|incline[11:9]) ? 10'h1ff : incline[9:0];
 assign incline_sat = incline[12] ? neg : pos;
 endmodule