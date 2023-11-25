`timescale 1us/100ps
`define TB_SCYCLE 20 // 50MHz

module tb ();

    reg clock;
    initial clock = 1;
    always #(`TB_SCYCLE / 2) clock = ~clock;

    reg reset;
    initial reset = 0;

    reg [(4 * 10)-1:0] UART_STATE; 
    always @(uTop.uUART.uTxd.uTransmitState.STATE) begin
       case (uTop.uUART.uTxd.uTransmitState.STATE)
            0:  UART_STATE = "UART_IDLE";
            1:  UART_STATE = "UART_BUSY";
        endcase 
    end
        
    // Transmit
    reg  [7:0] txdata;
    reg  txstart;
    wire tx, txbusy, txdone;
    // Recieve 
    wire [7:0] rxdata;
    wire rx, rxbusy, rxdone;
    // UART Tx To Rx
    `ifdef UART
        Top uTop (
            clock, reset,
            tx, txstart, txbusy, txdone,
            tx, rxbusy, rxdone,
            txdata, rxdata
        );
    `else
        `ifdef TRANSMIT
            Top uTop (
                clock, reset,
                tx, txstart, txbusy, txdone,
                rx, rxbusy, rxdone,
                txdata, rxdata
            );
        `else
            Top uTop (
                clock, reset,
                tx, txstart, txbusy, txdone,
                tx, rxbusy, rxdone,
                txdata, rxdata
            );
        `endif
    `endif

    initial begin
        RESET();
        Transmit(8'h0A);
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