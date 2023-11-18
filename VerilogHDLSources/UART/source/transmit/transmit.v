
`include "../definestate.vh"

module TRANSMIT (
    input  wire       CLK     ,
    input  wire       RESET   ,
    input  wire [1:0] STATE   ,
    input  wire       BCLK    ,
    input  wire [7:0] TXDATA  ,
    output reg        TXBUSY  ,
    output reg        TXDONE  ,
    output wire       TX
);

reg [9:0] senddata;
assign TX = senddata[0];
////////////////
// TXDATA 
////////////////
always @(posedge CLK, negedge RESET) begin
    if (~RESET) senddata <= 10'hFF;
    else 
        case (STATE)
            `IDLE_MODE: senddata <= 10'hFF;    
            `INIT_MODE: senddata <= (BCLK) ? {1'b1, TXDATA, 1'b0}  : senddata;
            `BUSY_MODE: senddata <= (BCLK) ? {1'b1, senddata[9:1]} : senddata;
            `DONE_MODE: senddata <= senddata;
            default:    senddata <= 10'hFF;
        endcase
end
////////////////
// TXBUSY 
////////////////
always @(posedge CLK, negedge RESET) begin
    if (~RESET) begin
        TXBUSY <= 0;
    end else begin
        case (STATE)
            `IDLE_MODE: TXBUSY <= 1'b0;
            `INIT_MODE: TXBUSY <= (BCLK) ? 1'b1 : 1'b0;
            `BUSY_MODE: TXBUSY <= 1'b1;
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
            `INIT_MODE: TXDONE <= 1'b0;
            `BUSY_MODE: TXDONE <= 1'b0;
            `DONE_MODE: TXDONE <= 1'b1;
            default:    TXDONE <= 1'b0;
        endcase 
    end
end
endmodule