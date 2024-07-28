`include "../uart_state.v"

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