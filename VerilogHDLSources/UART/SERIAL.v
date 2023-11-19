`include "source/uart.inc"

`define SCYCLE 50000000
`define BAUDRATE 115200

module SERIAL (
    input  wire       clk   ,
    input  wire       reset ,
    input  wire       rx    ,
    output wire       tx    ,
    output wire [7:0] leds
);

    wire clk50;
    PLL uPll (clk, clk50);

    wire [7:0] txdata, rxdata;
    wire txbusy, txdone;
    wire rxbusy, rxdone;
    wire sec1pos, txstart;

    assign leds = rxdata;

    UART #(
        .SCYCLE     (`SCYCLE   ), 
        .BAUDRATE   (`BAUDRATE )
    ) uUART (
        .CLK        (clk50     ),
        .RESET      (reset     ),
        .TX         (tx        ),
        .TXDATA     (rxdata    ),
        .TXSTART    (rxdone   ),
        .TXBUSY     (txbusy    ),
        .TXDONE     (txdone    ),
        .RX         (rx        ),
        .RXDATA     (rxdata    ),
        .RXBUSY     (rxbusy    ),
        .RXDONE     (rxdone    )
    );

endmodule