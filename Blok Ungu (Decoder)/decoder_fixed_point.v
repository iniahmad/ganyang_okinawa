`include "fixed_point_multiply.v" // Custom multiplier module
`include "fixed_point_add.v"      // Custom adder module

module decoder_fixed_point #(
    parameter N_input = 2,        // Number of inputs
    parameter M_output = 9,       // Number of outputs
    parameter BITSIZE = 32        // Data size (fixed-point 32-bit)
)(
    input wire [N_input*BITSIZE-1:0] z,           // Input data
    input wire [N_input*M_output*BITSIZE-1:0] w,  // Weight
    input wire [M_output*BITSIZE-1:0] b,          // Bias
    output wire [M_output*BITSIZE-1:0] out        // Output data
);

    // Internal wires for results
    wire [BITSIZE-1:0] mult_result [0:N_input-1][0:M_output-1]; // Multiplication results
    wire [BITSIZE-1:0] sum_result [0:M_output-1];               // Sum of multiplications
    wire [BITSIZE-1:0] final_result [0:M_output-1];             // Final result after adding bias

    genvar i, j;

    // Parallel multiplication logic for each combination of z and w
    generate
        for (i = 0; i < N_input; i = i + 1) begin : gen_z
            for (j = 0; j < M_output; j = j + 1) begin : gen_w
                fixed_point_multiply mult_inst (
                    .A(z[(i+1)*BITSIZE-1:i*BITSIZE]),   // Input z
                    .B(w[(j*N_input + i + 1)*BITSIZE-1:(j*N_input + i)*BITSIZE]), // Weight w
                    .C(mult_result[i][j])              // Multiplication result
                );
            end
        end
    endgenerate

    // Parallel summation of multiplication results for each output
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_sum
            reg [BITSIZE-1:0] temp_sum;
            integer k;

            always @(*) begin
                temp_sum = {BITSIZE{1'b0}}; // Initialize sum to zero
                for (k = 0; k < N_input; k = k + 1) begin
                    temp_sum = temp_sum + mult_result[k][j];
                end
            end
            assign sum_result[j] = temp_sum;
        end
    endgenerate

    // Add biases in parallel
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_bias
            fixed_point_add adder_bias (
                .A(sum_result[j]),
                .B(b[(j+1)*BITSIZE-1:j*BITSIZE]), // Bias
                .C(final_result[j])              // Final result
            );
            assign out[(j+1)*BITSIZE-1:j*BITSIZE] = final_result[j];
        end
    endgenerate

endmodule