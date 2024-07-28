`include "recieve.v"
`include "recievestate.v"
`include "recievebaudrate.v"

module RXD (

    input  wire       CLK       ,
    input  wire       RESET     ,
    input  wire       RX        ,
    output wire [7:0] RXDATA    ,
    output wire       RXBUSY    ,
    output wire       RXDONE

);

parameter 
    SCYCLE    = 50_000_000,
    BAUDRATE  = 9600;

wire rxstate;
wire rxbclk, rxbreak;
RECIEVESTATE uRecieveState (
    .CLK    (CLK     ),
    .RESET  (RESET   ),
    .START  (RX      ),
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
    .START      (RX      ),
    .STATE      (rxstate ),
    .BCLK       (rxbclk  ),
    .BREAK      (rxbreak )
);
RECIEVE uRecieve (
    .CLK    (CLK     ), 
    .RESET  (RESET   ),   
    .STATE  (rxstate ),
    .BCLK   (rxbclk  ), 
    .BREAK  (rxbreak ),  
    .RXDATA (RXDATA  ),  
    .RXBUSY (RXBUSY  ),  
    .RXDONE (RXDONE  ),  
    .RX     (RX      )  
);

endmodule