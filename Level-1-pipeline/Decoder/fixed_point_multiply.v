module fixed_point_multiply #(parameter BITSIZE = 16)
(
    input clk,                          // Clock signal
    input rst,                          // Reset signal
    input  [BITSIZE-1:0] A,             // Fixed-point input A
    input  [BITSIZE-1:0] B,             // Fixed-point input B
    output reg [BITSIZE-1:0] C          // Output Register
);

    // Sinyal Internal
    wire sign_A = A[BITSIZE-1];
    wire sign_B = B[BITSIZE-1];

    wire [BITSIZE-2:0] mag_A = A[BITSIZE-2:0];
    wire [BITSIZE-2:0] mag_B = B[BITSIZE-2:0];

    // Multiply magnitudes
    wire [(2*BITSIZE)-3:0] product_unsigned = mag_A * mag_B;

    wire [BITSIZE-1:0] normalized_product = product_unsigned[(2*BITSIZE)-6:BITSIZE-5];

    wire result_sign = sign_A ^ sign_B;

    wire [BITSIZE-1:0] next_C = {result_sign, normalized_product[BITSIZE-2:0]};

    // Sekuensial Logic
    always @(posedge clk or posedge rst) begin
        if (rst)
            C <= {BITSIZE{1'b0}}; // Reset ke '0'
        else
            C <= next_C;          // Update Output saat Rising Edge
    end

endmodule
