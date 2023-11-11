
module BAUDRATERX #(
    parameter SCYCLE = 50_000_000,
    parameter BAUDRATE = 9600
) (
    input wire CLK,
    input wire RESET,
    input wire BCLEAR,
    output wire BCLK
);

    localparam baudrate_a = (SCYCLE / BAUDRATE);
    localparam baudrate_b = baudrate_a / 2;

    reg [31:0] BCNT;
    wire BC = (BCNT == (baudrate_a - 1));
    assign BCLK = (BCNT == (baudrate_b - 1));
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) BCNT <= 0;
        else if (BC || BCLEAR) BCNT <= 0;
        else BCNT <= BCNT; 
    end
    
endmodule