// Counter
// ------------------------------------------------------------------------------------------------
module Counter (
    input  wire        CLOCK,
    input  wire        NRESET,
    input  wire [31:0] SCYCLE,
    output wire        OUTP
);
/*
Description

    ・　カウント・アップ・モジュール

    Parameter 
        None

    in : CLOCK      メイン・クロック　
    in : NRESET     ベガティブ・リセット
    in : SCYCLE     サイクル値
    out: OUTP       パルス発生 
*/

// カウント・アップ処理
// ----------------------------------------------
reg [31:0] cnt;
wire pos = (cnt == (SCYCLE - 1'b1)); // 条件一致で真
assign OUTP = pos;
always @(posedge CLOCK, negedge NRESET) begin
    if (!NRESET || pos) begin
        cnt <= 0;
    end else begin
        cnt <= cnt + 1'b1; 
    end
end
    
endmodule