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
    wire [BITSIZE-1:0] intermediate_sum [0:N_input-1][0:M_output-1]; // Penjumlahan hasil perkalian sebelum digabungkan semuanya

    genvar i, j, k;

    // Logic Perkalian Paralel
    generate
        for (i = 0; i < N_input; i = i + 1) begin : gen_z
            for (j = 0; j < M_output; j = j + 1) begin : gen_w
                fixed_point_multiply mult_inst (
                    .A(z[(i+1)*BITSIZE-1:i*BITSIZE]),   // Input z
                    .B(w[(j*N_input + i + 1)*BITSIZE-1:(j*N_input + i)*BITSIZE]), // Weight w
                    .C(mult_result[i][j])              // Hasil perkalian
                );
            end
        end
    endgenerate

    // Penjumlahan Hasil Perkalian Paralel
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_sum
            for (k = 0; k < N_input; k = k + 1) begin : gen_intermediate_add
                // Menjumlahkan semua perkalian untuk tiap output
                if (k == 0) begin
                    assign intermediate_sum[k][j] = mult_result[k][j];
                end else begin
                    fixed_point_add add_inst (
                        .A(intermediate_sum[k-1][j]),
                        .B(mult_result[k][j]),
                        .C(intermediate_sum[k][j])
                    );
                end
            end
            // Masing-masing output 1-9
            assign sum_result[j] = intermediate_sum[N_input-1][j];
        end
    endgenerate

    // Penjumlahan Bias Paralel
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_bias
            fixed_point_add adder_bias (
                .A(sum_result[j]),
                .B(b[(j+1)*BITSIZE-1:j*BITSIZE]), // Bias
                .C(final_result[j])               // Hasil Akhir
            );
            assign out[(j+1)*BITSIZE-1:j*BITSIZE] = final_result[j];
        end
    endgenerate

endmodule
