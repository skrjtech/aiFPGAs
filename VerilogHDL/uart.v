
`define IDLE_MODE 1'b0
`define BUSY_MODE 1'b1

// Transmit
// ------------------------------------------------------------------------------------------------
module Transmit (
    input  wire       CLOCK ,
    input  wire       NRESET,
    input  wire       STATE ,
    input  wire       START ,
    input  wire       BCLK  ,
    input  wire       BREAK ,
    input  wire [7:0] TXDATA,
    output wire       TXBUSY,
    output wire       TXDONE,
    output wire       TX
);

reg [8:0] data = 9'hFFF;
reg tx = 1'b1, txbusy = 1'b0, txdone = 1'b0;
assign {TXBUSY, TXDONE, TX} = {txbusy, txdone, tx};

////////////////
// TXSEND 
////////////////
always @(posedge START, posedge BCLK, negedge NRESET) begin
    if (!NRESET) begin
        tx <= 1'b1; 
    end else begin 
        case (STATE)
            `IDLE_MODE: tx <= (START) ? 1'b0    : 1'b1;
            `BUSY_MODE: tx <= (BCLK ) ? data[0] : tx;
            default: ;
        endcase
    end
end
////////////////
// TXDATA 
////////////////
always @(posedge CLOCK, negedge NRESET, posedge START) begin
    if (!NRESET) begin
        data <= 9'hFFF;
    end else begin 
        case (STATE)
            `IDLE_MODE: data <= (START) ? {1'b1, TXDATA}    : 9'hFFF;
            `BUSY_MODE: data <= (BCLK ) ? {1'b1, data[8:1]} : data;
            default: ;
        endcase
    end
end
////////////////
// TXBUSY 
////////////////
always @(posedge START, posedge BREAK, negedge NRESET) begin
    if (!NRESET) begin
        txbusy <= 0;
    end else begin
        case (STATE)
            `IDLE_MODE: txbusy <= (START) ? 1'b1 : 1'b0;
            `BUSY_MODE: txbusy <= (BREAK) ? 1'b0 : 1'b1;
            default: ;
        endcase
    end         
end
////////////////
// TXDONE 
////////////////
always @(posedge CLOCK, posedge BREAK, negedge NRESET) begin
    if (!NRESET) begin
        txdone <= 0;
    end else begin
    case (STATE)
            `IDLE_MODE: txdone <= 1'b0;
            `BUSY_MODE: txdone <= (BREAK) ? 1'b1 : 1'b0;
            default: ;
        endcase 
    end
end

endmodule

// TransmitBaudrate
// ------------------------------------------------------------------------------------------------
module TransmitBaudrate #(
    parameter 
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600
) (
    input  wire CLOCK ,
    input  wire NRESET,
    input  wire STATE ,
    input  wire START ,
    output wire BCLK  ,
    output wire BREAK
);

localparam BDR      = SCYCLE / BAUDRATE;    // Baudrate
localparam BDR_BITS = $clog2(BDR + 1);      // Baudrate Width Bits

reg [31: 0]           numcnt = 0;
reg [BDR_BITS - 1: 0] bcnt   = 0;
assign BCLK  = (bcnt == (BDR - 1'b1));
assign BREAK = ((numcnt == 9) && BCLK);
always @(posedge CLOCK, negedge NRESET) begin
    if (!NRESET)    numcnt <= 32'b0; 
    else if (BREAK) numcnt <= 32'b0;
    else if (BCLK)  numcnt <= numcnt + 1'b1;
    else            numcnt <= numcnt;
end
always @(posedge CLOCK, negedge NRESET) begin
    if (!NRESET) begin
        bcnt <= {BDR_BITS{1'b0}};
    end else begin
        case (STATE)
            `IDLE_MODE: bcnt <= 1'b0;
            `BUSY_MODE: bcnt <= (BCLK) ? {BDR_BITS{1'b0}} : bcnt + 1'b1;
            default: ;
        endcase
    end 
end

endmodule

// TransmitState
// ------------------------------------------------------------------------------------------------
module TransmitState (
    input  wire CLOCK ,
    input  wire NRESET,
    input  wire START ,
    input  wire BCLK  ,
    input  wire BREAK ,
    output wire STATE
);

reg nstate = `IDLE_MODE;
assign STATE = nstate;
always @(START or BREAK or NRESET) begin
    if (!NRESET) begin
        nstate <= `IDLE_MODE;
    end else begin
        case (STATE)
            `IDLE_MODE: nstate <= (START) ? `BUSY_MODE : nstate;
            `BUSY_MODE: nstate <= (BREAK) ? `IDLE_MODE : nstate;
            default: ;
        endcase 
    end
end

endmodule

// TxD
// ------------------------------------------------------------------------------------------------
module TxD #(
    parameter 
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600
) (
    input  wire       CLOCK  ,
    input  wire       NRESET ,
    output wire       TX     ,
    input  wire [7:0] TXDATA ,
    input  wire       TXSTART,
    output wire       TXBUSY ,
    output wire       TXDONE
);

wire txstate;
wire txbclk, txbreak;
TransmitState uTransmitState (
    .CLOCK      (CLOCK       ),
    .NRESET     (NRESET      ),
    .START      (TXSTART     ),
    .BCLK       (txbclk      ),
    .BREAK      (txbreak     ),
    .STATE      (txstate     )
);

TransmitBaudrate #(
    .SCYCLE     (SCYCLE      ),
    .BAUDRATE   (BAUDRATE    )
) uTransmitBaudrate (
    .CLOCK      (CLOCK       ),
    .NRESET     (NRESET      ),
    .START      (TXSTART     ),
    .STATE      (txstate     ),
    .BCLK       (txbclk      ),
    .BREAK      (txbreak     )
);

Transmit uTransmit (
    .CLOCK      (CLOCK       ), 
    .NRESET     (NRESET      ),   
    .STATE      (txstate     ),
    .START      (TXSTART     ),
    .BCLK       (txbclk      ),
    .BREAK      (txbreak     ),    
    .TXDATA     (TXDATA      ),  
    .TXBUSY     (TXBUSY      ),  
    .TXDONE     (TXDONE      ),  
    .TX         (TX          )  
);

endmodule

// Recieve
// ------------------------------------------------------------------------------------------------
module Recieve (
    input  wire       CLOCK ,
    input  wire       NRESET,
    input  wire       STATE ,
    input  wire       START ,
    input  wire       BCLK  ,
    input  wire       BREAK ,
    input  wire       RX    ,
    output wire [7:0] RXDATA,
    output wire       RXBUSY,
    output wire       RXDONE
);

reg [9: 0] data = 10'h00;
reg rxbusy, rxdone;
reg [7: 0] rxdata = 7'b0;
assign {RXBUSY, RXDONE, RXDATA} = {rxbusy, rxdone, rxdata};
////////////////
// RXDATA 
////////////////
always @(posedge BREAK) begin
    if (!NRESET) begin
        rxdata <= 8'h00;
    end else begin 
        rxdata <= data[8:1]; 
    end
end
////////////////
// DATA 
////////////////
always @(posedge START, posedge BCLK, negedge NRESET) begin
    if (!NRESET) begin
        data <= 10'h00;
    end else begin
        case (STATE)
            `IDLE_MODE: data <= (START) ? {RX, 9'h00} : 10'h00;
            `BUSY_MODE: data <= (BCLK ) ? {RX, data[9:1]} : data;
            default: ;
        endcase
    end 
end
////////////////
// RXBUSY 
////////////////
always @(posedge START, posedge BREAK, negedge NRESET) begin
    if (!NRESET) begin
        rxbusy <= 0;
    end else begin
        case (STATE)
            `IDLE_MODE: rxbusy <= (START) ? 1'b1 : 1'b0;
            `BUSY_MODE: rxbusy <= (BREAK) ? 1'b0 : 1'b1;
            default: ;
        endcase
    end
end
////////////////
// RXDONE 
////////////////
always @(posedge CLOCK, posedge BREAK, negedge NRESET) begin
    if (!NRESET) begin
        rxdone <= 0;
    end else begin
    case (STATE)
            `IDLE_MODE: rxdone <= 1'b0;
            `BUSY_MODE: rxdone <= (BREAK) ? 1'b1 : 1'b0;
            default: ;
        endcase 
    end
end

endmodule

// RecieveBaudrate
// ------------------------------------------------------------------------------------------------
module RecieveBaudrate # (
    parameter 
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600
) (
    input  wire CLOCK ,
    input  wire NRESET,
    input  wire STATE ,
    input  wire START ,
    output wire BCLK  ,
    output wire BREAK
);

localparam BDR      = SCYCLE / BAUDRATE;    // Baudrate
localparam BDR_BITS = $clog2(BDR + 1);      // Baudrate Width Bits

reg [3:0]           numcnt = 0;
reg [BDR_BITS-1:0]  bcnt   = 0;                         
assign BCLK  = (bcnt == ((BDR / 2) - 1)); 
wire   BPOS  = (bcnt == (BDR - 1));     
assign BREAK = (numcnt == 9 && BPOS);
always @(posedge CLOCK, negedge NRESET) begin
    if (!NRESET)    numcnt <= 0; 
    else if (BREAK) numcnt <= 0;
    else if (BPOS ) numcnt <= numcnt + 1;
    else            numcnt <= numcnt;
end
always @(posedge CLOCK, negedge NRESET) begin
    if (!NRESET) begin
        bcnt <= 0;
    end else begin
        case (STATE)
            `IDLE_MODE: bcnt <= (START) ? bcnt + 1 : 0;
            `BUSY_MODE: bcnt <= (BPOS ) ? 0 : bcnt + 1;
            default:    bcnt <= 0;
        endcase
    end 
end

endmodule

// RecieveState
// ------------------------------------------------------------------------------------------------
module RecieveState (
    input  wire CLOCK ,
    input  wire NRESET,
    input  wire START ,
    input  wire BCLK  ,
    input  wire BREAK ,
    output wire STATE
);

reg nstate = `IDLE_MODE;
assign STATE = nstate;
// always @(posedge START, posedge BREAK, negedge NRESET) begin
always @(START or BREAK or NRESET ) begin
    if (!NRESET) begin
        nstate <= `IDLE_MODE;
    end else begin
        case (STATE)
            `IDLE_MODE: nstate <= (START ) ? `BUSY_MODE : nstate;
            `BUSY_MODE: nstate <= (BREAK ) ? `IDLE_MODE : nstate;
            default:    nstate <= `IDLE_MODE;
        endcase 
    end
end

endmodule

// RxD
// ------------------------------------------------------------------------------------------------
module RxD #(
    parameter 
        SCYCLE    = 50_000_000,
        BAUDRATE  = 9600
) (
    input  wire       CLOCK ,
    input  wire       NRESET,
    input  wire       RX    ,
    output wire [7:0] RXDATA,
    output wire       RXBUSY,
    output wire       RXDONE
);

wire rxstate;
wire rxbclk, rxbreak;
wire start = !RX;
RecieveState uRecieveState (
    .CLOCK      (CLOCK    ),
    .NRESET     (NRESET   ),
    .START      (start    ),
    .BCLK       (rxbclk   ),
    .BREAK      (rxbreak  ),
    .STATE      (rxstate  )
);
RecieveBaudrate #(
    .SCYCLE     (SCYCLE   ),
    .BAUDRATE   (BAUDRATE )
) uRecieveBaudrate (
    .CLOCK      (CLOCK    ),
    .NRESET     (NRESET   ),
    .START      (start    ),
    .STATE      (rxstate  ),
    .BCLK       (rxbclk   ),
    .BREAK      (rxbreak  )
);
Recieve uRecieve (
    .CLOCK      (CLOCK   ), 
    .NRESET     (NRESET  ),   
    .STATE      (rxstate ),
    .START      (start   ),
    .BCLK       (rxbclk  ), 
    .BREAK      (rxbreak ),  
    .RXDATA     (RXDATA  ),  
    .RXBUSY     (RXBUSY  ),  
    .RXDONE     (RXDONE  ),  
    .RX         (RX      )  
);

endmodule

// UartSource
// ------------------------------------------------------------------------------------------------
module UartSource #(
    parameter
        SCYCLE   = 50000000,
        BAUDRATE = 9600,
        BYTES    = 8,
        DWIDTH   = BYTES * 8
) (
    input  wire                  iCLOCK ,
    input  wire                  iNRESET,
    input  wire                  iFEN,
    input  wire [DWIDTH - 1: 0 ] iFDATA,
    output wire                  oTX,
    output wire                  oDONE
);
/*
Description

    任意バイト送信モージュル

    Parameters
        None

    in  : iCLOCK    メイン・クロック
    in  : iNRESET   ベガティブ・リセット
    in  : iFEN      送信処理実行
    in  : iFDATA    送信用バイドデータ
    out : oTX       Bit送信
    out : oDONE     バイドデータ送信完了通知
*/

// データラッチ用レジスタ
reg [DWIDTH - 1: 0] var_data = {DWIDTH{1'b0}};
// 送信回数カウント・アップレジスタ
reg [31: 0] cnt = 32'b0;
wire    donepos = (cnt == BYTES);
// 送信完了通知レジスタ
reg done = 1'b0;
assign oDONE = done;
// TxD用ワイヤ
wire [7: 0] txdata;
assign txdata = var_data[7:0];
reg txstart = 1'b0;
wire txbusy, txdone, tx;
assign oTX = tx;

TxD #(
    .SCYCLE     (SCYCLE     ),
    .BAUDRATE   (BAUDRATE   )
) uTxD (
    .CLOCK      (iCLOCK     ),
    .NRESET     (iNRESET    ),
    .TXSTART    (txstart    ),
    .TXDATA     (txdata     ),
    .TXBUSY     (txbusy     ),
    .TXDONE     (txdone     ),
    .TX         (tx         )
);

// データラッチ・ビットシフト処理
always @(negedge iNRESET, posedge iFEN, posedge txdone) begin
    if (!iNRESET) begin
        var_data <= {DWIDTH{1'b0}};
    end else begin
        var_data <= (iFEN   ) ? iFDATA        :           // 全バイト送信後に初期化
                    (txdone ) ? var_data >> 8 :           // 8ビットシフト
                    (donepos) ? {DWIDTH{1'b0}}: var_data; // データラッチ
    end
end
// 送信要求処理
always @(posedge iCLOCK, negedge iNRESET) begin
    if (!iNRESET) begin
        txstart <= 1'b0;
    end else begin
        txstart <= (donepos) ? 1'b0:                         // 全バイト送信完了後初期化
                   (txdone ) ? 1'b1:                         // バイト送信完了時に次バイトの送信要求
                   (iFEN   ) ? 1'b1: 1'b0;                   // 送信要求
    end
end
// 送信カウント・アップ処理
always @(negedge iNRESET, posedge txdone, posedge donepos) begin
    if(!iNRESET) begin
        cnt <= 32'b0;
    end else begin
        cnt <= (donepos) ? 32'h0:                           // 全バイト送信後に初期化
               (txdone ) ? cnt + 1'b1: cnt;                 // 1バイト送信毎にカウント・アップ
    end
end
// 送信完了通知処理
always @(posedge iCLOCK, negedge iNRESET, posedge donepos) begin
    if (!iNRESET) begin
        done <= 1'b0;
    end else begin
        done <= (donepos) ? 1'b1: 1'b0;
    end
end

endmodule

// UartSink
// ------------------------------------------------------------------------------------------------
module UartSink #(
    parameter
        SCYCLE   = 50000000,
        BAUDRATE = 9600,
        BYTES    = 8,
        DWIDTH   = BYTES * 8
) (
    input  wire                 iCLOCK ,
    input  wire                 iNRESET,
    input  wire                 iRX,
    output wire                 oRECEPT,
    output wire                 oDONE,
    output wire [DWIDTH - 1: 0] oFDATA
);
/*
Description

    任意バイト受信モジュール

    Parameters
        None

    in  : iCLOCK     メイン・クロック
    in  : iNRESET    ベガティブ・リセット
    in  : iRX        ビット受信
    out : oRECEPT    受信中状態通知
    out : oDONE      全データ受信完了通知
    out : oFDATA     全データ出力
*/

// 受信回数カウント・アップ用レジスタ
reg [31: 0] cnt;
wire donepos = (cnt == BYTES);
// 受信データ格納用レジスタ
reg [DWIDTH - 1: 0] reg_data = {DWIDTH{1'b0}};
reg [DWIDTH - 1: 0] datao    = {DWIDTH{1'b0}};
assign oFDATA = datao;
// 任意バイト受信完了通知用レジスタ
reg done = 1'b0;
assign oDONE = done;
// 受信中状態通知用レジスタ
reg recept = 1'b0;
assign oRECEPT = recept;
// 受信モジュール用ワイヤ
wire [7: 0] rxdata;
wire        rxbusy, rxdone;

RxD #(
    .SCYCLE     (SCYCLE     ),
    .BAUDRATE   (BAUDRATE   )
) uRxD (
    .CLOCK      (iCLOCK     ),
    .NRESET     (iNRESET    ),
    .RX         (iRX        ),
    .RXDATA     (rxdata     ),
    .RXBUSY     (rxbusy     ),
    .RXDONE     (rxdone     )
);

// メイン処理
// ----------------------------------------------
always @(posedge rxdone, negedge iNRESET) begin
    if (!iNRESET) begin
        reg_data <= {DWIDTH{1'b0}};
    end else begin
        reg_data <= (donepos) ? {DWIDTH{1'b0}} :
                    (rxdone ) ? {rxdata, reg_data[DWIDTH - 1: 8]}: reg_data;
    end
end
// 受信回数処理
// ----------------------------------------------
always @(posedge rxdone, posedge donepos, negedge iNRESET) begin
    if (!iNRESET) begin
        cnt <= 32'h0;
    end else begin
        cnt <= (donepos) ? 32'h0:
               (rxdone ) ? cnt + 1'b1: cnt;
    end
end
//　全データ受信完了通知処理
// ----------------------------------------------
always @(posedge iCLOCK, posedge donepos, negedge iNRESET) begin
    if (!iNRESET) begin
        done <= 1'b0;
    end else begin
        done <= (donepos) ? 1'b1: 1'b0;
    end
end
// データ出力処理
// ----------------------------------------------
always @(posedge donepos, negedge iNRESET) begin
    if (!iNRESET) begin
        datao <= {DWIDTH{1'b0}};
    end else begin
        datao <= reg_data;
    end
end
// 受信状態処理
// ----------------------------------------------
always @(posedge iCLOCK, negedge iNRESET, posedge rxbusy) begin
    if (!iNRESET) begin
        recept <= 1'b0;
    end else begin
        recept <= (rxbusy) ? 1'b1:
                  (done  ) ? 1'b0: recept;
    end
end
endmodule


// UartModule
// ------------------------------------------------------------------------------------------------
module UartModule #(
    parameter 
        SCYCLE    = 50_000_000,
        BAUDRATE  = 9600

) (
    input  wire       CLOCK     ,
    input  wire       NRESET    ,
    output wire       TX        ,
    input  wire [7:0] TXDATA    ,
    input  wire       TXSTART   ,
    output wire       TXBUSY    ,
    output wire       TXDONE    ,
    input  wire       RX        ,
    output wire [7:0] RXDATA    ,
    output wire       RXBUSY    ,
    output wire       RXDONE
);

TxD #(
    .SCYCLE     (SCYCLE    ),
    .BAUDRATE   (BAUDRATE  )
) uTxD (
    .CLOCK      (CLOCK     ),
    .NRESET     (NRESET    ),
    .TX         (TX        ),
    .TXDATA     (TXDATA    ),
    .TXSTART    (TXSTART   ),
    .TXBUSY     (TXBUSY    ),
    .TXDONE     (TXDONE    )
);

RxD #(
    .SCYCLE     (SCYCLE    ),
    .BAUDRATE   (BAUDRATE  )
) uRxD (
    .CLOCK      (CLOCK     ),
    .NRESET     (NRESET    ),
    .RX         (RX        ),
    .RXDATA     (RXDATA    ),
    .RXBUSY     (RXBUSY    ),
    .RXDONE     (RXDONE    )
);

endmodule

module UartControllerModule #(
    parameter
        BYTES      = 8,
        DWIDTH     = 8,
        WORDS      = 1024
) (
    input  wire                           iCLOCK,
    input  wire                           iNRESET,
    input  wire                           iUART_RX_IRQ, // 受信時割込
    input  wire [(BYTES * DWIDTH) - 1: 0] iUART_RXDATA, // 受信データ
    output wire                           oUART_TX_REQ, // 送信要求
    input  wire                           iUART_TX_DONE,// 送信完了通知
    output wire [(BYTES * DWIDTH) - 1: 0] oUART_TXDATA, // 送信データ
    output wire [                  15: 0] oADDR_BUS,    // アドレス・バス
    input  wire [                  31: 0] iDATA_BUS,    // データ入力
    output wire [                  31: 0] oDATA_BUS,    // データ出力
    output wire                           oMEM_REQ,     // 書き込み要求
    input  wire                           iGPIO,
    output wire                           oGPIO
);

reg [(BYTES * DWIDTH) - 1: 0] latchdata = {(BYTES * DWIDTH){1'b0}};
always @(*) begin
    latchdata = (iUART_RX_IRQ) ? iUART_RXDATA: latchdata;
end

reg txreq = 1'b0;
assign oUART_TX_REQ = txreq;
reg [(BYTES * DWIDTH) - 1: 0] txdata = {(BYTES * DWIDTH){1'b0}};
assign oUART_TXDATA = txdata;

wire [16: 0] opecode = latchdata[63: 48];
wire [16: 0] address = latchdata[47: 32];
wire [31: 0] datas   = latchdata[31:  0];

reg wreq = 1'b0;
assign oMEM_REQ = wreq;
reg [16: 0] reg_address;
assign oADDR_BUS = reg_address;
reg [31: 0] reg_datas;
assign oDATA_BUS = reg_datas;

reg o_gpio = 1'b0;
assign oGPIO = o_gpio;

reg [3:0] state = 0;

always @(posedge iCLOCK) begin
    case (opecode)
        8'h00: begin // RAMへ書き込み
            wreq <= 1'b1;
            reg_address <= address;
            reg_datas <= datas;
        end 
        8'h01: begin // RAMから読み込み
            case (state)
                0: begin
                    wreq <= 1'b0;
                    reg_address <= address;
                    reg_datas <= iDATA_BUS;
                    state <= 1;
                end
                1: begin
                    txreq <= 1'b1;
                    txdata <= {opecode, reg_address, reg_datas};
                    state <= 2;
                end
                2: begin
                    txreq <= 1'b0;
                    state <= (iUART_TX_DONE) ? 3: state;
                end
                3: begin
                    state <= 0;
                end
                default: ;
            endcase
        end
        8'h02: begin
            o_gpio <= (datas == 1) ? 1'b1: 1'b0; 
        end
        8'h03: begin
            case (state)
                0: begin
                    txdata <= {opecode, reg_address, 32'b0 + iGPIO};
                    state <= 1;
                end
                1: begin
                    state <= (iUART_TX_DONE) ? 2: state;
                end
                2: begin
                    state <= 0;
                end
                default: ;
            endcase
        end
        default: ;
    endcase
end

endmodule