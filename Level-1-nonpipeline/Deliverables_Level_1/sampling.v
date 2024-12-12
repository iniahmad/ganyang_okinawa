
module sampling #(
    parameter N_input = 2,        // Jumlah Input
    parameter M_output = 2,       // Jumlah Output
    parameter BITSIZE = 32        // Fixed Point 32-bit
)(
    input wire [N_input*BITSIZE-1:0] ac,            // Input Mean
    input wire [N_input*BITSIZE-1:0] ad,            // Input Variance
    output wire [M_output*BITSIZE-1:0] a,           // Output
    output wire [N_input*BITSIZE-1:0] epsilon       // Epsilon (Untuk verifikasi output)
);

// UNTUK PIECEWISE SQUARE ROOT
// inisiasi value langsung untuk memperkecil perhitungan m tuh dari ((y2-y1)/(x2-x1)), c tuh (y1 - m*x1)
wire [31:0] m1 = 32'b01010011100011011111010011100000; // m1 = 10.4443   value m1 untuk membuat garis 1
wire [31:0] c1 = 32'b00000000000000000000000000000000; // c1 = 0.00000   value c1 untuk membuat garis 1

wire [31:0] m2 = 32'b00010011111000110101111100011000; // m2 = 2.4860    value m2 untuk membuat garis 2
wire [31:0] c2 = 32'b00000000100101010110100111011110; // c2 = 0.0730    value c2 untuk membuat garis 2

wire [31:0] m3 = 32'b00001000110010010110011111010111; // m3 = 1.0983    value m3 untuk membuat garis 3
wire [31:0] c3 = 32'b00000001101000000110011001100101; // c3 = 0.2033    value c3 untuk membuat garis 3

wire [31:0] m4 = 32'b00000101001101111110001000101011; // m4 = 0.6523    value m4 untuk membuat garis 4
wire [31:0] c4 = 32'b00000010111011011001111101101001; // c4 = 0.3660    value c4 untuk membuat garis 4

wire [31:0] m5 = 32'b00000011100011011111010011100110; // m5 = 0.4443   value m5 untuk membuat garis 5
wire [31:0] c5 = 32'b00000100010111010100110100000011; // c5 = 0.5456    value c5 untuk membuat garis 5

wire [31:0] m6 = 32'b00000010101010010001100011111100; // m6 = 0.3326    value m6 untuk membuat garis 6
wire [31:0] c6 = 32'b00000101111011010000000000110101; // c6 = 0.7407    value c6 untuk membuat garis 6

wire [31:0] m7 = 32'b00000010000111111000010111000011; // m7 = 0.2654    value m7 untuk membuat garis 7
wire [31:0] c7 = 32'b00000111011100111100011010010100; // c7 = 0.9315    value c7 untuk membuat garis 7

wire [31:0] m8 = 32'b00000001101111110101111100010111; // m8 = 0.2184    value m8 untuk membuat garis 8
wire [31:0] c8 = 32'b00001001000101001101001100001110; // c8 = 1.1352    value c8 untuk membuat garis 8

wire [31:0] m9 = 32'b00000001100000001011001100110101; // m9 = 0.1878    value m9 untuk membuat garis 9
wire [31:0] c9 = 32'b00001010100110110000010010111000; // c9 = 1.3257    value c9 untuk membuat garis 9

// Nilai slice x yang optimal
wire [31:0] x1 = 32'b00000000000100101100011001001010; // x1 = 0.00916727
wire [31:0] x2 = 32'b00000000110000000110010111011011; // x2 = 0.09394428
wire [31:0] x3 = 32'b00000010111010110000101011110011; // x3 = 0.36476698
wire [31:0] x4 = 32'b00000110111001111110101110101010; // x4 = 0.86324246 
wire [31:0] x5 = 32'b00001101111110001100111110100110; // x5 = 1.74648981 
wire [31:0] x6 = 32'b00010110101110010011110011100001; // x6 = 2.84044815
wire [31:0] x7 = 32'b00100010101100110000111110001001; // x7 = 4.33743198 
wire [31:0] x8 = 32'b00110001110011101110100000100011; // x8 = 6.2260287

// PENYIMPANAN INTERNAL
// Penyimpanan Bagian Penentuan Region
wire [31:0] m_out [0:N_input-1];        // Array untuk menyimpan m terpilih (tergantung region)
wire [31:0] c_out [0:N_input-1];        // Array untuk menyimpan c terpilih (tergantung region)

// Penyimpanan Hasil Square Root dengan Piecewise
wire [BITSIZE-1:0] mult_result_piecewise [0:N_input-1];          // Hasil perkalian m * x pada persamaan garis
wire [BITSIZE-1:0] add_result_piecewise [0:N_input-1];           // Hasil penjumlahan dengan c pada persamaan garis

// Penyimpanan Hasil Sampling
wire [BITSIZE-1:0] mult_result_sampling [0:N_input-1];      // Hasil perkalian ad dengan epsilon
wire [BITSIZE-1:0] add_result_sampling [0:M_output-1];                    // Penjumlahan ac dengan hasil perkalian

// GENVAR LOOP=======================================================
genvar i, j;

// BAGIAN PIECEWISE (SQUARE ROOT DARI AD)============================
// Compare piecewise
generate
    for (i = 0; i < N_input; i = i + 1) begin : gen_compare
        compare_8float custom_mux (
            .data  (ad[(i+1)*BITSIZE-1:i*BITSIZE]),
            .x1    (x1),
            .x2    (x2),
            .x3    (x3),
            .x4    (x4),
            .x5    (x5),
            .x6    (x6),
            .x7    (x7),
            .x8    (x8),
            .m1    (m1),
            .m2    (m2),
            .m3    (m3),
            .m4    (m4),
            .m5    (m5),
            .m6    (m6),
            .m7    (m7),
            .m8    (m8),
            .m9    (m9),
            .c1    (c1),
            .c2    (c2),
            .c3    (c3),
            .c4    (c4),
            .c5    (c5),
            .c6    (c6),
            .c7    (c7),
            .c8    (c8),
            .c9    (c9),
            .m     (m_out[i]),
            .c     (c_out[i])
        );
    end
endgenerate

// Perkalian m dengan ad (sebagai x)
generate
    for (i = 0; i < N_input; i = i + 1) begin : gen_mult_piecewise
        fixed_point_multiply M1 (
            .A(ad[(i+1)*BITSIZE-1:i*BITSIZE]), // Input ad
            .B(m_out[i]),                      // Slope m_out[i]
            .C(mult_result_piecewise[i])       // Hasil perkalian
        );
    end
endgenerate

// Penjumlahan dengan c
generate
    for (i = 0; i < N_input; i = i + 1) begin : gen_add_piecewise
        fixed_point_add A1 (
            .A(mult_result_piecewise[i]),      // Hasil perkalian m * x
            .B(c_out[i]),                      // Intercept m_out[i]
            .C(add_result_piecewise[i])        // Hasil penjumlahan
        );
    end
endgenerate

// BAGIAN SAMPLING================================================================
// Ambil nilai epsilon
wire [31:0] e[0:N_input-1];

// Declare PRNG instance
generate
    for (i = 0; i < N_input; i = i + 1) begin : gen_epsilon
        // Multiply z[i] with epsilon (random number)
        PRNG prng_inst (
            .random_out(e[i])  // Connect PRNG output to epsilon
        );
    end
endgenerate


// Perkalian akar ad dengan epsilon
// Logic Perkalian Paralel
generate
    for (i = 0; i < N_input; i = i + 1) begin : gen_mult_sampling
        // Multiply z[i] with epsilon (random number)
        fixed_point_multiply mult_inst (
            .A(add_result_piecewise[i]),   // Input z (square root of ad)
            .B(e[i]),                   // Random epsilon from PRNG
            .C(mult_result_sampling[i])    // Hasil perkalian
        );
        assign epsilon[(i+1)*BITSIZE-1:i*BITSIZE] = e[i];    
    end
endgenerate

// Penjumlahan dengan ac
generate
    for (i = 0; i < M_output; i = i + 1) begin : gen_add_sampling
        fixed_point_add A1 (
            .A(mult_result_sampling[i]),       // Hasil perkalian akar ad * epsilon
            .B(ac[(i+1)*BITSIZE-1:i*BITSIZE]), // Input ac
            .C(add_result_sampling[i])        // Hasil penjumlahan
        );
        assign a[(i+1)*BITSIZE-1:i*BITSIZE] = add_result_sampling[i];
    end
endgenerate

endmodule
