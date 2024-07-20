
/*
Description

    秒数の数え上げ

    Parameters
        SEC: 秒数指定 (Default: 1sec)

    input  CLOCK : 入力クロック
    input  NRESET: リセット
    output SECOUT: 0 ~ 59

*/

module Timer (
    input  wire        CLOCK , 
    input  wire        NRESET,
    input  wire [31:0] SCYCLE,
    input  wire [31:0] LIMIT ,
    output wire [5:0]  OUT
);

    wire time_pos;
    COUNTER uCNT (
        .CLOCK (CLOCK   ),
        .NRESET(NRESET  ),
        .SCYCLE(SCYCLE  ),
        .OUTP  (time_pos)
    );
    
    reg [5:0] sec;
    always @(posedge time_pos, negedge NRESET) begin
        if (!NRESET) begin
            sec <= 0;
        end
        else begin
            if (sec == (LIMIT - 1)) begin
                sec <= 0;
            end else begin
                sec <= sec + 1'b1;
            end
        end
    end
    
endmodule