
module BAUDRATETX #(
    parameter 
        SCYCLE = 50_000_000,
        BAUDRATE = 9600,
        BITS = 32
) (
    input  wire       CLK   ,
    input  wire       RESET ,
    input  wire [1:0] STATE ,
    output wire       BCLK
);

    localparam IDLE_MODE = 2'b00;
    localparam INIT_MODE = 2'b01;
    localparam BUSY_MODE = 2'b10;
    localparam DONE_MODE = 2'b11;

    reg [BITS-1:0] BCNT;
    assign BCLK = (BCNT == ((SCYCLE / BAUDRATE) - 1));
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            BCNT <= 0;
        end else begin
            case (STATE)
                IDLE_MODE:  begin
                    BCNT <= 0;
                end
                INIT_MODE:  begin
                    BCNT <= 0;
                end
                BUSY_MODE:  begin
                    if (BCLK) BCNT <= 0;
                    else BCNT <= BCNT + 1;
                end
                DONE_MODE:  begin
                    BCNT <= 0;
                end 
                default: BCNT <= 0;
            endcase
        end
    end

endmodule
