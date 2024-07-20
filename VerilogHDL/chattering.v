
/*
Description

    ボタン入力のノイズを軽減

    Parameters
        None

    input  CLOCK  :  入力クロック
    input  NRESET :  リセット
    input  SWITCHI:  スイッチ・ボタン
    output SWITCHO:  ノイズ除去後ボタン

*/

module CHATTERING (
    input  wire CLOCK,
    input  wire NRESET,
    input  wire SWITCHI,
    output wire SWITCHO
);

    reg [15:0] cnt; 
    wire C_CLOCK = cnt[15];
    always @(posedge CLOCK) begin 
        cnt = cnt + 1'b1; 
    end
    
    reg switch;
    assign SWITCHO = switch;
    always @(posedge C_CLOCK) begin 
        switch = SWITCHI; 
    end
    
endmodule