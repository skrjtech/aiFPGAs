`include "transmit/txd.v"
`include "recieve/rxd.v"

module UART (
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

parameter 
    SCYCLE    = 50_000_000,
    BAUDRATE  = 9600;

TXD #(
    .SCYCLE     (SCYCLE    ),
    .BAUDRATE   (BAUDRATE  )
) uTxd (
    .CLK        (CLK       ),
    .RESET      (RESET     ),
    .TX         (TX        ),
    .TXDATA     (TXDATA    ),
    .TXSTART    (TXSTART   ),
    .TXBUSY     (TXBUSY    ),
    .TXDONE     (TXDONE    )
);

RXD #(
    .SCYCLE     (SCYCLE    ),
    .BAUDRATE   (BAUDRATE  )
) uRxd (
    .CLK        (CLK       ),
    .RESET      (RESET     ),
    .RX         (RX        ),
    .RXDATA     (RXDATA    ),
    .RXBUSY     (RXBUSY    ),
    .RXDONE     (RXDONE    )
);
endmodule

module Uart_Instance ();

parameter 
    SCYCLE    = 50_000_000,
    BAUDRATE  = 9600;

UART #(
    .SCYCLE     (SCYCLE     ),
    .BAUDRATE   (BAUDRATE   )
) uUart (
    .CLK        (clock      ),
    .RESET      (reset      ),
    .TX         (tx         ),
    .TXDATA     (txdata     ),
    .TXSTART    (txstart    ),
    .TXBUSY     (txbusy     ),
    .TXDONE     (txdone     ),
    .RX         (rx         ),
    .RXDATA     (rxdata     ),
    .RXBUSY     (rxbusy     ),
    .RXDONE     (rxdone     )
);

TXD #(
    .SCYCLE     (SCYCLE    ),
    .BAUDRATE   (BAUDRATE  )
) uTxd (
    .CLK        (CLK       ),
    .RESET      (RESET     ),
    .TX         (TX        ),
    .TXDATA     (TXDATA    ),
    .TXSTART    (TXSTART   ),
    .TXBUSY     (TXBUSY    ),
    .TXDONE     (TXDONE    )
);

RXD #(
    .SCYCLE     (SCYCLE    ),
    .BAUDRATE   (BAUDRATE  )
) uRxd (
    .CLK        (CLK       ),
    .RESET      (RESET     ),
    .RX         (RX        ),
    .RXDATA     (RXDATA    ),
    .RXBUSY     (RXBUSY    ),
    .RXDONE     (RXDONE    )
);

endmodule