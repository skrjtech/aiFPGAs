
// `ifdef SIMULATION
//     `define SCYCLE 100
//     `define BAUDRATE 25
//     `define BITS 4
// `else 
//     `define SCYCLE 48_000_000
//     `define BAUDRATE 9600
//     `define BITS 13
// `endif 

`define SCYCLE 48_000_000
`define BAUDRATE 9600
`define BITS 32

module SERIAL (
    input  wire       clk   ,
    input  wire       reset ,
    input  wire       rx    ,
    output wire       tx    ,
    output wire [7:0] leds
);

wire [1:0] state;
wire start, bclk, break;
wire [7:0] txdata;
wire txbusy, txdone;
assign leds = txdata;
COUNTER #(
    .SCYCLE (`SCYCLE )
) uCounter (
    .CLK     (clk    ),
    .RESET   (reset  ),
    .COUT    (start  )
);
GEN8BITDATA uGenD (
    .CLK     (clk    ),
    .RESET   (reset  ),
    .SEC1POS (start  ),
    .DATA    (txdata )
);
UART #(
    `SCYCLE, `BAUDRATE, `BITS
) uUART (
    .CLK        (clk    ),
    .RESET      (reset  ),
    .TX         (tx     ),
    .TXDATA     (txdata ),
    .TXSTART    (start  ),
    .TXBUSY     (txbusy ),
    .TXDONE     (txdone )
);

endmodule