
`include "universal_transmit/universal_txd.v"
`include "universal_recieve/universal_rxd.v"

module UNIVERSAL_UART #(
    parameter
        SCYCLE      = 50_000_000,
        BAUDRATE    = 9600,
        BYTES       = 1
) (
    input  wire                 CLK,
    input  wire                 RESET,
    output wire                 TX,
    input  wire [(BYTES*8)-1:0] TXDATA,
    input  wire                 TXSTART,
    output wire                 TXBUSY,
    output wire                 TXDONE,
    input  wire                 RX,
    output wire [(BYTES*8)-1:0] RXDATA,
    output wire                 RXBUSY,
    output wire                 RXDONE
);
    UNIVERSAL_TXD #(
        .SCYCLE     (SCYCLE     ),
        .BAUDRATE   (BAUDRATE   ),
        .BYTES      (BYTES      )
    ) uUniTxd (
        .CLK        (CLK        ),
        .RESET      (RESET      ),
        .TX         (TX         ),
        .TXDATA     (TXDATA     ),
        .TXSTART    (TXSTART    ),
        .TXBUSY     (TXBUSY     ),
        .TXDONE     (TXDONE     )
    );

    UNIVERSAL_RXD #(
        .SCYCLE     (SCYCLE     ),
        .BAUDRATE   (BAUDRATE   ),
        .BYTES      (BYTES)
    ) uUniRxd (
        .CLK        (CLK        ),
        .RESET      (RESET      ),
        .RX         (RX         ),
        .RXDATA     (RXDATA     ),
        .RXBUSY     (RXBUSY     ),
        .RXDONE     (RXDONE     )
    );
endmodule