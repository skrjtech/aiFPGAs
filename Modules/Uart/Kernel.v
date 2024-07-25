
`define UARTMHZ  48000000
`define BAUDRATE 115200

module Kernel (
    input  wire clock,
    input  wire reset,
    input  wire i_gpio,
    output wire o_gpio,
    input  wire rx,
    output wire tx
);

wire         uart_tx_req;
wire         uart_rx_irq;
wire [63: 0] con_to_uart;
wire [63: 0] uart_to_con;
wire         txdone;
wire         recept;

UartSource #(
    .SCYCLE     (`UARTMHZ   ),
    .BAUDRATE   (`BAUDRATE  )
) uUartSrc (
    .iCLOCK     (clock      ),
    .iNRESET    (reset      ),
    .iFEN       (uart_tx_req),
    .iFDATA     (con_to_uart),
    .oTX        (tx         ),
    .oDONE      (txdone     )
);

UartSink #(
    .SCYCLE     (`UARTMHZ   ),
    .BAUDRATE   (`BAUDRATE  )
) uUartSink (
    .iCLOCK     (clock      ),
    .iNRESET    (reset      ),
    .iRX        (rx         ),
    .oRECEPT    (recept     ),
    .oDONE      (uart_rx_irq),
    .oFDATA     (uart_to_con)
);

wire mem_req;
wire [15: 0] address;
reg  [31: 0] idatas = 31'b0;
wire [31: 0] odatas;
UartControllerModule uUartCon (
    .iCLOCK         (clock      ),
    .iNRESET        (reset      ),
    .iUART_RX_IRQ   (uart_rx_irq),
    .iUART_RXDATA   (uart_to_con),
    .oUART_TX_REQ   (uart_tx_req),
    .iUART_TX_DONE  (txdone     ),
    .oUART_TXDATA   (con_to_uart),
    .oADDR_BUS      (address    ),
    .iDATA_BUS      (idatas     ),
    .oDATA_BUS      (odatas     ),
    .oMEM_REQ       (mem_req    ),
    .iGPIO          (i_gpio     ),
    .oGPIO          (o_gpio     )
);

reg [31: 0] RAM1 [0: 9];
reg [31: 0] RAM2 [0: 9];
always @(posedge clock) begin
    if (16'd1000 <= address && address < (16'd1000 + 16'd1024)) begin
        if (mem_req) begin
            RAM1[address - 16'd1000] <= odatas;
        end else begin
            idatas <= RAM1[address - 16'd1000];
        end
    end
    if (16'd3048 <= address && address < (16'd3048 + 16'd1024)) begin
        if (mem_req) begin
            RAM2[address - 16'd3048] <= odatas;
        end else begin
            idatas <= RAM2[address - 16'd3048];
        end
    end
end

endmodule