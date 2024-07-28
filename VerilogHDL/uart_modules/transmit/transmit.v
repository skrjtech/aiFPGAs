`include "../uart_state.v"

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