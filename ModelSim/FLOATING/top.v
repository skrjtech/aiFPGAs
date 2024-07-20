
module Top (
    input wire [ 1:0] opration,
    input wire [31:0] in_a,
    input wire [31:0] in_b,
    output reg [31:0] out
);

    wire [31:0] out_add, out_sub, out_mul, out_dib;
    // floating_point_adder_32bit      uAdd (in_a, in_b, out_add);
    floating_point_adder_32bit      uAdd (in_a, in_b, out_add);
    // floating_point_subtractor_32bit uSUB (in_a, in_b, out_sub);
    // floating_point_multiplier_32bit uMUL (in_a, in_b, out_mul);
    // floating_point_divider_32bit    uDIV (in_a, in_b, out_dib);

    always @(*) begin
        case (opration)
            2'b00:   out <= out_add;
            2'b01:   out <= out_sub;  
            2'b10:   out <= out_mul;  
            2'b11:   out <= out_dib;  
            default: out <= 0;
        endcase
    end
    
endmodule