`include "../macrostate.v"

module RECIEVE (

    input  wire       CLK     ,
    input  wire       RESET   ,
    input  wire [1:0] STATE   ,
    input  wire       BCLK    ,
    input  wire       BREAK   ,
    input  wire       RX      ,
    output wire [7:0] RXDATA  ,
    output reg        RXBUSY  ,
    output reg        RXDONE

);

reg [9:0] recvdata = 10'h00;
assign RXDATA = recvdata[8:1];
////////////////
// RXDATA 
////////////////
always @(posedge CLK, negedge RESET) begin
    if (~RESET) begin
        recvdata <= 10'h00;
    end else begin
        case (STATE)
            `IDLE_MODE: recvdata <= (~RX ) ? {RX, 9'h00} : recvdata;
            `INIT_MODE: recvdata <= recvdata;
            `BUSY_MODE: recvdata <= (BCLK) ? {RX, recvdata[9:1]} : recvdata;
            `DONE_MODE: recvdata <= recvdata;
            default:    recvdata <= recvdata;
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
            `INIT_MODE: RXBUSY <= 1'b1;
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
            `INIT_MODE: RXDONE <= 1'b0;
            `BUSY_MODE: RXDONE <= (BREAK) ? 1'b1 : 1'b0;
            `DONE_MODE: RXDONE <= 1'b0;
            default:    RXDONE <= 1'b0;
        endcase 
    end
end
endmodule