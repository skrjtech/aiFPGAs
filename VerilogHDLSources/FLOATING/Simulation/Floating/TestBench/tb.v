
`timescale 1us/100ps
`define TB_SCYCLE 20 // 50MHz

module tb ();

    reg clock;
    initial clock = 1;
    always #(`TB_SCYCLE / 2) clock = ~clock;

    reg  [31:0] in_a, in_b;
    wire [31:0] out_add, out_sub, out_mul, out_div;

    FLOATING_32BIT_ADD uAdd (in_a, in_b, out_add);
    FLOATING_32BIT_SUB uSub (in_a, in_b, out_sub);
    FLOATING_32BIT_MUL uMul (in_a, in_b, out_mul);
    FLOATING_32BIT_DIV uDiv (in_a, in_b, out_div);

    initial begin
    
        FLOATING_ADD_SUB_MUL_DIV(32'h4122_0000, 32'h3E00_0000); // ( 10.125) + ( 0.125) =  10.250
        FLOATING_ADD_SUB_MUL_DIV(32'h4122_0000, 32'hBE00_0000); // ( 10.125) + (-0.125) =  10.000
        FLOATING_ADD_SUB_MUL_DIV(32'hC122_0000, 32'h3E00_0000); // (-10.125) + ( 0.125) = -10.000
        FLOATING_ADD_SUB_MUL_DIV(32'hC122_0000, 32'hBE00_0000); // (-10.125) + (-0.125) = -10.250
        FLOATING_ADD_SUB_MUL_DIV(32'h3E00_0000, 32'h4122_0000); // ( 0.125) + ( 10.125) =  10.250
        FLOATING_ADD_SUB_MUL_DIV(32'hBE00_0000, 32'h4122_0000); // (-0.125) + ( 10.125) =  10.000
        FLOATING_ADD_SUB_MUL_DIV(32'h3E00_0000, 32'hC122_0000); // ( 0.125) + (-10.125) = -10.000
        FLOATING_ADD_SUB_MUL_DIV(32'hBE00_0000, 32'hC122_0000); // (-0.125) + (-10.125) = -10.250
        FLOATING_ADD_SUB_MUL_DIV(32'h4522_0000, 32'hC680_0001); // -30176.?    C6EB_C002

    end

    task FLOATING_ADD_SUB_MUL_DIV;
        input [31:0] a, b;
        begin
            in_a = a;
            in_b = b;
            #(`TB_SCYCLE/2 * 1);
        end
    endtask

endmodule