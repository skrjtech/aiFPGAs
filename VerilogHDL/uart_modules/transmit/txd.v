`include "transmit.v"
`include "transmitstate.v"
`include "transmitbaudrate.v"

module TXD (
    input  wire       CLK     ,
    input  wire       RESET   ,
    output wire       TX      ,
    input  wire [7:0] TXDATA  ,
    input  wire       TXSTART ,
    output wire       TXBUSY  ,
    output wire       TXDONE
);

parameter 
    SCYCLE   = 50_000_000,
    BAUDRATE = 9600;

wire txstate;
wire txbclk, txbreak;
TRANSMITSTATE uTransmitState (
    .CLK        (CLK         ),
    .RESET      (RESET       ),
    .START      (TXSTART     ),
    .BCLK       (txbclk      ),
    .BREAK      (txbreak     ),
    .STATE      (txstate     )
);

TRANSMITBAUDRATE #(
    .SCYCLE     (SCYCLE      ),
    .BAUDRATE   (BAUDRATE    )
) uTransmitBaudrate (
    .CLK        (CLK         ),
    .RESET      (RESET       ),
    .START      (TXSTART     ),
    .STATE      (txstate     ),
    .BCLK       (txbclk      ),
    .BREAK      (txbreak     )
);

TRANSMIT uTransmit (
    .CLK        (CLK         ), 
    .RESET      (RESET       ),   
    .STATE      (txstate     ),
    .START      (TXSTART     ),
    .BCLK       (txbclk      ),
    .BREAK      (txbreak     ),    
    .TXDATA     (TXDATA      ),  
    .TXBUSY     (TXBUSY      ),  
    .TXDONE     (TXDONE      ),  
    .TX         (TX          )  
);

endmodule