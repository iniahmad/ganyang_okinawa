module fixed_point_add #(parameter BITSIZE = 16) (
    input clk,                     // Clock signal
    input rst,                     // Reset signal
    input [BITSIZE-1:0] A,         // Fixed-point input A
    input [BITSIZE-1:0] B,         // Fixed-point input B
    output reg [BITSIZE-1:0] C     // Result output
);
    // Internal registers for inputs
    reg [BITSIZE-1:0] A_in;
    reg [BITSIZE-1:0] B_in;

    // Extract sign and value parts from both inputs
    wire sign_A = A_in[BITSIZE-1];         // Sign bit A
    wire sign_B = B_in[BITSIZE-1];         // Sign bit B
    wire [BITSIZE-2:0] value_A = A_in[BITSIZE-2:0]; // Value A
    wire [BITSIZE-2:0] value_B = B_in[BITSIZE-2:0]; // Value B

    // Result components
    wire [BITSIZE-1:0] sum;
    wire result_sign;
    wire [BITSIZE-2:0] result_value;

    // Perform addition or subtraction based on sign
    assign sum = (sign_A == sign_B) ? (value_A + value_B) : 
                 (value_A > value_B ? (value_A - value_B) : (value_B - value_A));

    // Determine the result sign
    assign result_sign = (sign_A == sign_B) ? sign_A : (value_A > value_B ? sign_A : sign_B);

    // Overflow detection
    wire overflow = (sign_A == sign_B) && ((sum[BITSIZE-1] != sign_A) || (sum == {1'b1, {BITSIZE-1{1'b0}}}));

    // Handle overflow and underflow
    assign result_value = overflow ? {BITSIZE-1{1'b1}} : sum[BITSIZE-2:0];

    // Sequential logic for registers
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            A_in <= 0;
            B_in <= 0;
            C <= 0;
        end else begin
            A_in <= A;
            B_in <= B;
            // Combine sign and value for the final result
            C <= {result_sign, result_value};
        end
    end

endmodule