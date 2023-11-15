`include "transmit/txd.v"
`include "recieve/rxd.v"

module UART #(
    parameter 
        SCYCLE    = 50_000_000    ,
        BAUDRATE  = 9600
) (
    input  wire       CLK       ,
    input  wire       RESET     ,
    
    output wire       TX        ,
    input  wire [7:0] TXDATA    ,
    input  wire       TXSTART   ,
    output wire       TXBUSY    ,
    output wire       TXDONE    ,

    input  wire       RX        ,
    output wire [7:0] RXDATA    ,
    output wire       RXBUSY    ,
    output wire       RXDONE
);

TXD #(
    .SCYCLE     (SCYCLE     ),
    .BAUDRATE   (BAUDRATE   )
) uTxd (
    .CLK        (CLK        ),
    .RESET      (RESET      ),
    .TX         (TX         ),
    .TXDATA     (TXDATA     ),
    .TXSTART    (TXSTART    ),
    .TXBUSY     (TXBUSY     ),
    .TXDONE     (TXDONE     )
);

RXD #(
    .SCYCLE     (SCYCLE     ),
    .BAUDRATE   (BAUDRATE   )
) uRxd (
    .CLK        (CLK        ),
    .RESET      (RESET      ),
    .RX         (RX         ),
    .RXDATA     (RXDATA     ),
    .RXBUSY     (RXBUSY     ),
    .RXDONE     (RXDONE     )
);

endmodule