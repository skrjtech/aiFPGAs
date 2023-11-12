
module TXD #(
    parameter 
        SCYCLE = 50_000_000   ,
        BAUDRATE = 9600       ,
        BITS = 32
) (
    
    input  wire         CLK     ,
    input  wire         RESET   ,
    input  wire [7:0]   TXDATA  ,
    input  wire         TXSTART ,
    output reg          TXBUSY  ,
    output reg          TXDONE  ,
    output reg          TX

);

    localparam IDLE_MODE = 2'b00;
    localparam INIT_MODE = 2'b01;
    localparam BUSY_MODE = 2'b10;
    localparam DONE_MODE = 2'b11;

    reg [1:0]   CURR_STATE, NEXT_STATE;
    reg [3:0]   RCOUNT;
    reg [9:0]   SENDDATA; // 10bit {1'b1, Datas, 1'b0}

    wire BCLK;
    BAUDRATETX #(
        .SCYCLE     (SCYCLE     ),
        .BAUDRATE   (BAUDRATE   ),
        .BITS       (BITS       )
    ) uDB (
        .CLK    (CLK            ),
        .RESET  (RESET          ),
        .STATE  (CURR_STATE     ),
        .BCLK   (BCLK           )
    );

    always @(posedge CLK, negedge RESET) begin
        if (~RESET) CURR_STATE <= IDLE_MODE;
        else        CURR_STATE <= NEXT_STATE;
    end

    always @* begin
        TX <= SENDDATA[0];
    end

    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            TXBUSY <= 0;
            TXDONE <= 0;
            RCOUNT <= 0;
            SENDDATA <= 10'hFF;
            NEXT_STATE <= IDLE_MODE;
        end else begin
            case (CURR_STATE)
                IDLE_MODE:  begin
                    if (TXSTART) begin
                        NEXT_STATE <= INIT_MODE; 
                    end else begin
                        TXBUSY <= 0;
                        TXDONE <= 0;
                        RCOUNT <= 0;
                        SENDDATA <= 10'hFF;
                        NEXT_STATE <= IDLE_MODE; 
                    end
                end
                INIT_MODE:  begin
                    RCOUNT <= 0;
                    TXBUSY <= 1;
                    SENDDATA <= {1'b1, TXDATA, 1'b0};
                    NEXT_STATE <= BUSY_MODE;
                end
                BUSY_MODE:  begin
                    if (RCOUNT < 10 && BCLK) begin
                        SENDDATA <= {1'b1, SENDDATA[9:1]};
                        RCOUNT <= RCOUNT + 1;
                    end else if (RCOUNT == 10) begin
                        NEXT_STATE <= DONE_MODE;
                    end
                end
                DONE_MODE:  begin
                    TXDONE <= 1;
                    NEXT_STATE <= IDLE_MODE;
                end
                default: CURR_STATE <= IDLE_MODE;
            endcase
        end
    end

endmodule