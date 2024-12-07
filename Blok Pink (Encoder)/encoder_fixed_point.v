`include "fixed_point_multiply.v" // Custom multiplier module
`include "fixed_point_add.v"      // Custom adder module

module encoder_fixed_point #(
    parameter N_input = 9,       // Number of inputs
    parameter M_output = 4,      // Number of outputs
    parameter BITSIZE = 32       // Data size (fixed-point 32-bit)
)(
    input wire [N_input*BITSIZE-1:0] x,           // Input data
    input wire [N_input*M_output*BITSIZE-1:0] w, // Weights
    input wire [M_output*BITSIZE-1:0] b,         // Bias
    output wire [M_output*BITSIZE-1:0] out,      // Output data
    input wire clk,                              // Clock
    input wire rst                               // Reset
);

    // Internal wires for intermediate results
    wire [BITSIZE-1:0] mult_result [0:N_input-1][0:M_output-1]; // Multiplication results
    wire [BITSIZE-1:0] sum_result [0:M_output-1];               // Sum of multiplications
    wire [BITSIZE-1:0] final_result [0:M_output-1];             // Final result after adding bias
    wire [BITSIZE-1:0] temp_sum [0:N_input];                    // Temporary sum for intermediate stages

    genvar i, j, k;

    // Parallel multiplication logic for each combination of x and w
    generate
        for (i = 0; i < N_input; i = i + 1) begin : gen_x
            for (j = 0; j < M_output; j = j + 1) begin : gen_w
                fixed_point_multiply mult_inst (
                    .A(x[(i+1)*BITSIZE-1:i*BITSIZE]),   // Input x
                    .B(w[(j*N_input + i + 1)*BITSIZE-1:(j*N_input + i)*BITSIZE]), // Weight w
                    .C(mult_result[i][j])              // Multiplication result
                );
            end
        end
    endgenerate

    // Parallel summation of multiplication results for each output
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_sum
            for (k = 0; k < N_input; k = k + 1) begin : gen_sum_stage
                if (k == 0) begin
                    assign temp_sum[k] = {BITSIZE{1'b0}}; // Initialize sum to zero
                end else begin
                    fixed_point_add add_inst (
                        .A(temp_sum[k-1]),
                        .B(mult_result[k-1][j]),
                        .C(temp_sum[k]) // Cumulative sum
                    );
                end
            end
            assign sum_result[j] = temp_sum[N_input-1];
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
