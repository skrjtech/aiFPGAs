module LATCH_MUL #(
    parameter
        DWIDTH = 32
) (
    input  wire                 START,
    input  wire [DWIDTH - 1: 0] INA,
    input  wire [DWIDTH - 1: 0] INB,
    output wire [DWIDTH - 1: 0] OUT
);

    reg  [DWIDTH - 1: 0] REGA, REGB;
    wire [DWIDTH - 1: 0] WIRE_OUT;
    assign OUT = WIRE_OUT;

    FLOATING_32BIT_MUL mul (.INA(REGA), .INB(REGB), .OUT(WIRE_OUT));
    always @(INA or INB) begin
        if (!START) begin
            {REGA, REGB} <= {DWIDTH{1'b0}};
        end else begin
            {REGA, REGB} <= {INA, INB};
        end
    end
    
endmodule

module SWITCH_ADD #(
    parameter
        DWIDTH = 32
) (
    input  wire                    CLOCK,
    input  wire                    START,
    input  wire [DWIDTH - 1: 0]    IN,
    output wire [DWIDTH - 1: 0]    OUT
);

    reg  [DWIDTH - 1: 0] REGA = 0, REGB = 0;
    wire [DWIDTH - 1: 0] WSUM;
    assign OUT = WSUM;
    FLOATING_32BIT_ADD add (
        .INA(REGA), 
        .INB(REGB),
        .OUT(WSUM)
    );

    reg flag = 0;
    always @(negedge CLOCK) begin
        if (!START) begin
            flag <= 0;
        end else begin
            if (!flag) begin
                flag <= 1;
                {REGA, REGB} <= {{DWIDTH{1'b0}}, IN};            
            end else begin
                {REGA, REGB} <= {WSUM, IN};
            end
        end
    end

endmodule

module MatrixMulSingleCore #(
    parameter
        DWIDTH = 32,
        SIZE   = DWIDTH

) (
    input  wire                 CLOCK   ,  
    input  wire                 START   ,
    input  wire [SIZE - 1: 0]   STREAM_A,
    input  wire [SIZE - 1: 0]   STREAM_B,
    output wire [DWIDTH - 1: 0] STREAM_O
);
           
    wire [DWIDTH - 1: 0] WIRE_AB, WIRE_SUM;
    assign STREAM_O = WIRE_SUM;

    LATCH_MUL #(
        .DWIDTH(DWIDTH)
    ) latch (
        .START  (START      ),
        .INA    (STREAM_A   ), 
        .INB    (STREAM_B   ), 
        .OUT    (WIRE_AB    )
    );
    SWITCH_ADD #(
        .DWIDTH(DWIDTH)
    ) switch (
        .CLOCK  (CLOCK      ),
        .START  (START      ), 
        .IN     (WIRE_AB    ),
        .OUT    (WIRE_SUM   )
    );

endmodule

module MatrixMul2Cores #(
    parameter
        DWIDTH = 32,
        CORES  = 2,
        SIZE   = DWIDTH * CORES

) (
    input  wire                 CLOCK   ,
    input  wire                 START   ,
    input  wire [SIZE - 1: 0]   STREAM_A,
    input  wire [SIZE - 1: 0]   STREAM_B,
    output wire [DWIDTH - 1: 0] STREAM_O
);

    generate
        genvar i, j, k;
        wire [DWIDTH - 1: 0] WIRE_SUM;
        assign STREAM_O = WIRE_SUM;

        wire [DWIDTH - 1: 0] OUTPUT [0: CORES - 1];
        for (i = 0; i < CORES; i = i + 1) begin: gen_cores
            MatrixMulSingleCore core (
                .CLOCK      (CLOCK                                       ), 
                .START      (START                                       ), 
                .STREAM_A   (STREAM_A[(DWIDTH * (i + 1)) - 1: DWIDTH * i]), 
                .STREAM_B   (STREAM_B[(DWIDTH * (i + 1)) - 1: DWIDTH * i]), 
                .STREAM_O   (OUTPUT[i]                                   )
            );
        end
        FLOATING_32BIT_ADD add (
            .INA            (OUTPUT[0]), 
            .INB            (OUTPUT[1]),
            .OUT            (WIRE_SUM )
        );
    endgenerate

endmodule

module MatrixMul4Cores #(
    parameter
        DWIDTH = 32,
        CORES  = 4,
        SIZE   = DWIDTH * CORES

) (
    input  wire                 CLOCK   ,
    input  wire                 START   ,
    input  wire [SIZE - 1: 0]   STREAM_A,
    input  wire [SIZE - 1: 0]   STREAM_B,
    output wire [DWIDTH - 1: 0] STREAM_O
);

    generate
        genvar i, j, k;
        wire [DWIDTH - 1: 0] OUTPUT [0: CORES * 2 - 2];
        assign STREAM_O = OUTPUT[CORES * 2 - 2];
        for (i = 0; i < CORES; i = i + 1) begin: gen_cores_mull
            MatrixMulSingleCore core (
                .CLOCK      (CLOCK                                       ), 
                .START      (START                                       ), 
                .STREAM_A   (STREAM_A[(DWIDTH * (i + 1)) - 1: DWIDTH * i]), 
                .STREAM_B   (STREAM_B[(DWIDTH * (i + 1)) - 1: DWIDTH * i]), 
                .STREAM_O   (OUTPUT[i]                                   )
            );
        end

        for (i = 0; i < CORES - 1; i = i + 1) begin: gen_cores_add
            FLOATING_32BIT_ADD add (
                .INA(OUTPUT[i * 2]    ), 
                .INB(OUTPUT[i * 2 + 1]), 
                .OUT(OUTPUT[i + CORES])
            ); 
        end
    endgenerate

endmodule

module MatrixMul8Cores #(
    parameter
        DWIDTH = 32,
        CORES  = 8,
        SIZE   = DWIDTH * CORES

) (
    input  wire                 CLOCK   ,
    input  wire                 START   ,
    input  wire [SIZE - 1: 0]   STREAM_A,
    input  wire [SIZE - 1: 0]   STREAM_B,
    output wire [DWIDTH - 1: 0] STREAM_O
);

    MatrixMul4Cores #(
        .DWIDTH(DWIDTH), 
        .CORES (CORES )
    ) cores (
        .CLOCK      (CLOCK   ),
        .START      (START   ),
        .STREAM_A   (STREAM_A),
        .STREAM_B   (STREAM_B),
        .STREAM_O   (STREAM_O)
    );

endmodule

module MatrixMul16Cores #(
    parameter
        DWIDTH = 32,
        CORES  = 16,
        SIZE   = DWIDTH * CORES

) (
    input  wire                 CLOCK   ,
    input  wire                 START   ,
    input  wire [SIZE - 1: 0]   STREAM_A,
    input  wire [SIZE - 1: 0]   STREAM_B,
    output wire [DWIDTH - 1: 0] STREAM_O
);

    MatrixMul4Cores #(
        .DWIDTH(DWIDTH), 
        .CORES (CORES )
    ) cores (
        .CLOCK   (CLOCK   ),
        .START   (START   ),
        .STREAM_A(STREAM_A),
        .STREAM_B(STREAM_B),
        .STREAM_O(STREAM_O)
    );

endmodule

module MatrixMul32Cores #(
    parameter
        DWIDTH = 32,
        CORES  = 32,
        SIZE   = DWIDTH * CORES

) (
    input  wire                 CLOCK   ,
    input  wire                 START   ,
    input  wire [SIZE - 1: 0]   STREAM_A,
    input  wire [SIZE - 1: 0]   STREAM_B,
    output wire [DWIDTH - 1: 0] STREAM_O
);

    MatrixMul4Cores #(
        .DWIDTH(DWIDTH), 
        .CORES (CORES )
    ) cores (
        .CLOCK   (CLOCK   ),
        .START   (START   ),
        .STREAM_A(STREAM_A),
        .STREAM_B(STREAM_B),
        .STREAM_O(STREAM_O)
    );

endmodule

module MatrixMulManyCores #(
    parameter
        DWIDTH = 32,
        CORES  = 64,
        SIZE   = DWIDTH * CORES

) (
    input  wire                 CLOCK   ,
    input  wire                 START   ,
    input  wire [SIZE - 1: 0]   STREAM_A,
    input  wire [SIZE - 1: 0]   STREAM_B,
    output wire [DWIDTH - 1: 0] STREAM_O
);

    MatrixMul4Cores #(
        .DWIDTH(DWIDTH), 
        .CORES (CORES )
    ) cores (
        .CLOCK   (CLOCK   ),
        .START   (START   ),
        .STREAM_A(STREAM_A),
        .STREAM_B(STREAM_B),
        .STREAM_O(STREAM_O)
    );

endmodule