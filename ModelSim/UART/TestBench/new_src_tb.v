`timescale 1us/1ps

`define TB_SCYCLE  20                                       // 50MHz Main Clock
`define DWIDTH     8                                        // ビット幅
`define OPCDBYTE   2                                        // 命令サイズ
`define ADDRBYTE   2                                        // メモリアドレスサイズ
`define DATABYTE   4                                        // メインメモリサイズ，データサイズ
`define BYTES      8                                        // 全Byte
`define UARTMHZ    50000000                                 // ペリフェラルヘルツ
`define BAUDRATE   115200                                   // ボードレート
`define BAUDSCYCLE (`UARTMHZ / `BAUDRATE * 10) * `TB_SCYCLE // ボードサイクル

module new_src_txd_tb;

// 必要に応じて
integer i, j, k;

reg clock;
reg reset;
always #(`SCYCLE / 2) clock = ~clock; // ＿|￣|＿|￣|＿|￣|＿|￣|＿|￣

reg        txstart = `FALSE;
reg [63: 0] txdata  = {64{1'b0}};
wire txbusy, txdone, tx;
wire bclk, break;
wire [1:0] state;

UartByteTransmit #(
    .UART_HZ                (50000000   ),
    .BAUDRATE               (115200     )
) uUartByteTxD (
    .i_clock                (clock      ),
    .i_n_reset              (reset      ),
    .i_send_request         (txstart    ),
    .i_data                 (txdata     ),
    .o_busy                 (txbusy     ),
    .o_done                 (txdone)    ,
    .o_tx                   (tx         )
);


wire rxbusy, rxdone;
wire [7: 0] rxdata;
UartRecieve #(
    .UART_HZ                (50000000   ),
    .BAUDRATE               (115200     )
) uUartRxD (
    .i_clock                (clock      ),
    .i_n_reset              (reset      ),
    .i_rx                   (tx         ),
    .o_busy                 (rxbusy     ),
    .o_done                 (rxdone     ),
    .o_data                 (rxdata     )
);

initial begin
    clock = 1;
    reset = 0;
    txstart = `FALSE;
    #(`SCYCLE * 1);
    reset = 1;
    #(`SCYCLE * 1);

    PatternA_Send8BitData();

    $stop;
end

// 転送要求切替
task PatternA_Send8BitData;
begin
    txdata  = {$urandom(), $urandom()};
    txstart = 1'b1;
    while (!txdone) #(`SCYCLE * 1);
end
endtask


endmodule