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

module txd_src_tb;

// 必要に応じて
integer i, j, k;

reg clock = 1;
reg reset = 0;
always #(`SCYCLE / 2) clock = ~clock; // ＿|￣|＿|￣|＿|￣|＿|￣|＿|￣

reg          uart_src_start  = 0;
reg  [63: 0] uart_src_datas  = 0;
wire tx, uart_src_done;

// uart_source_tb u_uart_src_tb();
// always @(*) begin
//     u_uart_src_tb.clock = clock;
//     u_uart_src_tb.reset = reset;
//     u_uart_src_tb.source_start = uart_src_start;
//     u_uart_src_tb.inputData    = uart_src_datas;
// end

// assign uart_src_done = u_uart_src_tb.source_done;

UartSource #(
    .SCYCLE     (`UARTMHZ ),
    .BAUDRATE   (`BAUDRATE)
) uUartSrc (
    .iCLOCK     (clock          ),
    .iNRESET    (reset          ),
    .iFEN       (uart_src_start ),
    .iFDATA     (uart_src_datas ),
    .oTX        (tx             ),
    .oDONE      (uart_src_done  )
);

initial begin
    clock = 1;
    reset = 0;
    #(`SCYCLE * 1);
    reset = 1;
    #(`SCYCLE * 1);

    // host -> kernel
    Testing();
    Testing();
    
    $stop;
end

// テスト用
task Testing;
begin
    uart_src_datas  = {$urandom(), $urandom()};
    uart_src_start = 1'b1; #(`SCYCLE * 1)
    uart_src_start = 1'b0;
    while (!uart_src_done) #(`SCYCLE * 1);
end
endtask
endmodule

module uart_source_tb;

parameter SOURSE_IDLE  = 0;
parameter SOURSE_LATCH = 1;
parameter TXDATA_LATCH = 2;
parameter TXDATA_START = 3;
parameter TXDATA_BUSY  = 4;
parameter SOURSE_DONE  = 5;

reg clock = 1;
reg reset = 0;

reg source_done = 0;
reg source_start = 0;
reg [63: 0] inputData = {0, 0};

reg txstart = 0;
wire tx, txbusy, txdone;
reg [7: 0] txdata = 0;

TxD #(
    .SCYCLE      (`UARTMHZ     ),
    .BAUDRATE    (`BAUDRATE   )
) uTxD (
    .iCLOCK      (clock      ),
    .iNRESET     (reset      ),
    .iTXSTART    (txstart    ),
    .iTXDATA     (txdata     ),
    .oTXBUSY     (txbusy     ),
    .oTXDONE     (txdone     ),
    .oTX         (tx         )
);

reg [63: 0] source_data = {0, 0};

reg [31: 0] cnt = 0;
wire cntpos = (cnt == 8);
reg [3: 0] nstate = 0;
always @(posedge clock, negedge reset) begin
    if (!reset) begin
        nstate <= 0;
    end else begin
        case (nstate)
            SOURSE_IDLE : begin
                source_done <= 0;
                cnt = 0;
                if (source_start) begin
                    nstate <= SOURSE_LATCH;
                end else begin
                    nstate <= SOURSE_IDLE;
                end
            end
            SOURSE_LATCH: begin
                source_data <= inputData;
                nstate <= TXDATA_LATCH;
            end
            TXDATA_LATCH: begin
                {source_data, txdata} <= {source_data, 8'b00000000} >> 8;
                nstate <= TXDATA_START;
            end
            TXDATA_START : begin
                txstart <= 1'b1;
                nstate <= TXDATA_BUSY;
            end
            TXDATA_BUSY  : begin
                txstart <= 1'b0;
                nstate  = (txdone) ? TXDATA_LATCH: TXDATA_BUSY;
                cnt     <= (txdone) ? cnt + 1: cnt;
                nstate  <= (cntpos) ? SOURSE_DONE: nstate;
            end
            SOURSE_DONE : begin
                source_done <= 1;
                nstate <= SOURSE_IDLE;
            end
            default: ;
        endcase
    end
end

function [63: 0] data_shift;
input [63: 0] data;
begin
    data_shift = {8'b00000000, data[63: 8]};
end    
endfunction

endmodule