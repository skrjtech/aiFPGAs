
`include "../macrostate.vh"

module RECIEVESTATE (
    input  wire         CLK   ,
    input  wire         RESET ,
    input  wire         START ,
    input  wire         BCLK  ,
    input  wire         BREAK ,
    output wire  [1:0]  STATE
);
reg [1:0] NEXT_STATE;
assign STATE = NEXT_STATE;
// always @(posedge CLK, negedge RESET) begin
//     if (~RESET) STATE = `IDLE_MODE;
//     else STATE = NEXT_STATE;
// end
always @(posedge CLK, negedge RESET) begin
    if (~RESET) begin
        NEXT_STATE <= `IDLE_MODE;
    end else begin
       case (STATE)
            `IDLE_MODE: NEXT_STATE = (~START) ? `INIT_MODE : NEXT_STATE;
            `INIT_MODE: NEXT_STATE = (BCLK  ) ? `BUSY_MODE : NEXT_STATE;
            `BUSY_MODE: NEXT_STATE = (BREAK ) ? `DONE_MODE : NEXT_STATE;
            `DONE_MODE: NEXT_STATE = `IDLE_MODE; 
            default:    NEXT_STATE = `IDLE_MODE;
        endcase 
    end
end
endmodule