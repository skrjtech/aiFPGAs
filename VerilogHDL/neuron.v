
module NeuronCore #(
    parameter 
        DWIDTH = 32, 
        CORES  = 1 , 
        SIZE   = DWIDTH * CORES
) (
    input  wire               CLOCK   ,
    input  wire               START   ,
    input  wire [SIZE - 1: 0] STREAM_A,
    input  wire [SIZE - 1: 0] STREAM_B,
    output wire [SIZE - 1: 0] STREAM_O
);

    generate
        if (CORES == 1) begin
            MatrixMulSingleCore #(
                .DWIDTH     (DWIDTH     )
            ) multiply (
                .CLOCK      (CLOCK      ),
                .START      (START      ),
                .STREAM_A   (STREAM_A   ),
                .STREAM_B   (STREAM_B   ),
                .STREAM_O   (STREAM_O   )
            );
        end else begin
            MatrixMulManyCores #(
                .DWIDTH     (DWIDTH     ),
                .CORES      (CORES      ),
                .SIZE       (SIZE       )
            ) multiply (
                .CLOCK      (CLOCK      ),
                .START      (START      ),
                .STREAM_A   (STREAM_A   ),
                .STREAM_B   (STREAM_B   ),
                .STREAM_O   (STREAM_O   )
            );
        end
    endgenerate

endmodule

module Neuron #(
    parameter 
        DWIDTH = 32           , 
        CORES  = 1            ,
        IDIM   = 1            ,
        ODIM   = 2            ,
        ASIZE  = DWIDTH * IDIM,
        BSIZE  = DWIDTH * ODIM,
        OSIZE  = DWIDTH * IDIM * ODIM
) (
    input  wire                CLOCK   ,
    input  wire                START   ,
    input  wire [ASIZE - 1: 0] STREAM_A,
    input  wire [BSIZE - 1: 0] STREAM_B,
    output wire [OSIZE - 1: 0] STREAM_O 
);
    generate
        genvar r,c;
        for (r = 0; r < IDIM; r = r + 1) begin: row_block
            for (c = 0; c < ODIM; c = c + 1) begin: col_block
                NeuronCore #(
                    .DWIDTH   (DWIDTH                                                                      ), 
                    .CORES    (CORES                                                                       )
                ) core (
                    .CLOCK    (CLOCK                                                                       ),
                    .START    (START                                                                       ),
                    .STREAM_A (STREAM_A[(DWIDTH * (r + 1)) - 1: (r * DWIDTH)]                              ),
                    .STREAM_B (STREAM_B[(DWIDTH * (c + 1)) - 1: (c * DWIDTH)]                              ),
                    .STREAM_O (STREAM_O[((DWIDTH * (c + 1)) - 1) + (r * BSIZE): (c * DWIDTH) + (r * BSIZE)])
                ); 
            end
        end
    endgenerate
endmodule