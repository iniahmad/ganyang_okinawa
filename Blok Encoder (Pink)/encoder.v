`include "fixed_point_multiply.v" // Modul custom multiplier
`include "fixed_point_add.v"      // Modul custom adder

module encoder_fixed_point #(
    parameter N_input = 9,       // Jumlah input
    parameter M_output = 4,     // Jumlah output
    parameter BITSIZE = 32      // Ukuran data (fixed-point 32-bit)
)(
    input wire [N_input*BITSIZE-1:0] x,           // Input data (flatten)
    input wire [N_input*M_output*BITSIZE-1:0] w, // Bobot (weights, flatten)
    input wire [M_output*BITSIZE-1:0] b,         // Bias (flatten)
    output reg [M_output*BITSIZE-1:0] output,    // Output data (flatten)
    input wire clk,                              // Clock
    input wire rst                               // Reset
);

    // Internal wires untuk hasil perkalian dan penjumlahan
    wire [BITSIZE-1:0] mult_result [0:N_input-1][0:M_output-1]; // Hasil perkalian
    reg [BITSIZE-1:0] sum [0:M_output-1];                      // Penjumlahan sementara
    wire [BITSIZE-1:0] add_result;                             // Hasil penjumlahan

    genvar i, j;

    // Generate blok multiplier untuk setiap kombinasi x dan w
    generate
        for (i = 0; i < N_input; i = i + 1) begin : gen_x
            for (j = 0; j < M_output; j = j + 1) begin : gen_w
                fixed_point_multiply mult_inst (
                    .A(x[(i+1)*BITSIZE-1:i*BITSIZE]),   // Input x
                    .B(w[(j*N_input + i + 1)*BITSIZE-1:(j*N_input + i)*BITSIZE]), // Input w
                    .C(mult_result[i][j])              // Hasil perkalian
                );
            end
        end
    endgenerate

    // Proses penjumlahan hasil perkalian dan penambahan bias
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset semua output
            output <= {M_output*BITSIZE{1'b0}};
        end else begin
            for (j = 0; j < M_output; j = j + 1) begin
                sum[j] = {BITSIZE{1'b0}}; // Reset penjumlahan sementara
                for (i = 0; i < N_input; i = i + 1) begin
                    // Gunakan fixed_point_add untuk penjumlahan
                    fixed_point_add adder_inst (
                        .A(sum[j]),
                        .B(mult_result[i][j]),
                        .C(add_result)
                    );
                    sum[j] = add_result; // Update sum dengan hasil penjumlahan
                end
                // Tambahkan bias menggunakan fixed_point_add
                fixed_point_add adder_bias (
                    .A(sum[j]),
                    .B(b[(j+1)*BITSIZE-1:j*BITSIZE]),
                    .C(output[(j+1)*BITSIZE-1:j*BITSIZE])
                );
            end
        end
    end

endmodule
