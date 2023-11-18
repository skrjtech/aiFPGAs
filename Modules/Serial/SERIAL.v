`include "source/counter.v"
`include "source/gen8bitdata.v"
`include "source/uart/uart.v"

`ifdef SIMULATION
    `define SCYCLE 100
    `define BAUDRATE 25
    `define BITS 4
`else 
    `define SCYCLE 48_000_000
    `define BAUDRATE 9600
    `define BITS 13
`endif 

module SERIAL (
    input  wire       clk   ,
    input  wire       reset ,
    input  wire       rx    ,
    output wire       tx    ,
    output wire [7:0] leds
);

wire [7:0] txdata, rxdata;
wire txbusy, txdone;
wire rxbusy, rxdone;
wire txstart;
assign leds = rxdata;

COUNTER #(
    .SCYCLE (`SCYCLE )
) uCounter (
    .CLK        (clk     ),
    .RESET   (reset  ),
    .COUT    (txstart  )
);
GEN8BITDATA uGenD (
    .CLK        (clk     ),
    .RESET   (reset   ),
    .SEC1POS (txstart ),
    .DATA    (txdata  )
);
UART #(
    `SCYCLE, `BAUDRATE
) uUART (
    .CLK        (clk     ),
    .RESET      (reset   ),
    
    .TX         (tx      ),
    .TXDATA     (txdata  ),
    .TXSTART    (txstart ),
    .TXBUSY     (txbusy  ),
    .TXDONE     (txdone  ),

    .RX         (tx      ),
    .RXDATA     (rxdata  ),
    .RXBUSY     (rxbusy  ),
    .RXDONE     (rxdone  )
);

endmodule