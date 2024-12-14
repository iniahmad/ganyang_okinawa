`include "fixed_point_add.v"
`include "fixed_point_multiply.v"

module encoder_fixed_point #(
    parameter N_input = 9,        // Jumlah Input
    parameter M_output = 4,       // Jumlah Output
    parameter BITSIZE = 32        // Fixed Point 32-bit
)(
    input clk,
    input rst,
    input wire signed [N_input*BITSIZE-1:0] x,           // Input
    input wire signed [N_input*M_output*BITSIZE-1:0] w,  // Weight
    input wire signed [M_output*BITSIZE-1:0] b,          // Bias
    output wire signed [M_output*BITSIZE-1:0] out       // Output    
);
    // Pipeline register parallel multiplication
    reg signed [BITSIZE-1:0] reg_x [0:N_input-1];
    reg signed [BITSIZE-1:0] reg_w [0:N_input-1][0:M_output-1];
    wire signed [BITSIZE-1:0] stage1_mul_result [0:N_input-1][0:M_output-1];

    // Pipeline register adder tree
    reg signed [BITSIZE-1:0] stage1_reg [0:N_input-1][0:M_output-1];
    wire signed [BITSIZE-1:0] stage2_tree_sum_result [0:M_output-1];  
    wire signed [BITSIZE-1:0] stage3_final_result [0:M_output-1];

    genvar i, j;
    integer k, l;
    
    // Buffer input dan weight
    always @(posedge clk or posedge rst) begin        
        if (rst) begin
        
            for (k = 0; k < N_input; k = k + 1) begin
                reg_x[k] <= 0;
                for (l = 0; l < M_output; l = l + 1) begin
                    reg_w[k][l] <= 0;
                end
            end
        end else begin
            for (k = 0; k < N_input; k = k + 1) begin
                reg_x[k] <= x[(k+1)*BITSIZE-1:k*BITSIZE];
                for (l = 0; l < M_output; l = l + 1) begin
                    reg_w[k][l] <= w[(l*N_input + k)*BITSIZE +: BITSIZE];
                end
            end
        end
    end

    // Perkalian Paralel
    generate
        for (i = 0; i < N_input; i = i + 1) begin : gen_x
            for (j = 0; j < M_output; j = j + 1) begin : gen_w
                fixed_point_multiply mult_inst (
                    .A(reg_x[i]),
                    .B(reg_w[i][j]),
                    .C(stage1_mul_result[i][j])
                );
            end
        end
    endgenerate

    // Buffer input tree stage 1
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < N_input; i = i + 1) begin
                for (j = 0; j < M_output; j = j + 1) begin
                    stage1_reg[i][j] <= 0;
                end
            end
        end else begin
            for (i = 0; i < N_input; i = i + 1) begin
                for (j = 0; j < M_output; j = j + 1) begin
                    stage1_reg[i][j] <= stage1_mul_result[i][j];
                end
            end
        end
    end
   
    // Adder Tree
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_adder_tree
            // Level 1: Tambahkan pasangan-pasangan
            wire signed [BITSIZE-1:0] level1_sum [0:4];
            for (i = 0; i < 4; i = i + 1) begin : level1
                fixed_point_add adder_level1 (
                    .A(stage1_reg[2*i][j]),
                    .B(stage1_reg[2*i+1][j]),
                    .C(level1_sum[i])
                );
            end
            assign level1_sum[4] = stage1_reg[8][j]; // Sisa input

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
                .C(stage2_tree_sum_result[j])
            );
        end
    endgenerate

    // Penambahan Bias
    generate
        for (j = 0; j < M_output; j = j + 1) begin : gen_bias
            fixed_point_add adder_bias (
                .A(stage2_tree_sum_result[j]),
                .B(b[(j+1)*BITSIZE-1:j*BITSIZE]),
                .C(stage3_final_result[j])
            );
            assign out[(j+1)*BITSIZE-1:j*BITSIZE] = stage3_final_result[j];
        end
    endgenerate

endmodule
