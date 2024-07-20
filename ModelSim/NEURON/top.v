
module BrainMachine #(
    parameter
        DWIDTH = 32
) (
    input wire CLOCK,
    input wire NRESET,

    // UART Interface
    input wire RX,
    output wire TX


);

    reg                  WE;
    reg  [12 - 1: 0]     ADDRES;
    reg  [DWIDTH - 1: 0] DATAIN;
    wire [DWIDTH - 1: 0] DATAOUT;
    BRAM #(
        .DWIDTH(DWIDTH), 
        .WORDS(1 << 12)
    ) map (
        .CLOCK(CLOCK), 
        .WE(WE), 
        .ADDR(ADDRES), 
        .DATAI(DATAIN), 
        .DATAO(DATAOUT)
    );

    // Transmit
    reg TXSTART;
    reg [7:0] TXDATA;
    wire TXDONE, TXBUSY;
    // Recieave
    wire [7:0] RXDATA;
    wire RXBUSY, RXDONE;
    UART #(
        .SCYCLE(50_000_000),
        .BAUDRATE(9600)
    ) uart (
        .CLK(CLOCK),
        .RESET(NRESET),
        .TX(TX),
        .TXDATA(TXDATA),
        .TXSTART(TXSTART),
        .TXBUSY(TXBUSY),
        .TXDONE(TXDONE),
        .RX(RX),
        .RXDATA(RXDATA),
        .RXBUSY(RXBUSY),
        .RXDONE(RXDONE)
    );

    localparam 
        UART_IDLE = 0,
        UART_BUFF = 2,
        UART_DONE = 3;
    reg [31:0] BUFFER;
    reg [1:0] uart_status = UART_IDLE;
    always @(posedge CLOCK, negedge NRESET) begin
        if (!NRESET) begin
            uart_status <= UART_IDLE;
            BUFFER <= {31{1'b0}};
        end else begin
            case (uart_status)
                UART_IDLE: begin
                    BUFFER <= {31{1'b0}};
                    if (RXBUSY) begin
                        uart_status <= UART_BUFF;
                    end else begin
                        uart_status <= UART_IDLE;
                    end
                end
                UART_BUFF: begin
                    if (RXDONE) begin
                        case (RXDATA)
                            // 改行で確定
                            7'h0A: begin
                                uart_status <= UART_DONE;
                            end
                            // 一文字取消
                            7'h0D: begin
                                BUFFER <= {8'b0, BUFFER[31:8]};
                            end
                            default: begin
                                BUFFER <= {BUFFER[23:0], RXDATA};
                            end
                        endcase
                    end
                end
                UART_DONE: begin
                    uart_status <= UART_IDLE;
                end 
                default: uart_status <= UART_IDLE;
            endcase
        end
    end
endmodule