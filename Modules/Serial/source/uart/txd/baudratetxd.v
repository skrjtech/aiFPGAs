`define IDLE_MODE 2'b00
`define INIT_MODE 2'b01
`define BUSY_MODE 2'b10
`define DONE_MODE 2'b11

module BAUDRATETX #(
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
reg [3:0] NUMCNT;
reg [BITS-1:0] BCNT;
assign BREAK = (NUMCNT == 10);
assign BCLK = (BCNT == ((SCYCLE / BAUDRATE) - 1));
always @(posedge CLK, negedge RESET) begin
    if (~RESET) NUMCNT <= 0; 
    else if (BCLK) NUMCNT <= NUMCNT + 1;
    else if (BREAK) NUMCNT <= 0;
end
always @(posedge CLK, negedge RESET) begin
    if (~RESET) begin
        BCNT <= 0;
    end else begin
        case (STATE)
            `IDLE_MODE:  BCNT <= 0;
            `INIT_MODE:  BCNT <= (BCLK) ? 0 : BCNT + 1;
            `BUSY_MODE:  BCNT <= (BCLK) ? 0 : BCNT + 1;
            `DONE_MODE:  BCNT <= 0;
            default:     BCNT <= 0;
        endcase
    end
end
endmodule