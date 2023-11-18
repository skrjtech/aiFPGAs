
module COUNTER #(
    parameter 
        SCYCLE = 50_000_000
) (
    input  wire CLK     ,
    input  wire RESET   ,
    output wire COUT
);
    localparam BITS = $clog2(SCYCLE + 1);
    reg [BITS-1:0] CNT;
    assign COUT = (CNT == (SCYCLE - 1));
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) CNT <= 0;
        else if (COUT) CNT <= 0;
        else CNT <= CNT + 1;
    end
    
endmodule