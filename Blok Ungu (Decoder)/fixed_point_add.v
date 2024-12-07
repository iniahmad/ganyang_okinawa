module fixed_point_add
(
    input [31:0] A,  // Fixed-point input A
    input [31:0] B,  // Fixed-point input B
    output [31:0] C  // Hasil output
);
    // Ekstraksi bagian sign dan value dari kedua input
    wire sign_A = A[31];           // Sign bit A
    wire sign_B = B[31];           // Sign bit B
    wire [30:0] value_A = A[30:0]; // Value A (mantissa + exponent dalam satu nilai)
    wire [30:0] value_B = B[30:0]; // Value B (mantissa + exponent dalam satu nilai)

    // Tentukan hasil sign dan nilai akhir
    wire result_sign;
    wire new_result_sign;
    wire [30:0] result_value;

    // Jika sign bit sama, lakukan penjumlahan, jika berbeda, lakukan pengurangan
    assign result_sign = (sign_A == sign_B) ? sign_A : (value_A > value_B ? sign_A : sign_B);

    // Jika sign bit sama, tambahkan value, jika berbeda, kurangi value
    assign result_value = (sign_A == sign_B) ? (value_A + value_B) : 
                          (value_A > value_B ? (value_A - value_B) : (value_B - value_A));

    assign new_result_sign = (result_value == 0) ? 0 : result_sign;

    // Tentukan hasil akhir, gabungkan sign dan value
    assign C = {new_result_sign, result_value};

endmodule
