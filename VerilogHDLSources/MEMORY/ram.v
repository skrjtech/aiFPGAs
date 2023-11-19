
module MEMORY #(
    parameter 
        ADDRBITS = 4,
        DATABITS = 4
) (
    input  wire                CLK     ,
    input  wire [ADDRBITS-1:0] ADDR    ,
    input  wire                WE      ,
    input  wire [DATABITS-1:0] DATAIN  ,
    output reg  [DATABITS-1:0] DATAOUT
);

    reg [DATABITS-1:0] MEM [2**ADDRBITS-1:0];
    always @(posedge CLK) begin
        if (WE) MEM[ADDR] <= DATAIN;
        else DATAOUT <= MEM[ADDR];
    end

endmodule