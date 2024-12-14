module fixed_point_add #(parameter BITSIZE = 16)
(
    input clk,                          // Clock signal
    input rst,                          // Reset signal
    input [BITSIZE-1:0] A,              // Fixed-point input A
    input [BITSIZE-1:0] B,              // Fixed-point input B
    output reg [BITSIZE-1:0] C          // Output Register
);

    // Internal wires
    wire sign_A = A[BITSIZE-1];                  // Sign bit A
    wire sign_B = B[BITSIZE-1];                  // Sign bit B
    wire [BITSIZE-2:0] value_A = A[BITSIZE-2:0];
    wire [BITSIZE-2:0] value_B = B[BITSIZE-2:0];

    wire result_sign;
    wire new_result_sign;
    wire [BITSIZE-2:0] result_value;

    // Determine result sign and value
    assign result_sign = (sign_A == sign_B) ? sign_A : (value_A > value_B ? sign_A : sign_B);
    assign result_value = (sign_A == sign_B) ? (value_A + value_B) : 
                          (value_A > value_B ? (value_A - value_B) : (value_B - value_A));
    assign new_result_sign = (result_value == 0) ? 0 : result_sign;

    wire [BITSIZE-1:0] next_C = {new_result_sign, result_value};

    // Sequential logic for registered output
    always @(posedge clk or posedge rst) begin
        if (rst)
            C <= {BITSIZE{1'b0}}; // Reset Output ke '0'
        else
            C <= next_C;          // Update Output saat Rising Edge
    end

endmodule
