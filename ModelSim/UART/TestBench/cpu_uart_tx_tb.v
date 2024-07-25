`timescale 1us/100ps

`define SCYCLE     20                                    // 50MHz Main Clock
`define DWIDTH     8                                     // ビット幅
`define OPCDBYTE   2                                     // 命令サイズ
`define ADDRBYTE   2                                     // メモリアドレスサイズ
`define DATABYTE   4                                     // メインメモリサイズ，データサイズ
`define BYTES      (`OPCDBYTE + `ADDRBYTE + `DATABYTE)   // 全Byte
`define UARTMHZ    50000000                              // ペリフェラルヘルツ
`define BAUDRATE   115200                                // ボードレート
`define BAUDSCYCLE `SCYCLE * (`UARTMHZ / `BAUDRATE) * 10 // ボードサイクル

// module cpu_uart_tx_tb (
//     input  wire clock,
//     input  wire reset,
//     output wire tx
// );
module cpu_uart_tx_tb;

reg clock, reset;
wire tx, rx;

// 必要に応じて
integer i, j, k;

// 送信用レジスタ
reg fen = 0;
reg [(`BYTES * `DWIDTH) - 1: 0] fdata = 0;
// 送信用ワイヤ
wire tx2tx, txstart, txbusy, uart_src_done;
wire [7:0] txdata;
assign tx = tx2tx;
// 受信用ワイヤ
wire rxbusy, rxdone, sink_done;
wire [7:0] rxdata;
wire [(`BYTES * `DWIDTH) - 1: 0] sink_data;


reg [(`OPCDBYTE * `DWIDTH) - 1: 0] opcode   = 0;
reg [(`ADDRBYTE * `DWIDTH) - 1: 0] address  = 0;
reg [(`DATABYTE * `DWIDTH) - 1: 0] maindata = 0;

// TXD #(
//     .SCYCLE     (`UARTMHZ       ),
//     .BAUDRATE   (`BAUDRATE      )
// ) uTxd (
//     .CLOCK      (clock          ),
//     .NRESET     (reset          ),
//     .TX         (tx2tx          ),
//     .TXDATA     (txdata         ),
//     .TXSTART    (txstart        ),
//     .TXBUSY     (txbusy         ),
//     .TXDONE     (txdone         )
// );

UART #(
    .SCYCLE             (`UARTMHZ   ),
    .BAUDRATE           (`BAUDRATE  )
) uUART (
    .CLOCK              (clock      ),
    .NRESET             (reset      ),
    // 受信用
    .RX                 (rx         ),
    .RXDATA             (rxdata     ),
    .RXBUSY             (rxbusy     ),
    .RXDONE             (rxdone     ),
    // 送信用
    .TX                 (tx2tx      ),
    .TXDATA             (txdata     ),
    .TXSTART            (txstart    ),
    .TXBUSY             (txbusy     ),
    .TXDONE             (txdone     )
);

UartSink #(
    .BYTES      (`BYTES)
) uUartSink (
    .CLOCK      (clock          ),  
    .NRESET     (reset          ),
    .RXDATA     (rxdata         ),
    .RXDONE     (rxdone         ),
    .DONE       (sink_done      ),
    .DATAO      (sink_data      )
);

UartSource #(
    .BYTES      (`BYTES         )
) uUartSrc (
    .CLOCK      (clock          ),
    .NRESET     (reset          ),
    .FEN        (fen            ),
    .FDATA      (fdata          ),
    .TXSTART    (txstart        ),
    .TXDATA     (txdata         ),
    .TXDONE     (txdone         ),
    .DONE       (uart_src_done  )
);

initial begin
    Init();
end

task Init;
begin
    fen      = 0;
    fdata    = 0;
    opcode   = 0;
    address  = 0;
    maindata = 0;
end
endtask

task TransmitData;
input [(`OPCDBYTE * `DWIDTH) - 1: 0] op;
input [(`ADDRBYTE * `DWIDTH) - 1: 0] addr;
input [(`DATABYTE * `DWIDTH) - 1: 0] data;
begin
    fdata = {op, addr, data};
    fen   = 1'b1;
    #(`SCYCLE * 1);
    fen   = 1'b0;
    while (!uart_src_done) begin
        #(`SCYCLE * 1);
    end
end
endtask

endmodule