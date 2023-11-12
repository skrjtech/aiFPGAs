`define IDLE_MODE 2'b00
`define INIT_MODE 2'b01
`define BUSY_MODE 2'b10
`define DONE_MODE 2'b11

module BAUDRATERX #(
    parameter SCYCLE = 50_000_000,
    parameter BAUDRATE = 9600,
    parameter BITS = 32
) (
    input  wire       CLK    ,
    input  wire       RESET  ,
    input  wire [1:0] STATE  ,
    output wire       BCLK   ,
    output wire       BREAK
);
reg [3:0] NUMCNT;                                       // 受信回数・カウント
reg [BITS-1:0] BCNT;                                    // ボードレート・カウント
assign BREAK = (NUMCNT == 10);                          // 受信回数達成立ち上がり
assign BCLK  = (BCNT == ((SCYCLE / BAUDRATE / 2) - 1)); // 受信タイミング
wire   BPOS  = (BCNT == ((SCYCLE / BAUDRATE) - 1));     // 受信回数・カウント立ち上がり
always @(posedge CLK, negedge RESET) begin
    if (~RESET) NUMCNT <= 0; 
    else if (BREAK) NUMCNT <= 0;
    else if (BPOS ) NUMCNT <= NUMCNT + 1;
end
always @(posedge CLK, negedge RESET) begin
    if (~RESET) begin
        BCNT <= 0;
    end else begin
        case (STATE)
            `IDLE_MODE:  BCNT <= 0;
            `INIT_MODE:  BCNT <= (BPOS) ? 0 : BCNT + 1;
            `BUSY_MODE:  BCNT <= (BPOS) ? 0 : BCNT + 1;
            `DONE_MODE:  BCNT <= 0;
            default:     BCNT <= 0;
        endcase
    end
end
endmodule