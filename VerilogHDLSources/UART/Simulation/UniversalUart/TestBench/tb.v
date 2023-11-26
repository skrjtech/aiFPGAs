
`timescale 1us/100ps
`define TB_SCYCLE 20 // 50MHz

module tb ();

    reg clock;
    initial clock = 1;
    always #(`TB_SCYCLE / 2) clock = ~clock;

    reg reset;
    initial reset = 1;

    wire tx, rx;

    // Transmit
    reg  [31:0] txdata;
    reg  txstart;
    initial txstart = 0;
    wire txbusy, txdone;
    // Recieve 
    wire [31:0] rxdata;
    wire rxbusy, rxdone;

    Top uTop (
        .clk        (clock    ),
        .reset      (reset    ),
        .tx         (tx       ),
        .txdata     (txdata   ),
        .txstart    (txstart  ),
        .txbusy     (txbusy   ),
        .txdone     (txdone   ),
        .rx         (tx       ),
        .rxdata     (rxdata   ),
        .rxbusy     (rxbusy   ),
        .rxdone     (rxdone   )
    );



    UNIVERSAL_TXD #(
        .SCYCLE     (100    ),
        .BAUDRATE   (50     ),
        .BYTES      (4      )
    ) uTxd (
        .CLK        (clock  ),
        .RESET      (reset  ),
        .TX         (tx     ),
        .TXDATA     (txdata ),
        .TXSTART    (txstart),
        .TXBUSY     (txbusy ),
        .TXDONE     (txdone )
    ); 

    UNIVERSAL_RXD #(
        .SCYCLE     (100    ),
        .BAUDRATE   (50     ),
        .BYTES      (4      )
    ) uRxd (
        .CLK        (clock  ),
        .RESET      (reset  ),
        .RX         (tx     ),
        .RXDATA     (rxdata ),
        .RXBUSY     (rxbusy ),
        .RXDONE     (rxdone )
    ); 

    initial begin
        RESET();
        UART_SEND(32'h5F99_01FA);
        UART_SEND(32'h1234_5678);
    end

    task RESET;
        begin
            #(`TB_SCYCLE * 0);
            reset = 0;
            #(`TB_SCYCLE * 1);
            reset = 1;
        end
    endtask

    task UART_SEND;
        input [31:0] data;
        begin
            #(`TB_SCYCLE * 1);
            txdata = data;
            txstart = 1;
            #(`TB_SCYCLE * 1);
            txstart = 0;
            #(`TB_SCYCLE * (22 * 4));
        end
    endtask

endmodule