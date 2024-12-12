module fixed_point_multiply #(parameter BITSIZE = 16) (
    input  [BITSIZE-1:0] A,  // BITSIZE-bit fixed-point input (sign-magnitude)
    input  [BITSIZE-1:0] B,  // BITSIZE-bit fixed-point input (sign-magnitude)
    output [BITSIZE-1:0] C   // BITSIZE-bit fixed-point output (sign-magnitude)
);
    // Extract sign bits
    wire sign_A = A[BITSIZE-1];
    wire sign_B = B[BITSIZE-1];

    // Extract magnitude (mantissa + fraction)
    wire [BITSIZE-2:0] mag_A = A[BITSIZE-2:0];
    wire [BITSIZE-2:0] mag_B = B[BITSIZE-2:0];

    // Multiply magnitudes (unsigned multiplication)
    wire [(2*BITSIZE)-3:0] product_unsigned = mag_A * mag_B;

    // Normalize the result by right-shifting (BITSIZE-1) bits
    wire [BITSIZE-1:0] normalized_product = product_unsigned[(2*BITSIZE)-6:BITSIZE-5]; // Keep BITSIZE bits (including 1 for sign)

    // Determine the sign of the result
    wire result_sign = sign_A ^ sign_B; // XOR for determining sign

    // Combine sign and magnitude into final output
    assign C = {result_sign, normalized_product[BITSIZE-2:0]}; // Concatenate sign and magnitude
endmodule