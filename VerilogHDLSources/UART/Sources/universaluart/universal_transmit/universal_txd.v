
`include "universal_transmit.v"
`include "universal_transmit_state.v"

module UNIVERSAL_TXD #(
    parameter
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600,
        BYTES    = 1
) (
    input  wire                   CLK, 
    input  wire                   RESET,
    output wire                   TX,
    input  wire [(BYTES * 8)-1:0] TXDATA,
    input  wire                   TXSTART,
    output wire                   TXBUSY,
    output wire                   TXDONE
);

    wire [7:0] senddata;
    wire senddone, sendstart;
    wire status, break;

    UNIVERSAL_TRANSMIT_STATE uSTATUS (
        .CLK        (CLK        ),
        .RESET      (RESET      ),
        .START      (TXSTART    ),
        .BREAK      (break      ),
        .STATUS     (status     )
    );

    UNIVERSAL_TRANSMIT #(
        .SCYCLE     (SCYCLE     ),
        .BAUDRATE   (BAUDRATE   ),
        .BYTES      (BYTES      )
    ) uTransmit (
        .CLK        (CLK        ),
        .RESET      (RESET      ),
        .STATUS     (status     ),
        .TXDATA     (TXDATA     ),
        .TXSTART    (TXSTART    ),
        .TXBUSY     (TXBUSY     ),
        .TXDONE     (TXDONE     ),
        .BREAK      (break      ),
        .SENDDATA   (senddata   ),
        .SENDDONE   (senddone   ), // Shift Request
        .SENDSTART  (sendstart  )  // Tx Start
    );

    TXD #(
        .SCYCLE     (SCYCLE     ),
        .BAUDRATE   (BAUDRATE   )
    ) uTxd (
        .CLK        (CLK        ),
        .RESET      (RESET      ),
        .TX         (TX         ),
        .TXDATA     (senddata   ),
        .TXSTART    (sendstart  ), // Tx Start
        .TXDONE     (senddone   )  // Shift Request
    );

endmodule