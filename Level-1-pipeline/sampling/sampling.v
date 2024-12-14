`include "fixed_point_multiply.v" // Custom multiplier module
`include "fixed_point_add.v"      // Custom adder module
`include "compare_8float.v"       // Compare module for piecewise
`include "PRNG.v"                 // Random generator module

module sampling_VAE #(
    parameter N_input = 2,        // Number of Inputs
    parameter M_output = 2,       // Number of Outputs
    parameter BITSIZE = 16        // Fixed Point 16-bit
)(
    input wire clk,                                    // Clock signal
    input wire rst,                                    // Reset signal
    input wire [N_input*BITSIZE-1:0] ac,               // Input Mean
    input wire [N_input*BITSIZE-1:0] ad,               // Input Variance
    output reg [M_output*BITSIZE-1:0] a,              // Output
    output wire [N_input*BITSIZE-1:0] epsilon          // Epsilon for verification
);


// UNTUK PIECEWISE SQUARE ROOT
// inisiasi value langsung untuk memperkecil perhitungan m tuh dari ((y2-y1)/(x2-x1)), c tuh (y1 - m*x1)
wire [15:0] m1 = 16'b0101001110001101; // m1 = 10.4443   value m1 untuk membuat garis 1
wire [15:0] c1 = 16'b0000000000000000; // c1 = 0.00000   value c1 untuk membuat garis 1

wire [15:0] m2 = 16'b0001001111100011; // m2 = 2.4860    value m2 untuk membuat garis 2
wire [15:0] c2 = 16'b0000000010010101; // c2 = 0.0730    value c2 untuk membuat garis 2

wire [15:0] m3 = 16'b0000100011001001; // m3 = 1.0983    value m3 untuk membuat garis 3
wire [15:0] c3 = 16'b0000000110100000; // c3 = 0.2033    value c3 untuk membuat garis 3

wire [15:0] m4 = 16'b0000010100110111; // m4 = 0.6523    value m4 untuk membuat garis 4
wire [15:0] c4 = 16'b0000001011101101; // c4 = 0.3660    value c4 untuk membuat garis 4

wire [15:0] m5 = 16'b0000001110001101; // m5 = 0.4443   value m5 untuk membuat garis 5
wire [15:0] c5 = 16'b0000010001011101; // c5 = 0.5456    value c5 untuk membuat garis 5

wire [15:0] m6 = 16'b0000001010101001; // m6 = 0.3326    value m6 untuk membuat garis 6
wire [15:0] c6 = 16'b0000010111101101; // c6 = 0.7407    value c6 untuk membuat garis 6

wire [15:0] m7 = 16'b0000001000011111; // m7 = 0.2654    value m7 untuk membuat garis 7
wire [15:0] c7 = 16'b0000011101110011; // c7 = 0.9315    value c7 untuk membuat garis 7

wire [15:0] m8 = 16'b0000000110111111; // m8 = 0.2184    value m8 untuk membuat garis 8
wire [15:0] c8 = 16'b0000100100010100; // c8 = 1.1352    value c8 untuk membuat garis 8

wire [15:0] m9 = 16'b0000000110000000; // m9 = 0.1878    value m9 untuk membuat garis 9
wire [15:0] c9 = 16'b0000101010011011; // c9 = 1.3257    value c9 untuk membuat garis 9

// Nilai slice x yang optimal
wire [15:0] x1 = 16'b0000000000010010; // x1 = 0.00916727
wire [15:0] x2 = 16'b0000000011000000; // x2 = 0.09394428
wire [15:0] x3 = 16'b0000001011101011; // x3 = 0.36476698
wire [15:0] x4 = 16'b0000011011100111; // x4 = 0.86324246 
wire [15:0] x5 = 16'b0000110111111000; // x5 = 1.74648981 
wire [15:0] x6 = 16'b0001011010111001; // x6 = 2.84044815
wire [15:0] x7 = 16'b0010001010110011; // x7 = 4.33743198 
wire [15:0] x8 = 16'b0011000111001110; // x8 = 6.2260287

// Internal registers for pipeline stages
reg [BITSIZE-1:0] mult_result_piecewise_reg [0:N_input-1];
reg [BITSIZE-1:0] add_result_piecewise_reg [0:N_input-1];
reg [BITSIZE-1:0] epsilon_reg [0:N_input-1];
reg [BITSIZE-1:0] mult_result_sampling_reg [0:N_input-1];
reg [BITSIZE-1:0] add_result_sampling_reg[0:M_output-1];

// Penyimpanan Bagian Penentuan Region
wire [BITSIZE-1:0] m_out [0:N_input-1];        // Array untuk menyimpan m terpilih (tergantung region)
wire [BITSIZE-1:0] c_out [0:N_input-1];        // Array untuk menyimpan c terpilih (tergantung region)

// GENVAR LOOP
genvar i;

// PIECEWISE OPERATION
generate
    for (i = 0; i < N_input; i = i + 1) begin : pipeline_piecewise
        wire [BITSIZE-1:0] mult_temp, add_temp;

        // Compare piecewise
        compare_8float custom_mux (
            .data  (ad[(i+1)*BITSIZE-1:i*BITSIZE]),
            .x1    (x1), .x2(x2), .x3(x3), .x4(x4),
            .x5    (x5), .x6(x6), .x7(x7), .x8(x8),
            .m1    (m1), .m2(m2), .m3(m3), .m4(m4),
            .m5    (m5), .m6(m6), .m7(m7), .m8(m8), .m9(m9),
            .c1    (c1), .c2(c2), .c3(c3), .c4(c4),
            .c5    (c5), .c6(c6), .c7(c7), .c8(c8), .c9(c9),
            .m     (m_out[i]),
            .c     (c_out[i]),
            .clk   (clk), .reset(rst)
        );

        // Multiply m with ad
        fixed_point_multiply M1 (
            .A(ad[(i+1)*BITSIZE-1:i*BITSIZE]),
            .B(m_out[i]),
            .C(mult_temp)
        );

        // Pipeline register stage 2
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                mult_result_piecewise_reg[i] <= 0;
            end else begin
                mult_result_piecewise_reg[i] <= mult_temp;
            end
        end

        // Add c
        fixed_point_add A1 (
            .A(mult_result_piecewise_reg[i]),
            .B(c_out[i]),
            .C(add_temp)
        );

        // Pipeline register stage 3
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                add_result_piecewise_reg[i] <= 0;
            end else begin
                add_result_piecewise_reg[i] <= add_temp;
            end
        end
    end
endgenerate

// Ambil nilai epsilon
wire [BITSIZE-1:0] e[0:N_input-1];
wire [4:0] state;
reg  [4:0] seed;

// GENERATE EPSILON (PRNG OUTPUT)
generate
    for (i = 0; i < N_input; i = i + 1) begin : pipeline_epsilon

        PRNG prng_inst (
            .random_out(e[i]),
            .clk(clk),
            .rst(rst),
            .seed(seed),
            .statee(state)
        );

        assign epsilon[(i+1)*BITSIZE-1:i*BITSIZE] = e[i];
    end
endgenerate

// SAMPLING OPERATION
generate
    for (i = 0; i < N_input; i = i + 1) begin : pipeline_sampling
        wire [BITSIZE-1:0] mult_temp;

        fixed_point_multiply mult_inst (
            .A(add_result_piecewise_reg[i]),
            .B(e[i]),
            .C(mult_temp)
        );

        // Pipeline register stage for sampling multiplication
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                mult_result_sampling_reg[i] <= 0;
            end else begin
                mult_result_sampling_reg[i] <= mult_temp;
            end
        end
    end
endgenerate

// FINAL ADDITION WITH MEAN (ac)
generate
    for (i = 0; i < M_output; i = i + 1) begin : pipeline_final_add
        wire [BITSIZE-1:0] add_temp;

        fixed_point_add A2 (
            .A(mult_result_sampling_reg[i]),
            .B(ac[(i+1)*BITSIZE-1:i*BITSIZE]),
            .C(add_temp)
        );

        // Pipeline register stage for final addition
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                add_result_sampling_reg[i] <= 0;
            end else begin
                add_result_sampling_reg[i] <= add_temp;
            end
        end

        // Use an always block to assign to a
        always @(posedge clk or posedge rst) begin
            if (rst) begin
                a[(i+1)*BITSIZE-1:i*BITSIZE] <= 0;
            end else begin
                a[(i+1)*BITSIZE-1:i*BITSIZE] <= add_result_sampling_reg[i];
            end
        end
    end
endgenerate

endmodule
