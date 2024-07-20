`timescale 1us/1ps
`define SCYCLE 20

`define RANDOMMAX +2147483647
`define RANDOMMIN -2147483648

module single_core_tb;

    localparam 
        DWIDTH = 32, 
        WORDS = 1 << 12, 
        SIZE = $clog2(WORDS);

    reg clock = 1, reset = 0;
    always #(`SCYCLE / 2) clock = ~clock;

    reg                  start;
    reg  [DWIDTH - 1: 0] stream_a, stream_b;
    wire [DWIDTH - 1: 0] stream_o;
    MatrixMulSingleCore #(
        .DWIDTH(DWIDTH)
    ) singel_core (
        .CLOCK   (clock   ),
        .START   (start   ),
        .STREAM_A(stream_a),
        .STREAM_B(stream_b),
        .STREAM_O(stream_o)
    ); 

    integer i, j;
    // Main Task    
    initial begin
        #(`SCYCLE * 1);
        reset = 1;
        start = 1;
        #(`SCYCLE * 1);
        for (i = 0; i < 10; i = i + 1) begin
            stream_a = Random(5, 1);
            stream_b = Random(5, 1);
            #(`SCYCLE * 10);
        end
       $stop; 
    end

    function [31:0] itof;
        input [32:0] in;
        begin
            case (in)
                0: itof = 31'h0000_0000;
                1: itof = 31'h3F80_0000;
                2: itof = 31'h4000_0000; 
                3: itof = 31'h4040_0000; 
                4: itof = 31'h4080_0000; 
                5: itof = 31'h40A0_0000; 
                6: itof = 31'h40C0_0000; 
                7: itof = 31'h40E0_0000; 
                8: itof = 31'h4100_0000; 
                9: itof = 31'h4110_0000; 
                default: itof = 31'h0000_0000;
            endcase
        end
    endfunction

    function [31:0] Random;
        input [31:0] MAX;
        input [31:0] MIN;
        begin
            Random = itof($urandom % (MAX - MIN + 1) + MIN);
        end
    endfunction    

endmodule