
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
    parameters SEC = 60
) (
    input wire CLK, 
    input wire RESET,
    output wire [5:0] SECOUT
);

    wire pos1sec;
    reg [5:0] cnt;
    assign SECOUT = cnt;

    Counter uCounter1 (
        .CLK(CLK),
        .RESET(RESET),
        .CLKOUT(SECOUT)
    );
    
    always @(posedge pos1sec, negedge reset) begin
        if (~reset) cnt <= 0;
        else if (cnt == (SEC - 1)) cnt <= 0;
        else cnt <= cnt + 1;
    end
    
endmodule