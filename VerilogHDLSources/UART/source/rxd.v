
module RXD #( 
    parameter 
        SCYCLE = 50_000_000   ,
        BAUDRATE = 9600       ,
        BITS = 32
) (
    
    input  wire      CLK     ,
    input  wire      RESET   ,
    input  wire      RX      ,
    output reg [7:0] RXDATA  ,
    output reg       RXCATCH ,
    output reg       RXBUSY  ,
    output reg       RXDONE 

);
 
    localparam IDLE_MODE = 2'b00;
    localparam INIT_MODE = 2'b01;
    localparam BUSY_MODE = 2'b10;
    localparam DONE_MODE = 2'b11;

    reg [1:0] CURR_STATE, NEXT_STATE;
    reg [3:0] RCOUNT;
    reg [9:0] RECVDATA;

    wire BCLK;
    BAUDRATERX #(
        .SCYCLE     (SCYCLE     ),
        .BAUDRATE   (BAUDRATE   ),
        .BITS       (BITS       )
    ) uBD (
        .CLK    (CLK        ),
        .RESET  (RESET      ),
        .STATE  (CURR_STATE ),
        .BCLK   (BCLK       )
    );

    always @(posedge CLK, negedge RESET) begin
        if (~RESET) CURR_STATE <= IDLE_MODE;
        else CURR_STATE <= NEXT_STATE;
    end

    always @* begin
        RXDATA <= RECVDATA[8:1];
    end

    always @(posedge CLK) begin
        if (~RESET) begin
            RXBUSY <= 0;
            RXDONE <= 0;
            NEXT_STATE <= IDLE_MODE;
        end else begin
            case (CURR_STATE)
                IDLE_MODE: begin
                    if (~RX) begin
                        RXCATCH <= 1;
                        NEXT_STATE <= INIT_MODE;
                    end else begin
                        RXDONE <= 0;
                        RXBUSY <= 0;
                    end
                end
                INIT_MODE:
                    if (~RX) begin
                        RCOUNT <= 0;
                        RXBUSY <= 1;
                        NEXT_STATE <= BUSY_MODE;
                    end 
                BUSY_MODE: begin
                    if (RCOUNT < 10 && BCLK) begin
                        RECVDATA <= {RX, RECVDATA[9:1]};
                        RCOUNT <= RCOUNT + 1;
                    end else if (RCOUNT == 10) begin
                        NEXT_STATE <= DONE_MODE;
                    end
                end
                DONE_MODE: begin
                    RXBUSY <= 0;
                    RXDONE <= 1;
                    RXCATCH <= 0;
                    NEXT_STATE <= IDLE_MODE;
                end
                default: CURR_STATE <= IDLE_MODE;
            endcase
        end
    end
    
endmodule