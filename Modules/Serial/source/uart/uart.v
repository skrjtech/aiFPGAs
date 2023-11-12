
module UART #(
    parameter SCYCLE    = 50_000_000    ,
    parameter BAUDRATE  = 9600          ,
    parameter BITS      = 32
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

wire [1:0] txstate;
wire txbclk, txbreak;
TXSTATE uTxState (
    .CLK    (CLK        ),
    .RESET  (RESET      ),
    .START  (TXSTART    ),
    .BCLK   (txbclk     ),
    .BREAK  (txbreak    ),
    .STATE  (txstate    )
);
BAUDRATETX #(
    .SCYCLE     (SCYCLE   ),
    .BAUDRATE   (BAUDRATE ),
    .BITS       (BITS     )
) uBDTx (
    .CLK        (CLK     ),
    .RESET      (RESET   ),
    .STATE      (txstate ),
    .BCLK       (txbclk  ),
    .BREAK      (txbreak )
);
TXD uTxD (
    .CLK    (CLK     ), 
    .RESET  (RESET   ),   
    .STATE  (txstate ),   
    .BCLK   (txbclk  ),    
    .TXDATA (TXDATA  ),  
    .TXBUSY (TXBUSY  ),  
    .TXDONE (TXDONE  ),  
    .TX     (TX      )  
);

wire [1:0] rxstate;
wire rxbclk, rxbreak;
RXSTATE uRxState (
    .CLK    (CLK     ),
    .RESET  (RESET   ),
    .START  (RX     ),
    .BCLK   (rxbclk  ),
    .BREAK  (rxbreak ),
    .STATE  (rxstate )
);
BAUDRATERX #(
    .SCYCLE     (SCYCLE   ),
    .BAUDRATE   (BAUDRATE ),
    .BITS       (BITS     )
) uBDRx (
    .CLK        (CLK     ),
    .RESET      (RESET   ),
    .STATE      (rxstate ),
    .BCLK       (rxbclk  ),
    .BREAK      (rxbreak )
);
RXD uRxD (
    .CLK    (CLK     ), 
    .RESET  (RESET   ),   
    .STATE  (rxstate ),   
    .BCLK   (rxbclk  ),    
    .RXDATA (RXDATA  ),  
    .RXBUSY (RXBUSY  ),  
    .RXDONE (RXDONE  ),  
    .RX     (RX      )  
);

endmodule