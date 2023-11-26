`timescale 1us/100ps
`define TB_SCYCLE 20 // 50MHz

module tb ();

    reg clock;
    initial clock = 1;
    always #(`TB_SCYCLE / 2) clock = ~clock;

    reg reset;
    initial reset = 0;
        
    // Transmit
    reg  [7:0] txdata;
    reg  txstart;
    wire tx, txbusy, txdone;
    // Recieve 
    wire [7:0] rxdata;
    wire rx, rxbusy, rxdone;
    // UART Tx To Rx

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

    initial begin
        RESET();
        Transmit(8'hFA);
    end

    task RESET;
        begin
            #(`TB_SCYCLE * 0);
            reset = 0;
            #(`TB_SCYCLE * 1);
            reset = 1;
        end
    endtask

    task Transmit;
        input [7:0] data;
        begin
            txdata = data;
            txstart = 1;
            #(`TB_SCYCLE * 1);
            txstart = 0;
            #(`TB_SCYCLE * 19);
        end
    endtask

endmodule