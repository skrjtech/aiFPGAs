`define IDLE_MODE 2'b00
`define INIT_MODE 2'b01
`define BUSY_MODE 2'b10
`define DONE_MODE 2'b11

module RXD (
    input  wire       CLK     ,
    input  wire       RESET   ,
    input  wire [1:0] STATE   ,
    input  wire       BCLK    ,
    input  wire       RX      ,
    output reg  [7:0] RXDATA  ,
    output reg        RXBUSY  ,
    output reg        RXDONE
);

reg [9:0] recvdata;
always @(posedge CLK, negedge RESET) begin
    if (~RESET) begin
        RXBUSY <= 0;
        RXDONE <= 0;
        recvdata <= 10'h00;
    end else begin
        case (STATE)
            `IDLE_MODE:  begin
                RXBUSY <= 0;
                RXDONE <= 0;
                recvdata <= 10'h00;    
            end
            `INIT_MODE: RXBUSY <= 1;
            `BUSY_MODE: recvdata = (BCLK) ? {RX, recvdata[9:1]} : recvdata;
            `DONE_MODE: begin
                RXDONE <= 1;
                RXDATA <= recvdata[8:1];
            end
            default: recvdata <= 10'h00;
        endcase
    end
end
endmodule