
module BAUDRATETX #(
    parameter SCYCLE = 50_000_000,
    parameter BAUDRATE = 9600
) (
    input wire CLK,
    input wire RESET,
    input wire CLEAR,
    output wire BCLK
);

    localparam baudrate = SCYCLE / BAUDRATE;
    reg [31:0] BCNT;
    assign BCLK = (BCNT == (baudrate - 1));
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) BCNT <= 0;
        else if (BCLK || CLEAR) BCNT <= 0;
        else BCNT <= BCNT + 1;
    end

endmodule
