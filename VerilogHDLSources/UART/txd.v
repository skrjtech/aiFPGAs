
module TXD (
    
    input wire  CLK,
    input wire  RESET,
    input wire  BCLK,

    input wire  [7:0] TXDATA,
    input wire  TXSTART,
    output wire TXBUSY,
    output wire TXDONE,
    output wire TX

);

    localparam IDLE_MODE = 0;
    localparam INIT_MODE = 1;
    localparam BUSY_MODE = 2;
    localparam DONE_MODE = 3;

    reg [1:0]   CURR_STATE, NEXT_STATE;
    reg [3:0]   RCOUNT;
    reg [9:0]   SENDDATA;
    assign TX = SENDDATA[0];

    always @(posedge CLK, negedge RESET) begin
        if (~RESET) CURR_STATE <= IDLE_MODE;
        else        CURR_STATE <= NEXT_STATE;
    end

    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
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
                        TXDONE <= 0;
                        TXBUSY <= 0;
                        NEXT_STATE <= IDLE_MODE; 
                    end
                end
                INIT_MODE: begin
                    RCOUNT <= 0;
                    TXBUSY <= 1;
                    SENDDATA <= {1'b1, TXDATA, 1'b0};
                    NEXT_STATE <= BUSY_MODE;
                end
                BUSY_MODE: begin
                    if (RCOUNT < 10 && BCLK) begin
                        SENDDATA <= {1'b1, SENDDATA[9:1]};
                        RCOUNT <= RCOUNT + 1;
                        NEXT_STATE <= BUSY_MODE;
                    end else if (RCOUNT == 10) begin
                        NEXT_STATE <= DONE_MODE;
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