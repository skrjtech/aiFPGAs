
module RXD (
    
    input wire CLK,
    input wire RESET,

    input wire BCLK,
    output wire BCLKRESET,

    input wire RX,
    output reg [7:0] RXDATA,
    output reg RXBUSY,
    output reg RXDONE

);
 
    localparam IDLE_MODE = 0;
    localparam INIT_MODE = 1;
    localparam BUSY_MODE = 2;
    localparam DONE_MODE = 3;

    reg [1:0] CURR_STATE, NEXT_STATE;
    reg [3:0] RCOUNT;
    reg [9:0] RECVDATA;

    wire BCLK;
    reg BDSTART;
    BAUDRATERX #(
        .SCYCLE(SCYCLE),
        .BAUDRATE(BAUDRATE)
    ) uBD (
        .CLK(CLK),
        .RESET(RESET),
        .START(BDSTART),
        .BCLK(BCLK)
    );

    always @(posedge CLK, negedge RESET) begin
        if (~RESET) CURR_STATE <= IDLE_MODE;
        else CURR_STATE <= NEXT_STATE;
    end

    always @(posedge CLK) begin
        if (~RESET) begin
            RXDATA <= 0;
            RXBUSY <= 0;
            RXDONE <= 0;
            BDSTART <= 0;
            NEXT_STATE <= IDLE_MODE;
        end else begin
            case (CURR_STATE)
                IDLE_MODE: begin
                    if (~RX) begin
                        BDSTART <= 1;
                        NEXT_STATE <= START_MODE;
                    end
                    RXDONE <= 0;
                    RXBUSY <= 0;
                end
                START_MODE:
                    if (~RX) begin
                        RCOUNT <= 0;
                        RXBUSY <= 1;
                        BDSTART <= 0;
                        NEXT_STATE <= BUSY_MODE;
                    end 
                BUSY_MODE: begin
                    if (RCOUNT < 10) begin
                        if (BCLK) begin
                            RECVDATA[RCOUNT] <= RX;
                            RCOUNT <= RCOUNT + 1;
                        end
                    end else begin
                        RXDATA <= RECVDATA[8:1];
                        NEXT_STATE <= DONE_MODE;
                    end
                end
                DONE_MODE: begin
                    RXBUSY <= 0;
                    RXDONE <= 1;
                    NEXT_STATE <= IDLE_MODE;
                end
                default: CURR_STATE <= 2'bxx;
            endcase
        end
    end
    
endmodule