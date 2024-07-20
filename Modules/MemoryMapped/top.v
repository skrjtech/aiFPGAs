
module Top (
    input wire          clk, 
    input wire          reset,
    // Serial Recieve
    input wire          rx,

    output wire [31:0] CMD,
    output wire [31:0] addr,
    output wire [31:0] data,
    output wire        done
);

parameter 
    SCYCLE = 50_000_000,
    BAUDRATE = 9600;

wire [7:0] rxdata;
wire       rxdone;
RXD #(
    .SCYCLE     (SCYCLE    ),
    .BAUDRATE   (BAUDRATE  )
) uRxd (
    .CLK        (clk       ),
    .RESET      (reset     ),
    .RX         (rx        ),
    .RXDATA     (rxdata    ),
    .RXBUSY     (rxbusy    ),
    .RXDONE     (rxdone    )
);

wire request;
wire [31:0] data_out;
FIFO_8to32 #(
    .SIZE(4)
) uFIFO_8to32 (
    .clk        (clk      ), 
    .reset      (reset    ), 
    .data_in    (rxdata   ), 
    .write_en   (rxdone   ), 
    .read_en    (request  ), 
    .data_out   (data_out ), 
    .full       (full     ), 
    .empty      (empty    )
);

UARTCMD uUARTCMD (
    .clk            (clk      ),
    .reset          (reset    ),

    .fifo_empty     (empty    ),
    .fifo_request   (request  ),
    .data_in        (data_out ),
    .CMD            (CMD),
    .data_add       (addr),
    .data_out       (data),
    .done           (done)
);

endmodule