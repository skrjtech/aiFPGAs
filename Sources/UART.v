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

    // Tx 
    // 処理コード

    // Rx
    // 処理コード

endmodule

/*
Description

    UART通信送信用BoudRate生成

    Parameters
        RATE: 9600　(Default: 9600)

    input CLK:      入力クロック (Default: 50MHz)
    input RESET:    リセット
    output CLKOUT:  出力クロック

*/

module BoudrateTx(
    input wire CLK,
    input wire [1:0] MODE,
    output wire OUTCLK
);

    reg [11:0] cnt;
    reg block;
    reg [2:0] div;

    always @(posedge CLK) begin
        if(cnt == 12'd1301) cnt = 0;
        else cnt = cnt + 1;        
    end
    always @(posedge CLK) begin
        if(cnt == 12'h000) block = 1'b1;
        else block = 1'b0;
    end
    always @(posedge block) begin
        div = div + 1;
    end
    assign OUTCLK = (MODE == 2'h0) ? block :
                    (MODE == 2'h1) ? div[0] : 
                    (MODE == 2'h2) ? div[1] : div[2];

endmodule

/*
Description

    UART通信送信用Tx

    Parameters
        RATE: 9600　(Default: 9600)

    input CLK:      入力クロック (Default: 50MHz)
    input RESET:    リセット
    output CLKOUT:  出力クロック

*/

module Tx (
    input wire CLK,
    input wire RESET,
    input wire [7:0] TXDATA,
    output wire SOUT
);

    reg [3:0] cnt;

    function BitSel;
        input wire [7:0] data;
        input wire [3:0] i;
        begin
            case (i)
                1: BitSel = 0;
                2: BitSel = dat[0];
                3: BitSel = dat[1];
                4: BitSel = dat[2];
                5: BitSel = dat[3];
                6: BitSel = dat[4];
                7: BitSel = dat[5];
                8: BitSel = dat[6];
                9: BitSel = dat[7];
                default: BitSel = 1;
            endcase 
        end
    endfunction

    always @(posedge CLK, posedge RESET) begin
        if (RESET) begin cnt = 0; end 
        else begin 
            if (cnt != 0) cnt = cnt + 1;
        end
    end
    
    assign SOUT = BitSel(TXDATA, cnt);

endmodule


/*
Description

    UART通信受信用BoudRate生成

    Parameters
        RATE: 9600　(Default: 9600)

    input CLK:      入力クロック (Default: 50MHz)
    input RESET:    リセット
    output CLKOUT:  出力クロック

*/

module BoudrateRx(
    input wire CLK,
    input wire [1:0] MODE,
    output wire OUTCLK
);

    reg [11:0] cnt;
    reg block;
    reg [2:0] div;

    always @(posedge CLK) begin
        if(cnt == 12'd650) cnt = 0;
        else cnt = cnt + 1;        
    end
    always @(posedge CLK) begin
        if(cnt == 12'h000) block = 1'b1;
        else block = 1'b0;
    end
    always @(posedge block) begin
        div = div + 1;
    end
    assign OUTCLK = (MODE == 2'h0) ? block :
                    (MODE == 2'h1) ? div[0] : 
                    (MODE == 2'h2) ? div[1] : div[2];

endmodule

/*
Description

    UART通信受信用Rx

    Parameters
        RATE: 9600　(Default: 9600)

    input CLK:      入力クロック (Default: 50MHz)
    input RESET:    リセット
    output CLKOUT:  出力クロック

*/

module Rx (
    input wire CLK,
    input wire RX,
    output wire [7:0] RXDATA
);

    reg [4:0] cnt;
    reg [7:0] sreg;
    always @(posedge CLK) begin
        if (cnt == 5'h0) begin 
            if (RX == 1'b0) cnt = 5'h1;
        end else begin
            if (cnt == 5'd18) cnt = 5'd0;
            else cnt = cnt + 1;
        end
    end
    always @(posedge CLK) begin
        if (cnt[0] == 1'b1) sreg = {RX, sreg[7:1]};
    end    
    assign RXDATA = sreg;

endmodule
