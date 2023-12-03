
module FLOATING_32BIT_ADD_SUB (
    input  wire [31:0] in_a, in_b,
    output wire [31:0] out
);

    wire            sign_a = in_a[31];
    wire [7: 0] exponent_a = in_a[30:23];
    wire [22:0] fraction_a = in_a[22: 0];

    wire            sign_b = in_b[31];
    wire [7: 0] exponent_b = in_b[30:23];
    wire [22:0] fraction_b = in_b[22: 0];

    wire a_is_nan  =  ( exponent_a == 8'hFF) &&  |fraction_a;
    wire b_is_nan  =  ( exponent_b == 8'hFF) &&  |fraction_b;
    wire a_is_inf  =  ( exponent_a == 8'hFF) && ~|fraction_a;
    wire b_is_inf  =  ( exponent_b == 8'hFF) && ~|fraction_b;
    wire a_is_zero = ~(|exponent_a         ) && ~|fraction_a;
    wire b_is_zero = ~(|exponent_b         ) && ~|fraction_b;
    
    wire [7: 0] exp_diff           = (exponent_a >  exponent_b)  ? (exponent_a - exponent_b) : (exponent_b - exponent_a         );
    wire [24:0] aligned_fraction_a = (exponent_a >  exponent_b)  ? ({2'b01, fraction_a}    ) : ({2'b01, fraction_a} >> exp_diff );
    wire [24:0] aligned_fraction_b = (exponent_a <= exponent_b)  ? ({2'b01, fraction_b}    ) : ({2'b01, fraction_b} >> exp_diff );
    wire [7: 0] aligned_exponent   = (exponent_a >  exponent_b)  ? (exponent_a             ) : (exponent_b                      );

    wire [24:0] aligned_fraction_h = (aligned_fraction_b <  aligned_fraction_a) ? aligned_fraction_a : aligned_fraction_b;
    wire [24:0] aligned_fraction_l = (aligned_fraction_a <= aligned_fraction_b) ? aligned_fraction_a : aligned_fraction_b;
    wire [24:0] sum_fraction = (sign_a == sign_b) ? ({1'b0, aligned_fraction_h} + {1'b0, aligned_fraction_l}) : ({1'b0, aligned_fraction_h} - {1'b0, aligned_fraction_l});
    wire        sum_sign     = (sign_a == sign_b)                                   ? sign_a : 
                               (sign_a & (aligned_fraction_a > aligned_fraction_b)) ? sign_a : 
                               (sign_b & (aligned_fraction_b > aligned_fraction_a)) ? sign_b : sum_fraction[24];

    wire [7: 0] normalized_exponent = sum_fraction[24] ? aligned_exponent + 1'b1 : aligned_exponent  ;
    wire [21:0] normalized_fraction = sum_fraction[24] ? sum_fraction[23:2]      : sum_fraction[22:1];

    wire round_bit = sum_fraction[0];

    assign out = (a_is_nan  || b_is_nan ) ? 32'h7FC00000 :
                 (a_is_inf  || b_is_inf ) ? 32'h7F800000 : 
                 (a_is_zero && b_is_zero) ? {sign_a | sign_b, 31'h00000000} : {sum_sign, {normalized_exponent, normalized_fraction + round_bit, 1'b0}};

endmodule

module FLOATING_32BIT_ADD (
    input  wire [31:0] in_a, in_b,
    output wire [31:0] out
);

    FLOATING_32BIT_ADD_SUB uADD(in_a, in_b, out);

endmodule

module FLOATING_32BIT_SUB (
    input  wire [31:0] in_a, in_b,
    output wire [31:0] out
);

    FLOATING_32BIT_ADD_SUB uSUB(in_a, in_b, out);

endmodule