// Chattering
// ------------------------------------------------------------------------------------------------
module Chattering (
    input  wire CLOCK,
    input  wire NRESET,
    input  wire SWITCHI,
    output wire SWITCHO
);

/*
Description

    ボタン入力ノイズ軽減

    Parameters
        None

    in  : CLOCK     メイン・クロック
    in  : NRESET    ベガティブ・リセット
    in  : SWITCHI   スイッチ・ボタン
    out : SWITCHO   ノイズ除去後ボタン

*/

// +1 カウント・アップ
// ----------------------------------------------
reg [15:0] cnt; 
wire C_CLOCK = cnt[15];
always @(posedge CLOCK) begin 
    cnt = cnt + 1'b1; 
end

// 入力ロジック
// ----------------------------------------------
reg switch;
assign SWITCHO = switch;
always @(posedge C_CLOCK) begin 
    switch = SWITCHI; 
end
    
endmodule