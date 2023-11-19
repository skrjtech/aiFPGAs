`include "../states.v"

module RECIEVE (
    input  wire       CLK     ,
    input  wire       RESET   ,
    input  wire [1:0] STATE   ,
    input  wire       BCLK    ,
    input  wire       BREAK   ,
    input  wire       RX      ,
    output reg  [7:0] RXDATA  ,
    output reg        RXBUSY  ,
    output reg        RXDONE
);

reg [9:0] data = 10'h00;
always @(posedge BREAK) begin
    RXDATA <= data[8:1];
end
////////////////
// RXDATA 
////////////////
always @(posedge CLK, negedge RESET) begin
    if (~RESET) begin
        data <= 10'h00;
    end else begin
        case (STATE)
            `IDLE_MODE: data <= (~RX ) ? {RX, 9'h00} : 10'h00;
            `BUSY_MODE: data <= (BCLK) ? {RX, data[9:1]} : data;
            `DONE_MODE: data <= 10'h00;
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
            `DONE_MODE: RXBUSY <= 1'b0;
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
            `DONE_MODE: RXDONE <= 1'b0;
            default:    RXDONE <= 1'b0;
        endcase 
    end
end
endmodule