`timescale 1ns/1ns
`define TB_SCYCLE 20 // 50MHz

module uart_tb ();

//-------------------------------
// Generate Clock
//-------------------------------
reg clk;
initial clk = 1'b0;
always #(`TB_SCYCLE / 2) clk = ~clk;


//-------------------------------
// Clock CountUP
//-------------------------------
reg [31:0] count;
initial count = 31'd0;
always @(posedge clk) begin
    if (count == 50000000 - 1) count <= 0;
    else count <= count + 1; 
end

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
reg [7:0] sec1pos_cnt;
initial sec1pos_cnt = 8'h00;
wire sec1pos;
assign sec1pos = uSERIAL.txstart;
always @(posedge clk) begin
    if (sec1pos) begin
        if (sec1pos_cnt == 3) $stop;
        else sec1pos_cnt <= sec1pos_cnt + 1;    
    end
end

//------------------------------
// Generate Top
//------------------------------
wire tx, rx;
wire [7:0] leds;
SERIAL uSERIAL (
    .clk    (clk    ),
    .reset  (reset  ),
    .rx     (rx     ),
    .tx     (tx     ),
    .leds   (leds   )
);

endmodule