/*
Description

    UART通信構成

    Parameters
        RATE: 9600　(Default: 9600)

    input CLK:      入力クロック (Default: 50MHz)
    input RESET:    リセット
    output CLKOUT:  出力クロック

*/

module UART #(
    parameters RATE = 9600
) (
    input wire CLK,
    input wire RESET,

    input wire [7:0] TXDATA,
    input wire TXSTART,
    output wire TXDONE,
    output wire TX,
    
    output wire [7:0] RXDATA,
    output wire RXDONE,
    input wire RX
);

    Boudrate uBoudRate1 #(RATE) (
        .CLK(CLK),
        .RESET(RESET),
        .OUTCLK(OUTCLK)
    );

    // Tx 
    // 処理コード

    // Rx
    // 処理コード

endmodule

/*
Description

    UART通信構成BoudRate生成

    Parameters
        RATE: 9600　(Default: 9600)

    input CLK:      入力クロック (Default: 50MHz)
    input RESET:    リセット
    output CLKOUT:  出力クロック

*/

module Boudrate #(
    parameters RATE = 9600
) (
    input wire CLK,
    input wire RESET,
    output wire OUTCLK
);
    
endmodule

/*
Description

    UART通信構成BoudRate生成

    Parameters
        RATE: 9600　(Default: 9600)

    input CLK:      入力クロック (Default: 50MHz)
    input RESET:    リセット
    output CLKOUT:  出力クロック

*/

module TxD (
    ports
);
    
endmodule


module RxD (
    ports
);
    
endmodule