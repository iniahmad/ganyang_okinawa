module fixed_point_multiply
(
    input  [31:0] A,  // 32-bit fixed-point input
    input  [31:0] B,  // 32-bit fixed-point input
    output [31:0] C   // 32-bit fixed-point output
);
    // Extraksi sign bits
    wire sign_A = A[31];
    wire sign_B = B[31];

    // Extraksi magnitude (mantissa + fraction)
    wire [30:0] mag_A = A[30:0];
    wire [30:0] mag_B = B[30:0];

    // Multiply magnitudes (unsigned multiplication)
    wire [61:0] product_unsigned = mag_A * mag_B;

    // Normalize the result by right-shifting 27 bits
    wire [31:0] normalized_product = product_unsigned[58:27]; // Keep 31 bits (including 1 for sign)

    // Determine the sign of the result
    wire result_sign = sign_A ^ sign_B; // XOR for determining sign

    // Combine sign and magnitude into final output
    assign C = {result_sign, normalized_product[30:0]}; // Concatenate sign and magnitude
endmodule