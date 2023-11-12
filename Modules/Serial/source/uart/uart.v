
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
    input  wire       RXCATCH   ,
    output wire       RXBUSY    ,
    output wire       RXDONE
);

wire [1:0] STATE;
wire BCLK, BREAK;
TXSTATE uTxState (
    .CLK    (CLK        ),
    .RESET  (RESET      ),
    .START  (TXSTART    ),
    .BCLK   (BCLK       ),
    .BREAK  (BREAK      ),
    .STATE  (STATE      )
);
BAUDRATETX #(
    .SCYCLE     (SCYCLE    ),
    .BAUDRATE   (BAUDRATE  ),
    .BITS       (BITS      )
) uBDTx (
    .CLK        (CLK    ),
    .RESET      (RESET  ),
    .STATE      (STATE  ),
    .BCLK       (BCLK   ),
    .BREAK      (BREAK  )
);
TXD uTxD (
    .CLK    (CLK    ), 
    .RESET  (RESET  ),   
    .STATE  (STATE  ),   
    .BCLK   (BCLK   ),    
    .TXDATA (TXDATA ),  
    .TXBUSY (TXBUSY ),  
    .TXDONE (TXDONE ),  
    .TX     (TX     )  
);

endmodule