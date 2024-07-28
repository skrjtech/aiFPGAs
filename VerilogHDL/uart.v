`include "uart_modules/uart.v"

module UartFrameDatas #(
    parameter 
        SCYCLE    = 50_000_000,
        BAUDRATE  = 9600,
        BYTES     = 8,
        DWIDTH    = 8,
        _D        = BYTES * DWIDTH
) (
    input  wire             iClock,
    input  wire             iNreset,
    input  wire             iSendReq,
    input  wire [_D - 1: 0] iSendDatas,
    output wire             oSendBusy,
    output wire             oSendDone,
    output wire             oTx,
    output wire             oRecvRecepttion,
    output wire [_D - 1: 0] orecvDatas,
    output wire             oRecvDone,
    input  wire             iRx
);

localparam False = 1'b0;
localparam True  = 1'b1;

localparam STATE_IDLE = 5'h00;
localparam STATE_BUSY = 5'h01;

reg [4: 0] state, nextState;
reg [4: 0] sendingCounter;      // Max Send 32 Bytes

reg [_D: 0] sendDatas;
reg [_D: 0] recvDatas;

reg txStart;
wire [DWIDTH - 1: 0] txData;
wire txBusy, txDone;
wire [DWIDTH - 1: 0] rxData;
wire rxBusy, rxDone;

// assign sendingCounterPos = (sendingCounter == BYTES - 1 && txDone) ? True: False;
assign            txData = sendDatas[7: 0];
assign         oSendBusy = (nextState == STATE_BUSY)  ? True: False;
assign         oSendDone = (sendingCounter == BYTES - 1 && txDone) ? True: False;

initial begin
    txStart        = False;
    state          = STATE_IDLE;
    nextState      = STATE_IDLE;
    sendingCounter = {  5{ 1'b0 } };
    sendDatas      = { _D{ 1'b0 } };
    recvDatas      = { _D{ 1'b0 } };
end

UART #(
    .SCYCLE     (SCYCLE     ),
    .BAUDRATE   (BAUDRATE   )
) uUart (
    .CLK        (iClock     ),
    .RESET      (iNreset    ),
    .TX         (oTx        ),
    .TXDATA     (txData     ),
    .TXSTART    (txStart    ),
    .TXBUSY     (txBusy     ),
    .TXDONE     (txDone     ),
    .RX         (iRx        ),
    .RXDATA     (rxData     ),
    .RXBUSY     (rxBusy     ),
    .RXDONE     (rxDone     )
);

// ----------------------------------------------
// 送信用
// ----------------------------------------------

// ステート制御
// ----------------------------------------------
always @(posedge iClock, negedge iNreset) begin
    if (!iNreset) begin
        state <= STATE_IDLE;
    end else begin
        state <= nextState;
    end
end
always @(*) begin
    case (state)
        STATE_IDLE: nextState = ( iSendReq  ) ? STATE_BUSY: nextState;
        STATE_BUSY: nextState = ( oSendDone ) ? STATE_IDLE: nextState;
        default: nextState = STATE_IDLE;
    endcase
end
// 送信要求
// ----------------------------------------------
always @(posedge iClock, negedge iNreset) begin
    if (!iNreset) begin
        txStart = False;
    end else if (iSendReq || txDone) begin
        txStart = True;
    end else begin
        txStart = False;
    end
end
// データセット
// ----------------------------------------------
always @(posedge iClock, negedge iNreset) begin
    if (!iNreset) begin
        sendDatas <= { _D{ 1'b0 } };
    end else if (iSendReq) begin
        sendDatas <= iSendDatas;
    end else if (txDone) begin
        sendDatas <= sendDatas >> DWIDTH;
    end else begin
        sendDatas <= sendDatas;
    end
end
// 送信回数カウント
// ----------------------------------------------
always @(posedge iClock, negedge iNreset) begin
    if (!iNreset) begin
        sendingCounter <= { 5{ 1'b0 } };
    end else if (txDone) begin
        sendingCounter <= sendingCounter + 5'h01;
    end else begin
        sendingCounter <= sendingCounter;
    end
end

// ----------------------------------------------
// 受信用
// ----------------------------------------------

endmodule

module Inst_UartFrameDatas ();

UartFrameDatas #(
    .SCYCLE    (50_000_000),
    .BAUDRATE  (9600),
    .BYTES     (8)
) uUartInst (
    .iClock             (clock          ),
    .iNreset            (nReset         ),
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


endmodule