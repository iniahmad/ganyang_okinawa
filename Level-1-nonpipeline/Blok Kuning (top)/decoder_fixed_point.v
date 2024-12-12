
module decoder_fixed_point #(
    parameter N_input = 2,        // Jumlah Input
    parameter M_output = 9,       // Jumlah Output
    parameter BITSIZE = 32        // Fixed Point 32-bit
)(
    input wire signed [N_input*BITSIZE-1:0] z,           // Input
    input wire signed [N_input*M_output*BITSIZE-1:0] w,  // Weight
    input wire signed [M_output*BITSIZE-1:0] b,          // Bias
    output wire signed [M_output*BITSIZE-1:0] out        // Output
);

    // Internal wires for results
    wire signed [BITSIZE-1:0] mult_result [0:N_input-1][0:M_output-1];    // Hasil perkalian
    wire signed [BITSIZE-1:0] final_result [0:M_output-1];                // Hasil akhir setelah ditambahkan bias
    wire signed [BITSIZE-1:0] tree_sum_result [0:M_output-1];             // Hasil adder tree untuk setiap output

    genvar i, j;

    // Logic Perkalian Paralel
    generate
        for (i = 0; i < N_input; i = i + 1) begin : gen_z
            for (j = 0; j < M_output; j = j + 1) begin : gen_w
                fixed_point_multiply mult_inst (
                    .A(z[(i+1)*BITSIZE-1:i*BITSIZE]),  // Input z: Select the correct slice for z
                    .B(w[(j*N_input + i)*BITSIZE +: BITSIZE]), // Weight w: Select the correct slice for w
                    .C(mult_result[i][j]) // Hasil perkalian
                );
            end
        end
    endgenerate

    // 1-Level Parallel Adder Tree (Penjumlahan Langsung dari 2 Multiplier)
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_adder_tree
            wire [BITSIZE-1:0] level1_sum;

            fixed_point_add level1_adder
            (
                .A(mult_result[0][j]),
                .B(mult_result[1][j]),
                .C(level1_sum)
            );

            assign tree_sum_result[j] = level1_sum;
        end
    endgenerate

    // Add Bias in Parallel
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_bias
            fixed_point_add adder_bias (
                .A(tree_sum_result[j]),                          // Hasil Akhir Penjumlahan dari Modul Perkalian
                .B(b[(j+1)*BITSIZE-1:j*BITSIZE]),                // Bias
                .C(final_result[j])                              // Hasil Akhir Setelah Bias
            );
            assign out[(j+1)*BITSIZE-1:j*BITSIZE] = final_result[j];
        end
    endgenerate

endmodule
