
/*
Description

    秒数の数え上げ

    Parameters
        SEC: 秒数指定 (Default: 1sec)

    input CLK:          入力クロック (Default: 50MHz)
    input RESET:        リセット
    output [5:0] SECOUT:   0 ~ 59

*/

module Timer #(
    parameter SCYCLE = 50_000_000,
    parameter BITS = 26,
    parameter SEC = 60
) (
    input wire CLK, 
    input wire RESET,
    output wire [5:0] SOUT
);

    reg [5:0] secout;
    assign SOUT = secout;

    wire SEC1POS;
    wire COUT;

    COUNTER #(.SCYCLE(SCYCLE), .BITS(BITS)) uCNT (
        .CLK(CLK),
        .RESET(RESET),
        .SEC1POS(SEC1POS),
        .COUT(COUT)
    );
    
    always @(posedge CLK, negedge RESET) begin
        if (~RESET) secout <= 0;
        else begin
            if (SEC1POS) begin
                if (secout == (SEC - 1)) secout <= 0;
                else secout <= secout + 1;
            end else begin
                secout <= secout;
            end
        end
    end
    
endmodule