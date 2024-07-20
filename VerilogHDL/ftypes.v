/*
    IEEE754 Standard for Floating-Point Arithmetic
*/

// ADDITION
module HALF_ADD (
    input  wire [15:0] IN_A,
    input  wire [15:0] IN_B,
    output wire [15:0] OUT
);
    
endmodule

module FLOAT_ADD (
    input  wire [31:0] IN_A,
    input  wire [31:0] IN_B,
    output wire [31:0] OUT
);

    wire            sign_a = IN_A[31   ]; 
    wire [7:0]  exponent_a = IN_A[30:23]; 
    wire [22:0] fraction_a = IN_A[22: 0];

    wire            sign_b = IN_B[31   ];
    wire [7:0]  exponent_b = IN_B[30:23];
    wire [22:0] fraction_b = IN_B[22: 0];
    
endmodule

module DOUBLE_ADD (
    input  wire [127:0] IN_A,
    input  wire [127:0] IN_B,
    output wire [127:0] OUT
);
    
endmodule

// SUBTRACTION
module HALF_SUB (
    input  wire [15:0] IN_A,
    input  wire [15:0] IN_B,
    output wire [15:0] OUT
);
    
endmodule

module FLOAT_SUB (
    input  wire [31:0] IN_A,
    input  wire [31:0] IN_B,
    output wire [31:0] OUT
);
    
endmodule

module DOUBLE_SUB (
    input  wire [127:0] IN_A,
    input  wire [127:0] IN_B,
    output wire [127:0] OUT
);
    
endmodule

// MULTIPLICATION
module HALF_MUL (
    input  wire [15:0] IN_A,
    input  wire [15:0] IN_B,
    output wire [15:0] OUT
);
    
endmodule

module FLOAT_MUL (
    input  wire [31:0] IN_A,
    input  wire [31:0] IN_B,
    output wire [31:0] OUT
);
    
endmodule

module DOUBLE_MUL (
    input  wire [127:0] IN_A,
    input  wire [127:0] IN_B,
    output wire [127:0] OUT
);
    
endmodule

// DIVISION
module HALF_DIV (
    input  wire [15:0] IN_A,
    input  wire [15:0] IN_B,
    output wire [15:0] OUT
);
    
endmodule

module FLOAT_DIV (
    input  wire [31:0] IN_A,
    input  wire [31:0] IN_B,
    output wire [31:0] OUT
);
    
endmodule

module DOUBLE_DIV (
    input  wire [127:0] IN_A,
    input  wire [127:0] IN_B,
    output wire [127:0] OUT
);
    
endmodule

// DIVISION AND REMAINDER
module HALF_DIV_WITH_REM (
    input  wire [15:0] IN_A,
    input  wire [15:0] IN_B,
    output wire [15:0] OUT
);
    
endmodule

module FLOAT_DIV_WITH_REM (
    input  wire [31:0] IN_A,
    input  wire [31:0] IN_B,
    output wire [31:0] OUT
);
    
endmodule

module DOUBLE_DIV_WITH_REM (
    input  wire [127:0] IN_A,
    input  wire [127:0] IN_B,
    output wire [127:0] OUT
);
    
endmodule