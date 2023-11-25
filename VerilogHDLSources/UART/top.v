
module Top (
    input wire       clk, reset,
    input wire       tx, txstart, txbusy, txdone,
    input wire       rx, rxbusy, rxdone,
    input wire [7:0] txdata, rxdata
);

    UART #(
        .SCYCLE     (100        ),
        .BAUDRATE   (50         )
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