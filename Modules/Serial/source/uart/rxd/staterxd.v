`define IDLE_MODE 2'b00
`define INIT_MODE 2'b01
`define BUSY_MODE 2'b10
`define DONE_MODE 2'b11

module RXSTATE (
    input  wire         CLK   ,
    input  wire         RESET ,
    input  wire         START ,
    input  wire         BCLK  ,
    input  wire         BREAK ,
    output reg  [1:0]   STATE
);
reg [1:0] NEXT_STATE;
always @(posedge CLK, negedge RESET) begin
    if (~RESET) STATE = `IDLE_MODE;
    else STATE = NEXT_STATE;
end
always @* begin
    case (STATE)
        `IDLE_MODE: NEXT_STATE = (~START) ? `INIT_MODE : NEXT_STATE;
        `INIT_MODE: NEXT_STATE = (BCLK  ) ? `BUSY_MODE : NEXT_STATE;
        `BUSY_MODE: NEXT_STATE = (BREAK ) ? `DONE_MODE : NEXT_STATE;
        `DONE_MODE: NEXT_STATE = `IDLE_MODE; 
        default:    NEXT_STATE = `IDLE_MODE;
    endcase
end
endmodule