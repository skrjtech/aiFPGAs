
`include "../uart_state.v"

module UNIVERSAL_RECIEVE_STATE (
    input   wire CLK,
    input   wire RESET,
    input   wire START,
    input   wire BREAK,
    output  wire STATUS
);
    
    reg NEXT_STATUS;
    assign STATUS = NEXT_STATUS;
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            NEXT_STATUS <= `IDLE_MODE;
        end else begin
            case (STATUS)
                `IDLE_MODE: NEXT_STATUS <= (~START) ? `BUSY_MODE : `IDLE_MODE;
                `BUSY_MODE: NEXT_STATUS <= (BREAK ) ? `IDLE_MODE : `BUSY_MODE;
                default:    NEXT_STATUS <= `IDLE_MODE;
            endcase
        end
    end

endmodule