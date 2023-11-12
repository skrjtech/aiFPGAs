
module UART #(
    parameter 
        SCYCLE    = 50_000_000    ,
        BAUDRATE  = 9600          ,
        BITS      = 32
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
    input  wire       RXCATCH   ,
    output wire       RXBUSY    ,
    output wire       RXDONE
);

    TXD #(
        .SCYCLE     (SCYCLE     ), 
        .BAUDRATE   (BAUDRATE   ),
        .BITS       (BITS       )
    ) uTx (
        .CLK        (CLK        ),
        .RESET      (RESET      ),
        .TXDATA     (TXDATA     ),
        .TXSTART    (TXSTART    ), 
        .TXBUSY     (TXBUSY     ),
        .TXDONE     (TXDONE     ),
        .TX         (TX         )
    );

    RXD #(
        .SCYCLE     (SCYCLE     ), 
        .BAUDRATE   (BAUDRATE   ),
        .BITS       (BITS       )
    ) uRx (
        .CLK        (CLK        ),
        .RESET      (RESET      ),
        .RX         (RX         ),
        .RXDATA     (RXDATA     ),
        .RXCATCH    (RXCATCH    ),
        .RXBUSY     (RXBUSY     ),
        .RXDONE     (RXDONE     )
    );

endmodule
