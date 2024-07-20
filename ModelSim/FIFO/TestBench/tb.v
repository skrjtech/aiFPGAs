`timescale 1ps/1ps
`define RSCYCLE 10
`define WSCYCLE 20

module tb ();
  
    localparam BITS = 8;
    localparam WORDS = 4;
    localparam CAPA = 1 << WORDS;

    reg wclock=1, rclock=1;
    always #(`WSCYCLE / 2) wclock = ~wclock;
    always #(`RSCYCLE / 2) rclock = ~rclock;

    reg reset = 1;

    reg [BITS-1:0] datain=0;
    reg we=0, re=0;
    wire [BITS-1:0] q;
    wire full, empty;
    ASYNCFIFO ufifo (
        .WCLK(wclock), .RCLK(rclock), .RESET(reset), 
        .WE(we), .RE(re), 
        .DATAIN(datain), .Q(q), 
        .FULL(full), .EMPTY(empty)
    );

    integer i;
    initial begin

        reset = 0; #(`WSCYCLE);
        reset = 1;
        for (i = 0; i < 64; i = i + 1) begin
            we = 0;
            re = 0;
            datain = i;
            re = 0; //(~empty) ? 1'b1 : 1'b0 ;
            we = 1;
            #(`WSCYCLE);
        end
        #(`WSCYCLE);
        
        $stop;
    end
endmodule