`include "fixed_point_add.v"
`include "fixed_point_multiply.v"

module encoder_fixed_point #(
    parameter N_input = 9,        // Jumlah Input
    parameter M_output = 4,       // Jumlah Output
    parameter BITSIZE = 32        // Fixed Point 32-bit
)(
    input wire signed [N_input*BITSIZE-1:0] x,           // Input
    input wire signed [N_input*M_output*BITSIZE-1:0] w,  // Weight
    input wire signed [M_output*BITSIZE-1:0] b,          // Bias
    output wire signed [M_output*BITSIZE-1:0] out        // Output
);

    // Internal wires for results
    wire signed [BITSIZE-1:0] mult_result [0:N_input-1][0:M_output-1];    // Hasil perkalian
    wire signed [BITSIZE-1:0] tree_sum_result [0:M_output-1];             // Hasil adder tree untuk setiap output
    wire signed [BITSIZE-1:0] final_result [0:M_output-1];                // Hasil akhir setelah bias

    genvar i, j;

    // Perkalian Paralel
    generate
        for (i = 0; i < N_input; i = i + 1) begin : gen_x
            for (j = 0; j < M_output; j = j + 1) begin : gen_w
                fixed_point_multiply mult_inst (
                    .A(x[(i+1)*BITSIZE-1:i*BITSIZE]),
                    .B(w[(j*N_input + i)*BITSIZE +: BITSIZE]),
                    .C(mult_result[i][j])
                );
            end
        end
    endgenerate

    // Adder Tree
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_adder_tree
            // Level 1: Tambahkan pasangan-pasangan
            wire signed [BITSIZE-1:0] level1_sum [0:4];
            for (i = 0; i < 4; i = i + 1) begin : level1
                fixed_point_add adder_level1 (
                    .A(mult_result[2*i][j]),
                    .B(mult_result[2*i+1][j]),
                    .C(level1_sum[i])
                );
            end
            assign level1_sum[4] = mult_result[8][j]; // Sisa input

            // Level 2: Tambahkan hasil dari Level 1
            wire signed [BITSIZE-1:0] level2_sum [0:2];
            for (i = 0; i < 2; i = i + 1) begin : level2
                fixed_point_add adder_level2 (
                    .A(level1_sum[2*i]),
                    .B(level1_sum[2*i+1]),
                    .C(level2_sum[i])
                );
            end
            assign level2_sum[2] = level1_sum[4]; // Sisa input

            // Level 3: Tambahkan hasil dari Level 2
            wire signed [BITSIZE-1:0] level3_sum;
            fixed_point_add adder_level3 (
                .A(level2_sum[0]),
                .B(level2_sum[1]),
                .C(level3_sum)
            );

            // Final result dari Level 3 dan sisa
            fixed_point_add adder_final (
                .A(level3_sum),
                .B(level2_sum[2]),
                .C(tree_sum_result[j])
            );
        end
    endgenerate

    // Penambahan Bias
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_bias
            fixed_point_add adder_bias (
                .A(tree_sum_result[j]),
                .B(b[(j+1)*BITSIZE-1:j*BITSIZE]),
                .C(final_result[j])
            );
            assign out[(j+1)*BITSIZE-1:j*BITSIZE] = final_result[j];
        end
    endgenerate

endmodule
