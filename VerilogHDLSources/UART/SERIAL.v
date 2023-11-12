
`ifdef SIMULATION
    `define SCYCLE 50
    `define BAUDRATE 5
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

    wire [7:0]  txdata,  rxdata;
    wire        txstart, rxcatch;
    wire        txbusy,  rxbusy;
    wire        txdone,  rxdone;
    assign leds = rxdata;
    UART #(
        .SCYCLE     (`SCYCLE    ),
        .BAUDRATE   (`BAUDRATE  ),
        .BITS       (`BITS      )
    ) uUart (
        .CLK        (clk48      ),
        .RESET      (reset      ),
        .TX         (tx         ),
        .TXDATA     (txdata     ),
        .TXSTART    (txstart    ),
        .TXBUSY     (txbusy     ),
        .TXDONE     (txdone     ),
        .RX         (rx         ),
        .RXDATA     (rxdata     ),
        .RXCATCH    (rxcatch    ),
        .RXBUSY     (rxbusy     ),
        .RXDONE     (rxdone     )
    );

    wire pos1sec;
    assign txstart = pos1sec;
    COUNTER #(
        .SCYCLE (`SCYCLE )
    ) uCounter (
        .CLK    (clk        ),
        .RESET  (reset      ),
        .COUT   (pos1sec    )
    );
    GEN8BITDATA uGen (
        .CLK        (clk        ),
        .RESET      (reset      ),
        .SEC1POS    (pos1sec    ),
        .DATA       (txdata     )
    );
    
endmodule