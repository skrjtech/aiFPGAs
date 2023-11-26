
`include "../uart_state.v"

module UNIVERSAL_RECIEVE #(
    parameter
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600,
        BYTES    = 1
) (
    input  wire                   CLK, 
    input  wire                   RESET,
    input  wire                   STATUS,
    output reg  [(BYTES * 8)-1:0] RXDATA,
    input  wire                   RXSTART,
    output reg                    RXBUSY,
    output reg                    RXDONE,
    output wire                   BREAK,

    input  wire [7:0]             RECVDATA,
    input  wire                   RECVDONE
);

    localparam BITS = $clog2(BYTES);
    reg [BITS-1:0] CNT = {BITS{1'b0}};
    assign BREAK = (CNT == BYTES);
    //
    // CONTINUE BYTES COUNTER
    //
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            CNT <= 0;
        end else begin
            case (STATUS)
                `IDLE_MODE: CNT <= 0;
                `BUSY_MODE: CNT <= (RECVDONE) ? CNT + 1: CNT;
                default:    CNT <= 0;
            endcase    
        end
    end
    //
    // RXBUSY 
    //
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            RXBUSY <= 1'b0;
        end else begin
            case (STATUS)
                `IDLE_MODE: RXBUSY <= (~RXSTART) ? 1'b1: 1'b0;
                `BUSY_MODE: RXBUSY <= (BREAK   ) ? 1'b0: 1'b1;
                default:    RXBUSY <= 1'b0;
            endcase
        end
    end
    //
    // RXDONE 
    //
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            RXDONE <= 1'b0;
        end else begin
            case (STATUS)
                `IDLE_MODE: RXDONE <= 1'b0;
                `BUSY_MODE: RXDONE <= (BREAK) ? 1'b1: 1'b0;
                default:    RXDONE <= 1'b0;
            endcase
        end
    end
    //
    // DATA SHIFT 
    //
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            RXDATA <= {(BYTES * 8){1'b0}};
        end else begin
            case (STATUS)
                `IDLE_MODE: RXDATA <= {(BYTES * 8){1'b0}};
                `BUSY_MODE: RXDATA <= (RECVDONE) ? {RECVDATA, RXDATA[(BYTES * 8) - 1:8]}: RXDATA;
                default:    RXDATA <= {(BYTES * 8){1'b0}};
            endcase    
        end
    end

endmodule