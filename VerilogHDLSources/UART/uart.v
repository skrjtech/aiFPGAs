
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

    wire BCLKTX;
    BAUDRATETX #(
        .SCYCLE(SCYCLE), .BAUDRATE(BAUDRATE)
    ) uBTX (
        .CLK(CLK),
        .RESET((RESET || (~TXSTART))),
        .BCLK(BCLKTX)
    );
    TXD uTx (
        .CLK(CLK),
        .RESET(RESET),
        
        .BLCK(BCLKTX),
        
        .TXDATA(TXDATA),
        .TXSTART(TXSTART), 
        .TXBUSY(TXBUSY),
        .TXDONE(TXDONE),
        .TX(TX),
    );

    wire BCLKRESET, BLKCRX;
    BAUDRATERX #(
        .SCYCLE(SCYCLE), .BAUDRATE(BAUDRATE)
    ) uBRX (
        .CLK(CLK),
        .RESET((RESET || (~BCLKRESET))),
        .BCLK(BLKCRX)
    );
    RXD uRx (
        .CLK(CLK),
        .RESET(RESET),
        
        .BCLK(BLKCRX),
        .BCLKRESET(BCLKRESET),

        .RX(RX),
        .RXDATA(RXDATA),
        .RXBUSY(RXBUSY),
        .RXDONE(RXDONE)
    );

endmodule
