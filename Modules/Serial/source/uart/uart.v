
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

wire [1:0] txstate;
wire txbclk, txbreak;
TRANSMITSTATE uTransmitState (
    .CLK    (CLK        ),
    .RESET  (RESET      ),
    .START  (TXSTART    ),
    .BCLK   (txbclk     ),
    .BREAK  (txbreak    ),
    .STATE  (txstate    )
);
TRANSMITBAUDRATE #(
    .SCYCLE     (SCYCLE   ),
    .BAUDRATE   (BAUDRATE )
) uTransmitBaudrate (
    .CLK        (CLK     ),
    .RESET      (RESET   ),
    .STATE      (txstate ),
    .BCLK       (txbclk  ),
    .BREAK      (txbreak )
);
TRANSMIT uTransmit (
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
RECIEVESTATE uRecieveState (
    .CLK    (CLK     ),
    .RESET  (RESET   ),
    .START  (RX     ),
    .BCLK   (rxbclk  ),
    .BREAK  (rxbreak ),
    .STATE  (rxstate )
);
RECIEVEBAUDRATE #(
    .SCYCLE     (SCYCLE   ),
    .BAUDRATE   (BAUDRATE )
) uRecieveBaudrate (
    .CLK        (CLK     ),
    .RESET      (RESET   ),
    .STATE      (rxstate ),
    .BCLK       (rxbclk  ),
    .BREAK      (rxbreak )
);
RECIEVE uRecieve (
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