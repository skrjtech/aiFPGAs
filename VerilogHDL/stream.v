
module Streamer #(
    parameter
        DWIDTH = 8
) (
    input  wire                        CLOCK,
    input  wire                        RESET,
    input  wire                        EN,
    input  wire [31:0]                 START, 
    input  wire [31:0]                 LIMIT,
    output reg  [31:0]                 ADDR,
    input  wire [DWIDTH - 1: 0]        DATAI,
    output reg  [DWIDTH - 1: 0]        DATAO,
    output wire                        DONE
);
    
    reg [31: 0] counter = 0;
    wire            pos = ((counter + START) == LIMIT);
    assign DONE = pos;
    always @(posedge CLOCK) begin
        if (~RESET) begin
            counter <= 0;
        end else if (pos) begin
            counter <= 0;
        end else begin
            if (EN) begin
                // ADDR    <= counter + START;
                counter <= counter + 1; 
            end
        end
    end

    always @(*) begin
        if (EN) begin
            DATAO <= DATAI;
        end
        ADDR  <= counter + START;
    end

endmodule