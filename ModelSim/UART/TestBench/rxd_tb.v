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

module rxd_tb;

// 必要に応じて
integer i, j, k;

reg clock = 1;
reg reset = 0;
always #(`SCYCLE / 2) clock = ~clock; // ＿|￣|＿|￣|＿|￣|＿|￣|＿|￣

wire [7: 0] rxdata;
wire rxbusy, rxdone, rx;
wire bclk, break;
wire [1:0] state;

txd_tb u_txd_tb();
always @(*) begin
    u_txd_tb.clock = clock;
    u_txd_tb.reset = reset;
end

assign rx = u_txd_tb.tx;
wire start = !rx;

RecieveState uRecieveState (
    .iCLOCK     (clock      ),
    .iNRESET    (reset      ),
    .iSTART     (start      ),
    .iBCLK      (bclk       ),
    .iBREAK     (break      ),
    .oSTATE     (state      )
);

RecieveBaudrate #(
    .SCYCLE     (`UARTMHZ   ),
    .BAUDRATE   (`BAUDRATE  )
) uRecieveBaudrate (
    .iCLOCK     (clock      ),
    .iNRESET    (reset      ),
    .iSTATE     (state      ),
    .iSTART     (start      ),
    .oBCLK      (bclk       ),
    .oBREAK     (break      )
);

Recieve uRecieve (
    .iCLOCK     (clock  ),
    .iNRESET    (reset  ),
    .iSTATE     (state  ),
    .iSTART     (start  ),
    .iBCLK      (bclk   ),
    .iBREAK     (break  ),
    .iRX        (rx     ),
    .oRXDATA    (rxdata ),
    .oRXBUSY    (rxbusy ),
    .oRXDONE    (rxdone )
);

// initial begin
//     clock = 1;
//     reset = 0;
//     #(`SCYCLE * 1);
//     reset = 1;
//     #(`SCYCLE * 1);
    
//     u_txd_tb.Testing(); // OK!
//     u_txd_tb.Testing(); // OK!
//     u_txd_tb.PatternA_Send8BitData(); // OK!
//     u_txd_tb.PatternB_Send8BitData(); // OK!
//     u_txd_tb.PatternC_Send8BitData(); // OK!
//     u_txd_tb.PatternD_Send8BitData(); // OK! 例外処理
//     u_txd_tb.PatternE_Send8BitData(); // OK!
//     u_txd_tb.PatternF_Send8BitData(); // OK!
    
//     $stop;
// end
endmodule