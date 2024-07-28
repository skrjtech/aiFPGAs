`timescale 1us/1ps

`define SCYCLE     20                                    // 50MHz Main Clock
`define DWIDTH     8                                     // ビット幅
`define OPCDBYTE   2                                     // 命令サイズ
`define ADDRBYTE   2                                     // メモリアドレスサイズ
`define DATABYTE   4                                     // メインメモリサイズ，データサイズ
`define BYTES      8                                     // 全Byte
`define UARTMHZ    50000000                              // ペリフェラルヘルツ
`define BAUDRATE   115200                                // ボードレート
`define BAUDSCYCLE (`UARTMHZ / `BAUDRATE * 10) * `SCYCLE // ボードサイクル

module txd_tb;

// 必要に応じて
integer i, j, k;

reg clock;
reg reset;
always #(`SCYCLE / 2) clock = ~clock; // ＿|￣|＿|￣|＿|￣|＿|￣|＿|￣

reg        txstart = `FALSE;
reg [7: 0] txdata  = 8'b00000000;
wire txbusy, txdone, tx;
wire bclk, break;
wire [1:0] state;

TransmitState uTransmitState (
    .iCLOCK     (clock      ),
    .iNRESET    (reset      ),
    .iSTART     (txstart    ),
    .iBCLK      (bclk       ),
    .iBREAK     (break      ),
    .oSTATE     (state      )
);

TransmitBaudrate #(
    .SCYCLE     (`UARTMHZ   ),
    .BAUDRATE   (`BAUDRATE  )
) uTransmitBaudrate (
    .iCLOCK     (clock      ),
    .iNRESET    (reset      ),
    .iSTATE     (state      ),
    .iSTART     (txstart    ),
    .oBCLK      (bclk       ),
    .oBREAK     (break      )
);

Transmit uTransmit (
    .iCLOCK     (clock      ),
    .iNRESET    (reset      ),
    .iSTATE     (state      ),
    .iSTART     (txstart    ),
    .iBCLK      (bclk       ),
    .iBREAK     (break      ),
    .iTXDATA    (txdata     ),
    .oTXBUSY    (txbusy     ),
    .oTXDONE    (txdone     ),
    .oTX        (tx         )
);

initial begin
    $display("state: %d pos: %d", uTransmitState.nstate, uTransmitState.iSTART);
end

initial begin
    clock = 1;
    reset = 0;
    txstart = `FALSE;
    #(`SCYCLE * 1);
    reset = 1;
    #(`SCYCLE * 2);

    // Testing(); // OK!
    // Testing(); // OK!
    // Testing(); // OK!
    PatternA_Send8BitData(); // OK!
    // PatternB_Send8BitData(); // OK!
    // PatternC_Send8BitData(); // OK!
    // PatternD_Send8BitData(); // OK! 例外処理
    // PatternE_Send8BitData(); // OK!
    // PatternF_Send8BitData(); // OK!

    $stop;
end

// テスト用
task Testing;
begin
    txdata  = $urandom(); #(`SCYCLE * 1)
    txstart = 1'b1;       #(`SCYCLE * 1)
    txstart = 1'b0;       #(`SCYCLE * 1)
    #(`BAUDSCYCLE);
    #(`SCYCLE * 1);
end
endtask
// 転送要求切替
task PatternA_Send8BitData;
begin
    txdata  = $urandom();
    txstart = 1'b1;
    // while (!txdone) #(`SCYCLE * 1);
    while (!txdone) begin
        #(`SCYCLE * 1);
        txstart = 1'b0;
        $display("state: %d pos: %d", uTransmitState.nstate, uTransmitState.iSTART);
    end
end
endtask
// 転送要求持続
task PatternB_Send8BitData;
begin
    txdata  = $urandom();
    txstart = 1'b1;
    while (!txdone) #(`SCYCLE * 1);
end
endtask
// 転送連続要求切替
task PatternC_Send8BitData;
begin
    PatternA_Send8BitData();
    PatternA_Send8BitData();
    PatternA_Send8BitData();
end
endtask
// 転送連続要求持続
task PatternD_Send8BitData;
begin
    PatternB_Send8BitData();
    PatternB_Send8BitData();
    PatternB_Send8BitData();
end
endtask
// 転送連続要求切替 1サイクル毎
task PatternE_Send8BitData;
begin
    PatternA_Send8BitData();
    #(`SCYCLE * 1)
    PatternA_Send8BitData();
    #(`SCYCLE * 1)
    PatternA_Send8BitData();
    PatternA_Send8BitData();
end
endtask
// 転送連続要求持続 1サイクル毎
task PatternF_Send8BitData;
begin
    PatternB_Send8BitData();
    #(`SCYCLE * 1)
    PatternB_Send8BitData();
    #(`SCYCLE * 1)
    PatternB_Send8BitData();
    PatternB_Send8BitData();
end
endtask

endmodule