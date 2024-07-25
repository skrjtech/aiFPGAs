// Timer
// ------------------------------------------------------------------------------------------------
module Timer (
    input  wire        CLOCK , 
    input  wire        NRESET,
    input  wire [31:0] SCYCLE,
    input  wire [31:0] LIMIT ,
    output wire [5:0]  OUT
);
/*
Description

    ・　秒数の数え上げ

    Parameter 
        None

    in : CLOCK      メイン・クロック　
    in : NRESET     ベガティブ・リセット
    in : SCYCLE     ?
    in : LIMIT      秒数制限
    out: OUT        
*/

// Counter Module
// ----------------------------------------------
wire time_pos;
Counter uCnt (
    .CLOCK (CLOCK   ),
    .NRESET(NRESET  ),
    .SCYCLE(SCYCLE  ),
    .OUTP  (time_pos)
);

// 数え上げ処理
// ----------------------------------------------
reg [5:0] sec;
always @(posedge time_pos, negedge NRESET) begin
    if (!NRESET) begin
        sec <= 6'b0;
    end else begin
        if (sec == (LIMIT - 1)) begin
            sec <= 6'b0;
        end else begin
            sec <= sec + 1'b1;
        end
    end
end

endmodule