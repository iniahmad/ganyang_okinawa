`include "fixed_point_multiply.v" // Custom multiplier module for our version of 32-bit Fixed_Point
`include "fixed_point_add.v"      // Custom adder module for our version of 32-bit Fixed_Point

module decoder_fixed_point #(
    parameter N_input = 2,        // Jumlah Input
    parameter M_output = 9,       // Jumlah Output
    parameter BITSIZE = 32        // Fixed Point 32-bit
)(
    input wire [N_input*BITSIZE-1:0] z,           // Input
    input wire [N_input*M_output*BITSIZE-1:0] w,  // Weight
    input wire [M_output*BITSIZE-1:0] b,          // Bias
    output wire [M_output*BITSIZE-1:0] out        // Output
);

    // Internal wires for results
    wire [BITSIZE-1:0] mult_result [0:N_input-1][0:M_output-1];      // Hasil perkalian
    wire [BITSIZE-1:0] sum_result [0:M_output-1];                    // Penjumlahan hasil perkalian setelah digabungkan semuanya
    wire [BITSIZE-1:0] final_result [0:M_output-1];                  // Hasil akhir setelah ditambahkan bias
    wire [BITSIZE-1:0] tree_sum_result [0:M_output-1];               // Hasil adder tree untuk setiap output

    genvar i, j, k;

    // Logic Perkalian Paralel
    generate
        for (i = 0; i < N_input; i = i + 1) begin : gen_z
            for (j = 0; j < M_output; j = j + 1) begin : gen_w
                fixed_point_multiply mult_inst (
                    .A(z[(i+1)*BITSIZE-1:i*BITSIZE]),                             // Input z
                    .B(w[(j*N_input + i + 1)*BITSIZE-1:(j*N_input + i)*BITSIZE]), // Weight w
                    .C(mult_result[i][j])                                         // Hasil perkalian
                );
            end
        end
    endgenerate

    // Parallel Adder Tree supaya 100% Paralel
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_adder_tree
            // Level 1: Menjumlahkan Hasil Perkalian
            wire [BITSIZE-1:0] level1_sum [0:N_input/2-1];
            if (N_input >= 2) begin
                for (k = 0; k < N_input/2; k = k + 1) begin : level1
                    fixed_point_add level1_adder
                    (
                        .A(mult_result[2*k][j]),
                        .B(mult_result[2*k+1][j]),
                        .C(level1_sum[k])
                    );
                end
            end

            // Level 2: Penjumlahan dari Level 1
            wire [BITSIZE-1:0] level2_sum [0:N_input/4-1];
            if (N_input >= 4) begin
                for (k = 0; k < N_input/4; k = k + 1) begin : level2
                    fixed_point_add level2_adder (
                        .A(level1_sum[2*k]),
                        .B(level1_sum[2*k+1]),
                        .C(level2_sum[k])
                    );
                end
            end

            // Level 3
            wire [BITSIZE-1:0] level3_sum [0:N_input/8-1];
            if (N_input >= 8) begin
                for (k = 0; k < N_input/8; k = k + 1) begin : level3
                    fixed_point_add level3_adder (
                        .A(level2_sum[2*k]),
                        .B(level2_sum[2*k+1]),
                        .C(level3_sum[k])
                    );
                end
            end

            // Final Result dari Summation
            assign tree_sum_result[j] = (N_input >= 8) ? level3_sum[0] : (N_input >= 4) ? level2_sum[0] : level1_sum[0];
        end
    endgenerate

    // Penjumlahan Bias Paralel
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
