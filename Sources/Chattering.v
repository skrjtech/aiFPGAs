
/*
Description

    ボタン入力のノイズを軽減

    Parameters
        None

    input CLK:      入力クロック
    input RESET:    リセット
    input SWITCH:   スイッチ・ボタン
    output OUTSWITCH:  ノイズ除去後ボタン

*/

module Chattering (
    input wire CLK,
    input wire RESET,
    input wire SWITCH,
    output wire OUTSWITCH
);

    // Count
    reg [15:0] cnt; 
    always @(posedge clk) begin
        cnt = cnt + 1;
    end

    // Last Bit View
    reg dff;
    always @(posedge cnt[15]) begin
        dff = switch;
    end

    // Output
    assign OUTSWITCH = dff;

endmodule