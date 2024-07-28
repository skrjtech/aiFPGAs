`timescale 1us/100ps

`define SCYCLE     20                                    // 50MHz Main Clock
`define DWIDTH     8                                     // ビット幅
`define OPCDBYTE   2                                     // 命令サイズ
`define ADDRBYTE   2                                     // メモリアドレスサイズ
`define DATABYTE   4                                     // メインメモリサイズ，データサイズ
`define BYTES      8                                     // 全Byte
`define UARTMHZ    50000000                              // ペリフェラルヘルツ
`define BAUDRATE   115200                                // ボードレート
`define BAUDSCYCLE (`UARTMHZ / `BAUDRATE * 10) * `SCYCLE // ボードサイクル

module rxd_sink_tb;

// 必要に応じて
integer i, j, k;

reg clock = 1;
reg reset = 0;
always #(`SCYCLE / 2) clock = ~clock; // ＿|￣|＿|￣|＿|￣|＿|￣|＿|￣

txd_src_tb u_txd_src_tb();
always @(*) begin
    u_txd_src_tb.clock = clock;
    u_txd_src_tb.reset = reset;
end

wire         uart_sink_recept = 0;
wire [63: 0] uart_sink_datas  = 0;
wire         uart_sink_done;

UartSink #(
    .SCYCLE     (`UARTMHZ        ),
    .BAUDRATE   (`BAUDRATE       )
) uUartSink (
    .iCLOCK     (clock           ),
    .iNRESET    (reset           ),
    .iRX        (u_txd_src_tb.tx ),
    .oRECEPT    (uart_sink_recept),
    .oDONE      (uart_sink_done  ),
    .oFDATA     (uart_sink_datas )
);

initial begin
    clock = 1;
    reset = 0;
    #(`SCYCLE * 1);
    reset = 1;
    #(`SCYCLE * 1);

    // kernel <- host
    u_txd_src_tb.Testing();
    u_txd_src_tb.Testing();

    $stop;
end
endmodule