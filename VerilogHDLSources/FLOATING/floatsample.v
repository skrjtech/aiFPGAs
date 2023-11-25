
module floating_point_adder_16bit(
    input [15:0] a,
    input [15:0] b,
    output reg [15:0] sum
);
    wire sign_a = a[15];
    wire [4:0] exponent_a = a[14:10];
    wire [9:0] mantissa_a = {1'b1, a[9:0]};

    wire sign_b = b[15];
    wire [4:0] exponent_b = b[14:10];
    wire [9:0] mantissa_b = {1'b1, b[9:0]};

    // 特殊ケースの処理
    wire a_is_nan = (exponent_a == 5'h1F) && |mantissa_a[9:0];
    wire b_is_nan = (exponent_b == 5'h1F) && |mantissa_b[9:0];
    wire a_is_inf = (exponent_a == 5'h1F) && ~|mantissa_a[9:0];
    wire b_is_inf = (exponent_b == 5'h1F) && ~|mantissa_b[9:0];
    wire a_is_zero = ~|a[14:0];
    wire b_is_zero = ~|b[14:0];

    // 指数のアライメント
    wire [4:0] exp_diff = (exponent_a > exponent_b) ? (exponent_a - exponent_b) : (exponent_b - exponent_a);
    wire [9:0] aligned_mantissa_a = (exponent_a > exponent_b) ? mantissa_a : (mantissa_a >> exp_diff);
    wire [9:0] aligned_mantissa_b = (exponent_a <= exponent_b) ? mantissa_b : (mantissa_b >> exp_diff);
    wire [4:0] aligned_exponent = (exponent_a > exponent_b) ? exponent_a : exponent_b;

    // 仮数の加算
    wire [10:0] sum_mantissa = {1'b0, aligned_mantissa_a} + {1'b0, aligned_mantissa_b};

    // 正規化
    wire [4:0] normalized_exponent = sum_mantissa[10] ? aligned_exponent + 1 : aligned_exponent;
    wire [9:0] normalized_mantissa = sum_mantissa[10] ? sum_mantissa[9:1] : sum_mantissa[8:0];

    // 丸め処理
    wire round_bit = sum_mantissa[0];
    wire [9:0] rounded_mantissa = normalized_mantissa + round_bit;

    // 結果の組み立て
    always @* begin
        if (a_is_nan || b_is_nan) begin
            sum = 16'h7E00; // NaN
        end else if (a_is_inf || b_is_inf) begin
            sum = 16'h7C00; // 無限大
        end else if (a_is_zero && b_is_zero) begin
            sum = 16'h0000; // ゼロ
        end else begin
            sum = {sign_a, normalized_exponent, rounded_mantissa[9:1]};
        end
    end
endmodule

module floating_point_adder_32bit(
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] sum
);
    // 符号、指数、仮数の分解
    wire sign_a = a[31];
    wire [7:0] exponent_a = a[30:23];
    wire [22:0] mantissa_a = {1'b1, a[22:0]};

    wire sign_b = b[31];
    wire [7:0] exponent_b = b[30:23];
    wire [22:0] mantissa_b = {1'b1, b[22:0]};

    // 特殊ケースの処理
    wire a_is_nan = (exponent_a == 8'hFF) && |mantissa_a[22:0];
    wire b_is_nan = (exponent_b == 8'hFF) && |mantissa_b[22:0];
    wire a_is_inf = (exponent_a == 8'hFF) && ~|mantissa_a[22:0];
    wire b_is_inf = (exponent_b == 8'hFF) && ~|mantissa_b[22:0];
    wire a_is_zero = ~(|exponent_a) && ~|mantissa_a[22:0];
    wire b_is_zero = ~(|exponent_b) && ~|mantissa_b[22:0];

    // 指数のアライメント
    wire [7:0] exp_diff = (exponent_a > exponent_b) ? (exponent_a - exponent_b) : (exponent_b - exponent_a);
    wire [22:0] aligned_mantissa_a = (exponent_a > exponent_b) ? mantissa_a : (mantissa_a >> exp_diff);
    wire [22:0] aligned_mantissa_b = (exponent_a <= exponent_b) ? mantissa_b : (mantissa_b >> exp_diff);
    wire [7:0] aligned_exponent = (exponent_a > exponent_b) ? exponent_a : exponent_b;

    // 仮数の加算
    wire [24:0] sum_mantissa = {1'b0, aligned_mantissa_a} + {1'b0, aligned_mantissa_b};
    wire sum_sign = (sign_a == sign_b) ? sign_a : sum_mantissa[24];

    // 正規化
    wire [7:0] normalized_exponent = sum_mantissa[24] ? aligned_exponent + 1 : aligned_exponent;
    wire [22:0] normalized_mantissa = sum_mantissa[24] ? sum_mantissa[23:1] : sum_mantissa[22:0];

    // 丸め処理
    wire round_bit = sum_mantissa[0];

    // 結果の組み立て
    always @* begin
        if (a_is_nan || b_is_nan) begin
            sum = 32'h7FC00000; // NaN
        end else if (a_is_inf || b_is_inf) begin
            sum = 32'h7F800000; // 無限大
        end else if (a_is_zero && b_is_zero) begin
            sum = {sign_a & sign_b, 31'h00000000}; // ゼロ
        end else begin
            sum = {sum_sign, normalized_exponent, normalized_mantissa + round_bit};
        end
    end
endmodule

module floating_point_multiplier_32bit(
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] product
);
    wire sign_a = a[31];
    wire [7:0] exponent_a = a[30:23];
    wire [22:0] mantissa_a = {1'b1, a[22:0]};

    wire sign_b = b[31];
    wire [7:0] exponent_b = b[30:23];
    wire [22:0] mantissa_b = {1'b1, b[22:0]};

    // 符号の計算
    wire product_sign = sign_a ^ sign_b;

    // 指数の計算
    wire [8:0] sum_exponent = exponent_a + exponent_b - 127;

    // 仮数の乗算
    wire [47:0] product_mantissa = mantissa_a * mantissa_b;

    // 正規化
    wire normalized = product_mantissa[47];
    wire [7:0] product_exponent = normalized ? sum_exponent + 1 : sum_exponent;
    wire [22:0] normalized_mantissa = normalized ? product_mantissa[46:24] : product_mantissa[45:23];

    // 結果の組み立て
    always @* begin
        product <= {product_sign, product_exponent, normalized_mantissa};
    end
endmodule

module floating_point_multiplier_16bit(
    input [15:0] a,
    input [15:0] b,
    output reg [15:0] product
);
    wire sign_a = a[15];
    wire [4:0] exponent_a = a[14:10];
    wire [9:0] mantissa_a = {1'b1, a[9:0]};

    wire sign_b = b[15];
    wire [4:0] exponent_b = b[14:10];
    wire [9:0] mantissa_b = {1'b1, b[9:0]};

    // 符号の計算
    wire product_sign = sign_a ^ sign_b;

    // 指数の計算
    wire [5:0] sum_exponent = exponent_a + exponent_b - 15;

    // 仮数の乗算
    wire [19:0] product_mantissa = mantissa_a * mantissa_b;

    // 正規化
    wire normalized = product_mantissa[19];
    wire [4:0] product_exponent = normalized ? sum_exponent + 1 : sum_exponent;
    wire [9:0] normalized_mantissa = normalized ? product_mantissa[18:9] : product_mantissa[17:8];

    // 結果の組み立て
    always @* begin
        product <= {product_sign, product_exponent, normalized_mantissa};
    end
endmodule

module floating_point_multiplier_16bit(
    input [15:0] a,
    input [15:0] b,
    output reg [15:0] product
);
    wire sign_a = a[15];
    wire [4:0] exponent_a = a[14:10];
    wire [10:0] mantissa_a = {1'b1, a[9:0], 1'b0}; // 1ビットのガードビットを追加

    wire sign_b = b[15];
    wire [4:0] exponent_b = b[14:10];
    wire [10:0] mantissa_b = {1'b1, b[9:0], 1'b0}; // 1ビットのガードビットを追加

    // 符号の計算
    wire product_sign = sign_a ^ sign_b;

    // 特殊ケースの処理
    wire a_is_zero = (exponent_a == 0) && (a[9:0] == 0);
    wire b_is_zero = (exponent_b == 0) && (b[9:0] == 0);
    wire a_or_b_is_inf = (exponent_a == 31) || (exponent_b == 31);
    wire a_or_b_is_nan = (exponent_a == 31 && |a[9:0]) || (exponent_b == 31 && |b[9:0]);

    // 指数の計算
    wire [5:0] sum_exponent = exponent_a + exponent_b - 15;

    // 仮数の乗算
    wire [21:0] product_mantissa = mantissa_a * mantissa_b;

    // 正規化
    wire [4:0] normalized_exponent = product_mantissa[21] ? sum_exponent + 1 : sum_exponent;
    wire [9:0] normalized_mantissa = product_mantissa[21] ? product_mantissa[20:11] : product_mantissa[19:10];

    // 丸め処理
    wire round_bit = product_mantissa[10];
    wire [9:0] rounded_mantissa = normalized_mantissa + round_bit;

    // 結果の組み立て
    always @* begin
        if (a_or_b_is_nan) begin
            product = 16'h7E00; // NaN
        end else if (a_or_b_is_inf || (sum_exponent >= 31)) begin
            product = {product_sign, 5'h1F, 10'h000}; // 無限大またはオーバーフロー
        end else if (a_is_zero || b_is_zero || (sum_exponent <= 0)) begin
            product = 16'h0000; // ゼロまたはアンダーフロー
        end else begin
            product = {product_sign, normalized_exponent, rounded_mantissa[9:1]};
        end
    end
endmodule

module floating_point_multiplier_32bit(
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] product
);
    wire sign_a = a[31];
    wire [7:0] exponent_a = a[30:23];
    wire [23:0] mantissa_a = {1'b1, a[22:0], 1'b0}; // 1ビットのガードビットを追加

    wire sign_b = b[31];
    wire [7:0] exponent_b = b[30:23];
    wire [23:0] mantissa_b = {1'b1, b[22:0], 1'b0}; // 1ビットのガードビットを追加

    // 符号の計算
    wire product_sign = sign_a ^ sign_b;

    // 特殊ケースの処理
    wire a_is_zero = (exponent_a == 0) && (a[22:0] == 0);
    wire b_is_zero = (exponent_b == 0) && (b[22:0] == 0);
    wire a_or_b_is_inf = (exponent_a == 255) || (exponent_b == 255);
    wire a_or_b_is_nan = (exponent_a == 255 && |a[22:0]) || (exponent_b == 255 && |b[22:0]);

    // 指数の計算
    wire [8:0] sum_exponent = exponent_a + exponent_b - 127;

    // 仮数の乗算
    wire [47:0] product_mantissa = mantissa_a * mantissa_b;

    // 正規化
    wire [7:0] normalized_exponent = product_mantissa[47] ? sum_exponent + 1 : sum_exponent;
    wire [22:0] normalized_mantissa = product_mantissa[47] ? product_mantissa[46:24] : product_mantissa[45:23];

    // 丸め処理
    wire round_bit = product_mantissa[23];
    wire [22:0] rounded_mantissa = normalized_mantissa + round_bit;

    // 結果の組み立て
    always @* begin
        if (a_or_b_is_nan) begin
            product = 32'h7FC00000; // NaN
        end else if (a_or_b_is_inf || (sum_exponent >= 255)) begin
            product = {product_sign, 8'hFF, 23'h000000}; // 無限大またはオーバーフロー
        end else if (a_is_zero || b_is_zero || (sum_exponent <= 0)) begin
            product = 32'h00000000; // ゼロまたはアンダーフロー
        end else begin
            product = {product_sign, normalized_exponent, rounded_mantissa[22:1]};
        end
    end
endmodule

module floating_point_subtractor_16bit(
    input [15:0] a,
    input [15:0] b,
    output [15:0] diff
);
    // bの符号ビットを反転させて加算器に渡す
    floating_point_adder_16bit adder(a, {~b[15], b[14:0]}, diff);
endmodule

module floating_point_subtractor_32bit(
    input [31:0] a,
    input [31:0] b,
    output [31:0] diff
);
    // bの符号ビットを反転させて加算器に渡す
    floating_point_adder_32bit adder(a, {~b[31], b[30:0]}, diff);
endmodule

module floating_point_divider_16bit(
    input [15:0] a,
    input [15:0] b,
    output reg [15:0] quotient
);
    wire sign_a = a[15];
    wire [4:0] exponent_a = a[14:10];
    wire [10:0] mantissa_a = {1'b1, a[9:0], 1'b0}; // 1ビットのガードビット

    wire sign_b = b[15];
    wire [4:0] exponent_b = b[14:10];
    wire [10:0] mantissa_b = {1'b1, b[9:0], 1'b0}; // 1ビットのガードビット

    wire quotient_sign = sign_a ^ sign_b;
    wire [5:0] diff_exponent = exponent_a - exponent_b + 15;

    // 仮数の割り算
    reg [10:0] quotient_mantissa;
    reg [5:0] quotient_exponent;
    always @(mantissa_a, mantissa_b) begin
        quotient_mantissa = mantissa_a / mantissa_b;
        quotient_exponent = diff_exponent;

        // 正規化
        if (quotient_mantissa[10] == 0) begin
            quotient_mantissa = quotient_mantissa << 1;
            quotient_exponent = quotient_exponent - 1;
        end
    end

    // 丸め処理
    wire round_bit = quotient_mantissa[0];
    wire [9:0] rounded_mantissa = quotient_mantissa[10:1] + round_bit;

    // 結果の組み立て
    always @* begin
        quotient <= {quotient_sign, quotient_exponent[4:0], rounded_mantissa};
    end
endmodule

module floating_point_divider_32bit(
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] quotient
);
    wire sign_a = a[31];
    wire [7:0] exponent_a = a[30:23];
    wire [23:0] mantissa_a = {1'b1, a[22:0], 1'b0}; // 1ビットのガードビット

    wire sign_b = b[31];
    wire [7:0] exponent_b = b[30:23];
    wire [23:0] mantissa_b = {1'b1, b[22:0], 1'b0}; // 1ビットのガードビット

    wire quotient_sign = sign_a ^ sign_b;
    wire [8:0] diff_exponent = exponent_a - exponent_b + 127;

    // 仮数の割り算
    reg [23:0] quotient_mantissa;
    reg [8:0] quotient_exponent;
    always @(mantissa_a, mantissa_b) begin
        quotient_mantissa = mantissa_a / mantissa_b;
        quotient_exponent = diff_exponent;

        // 正規化
        if (quotient_mantissa[23] == 0) begin
            quotient_mantissa = quotient_mantissa << 1;
            quotient_exponent = quotient_exponent - 1;
        end
    end

    // 丸め処理
    wire round_bit = quotient_mantissa[0];
    wire [22:0] rounded_mantissa = quotient_mantissa[23:1] + round_bit;

    // 結果の組み立て
    always @* begin
        quotient <= {quotient_sign, quotient_exponent[7:0], rounded_mantissa};
    end
endmodule

module floating_point_divider_16bit(
    input [15:0] a,
    input [15:0] b,
    output reg [15:0] quotient
);
    wire sign_a = a[15];
    wire [4:0] exponent_a = a[14:10];
    wire [10:0] mantissa_a = {1'b1, a[9:0], 1'b0};

    wire sign_b = b[15];
    wire [4:0] exponent_b = b[14:10];
    wire [10:0] mantissa_b = {1'b1, b[9:0], 1'b0};

    wire quotient_sign = sign_a ^ sign_b;
    wire [5:0] diff_exponent = exponent_a - exponent_b + 15;

    reg [10:0] quotient_mantissa;
    reg [5:0] quotient_exponent;
    always @(mantissa_a, mantissa_b) begin
        if (b == 0) begin
            quotient <= 16'h7C00; // 無限大（除数が0）
        end else if (a == 0) begin
            quotient <= 0; // ゼロ（被除数が0）
        end else begin
            quotient_mantissa = mantissa_a / mantissa_b;
            quotient_exponent = diff_exponent;
            if (quotient_mantissa[10] == 0) begin
                quotient_mantissa = quotient_mantissa << 1;
                quotient_exponent = quotient_exponent - 1;
            end
            quotient <= {quotient_sign, quotient_exponent[4:0], quotient_mantissa[9:1]};
        end
    end
endmodule

module floating_point_divider_32bit(
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] quotient
);
    wire sign_a = a[31];
    wire [7:0] exponent_a = a[30:23];
    wire [23:0] mantissa_a = {1'b1, a[22:0], 1'b0};

    wire sign_b = b[31];
    wire [7:0] exponent_b = b[30:23];
    wire [23:0] mantissa_b = {1'b1, b[22:0], 1'b0};

    wire quotient_sign = sign_a ^ sign_b;
    wire [8:0] diff_exponent = exponent_a - exponent_b + 127;

    reg [23:0] quotient_mantissa;
    reg [8:0] quotient_exponent;
    always @(mantissa_a, mantissa_b) begin
        if (b == 0) begin
            quotient <= 32'h7F800000; // 無限大（除数が0）
        end else if (a == 0) begin
            quotient <= 0; // ゼロ（被除数が0）
        end else begin
            quotient_mantissa = mantissa_a / mantissa_b;
            quotient_exponent = diff_exponent;
            if (quotient_mantissa[23] == 0) begin
                quotient_mantissa = quotient_mantissa << 1;
                quotient_exponent = quotient_exponent - 1;
            end
            quotient <= {quotient_sign, quotient_exponent[7:0], quotient_mantissa[22:1]};
        end
    end
endmodule
