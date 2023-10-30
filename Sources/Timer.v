
/*
Description

    秒数の数え上げ

    Parameters
        SEC: 秒数指定 (Default: 1sec)

    input CLK:      入力クロック (Default: 50MHz)
    input RESET:    リセット
    output CLKOUT:  出力クロック

*/

module Timer #(
    parameters SEC = 1
) (
    input wire CLK, 
    input wire RESET,
    output wire SECOUT
);

    Counter uCounter1 (
        .CLK(CLK),
        .RESET(RESET),
        .CLKOUT(SECOUT)
    );
    
endmodule