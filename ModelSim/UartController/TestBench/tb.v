`define SCYCLE_50MHZ
// `define SCYCLE_1GHZ
// `define SCYCLE_2P5GMHZ

`ifdef SCYCLE_50MHZ
    `timescale 1ns/100ps
    // 50MHz = 10^9 (GHZ) / 50*10^6 (MHZ)
    `define TB_SCYCLE   20
    `define MAINCLOCK   50_000_000
`elsif SCYCLE_1GHZ
    `timescale 1ps/1ps
    // 1GHz = 10^12 (THZ) / 1*10^9 (GHZ)
    `define TB_SCYCLE   1000
    `define MAINCLOCK   1_000_000_000
`elsif SCYCLE_2P5GMHZ
    `timescale 1ps/1ps
    // 50MHz = 10^12 (THZ) / 2.5*10^9 (MHZ)
    `define TB_SCYCLE   400
    `define MAINCLOCK   2_500_000_000
`endif

`define UART_SETCLOCK   50000000
`define UART_BAUDRATE   115200
`define UART_TOTALBIT   10
`define UART_ONE_SCYCLE (`UART_SETCLOCK / `UART_BAUDRATE * 1) * `TB_SCYCLE
`define UART_ALL_SCYCLE (`UART_SETCLOCK / `UART_BAUDRATE * `UART_TOTALBIT) * `TB_SCYCLE

module tb ();

reg clock;
reg reset;
always #(`TB_SCYCLE / 2) clock = ~clock;

reg          sendReq;
reg  [63: 0] sendDatas;
wire         sendBusy;
wire         sendDone;
wire         tx;
wire         recvRecepttion;
wire [63: 0] recvDatas;
wire         recvDone;
wire         rx;

initial begin
    sendReq   = 1'b0;
    sendDatas = { 64{ 1'b0 } };
end

UartFrameDatas #(
    .SCYCLE    (`MAINCLOCK    ),
    .BAUDRATE  (`UART_BAUDRATE),
    .BYTES     (8             )
) uUartInst (
    .iClock             (clock          ),
    .iNreset            (reset          ),
    .iSendReq           (sendReq        ),
    .iSendDatas         (sendDatas      ),
    .oSendBusy          (sendBusy       ),
    .oSendDone          (sendDone       ),
    .oTx                (tx             ),
    .oRecvRecepttion    (recvRecepttion ),
    .orecvDatas         (recvDatas      ),
    .oRecvDone          (recvDone       ),
    .iRx                (rx             )
);

initial begin
    clock = 1;
    reset = 0;
    #(`TB_SCYCLE * 1);
    reset = 1;
    #(`TB_SCYCLE * 1);

    SendFrame(64'h0FDC_BA98_7654_3210);

    $stop;
end

task SendFrame;
input [63: 0] in;
begin
    sendDatas = in;
    #(`TB_SCYCLE * 1);
    sendReq = 1;
    #(`TB_SCYCLE * 1);
    sendReq = 0;
    while (!sendDone) #(`TB_SCYCLE * 1);
end
endtask
endmodule