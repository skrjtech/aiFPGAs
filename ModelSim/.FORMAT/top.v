
module Top #( 
    parameter 
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600
) (
    input  wire       clk, 
    input  wire       reset,
    output wire       tx,
    input  wire [7:0] txdata,
    input  wire       txstart,
    output wire       txbusy,
    output wire       txdone,
    input  wire       rx,
    output wire [7:0] rxdata,
    output wire       rxbusy,
    output wire       rxdone
);

UART #(
    .SCYCLE     (SCYCLE    ),
    .BAUDRATE   (BAUDRATE  )
) uUART (
    .CLK        (clk        ),
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

endmodule