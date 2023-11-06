
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

    reg [15:0] cnt;         // Count
    reg dff;                // Last Bit View
    assign OUTSWITCH = dff; // Output

    always @(posedge clk) begin cnt = cnt + 1; end
    always @(posedge cnt[15]) begin dff = switch; end
    
endmodule