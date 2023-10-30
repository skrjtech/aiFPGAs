
module Top (
    input wire CLK,
    input wire RESET,
    output wire OUT
);

    wire SEC1OUT;
    assign OUT = SEC1OUT;
    Counter #(
        .SCYCLE(48_000_000), 
        .BITS(26)
    ) uCounter (
        .CLK(CLK),
        .RESET(RESET),
        .CLKOUT(SEC1OUT)
    );
    
endmodule