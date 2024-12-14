//`include "fixed_point_add.v"
//`include "fixed_point_multiply.v"

module decoder_fixed_point_pipeline
#(
    parameter N_input = 2,        // Jumlah Input
    parameter M_output = 9,       // Jumlah Output
    parameter BITSIZE = 16        // Ukuran Bit
)
(
    input wire clk,                                     // Clock
    input wire reset,                                   // Reset
    input wire signed [N_input*BITSIZE-1:0] z,          // Input
    input wire signed [N_input*M_output*BITSIZE-1:0] w, // Weight
    input wire signed [M_output*BITSIZE-1:0] b,         // Bias
    output wire signed [M_output*BITSIZE-1:0] out       // Output
);

    // Internal signals
    wire signed [BITSIZE-1:0] mult_result [0:N_input-1][0:M_output-1];    // Hasil Perkalian
    reg signed [BITSIZE-1:0] mult_result_reg [0:N_input-1][0:M_output-1]; // Register Pipeline Penyimpanan Hasil Perkalian

    wire signed [BITSIZE-1:0] adder_tree_result [0:M_output-1];           // Hasil Adder Tree
    reg signed [BITSIZE-1:0] adder_tree_reg [0:M_output-1];               // Register Pipeline Penyimpanan Hasil Adder Tree

    wire signed [BITSIZE-1:0] final_result [0:M_output-1];                // Hasil Akhir
    reg signed [BITSIZE-1:0] final_result_reg [0:M_output-1];             // Register Pipeline Penyimpanan Hasil Akhir

    genvar i, j;

    //-----------------------------------//
    //      Stage 1: Multiplication      //
    //-----------------------------------//
    generate
        for (i = 0; i < N_input; i = i + 1) begin : gen_mult_input
            for (j = 0; j < M_output; j = j + 1) begin : gen_mult_weight
                fixed_point_multiply mult_inst
                (
//                    .clk(clk),                                      
//                    .rst(reset),                                     
                    .A(z[(i+1)*BITSIZE-1:i*BITSIZE]),                // Input
                    .B(w[(j*N_input + i)*BITSIZE +: BITSIZE]),       // Weight
                    .C(mult_result[i][j])                            // Hasil Perkalian
                );

                // Pipeline Register: Simpan Hasil Perkalian
                always @(posedge clk or posedge reset) begin
                    if (reset) begin
                        mult_result_reg[i][j] <= 0;
                    end else begin
                        mult_result_reg[i][j] <= mult_result[i][j];
                    end
                end
            end
        end
    endgenerate

    //----------------------------------//
    //   Stage 2: Parallel Adder Tree   //
    //----------------------------------//
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_adder_tree
            wire signed [BITSIZE-1:0] adder_tree_sum;

            fixed_point_add adder_tree_inst
            (
//                .clk(clk),                                     
//                .rst(reset),                                   
                .A(mult_result_reg[0][j]),                     // Hasil Perkalian Input 1
                .B(mult_result_reg[1][j]),                     // Hasil Perkalian Input 2
                .C(adder_tree_sum)                             // Hasil Adder Tree
            );

            // Pipeline Register: Simpan Hasil Adder Tree
            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    adder_tree_reg[j] <= 0;
                end else begin
                    adder_tree_reg[j] <= adder_tree_sum;
                end
            end
        end
    endgenerate

    //----------------------------------//
    //     Stage 3: Penjumlahan Bias    //
    //----------------------------------//
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_bias_addition
            wire signed [BITSIZE-1:0] bias_sum;

            fixed_point_add bias_adder_inst
            (
//                .clk(clk),                                         
//                .rst(reset),                                       
                .A(adder_tree_reg[j]),                             // Hasil Adder Tree
                .B(b[(j+1)*BITSIZE-1:j*BITSIZE]),                  // Bias
                .C(bias_sum)                                       // Hasil Akhir
            );

            // Pipeline Register: Simpan Hasil Akhir
            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    final_result_reg[j] <= 0;
                end else begin
                    final_result_reg[j] <= bias_sum;
                end
            end

            assign out[(j+1)*BITSIZE-1:j*BITSIZE] = final_result_reg[j];
        end
    endgenerate

endmodule
