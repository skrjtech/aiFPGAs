`define IDLE_MODE 2'b00
`define INIT_MODE 2'b01
`define BUSY_MODE 2'b10
`define DONE_MODE 2'b11

module TXD (
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
always @(posedge CLK, negedge RESET) begin
    if (~RESET) begin
        TXBUSY <= 0;
        TXDONE <= 0;
        senddata <= 10'hFF;
    end else begin
        case (STATE)
            `IDLE_MODE:  begin
                TXBUSY <= 0;
                TXDONE <= 0;
                senddata <= 10'hFF;    
            end
            `INIT_MODE:  begin
                if (BCLK) begin
                    TXBUSY <= 1;
                    senddata = {1'b1, TXDATA, 1'b0}; 
                end
            end
            `BUSY_MODE: senddata = (BCLK) ? {1'b1, senddata[9:1]} : senddata;
            `DONE_MODE: TXDONE <= 1;
            default: senddata <= 10'hFF;
        endcase
    end
end
endmodule