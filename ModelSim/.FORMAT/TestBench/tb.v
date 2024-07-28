`timescale 1us/100ps
`define TB_SCYCLE 20 // 50MHz

module tb ();

reg clock = 0;
reg reset = 0;
always #(`TB_SCYCLE / 2) clock = ~clock;

endmodule