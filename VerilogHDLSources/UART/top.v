
`ifdef SIMULATION
    `define SCYCLE   100
    `define BAUDRATE 50
    `define BYTES    4
`else
    `define SCYCLE   50000000
    `define BAUDRATE 96000
    `define BYTES    4
`endif

`ifdef UART
    module Top (
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
            .SCYCLE     (`SCYCLE    ),
            .BAUDRATE   (`BAUDRATE  )
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
`endif

 `ifdef UNIVERSAL
    module Top (
        input  wire                    clk, 
        input  wire                    reset,
        output wire                    tx,
        input  wire [(`BYTES * 8)-1:0] txdata,
        input  wire                    txstart,
        output wire                    txbusy,
        output wire                    txdone,
        input  wire                    rx,
        output wire [(`BYTES * 8)-1:0] rxdata,
        output wire                    rxbusy,
        output wire                    rxdone
    );

        UNIVERSAL_UART #(
            .SCYCLE     (`SCYCLE    ),
            .BAUDRATE   (`BAUDRATE  ),
            .BYTES      (`BYTES     )
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
`endif