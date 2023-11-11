
module UART #(
    parameter SCYCLE = 50_000_000,
    parameter BAUDRATE = 9600
) (
    input  wire       CLK,
    input  wire       RESET,
    
    output wire       TX,
    input  wire [7:0] TXDATA,
    input  wire       TXSTART,
    output wire       TXDONE,
    output wire       TXBUSY,
    
    input  wire       RX,
    output wire [7:0] RXDATA,
    output wire       RXCATCH,
    output wire       RXBUSY,
    output wire       RXDONE
);

    TXD #(
        .SCYCLE(SCYCLE), 
        .BAUDRATE(BAUDRATE)
    ) uTx (
        .CLK(CLK),
        .RESET(RESET),
        .TXDATA(TXDATA),
        .TXSTART(TXSTART), 
        .TXBUSY(TXBUSY),
        .TXDONE(TXDONE),
        .TX(TX),
    );

    RXD #(
        .SCYCLE(SCYCLE), 
        .BAUDRATE(BAUDRATE)
    ) uRx (
        .CLK(CLK),
        .RESET(RESET),
        .RX(RX),
        .RXDATA(RXDATA),
        .RXBUSY(RXBUSY),
        .RXDONE(RXDONE)
    );

endmodule
