module fixed_point_add #(parameter BITSIZE = 16) (
    input [BITSIZE-1:0] A,  // Fixed-point input A
    input [BITSIZE-1:0] B,  // Fixed-point input B
    output [BITSIZE-1:0] C  // Result output
);
    // Ekstraksi bagian sign dan value dari kedua input
    wire sign_A = A[BITSIZE-1];         // Sign bit A
    wire sign_B = B[BITSIZE-1];         // Sign bit B
    wire [BITSIZE-2:0] value_A = A[BITSIZE-2:0]; // Value A (mantissa + exponent dalam satu nilai)
    wire [BITSIZE-2:0] value_B = B[BITSIZE-2:0]; // Value B (mantissa + exponent dalam satu nilai)

    // Tentukan hasil sign dan nilai akhir
    wire result_sign;
    wire new_result_sign;
    wire [BITSIZE-2:0] result_value;

    // Jika sign bit sama, lakukan penjumlahan, jika berbeda, lakukan pengurangan
    assign result_sign = (sign_A == sign_B) ? sign_A : (value_A > value_B ? sign_A : sign_B);

    // Jika sign bit sama, tambahkan value, jika berbeda, kurangi value
    assign result_value = (sign_A == sign_B) ? (value_A + value_B) : 
                          (value_A > value_B ? (value_A - value_B) : (value_B - value_A));

    assign new_result_sign = (result_value == 0) ? 0 : result_sign;

    // Tentukan hasil akhir, gabungkan sign dan value
    assign C = {new_result_sign, result_value};

endmodule
