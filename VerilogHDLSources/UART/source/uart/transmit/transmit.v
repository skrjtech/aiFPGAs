`include "../states.v"

module TRANSMIT (
    input  wire       CLK     ,
    input  wire       RESET   ,
    input  wire [1:0] STATE   ,
    input  wire       START   ,
    input  wire       BCLK    ,
    input  wire       BREAK   ,
    input  wire [7:0] TXDATA  ,
    output reg        TXBUSY  ,
    output reg        TXDONE  ,
    output wire       TX
);

reg [9:0] data;
assign TX = data[0];
////////////////
// TXDATA 
////////////////
always @(posedge CLK, negedge RESET) begin
    if (~RESET) data <= 10'hFF;
    else begin 
        case (STATE)
            `IDLE_MODE: data <= (START) ? {1'b1, TXDATA, 1'b0}  : 10'hFF;
            `BUSY_MODE: data <= (BCLK ) ? {1'b1, data[9:1]} : data;
            `DONE_MODE: data <= 10'hFF;
            default:    data <= 10'hFF;
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
            `DONE_MODE: TXBUSY <= 1'b0;
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
            `DONE_MODE: TXDONE <= 1'b0;
            default:    TXDONE <= 1'b0;
        endcase 
    end
end
endmodule