`timescale 1us/100ps

`define SCYCLE     20                               // 50MHz Main Clock
`define UARTMHZ    50000000                         // ペリフェラルヘルツ
`define BAUDRATE   115200                           // ボードレート
`define BAUDSCYCLE `SCYCLE * (`UARTMHZ / `BAUDRATE) // ボードサイクル

module uart_tb; // メイン

// 必要に応じて
integer i, j, k;

reg clock;
reg reset;
always #(`SCYCLE / 2) clock = ~clock; // ＿|￣|＿|￣|＿|￣|＿|￣|＿|￣

txd_tb u_txd_tb();
rxd_tb u_rxd_tb();
assign u_rxd_tb.rx = u_txd_tb.tx;
always @(*) begin
    // 送信側
    u_txd_tb.clock = clock;
    u_txd_tb.reset = reset;
    // 受信側
    u_rxd_tb.clock = clock;
    u_rxd_tb.reset = reset;
end

// Main Task
initial begin
    clock = 1;
    reset = 0;
    #(`SCYCLE * 1);
    reset = 1;
    #(`SCYCLE * 1);

    for (i = 0; i < 10; i = i + 1) begin
        u_txd_tb.SendData8Bit(8'hAA + i);
    end

    $stop;
end

endmodule

// TxD TestBench
// ------------------------------------------------------------------------------------------------
module txd_tb;

// 必要に応じて
integer i, j, k;

reg clock;
reg reset;

reg       txstart = 0;
reg [7:0] txdata  = 7'b0;
wire txbusy, txdone, tx;

TxD #(
    .SCYCLE     (`UARTMHZ   ), 
    .BAUDRATE   (`BAUDRATE  )
) uTxD (
    .CLOCK      (clock      ), 
    .NRESET     (reset      ), 
    .TX         (tx         ), 
    .TXDATA     (txdata     ), 
    .TXSTART    (txstart    ), 
    .TXBUSY     (txbusy     ), 
    .TXDONE     (txdone     )
);

task SendData8Bit;
input [7:0] data;
reg Break;
begin
    Break = 1'b0;

    txdata = data; 
    txstart = 1; #(`SCYCLE * 1)
    txstart = 0; 
    while (!Break) begin
        #(`SCYCLE * 1);
        Break = (txdone) ? !Break: Break;
    end
end
endtask

task SendBytesData;
input [(`BYTES * `DWIDTH) - 1: 0] data;
reg [31: 0] cnt;
reg         Break;
begin
    cnt = 32'h0;
    while (!(cnt == `BYTES)) begin
        Break = 1'b0;
        txdata  = data[(cnt * 8) +: 8];
        txstart = 1'b1; #(`SCYCLE * 1)
        txstart = 1'b0;
        while (!Break) begin
            #(`SCYCLE * 1);
            Break = (txdone) ? !Break: Break;
        end
        cnt = cnt + 32'h1;
        #(`SCYCLE * 1);
    end 
end
endtask

endmodule

// RxD TestBench
// ------------------------------------------------------------------------------------------------
module rxd_tb;

// 必要に応じて
integer i, j, k;

reg clock;
reg reset;

wire rxbusy, rxdone, rx;
wire [7:0] rxdata;
RxD #(
    .SCYCLE     (`UARTMHZ   ), 
    .BAUDRATE   (`BAUDRATE  )
) uRxD (
    .CLOCK      (clock      ), 
    .NRESET     (reset      ), 
    .RX         (rx         ), 
    .RXDATA     (rxdata     ), 
    .RXBUSY     (rxbusy     ), 
    .RXDONE     (rxdone     )
);

endmodule
