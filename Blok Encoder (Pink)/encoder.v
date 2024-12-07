`include "multiplier.v" // Include modul multiplier custom

module encoder #(
    parameter N_input = 9,       // Jumlah input
    parameter M_output = 4,     // Jumlah output
    parameter BITSIZE = 32      // Ukuran data (bit)
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

    genvar i, j;

    // Generate blok multiplier untuk setiap kombinasi x dan w
    generate
        for (i = 0; i < N_input; i = i + 1) begin : gen_x
            for (j = 0; j < M_output; j = j + 1) begin : gen_w
                multiplier #(
                    .BITSIZE(BITSIZE)
                ) mult_inst (
                    .a(x[(i+1)*BITSIZE-1:i*BITSIZE]),   // Input x
                    .b(w[(j*N_input + i + 1)*BITSIZE-1:(j*N_input + i)*BITSIZE]), // Input w
                    .result(mult_result[i][j])          // Hasil perkalian
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
                sum[j] = 0; // Reset penjumlahan sementara
                for (i = 0; i < N_input; i = i + 1) begin
                    sum[j] = sum[j] + mult_result[i][j]; // Penjumlahan hasil multiplier
                end
                // Tambahkan bias dan assign ke output
                output[(j+1)*BITSIZE-1:j*BITSIZE] = sum[j] + b[(j+1)*BITSIZE-1:j*BITSIZE];
            end
        end
    end

endmodule
