
`include "../macrostate.v"

module RECIEVEBAUDRATE #(
    parameter 
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600
) (
    input  wire       CLK    ,
    input  wire       RESET  ,
    input  wire [1:0] STATE  ,
    input  wire       START  ,
    output wire       BCLK   ,
    output wire       BREAK
);

localparam BDR      = SCYCLE / BAUDRATE;    // Baudrate
localparam BDR_BITS = $clog2(BDR);          // Baudrate Width Bits

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
            `INIT_MODE: BCNT <= BCNT + 1;
            `BUSY_MODE: BCNT <= (BPOS  ) ? 0 : BCNT + 1;
            `DONE_MODE: BCNT <= 0;
            default:    BCNT <= 0;
        endcase
    end 
end
endmodule