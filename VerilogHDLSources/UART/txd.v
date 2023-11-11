
module TXD #(
    parameter SCYCLE = 50_000_000,
    parameter BAUDRATE = 9600
) (
    
    input  wire         CLK,
    input  wire         RESET,
    input  wire [7:0]   TXDATA,
    input  wire         TXSTART,
    output reg          TXBUSY,
    output reg          TXDONE,
    output reg          TX

);

    localparam IDLE_MODE = 0;
    localparam INIT_MODE = 1;
    localparam BUSY_MODE = 2;
    localparam DONE_MODE = 3;

    reg [1:0]   CURR_STATE, NEXT_STATE;
    reg [3:0]   RCOUNT;
    reg [9:0]   SENDDATA; // 10bit {1'b1, Datas, 1'b0}

    wire BCLK;
    reg  BCLEAR;
    BAUDRATETX #(
        .SCYCLE(SCYCLE),
        .BAUDRATE(BAUDRATE)
    ) (
        .CLK(CLK),
        .RESET(RESET),
        .CLEAR(BCLEAR),
        .BCLK(BCLK)
    );

    always @(posedge CLK, negedge RESET) begin
        if (~RESET) CURR_STATE <= IDLE_MODE;
        else        CURR_STATE <= NEXT_STATE;
    end

    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            TX <= 1;
            BCLEAR <= 0;
            TXBUSY <= 0;
            TXDONE <= 0;
            RCOUNT <= 0;
            SENDDATA <= 0;
            NEXT_STATE <= IDLE_MODE;
        end else begin
            case (CURR_STATE)
                IDLE_MODE: begin
                    if (TXSTART) begin
                        NEXT_STATE <= INIT_MODE; 
                    end else begin
                        TX <= 1;
                        TXDONE <= 0;
                        TXBUSY <= 0;
                        BCLEAR <= 1;
                        NEXT_STATE <= IDLE_MODE; 
                    end
                end
                INIT_MODE: begin
                    RCOUNT <= 0;
                    TXBUSY <= 1;
                    BCLEAR <= 0;
                    SENDDATA <= {1'b1, TXDATA, 1'b0};
                    NEXT_STATE <= BUSY_MODE;
                end
                BUSY_MODE: begin
                    if (RCOUNT < 10 && BCLK) begin
                        SENDDATA <= {1'b1, SENDDATA[9:1]};
                        RCOUNT <= RCOUNT + 1;
                        NEXT_STATE <= BUSY_MODE;
                    end else if (RCOUNT == 10) begin
                        TX <= 1;
                        NEXT_STATE <= DONE_MODE;
                    end else begin
                        TX <= SENDDATA[0];
                    end
                end
                DONE_MODE: begin
                    TXDONE <= 1;
                    NEXT_STATE <= IDLE_MODE;
                end
                default: CURR_STATE <= IDLE_MODE;
            endcase
        end
    end

endmodule