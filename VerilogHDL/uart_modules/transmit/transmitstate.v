`include "../uart_state.v"

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