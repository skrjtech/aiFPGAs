
`define IDLE_MODE 1'b0
`define BUSY_MODE 1'b1

module UART_SINK #(
    parameter
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600,
        DWIDTH   = 8 * 6
) (
    input  wire                 CLOCK,
    input  wire                 NRESET,
    input  wire                 RX,
    output wire [DWIDTH - 1: 0] DATAO,
    output wire                 DONE
);

    wire rxbusy, rxdone;
    wire [7:0] rxdata;
    RXD #(
        .SCYCLE  (SCYCLE  ),
        .BAUDRATE(BAUDRATE)
    ) uRxd (
        .CLK   (CLOCK ),
        .RESET (NRESET),
        .RX    (RX    ),
        .RXBUSY(rxbusy),
        .RXDONE(rxdone),
        .RXDATA(rxdata)
    );

    reg flag = 0;
    reg [DWIDTH - 1: 0] reg_data = {1'b1, {DWIDTH-1{1'b0}}};
    assign DONE = flag;
    reg [DWIDTH - 1: 0] datao = 0;
    assign DATAO = datao;
    always @(posedge CLOCK, negedge NRESET) begin
        if (!NRESET || flag) begin
            {reg_data, flag} <= {1'b1, {DWIDTH{1'b0}}};
        end else begin
            if (rxdone) begin
                {reg_data, flag} <= {rxdata, reg_data[DWIDTH - 1: 8]};
                datao            <= {rxdata, datao[DWIDTH - 1: 8]};
            end else begin
                {reg_data, flag} <= {reg_data, flag};
                datao            <= datao;
            end
        end
    end

endmodule

module UART (
    input  wire       CLK       ,
    input  wire       RESET     ,
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

    parameter 
        SCYCLE    = 50_000_000,
        BAUDRATE  = 9600;

    TXD #(
        .SCYCLE     (SCYCLE    ),
        .BAUDRATE   (BAUDRATE  )
    ) uTxd (
        .CLK        (CLK       ),
        .RESET      (RESET     ),
        .TX         (TX        ),
        .TXDATA     (TXDATA    ),
        .TXSTART    (TXSTART   ),
        .TXBUSY     (TXBUSY    ),
        .TXDONE     (TXDONE    )
    );

    RXD #(
        .SCYCLE     (SCYCLE    ),
        .BAUDRATE   (BAUDRATE  )
    ) uRxd (
        .CLK        (CLK       ),
        .RESET      (RESET     ),
        .RX         (RX        ),
        .RXDATA     (RXDATA    ),
        .RXBUSY     (RXBUSY    ),
        .RXDONE     (RXDONE    )
    );

endmodule

module TRANSMIT (
    input  wire       CLK     ,
    input  wire       RESET   ,
    input  wire       STATE   ,
    input  wire       START   ,
    input  wire       BCLK    ,
    input  wire       BREAK   ,
    input  wire [7:0] TXDATA  ,
    output reg        TXBUSY  ,
    output reg        TXDONE  ,
    output reg        TX
);

    reg [8:0] data = 9'hFF;
    initial begin
        TXBUSY = 0;
        TXDONE = 0;
        TX     = 1;
    end
    // assign TX = data[0];
    ////////////////
    // TXSEND 
    ////////////////
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
        TX <= 1'b1; 
        end else begin 
            case (STATE)
                `IDLE_MODE: TX <= (START) ? 1'b0    : 1'b1;
                `BUSY_MODE: TX <= (BCLK ) ? data[0] : TX;
                default:    TX <= 1'b1;
            endcase
        end
    end
    ////////////////
    // TXDATA 
    ////////////////
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            data <= 9'hFF;
        end else begin 
            case (STATE)
                `IDLE_MODE: data <= (START) ? {1'b1, TXDATA}    : 9'hFF;
                `BUSY_MODE: data <= (BCLK ) ? {1'b1, data[8:1]} : data;
                default:    data <= 9'hFF;
            endcase
        end
    end
    ////////////////
    // TXBUSY 
    ////////////////
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            TXBUSY <= 0;
        end else begin
            case (STATE)
                `IDLE_MODE: TXBUSY <= (START) ? 1'b1 : 1'b0;
                `BUSY_MODE: TXBUSY <= (BREAK) ? 1'b0 : 1'b1;
                default:    TXBUSY <= 1'b0;
            endcase
        end         
    end
    ////////////////
    // TXDONE 
    ////////////////
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            TXDONE <= 0;
        end else begin
        case (STATE)
                `IDLE_MODE: TXDONE <= 1'b0;
                `BUSY_MODE: TXDONE <= (BREAK) ? 1'b1 : 1'b0;
                default:    TXDONE <= 1'b0;
            endcase 
        end
    end

endmodule

module TRANSMITBAUDRATE (
    input  wire CLK    ,
    input  wire RESET  ,
    input  wire STATE  ,
    input  wire START  ,
    output wire BCLK   ,
    output wire BREAK
);

    parameter 
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600;

    localparam BDR      = SCYCLE / BAUDRATE;    // Baudrate
    localparam BDR_BITS = $clog2(BDR + 1);      // Baudrate Width Bits

    reg [3:0]           NUMCNT = 0; // 9bit Counter
    reg [BDR_BITS-1:0]  BCNT   = 0;
    assign BCLK  = (BCNT == (BDR - 1));
    assign BREAK = ((NUMCNT == 9) && BCLK);
    always @(posedge CLK, negedge RESET) begin
        if (~RESET)     NUMCNT <= 0; 
        else if (BREAK) NUMCNT <= 0;
        else if (BCLK)  NUMCNT <= NUMCNT + 1;
        else            NUMCNT <= NUMCNT;
    end
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            BCNT <= 0;
        end else begin
            case (STATE)
                `IDLE_MODE: BCNT <= 1'b0;
                `BUSY_MODE: BCNT <= (BCLK) ? 0 : BCNT + 1;
                default:    BCNT <= 0;
            endcase
        end 
    end

endmodule

module TRANSMITSTATE (
    input  wire CLK   ,
    input  wire RESET ,
    input  wire START ,
    input  wire BCLK  ,
    input  wire BREAK ,
    output wire STATE
);

    reg NEXT_STATE = `IDLE_MODE;
    assign STATE = NEXT_STATE;
    always @(posedge CLK, negedge RESET) begin
        if (!RESET) begin
            NEXT_STATE <= `IDLE_MODE;
        end else begin
            case (STATE)
                `IDLE_MODE: NEXT_STATE <= (START) ? `BUSY_MODE : NEXT_STATE;
                `BUSY_MODE: NEXT_STATE <= (BREAK) ? `IDLE_MODE : NEXT_STATE;
                default:    NEXT_STATE <= `IDLE_MODE;
            endcase 
        end
    end

endmodule

module TXD (
    input  wire       CLK     ,
    input  wire       RESET   ,
    output wire       TX      ,
    input  wire [7:0] TXDATA  ,
    input  wire       TXSTART ,
    output wire       TXBUSY  ,
    output wire       TXDONE
);

    parameter 
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600;

    wire txstate;
    wire txbclk, txbreak;
    TRANSMITSTATE uTransmitState (
        .CLK        (CLK         ),
        .RESET      (RESET       ),
        .START      (TXSTART     ),
        .BCLK       (txbclk      ),
        .BREAK      (txbreak     ),
        .STATE      (txstate     )
    );

    TRANSMITBAUDRATE #(
        .SCYCLE     (SCYCLE      ),
        .BAUDRATE   (BAUDRATE    )
    ) uTransmitBaudrate (
        .CLK        (CLK         ),
        .RESET      (RESET       ),
        .START      (TXSTART     ),
        .STATE      (txstate     ),
        .BCLK       (txbclk      ),
        .BREAK      (txbreak     )
    );

    TRANSMIT uTransmit (
        .CLK        (CLK         ), 
        .RESET      (RESET       ),   
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

module RECIEVE (
    input  wire      CLK     ,
    input  wire      RESET   ,
    input  wire      STATE   ,
    input  wire      BCLK    ,
    input  wire      BREAK   ,
    input  wire      RX      ,
    output reg [7:0] RXDATA  ,
    output reg       RXBUSY  ,
    output reg       RXDONE
);

    reg [9:0] data = 10'h00;
    initial begin
        RXDATA = 0;
        RXBUSY = 0;
        RXDONE = 0;
    end
    ////////////////
    // RXDATA 
    ////////////////
    always @(*) begin
        if (~RESET) begin
            RXDATA <= 8'h00;
        end else begin
        if (BREAK) RXDATA <= data[8:1]; 
        end
    end
    ////////////////
    // DATA 
    ////////////////
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            data <= 10'h00;
        end else begin
            case (STATE)
                `IDLE_MODE: data <= (~RX ) ? {RX, 9'h00} : 10'h00;
                `BUSY_MODE: data <= (BCLK) ? {RX, data[9:1]} : data;
                default:    data <= data;
            endcase
        end 
    end
    ////////////////
    // RXBUSY 
    ////////////////
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            RXBUSY <= 0;
        end else begin
            case (STATE)
                `IDLE_MODE: RXBUSY <= (~RX  ) ? 1'b1 : 1'b0;
                `BUSY_MODE: RXBUSY <= (BREAK) ? 1'b0 : 1'b1;
                default:    RXBUSY <= 1'b0;
            endcase
        end
    end
    ////////////////
    // RXDONE 
    ////////////////
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            RXDONE <= 0;
        end else begin
        case (STATE)
                `IDLE_MODE: RXDONE <= 1'b0;
                `BUSY_MODE: RXDONE <= (BREAK) ? 1'b1 : 1'b0;
                default:    RXDONE <= 1'b0;
            endcase 
        end
    end

endmodule

module RECIEVEBAUDRATE (
    input  wire CLK    ,
    input  wire RESET  ,
    input  wire STATE  ,
    input  wire START  ,
    output wire BCLK   ,
    output wire BREAK
);

    parameter 
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600;

    localparam BDR      = SCYCLE / BAUDRATE;    // Baudrate
    localparam BDR_BITS = $clog2(BDR + 1);      // Baudrate Width Bits

    reg [3:0]           NUMCNT = 0;
    reg [BDR_BITS-1:0]  BCNT   = 0;                         
    assign BCLK  = (BCNT == ((BDR / 2) - 1)); 
    wire   BPOS  = (BCNT == (BDR - 1));     
    assign BREAK = (NUMCNT == 9 && BPOS);
    always @(posedge CLK, negedge RESET) begin
        if (~RESET)     NUMCNT <= 0; 
        else if (BREAK) NUMCNT <= 0;
        else if (BPOS ) NUMCNT <= NUMCNT + 1;
        else            NUMCNT <= NUMCNT;
    end
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            BCNT <= 0;
        end else begin
            case (STATE)
                `IDLE_MODE: BCNT <= (~START) ? BCNT + 1 : 0;
                `BUSY_MODE: BCNT <= (BPOS  ) ? 0 : BCNT + 1;
                default:    BCNT <= 0;
            endcase
        end 
    end

endmodule

module RECIEVESTATE (
    input  wire CLK   ,
    input  wire RESET ,
    input  wire START ,
    input  wire BCLK  ,
    input  wire BREAK ,
    output wire STATE
);

    reg NEXT_STATE = `IDLE_MODE;
    assign STATE = NEXT_STATE;
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            NEXT_STATE <= `IDLE_MODE;
        end else begin
            case (STATE)
                `IDLE_MODE: NEXT_STATE <= (~START) ? `BUSY_MODE : NEXT_STATE;
                `BUSY_MODE: NEXT_STATE <= (BREAK ) ? `IDLE_MODE : NEXT_STATE;
                default:    NEXT_STATE <= `IDLE_MODE;
            endcase 
        end
    end

endmodule

module RXD (
    input  wire       CLK       ,
    input  wire       RESET     ,
    input  wire       RX        ,
    output wire [7:0] RXDATA    ,
    output wire       RXBUSY    ,
    output wire       RXDONE
);

    parameter 
        SCYCLE    = 50_000_000,
        BAUDRATE  = 9600;

    wire rxstate;
    wire rxbclk, rxbreak;
    RECIEVESTATE uRecieveState (
        .CLK    (CLK     ),
        .RESET  (RESET   ),
        .START  (RX      ),
        .BCLK   (rxbclk  ),
        .BREAK  (rxbreak ),
        .STATE  (rxstate )
    );
    RECIEVEBAUDRATE #(
        .SCYCLE     (SCYCLE   ),
        .BAUDRATE   (BAUDRATE )
    ) uRecieveBaudrate (
        .CLK        (CLK     ),
        .RESET      (RESET   ),
        .START      (RX      ),
        .STATE      (rxstate ),
        .BCLK       (rxbclk  ),
        .BREAK      (rxbreak )
    );
    RECIEVE uRecieve (
        .CLK    (CLK     ), 
        .RESET  (RESET   ),   
        .STATE  (rxstate ),
        .BCLK   (rxbclk  ), 
        .BREAK  (rxbreak ),  
        .RXDATA (RXDATA  ),  
        .RXBUSY (RXBUSY  ),  
        .RXDONE (RXDONE  ),  
        .RX     (RX      )  
    );

endmodule