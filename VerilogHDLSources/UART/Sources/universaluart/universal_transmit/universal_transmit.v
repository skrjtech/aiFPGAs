
`include "../uart_state.v"

module UNIVERSAL_TRANSMIT #(
    parameter
        SCYCLE   = 50_000_000,
        BAUDRATE = 9600,
        BYTES    = 1
) (
    input  wire                   CLK, 
    input  wire                   RESET,
    input  wire                   STATUS,
    input  wire [(BYTES * 8)-1:0] TXDATA,
    input  wire                   TXSTART,
    output reg                    TXBUSY,
    output reg                    TXDONE,
    output wire                   BREAK,
    output wire [7:0]             SENDDATA,
    input  wire                   SENDDONE,
    output reg                    SENDSTART
);

    localparam BITS = $clog2(BYTES + 1);

    reg [BITS - 1:0] CNT = {BITS{1'b0}};
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
                `BUSY_MODE: CNT <= (SENDDONE) ? CNT + 1: CNT;
                default:    CNT <= 0;
            endcase
        end
    end
    //
    // TXBUSY 
    //
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            TXBUSY <= 1'b0;    
        end else begin
            case (STATUS)
                `IDLE_MODE: TXBUSY <= 1'b0;
                `BUSY_MODE: TXBUSY <= (BREAK) ? 1'b0: 1'b1;
                default:    TXBUSY <= 1'b0;
            endcase 
        end
    end
    //
    // TXDONE 
    //
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            TXDONE <= 1'b0;
        end else begin
            case (STATUS)
                `IDLE_MODE: TXDONE <= 1'b0;
                `BUSY_MODE: TXDONE <= (BREAK) ? 1'b1: 1'b0;
                default:    TXDONE <= 1'b0;
            endcase
        end
    end
    //
    // DATA SHIFT 
    //
    reg [(BYTES * 8) - 1:0] DATA = {(BYTES * 8){1'b1}};
    assign SENDDATA = DATA[7:0];
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            DATA <= {(BYTES * 8){1'b1}};
        end else begin
            case (STATUS)
                `IDLE_MODE: DATA <= TXDATA;
                `BUSY_MODE: DATA <= (SENDDONE) ? {8'hFF, DATA[(BYTES * 8) - 1:8]}: DATA;
                default:    DATA <= {(BYTES * 8){1'b1}};
            endcase    
        end
    end

    always @(posedge CLK, negedge RESET) begin
        if (~RESET) begin
            SENDSTART <= 1'b0;
        end else begin
            case (STATUS)
                `IDLE_MODE: SENDSTART <= (TXSTART ) ? 1'b1 : 1'b0;
                `BUSY_MODE: SENDSTART <= (SENDDONE && (CNT < (BYTES - 1))) ? 1'b1 : 1'b0;
                default:    SENDSTART <= 1'b0;
            endcase
        end
    end

endmodule