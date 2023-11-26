
`include "universal_recieve.v"
`include "universal_recieve_state.v"

module UNIVERSAL_RXD #(
    parameter
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600,
        BYTES    = 1
) (
    input  wire                   CLK, 
    input  wire                   RESET,
    input  wire                   RX,
    output wire [(BYTES * 8)-1:0] RXDATA,
    output wire                   RXBUSY,
    output wire                   RXDONE
);

    wire [7:0] recvdata;
    wire recvdone, status, break;
    
    UNIVERSAL_RECIEVE_STATE uSTATUS (
        .CLK        (CLK        ),
        .RESET      (RESET      ),
        .START      (RX         ),
        .BREAK      (break      ),
        .STATUS     (status     )
    );

    UNIVERSAL_RECIEVE #(
        .SCYCLE     (SCYCLE     ),
        .BAUDRATE   (BAUDRATE   ),
        .BYTES      (BYTES      )
    ) uRecieve (
        .CLK        (CLK        ),
        .RESET      (RESET      ),
        .STATUS     (status     ),
        .RXDATA     (RXDATA     ),
        .RXSTART    (RX         ),
        .RXBUSY     (RXBUSY     ),
        .RXDONE     (RXDONE     ),
        .BREAK      (break      ),
        .RECVDATA   (recvdata   ),
        .RECVDONE   (recvdone   )
    );

    RXD #(
        .SCYCLE     (SCYCLE     ),
        .BAUDRATE   (BAUDRATE   )
    ) uTxd (
        .CLK        (CLK        ),
        .RESET      (RESET      ),
        .RX         (RX         ),
        .RXDATA     (recvdata   ),
        .RXDONE     (recvdone   )
    );

endmodule