`timescale 1us/100ps
`define SCYCLE 20 // 50MHz

module tb ();

    reg clock = 0;
    reg reset = 0;
    always #(`SCYCLE / 2) clock = ~clock;

endmodule