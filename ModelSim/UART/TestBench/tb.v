
`timescale 1us/100ps

`define SCYCLE 20 // 50MHz

`define UARTMHZ  50_000_000
`define BAUDRATE 9600
`define TXRXSCYCLE `SCYCLE * (`UARTMHZ / `BAUDRATE)

module tb ();

    reg clock = 0;
    reg reset = 0;
    always #(`SCYCLE / 2) clock = ~clock;

    // Transmit
    reg  [7:0] txdata = 0;
    reg        txstart = 0;
    wire       tx, txbusy, txdone;
    // Recieve 
    wire [7:0] rxdata;
    wire       rx ;
    wire       rxbusy, rxdone;

    assign rx = tx;

    Top #(
        .SCYCLE     (`UARTMHZ   ),
        .BAUDRATE   (`BAUDRATE  )
    ) uTop (
        .clk        (clock    ),
        .reset      (reset    ),
        .tx         (tx       ),
        .txdata     (txdata   ),
        .txstart    (txstart  ),
        .txbusy     (txbusy   ),
        .txdone     (txdone   ),
        .rx         (rx       ),
        .rxdata     (rxdata   ),
        .rxbusy     (rxbusy   ),
        .rxdone     (rxdone   )
    );

    wire sink_done;
    wire [31:0] output_data;
    UART_SINK #(
        .SCYCLE     (`UARTMHZ   ),
        .BAUDRATE   (`BAUDRATE  )
    ) uSink (
        .CLOCK  (clock      ),
        .NRESET (reset      ),
        .RX     (tx         ),
        .DATAO  (output_data),
        .DONE   (sink_done  )
    );

    initial begin
        #(`SCYCLE);
        reset = 1;
        
        Transmit(8'hAA);
        Transmit(8'hBB);
        Transmit(8'h18);
        Transmit(8'h22);
        Transmit(8'h22);
        Transmit(8'h22);

        Transmit(8'hEE);
        Transmit(8'hBB);
        Transmit(8'h00);
        Transmit(8'hBB);
        Transmit(8'hBB);
        Transmit(8'h18);
        
        #(`TXRXSCYCLE * 10);
        $stop;

    end

    task Transmit;
        input [7:0] data;
        begin

            txdata = data;
            txstart = 1;
            #(`TXRXSCYCLE * 10);

        end
    endtask

endmodule