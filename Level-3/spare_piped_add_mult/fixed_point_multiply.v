module fixed_point_multiply #(parameter BITSIZE = 16, parameter FRAC = 11) (
    input clk,                     // Clock signal
    input rst,                     // Reset signal
    input [BITSIZE-1:0] A,         // BITSIZE-bit fixed-point input
    input [BITSIZE-1:0] B,         // BITSIZE-bit fixed-point input
    output reg [BITSIZE-1:0] C     // BITSIZE-bit fixed-point output
);

    // Internal registers for inputs
    reg [BITSIZE-1:0] A_in;
    reg [BITSIZE-1:0] B_in;

    // Extract sign bits
    wire sign_A = A_in[BITSIZE-1];
    wire sign_B = B_in[BITSIZE-1];

    // Extract magnitude (mantissa + fraction)
    wire [BITSIZE-2:0] mag_A = A_in[BITSIZE-2:0];
    wire [BITSIZE-2:0] mag_B = B_in[BITSIZE-2:0];

    // Multiply magnitudes (unsigned multiplication)
    wire [(2*BITSIZE)-3:0] product_unsigned = mag_A * mag_B;

    // Normalize the result by right-shifting FRAC bits
    wire [BITSIZE-2:0] normalized_product = product_unsigned[25:11];

    // Determine the sign of the result
    wire result_sign = sign_A ^ sign_B; // XOR for determining sign

    // Determine if the result is out of bounds (overflow)
    wire overflow = |product_unsigned[(2*BITSIZE)-3:26]; // Check if any of the higher bits are set

    // Sequential logic for registers
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_in <= 0;
            B_in <= 0;
            C <= 0;
        end else begin
            A_in <= A;
            B_in <= B;
            // Combine sign and magnitude into final output with saturation
            C <= overflow ? {result_sign, 15'b111_1111_1111_1111} : {result_sign, normalized_product};
        end
    end

endmodule
