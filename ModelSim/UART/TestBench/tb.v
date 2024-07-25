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

module tb;

// 必要に応じて
integer i, j, k;

reg clock = 0;
reg reset = 0;
always #(`SCYCLE / 2) clock = ~clock; // ＿|￣|＿|￣|＿|￣|＿|￣|＿|￣

wire tx;
cpu_uart_tx_tb u_cpu_uart_tx_tb();
uart_controller_tb u_uart_con_tb();
always @(*) begin
    u_cpu_uart_tx_tb.clock = clock;
    u_cpu_uart_tx_tb.reset = reset;

    u_uart_con_tb.clock = clock;
    u_uart_con_tb.reset = reset;
end
assign tx = u_cpu_uart_tx_tb.tx;
assign u_uart_con_tb.rx = tx;

// Main Run
initial begin
    Init();
    #(`SCYCLE / 2);
    reset = 1;
    for (i = 0; i < 10; i = i + 1) begin
        u_cpu_uart_tx_tb.TransmitData(16'hFF00, 16'h0000, 32'hBAFE_DCBA + i);
    end
    RUN_SCYCLE(1000);
    $stop;
end

task Init;
begin
    clock = 0;
    reset = 0;
end
endtask

task RUN_SCYCLE;
input [31:0] scycle;
begin
    #(`SCYCLE * scycle);
end
endtask

endmodule