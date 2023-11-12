`timescale 1ns/10ps
`define TB_SCYCLE 20 // 50MHz

module uart_tb ();

//-------------------------------
// Generate Clock
//-------------------------------
reg clk50;
initial clk50 = 1'b0;
always #(`TB_SCYCLE / 2) clk50 = ~clk50;

//------------------------------
// Generate Reset
//------------------------------
reg reset;
initial begin
    reset = 1'b0;
    # (`TB_SCYCLE * 2)
    reset = 1'b1;	
end

//------------------------------
// Generate Finish
//------------------------------
reg [7:0] cnt;
always @(posedge uSERIAL.sec1pos) begin
    if (cnt == 3) $finish;
    else cnt <= cnt + 1;
end

//------------------------------
// Generate Top
//------------------------------
wire [7:0] leds;
SERIAL uSERIAL (
    .clk    (clk50  ),
    .reset  (reset  ),
    .rx     (),
    .tx     (),
    .leds   (leds)
);

endmodule