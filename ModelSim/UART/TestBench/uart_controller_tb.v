`timescale 1us/100ps

`define SCYCLE     20                                    // 50MHz Main Clock
`define DWIDTH     8                                     // ビット幅
`define OPCDBYTE   2                                     // 命令サイズ
`define ADDRBYTE   2                                     // メモリアドレスサイズ
`define DATABYTE   4                                     // メインメモリサイズ，データサイズ
`define BYTES      8                                     // 全Byte
`define UARTMHZ    50000000                              // ペリフェラルヘルツ
`define BAUDRATE   115200                                // ボードレート
`define BAUDSCYCLE `SCYCLE * (`UARTMHZ / `BAUDRATE) * 10 // ボードサイクル

module uart_controller_tb;

// 必要に応じて
integer i, j, k;

reg clock;
reg reset;
always #(`SCYCLE / 2) clock = ~clock; // ￣|＿|￣|＿|￣|＿|￣|＿|￣|＿|￣

reg         hostStart = 1'b0;
reg [63: 0] hostData  = {64{1'b0}};
wire        tx, txdone, rx;
UartSource #(
    .SCYCLE     (`UARTMHZ   ),
    .BAUDRATE   (`BAUDRATE  )
) uHostUartSrc (
    .iCLOCK     (clock      ),
    .iNRESET    (reset      ),
    .iFEN       (hostStart  ),
    .iFDATA     (hostData   ),
    .oTX        (tx         ),
    .oDONE      (txdone     )
);
reg ip = 1'b0;
wire op;
Kernel uKernel (
    .clock  (clock),
    .reset  (reset),
    .i_gpio (ip   ),
    .o_gpio (op   ),
    .rx     (tx   ),
    .tx     (rx   )
);

initial begin
    clock = 1;
    reset = 0;
    #(`SCYCLE * 1);
    reset = 1;
    #(`SCYCLE * 1);

    // HostToKernel(0, 16'd1000, $urandom());
    // HostToKernel(0, 16'd1001, $urandom());
    for (i = 0; i < 5; i = i + 1) HostToKernel(0, 16'd1000 + i, $urandom());
    for (i = 0; i < 5; i = i + 1) HostToKernel(0, 16'd3048 + i, $urandom());

    HostToKernel(1, 16'd1000, 32'b0);
    HostToKernel(1, 16'd3048, 32'b0); 
    HostToKernel(2, 16'd0000, 32'b1);
    HostToKernel(2, 16'd0000, 32'b1);

    ip = 1; #(`SCYCLE)
    HostToKernel(3, 16'd0000, 32'b0);

    #(`BAUDSCYCLE);
    $stop;
end

task HostToKernel;
input [15: 0] opecode;
input [15: 0] address;
input [31: 0] datas;
reg Break;
begin
    Break = 1'b0;
    
    hostData = {opecode, address, datas};
    hostStart = 1'b1; #(`SCYCLE * 1);
    hostStart = 1'b0;
    while (!Break) begin
        #(`SCYCLE * 1);
        Break = (txdone) ? !Break: Break;
    end
end
endtask

task ReadMem;
reg Break;
begin
    Break = 1'b0;
    while (!Break) begin
        #(`SCYCLE * 1);
        Break = (uKernel.txdone) ? !Break: Break;
    end
end
endtask

endmodule

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

reg [31: 0] RAM1 [0: 1023];
reg [31: 0] RAM2 [0: 1023];
always @(posedge clock) begin
    if (16'd1000 <= address && address < (16'd1000 + 16'd1024)) begin
        if (mem_req) begin
            RAM1[address - 16'd1000] <= odatas;
        end else begin
            idatas <= RAM1[address - 16'd1000];
        end
    end
end
always @(posedge clock) begin
    if (16'd3048 <= address && address < (16'd3048 + 16'd1024)) begin
        if (mem_req) begin
            RAM2[address - 16'd3048] <= odatas;
        end else begin
            idatas <= RAM2[address - 16'd3048];
        end
    end
end

endmodule