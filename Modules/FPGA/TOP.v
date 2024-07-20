
module TOP (
    input  wire                   CLOCK,
    input  wire                   NRESET
);

    localparam DWIDTH = 32, CORES = 1024;

    reg  [(32 * CORES) - 1: 0] STREAM_A;
    reg  [(32 * CORES) - 1: 0] STREAM_B;
    wire [(32 * CORES) - 1: 0] STREAM_O;
    // MatrixMulSingleCore #(.DWIDTH(DWIDTH)) mul_cores (.CLOCK(CLOCK), .NRESET(NRESET), .START(START), .STREAM_A(STREAM_A), .STREAM_B(STREAM_B), .STREAM_O(STREAM_O));
    // MatrixMul2Cores #(.DWIDTH(DWIDTH)) mul_cores (.CLOCK(CLOCK), .NRESET(NRESET), .START(START), .STREAM_A(STREAM_A), .STREAM_B(STREAM_B), .STREAM_O(STREAM_O));
    // MatrixMul4Cores #(.DWIDTH(DWIDTH)) mul_cores (.CLOCK(CLOCK), .NRESET(NRESET), .START(START), .STREAM_A(STREAM_A), .STREAM_B(STREAM_B), .STREAM_O(STREAM_O));
    // MatrixMul16Cores #(.DWIDTH(DWIDTH)) mul_cores (.CLOCK(CLOCK), .NRESET(NRESET), .START(START), .STREAM_A(STREAM_A), .STREAM_B(STREAM_B), .STREAM_O(STREAM_O));
    // MatrixMul32Cores #(.DWIDTH(DWIDTH)) mul_cores (.CLOCK(CLOCK), .NRESET(NRESET), .START(START), .STREAM_A(STREAM_A), .STREAM_B(STREAM_B), .STREAM_O(STREAM_O));
    // MatrixMulManyCores #(.DWIDTH(DWIDTH), .CORES(CORES)) mul_cores (.CLOCK(CLOCK), .NRESET(NRESET), .START(START), .STREAM_A(STREAM_A), .STREAM_B(STREAM_B), .STREAM_O(STREAM_O));

    // Neuron #(.IDIM(10), .ODIM(10)) nuron (.CLOCK(clock));

    STSource st (.clk(CLOCK), .reset(NRESET));

endmodule
