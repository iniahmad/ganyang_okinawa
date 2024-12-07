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
    wire [BITSIZE-1:0] intermediate_sum [0:N_input-1][0:M_output-1]; // Intermediate sum results

    genvar i, j, k;

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

    // Parallel summation of multiplication results for each output using fixed_point_add
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_sum
            for (k = 0; k < N_input; k = k + 1) begin : gen_intermediate_add
                // Adding all multiplication results for each output
                if (k == 0) begin
                    assign intermediate_sum[k][j] = mult_result[k][j]; // Initialize with the first multiplier result
                end else begin
                    fixed_point_add add_inst (
                        .A(intermediate_sum[k-1][j]),
                        .B(mult_result[k][j]),
                        .C(intermediate_sum[k][j])
                    );
                end
            end
            // Assign the final sum for this output
            assign sum_result[j] = intermediate_sum[N_input-1][j];
        end
    endgenerate

    // Add biases in parallel using fixed_point_add
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_bias
            fixed_point_add adder_bias (
                .A(sum_result[j]),
                .B(b[(j+1)*BITSIZE-1:j*BITSIZE]), // Bias
                .C(final_result[j])               // Final result
            );
            assign out[(j+1)*BITSIZE-1:j*BITSIZE] = final_result[j];
        end
    endgenerate

endmodule
