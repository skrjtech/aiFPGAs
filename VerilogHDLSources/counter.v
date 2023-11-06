
/*
Description

    入力クロックから指定の出力クロックに変換

    Parameters
        SCYCLE: 出力周波数の設定　         (Default: 50MHz)
        BITS:   出力周波数用格納ビット数    (Default: 26Bits [ceil(Log(50 x 10^6) / Log(2)))])  

    input CLK:      入力クロック
    input RESET:    リセット
    output CLKOUT:  出力クロック

*/

module COUNTER #(
    parameter SCYCLE = 50_000_000,
    parameter BITS = 26
) (
    input wire CLK,
    input wire RESET,
    output wire COUT
);

    reg [BITS-1:0] CNT;
    assign COUT = (CNT == (SCYCLE - 1));
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) CNT <= 0;
        else if (COUT) CNT <= 0;
        else CNT <= CNT + 1;
    end
    
endmodule