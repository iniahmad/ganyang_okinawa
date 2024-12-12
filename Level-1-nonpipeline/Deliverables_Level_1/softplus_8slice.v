
module softplus_8slice (
    input wire  [31:0] data_in,
    output wire [31:0] data_out
);

    // Inisialisasi nilai m dan c untuk setiap slice
    reg [31:0] m1 = 32'b00000000000010100000100000110110; // value m1 untuk garis 1
    reg [31:0] c1 = 32'b00000000010100001111000110001001; // value c1 untuk garis 1

    reg [31:0] m2 = 32'b00000000011000110011110000111110; // value m2 untuk garis 2
    reg [31:0] c2 = 32'b00000001101010101001101110010111; // value c2 untuk garis 2

    reg [31:0] m3 = 32'b00000001001110001111111111001101; // value m3 untuk garis 3
    reg [31:0] c3 = 32'b00000011100011111101111101110000; // value c3 untuk garis 3

    reg [31:0] m4 = 32'b00000010011111100010010110011111; // value m4 untuk garis 4
    reg [31:0] c4 = 32'b00000101000111000001011011001010; // value c4 untuk garis 4

    reg [31:0] m5 = 32'b00000011111111110011000110011101; // value m5 untuk garis 5
    reg [31:0] c5 = 32'b00000101101100011001111010110010; // value c5 untuk garis 5

    reg [31:0] m6 = 32'b00000101100000011010110011001100; // value m6 untuk garis 6
    reg [31:0] c6 = 32'b00000101000111001100001110100101; // value c6 untuk garis 6

    reg [31:0] m7 = 32'b00000011100011100010001000001111; // value m7 untuk garis 7
    reg [31:0] c7 = 32'b00001010101001110110011101001110; // value c7 untuk garis 7

    reg [31:0] m8 = 32'b00000001101010011000101100001000; // value m8 untuk garis 8
    reg [31:0] c8 = 32'b00001100011110110011100010101010; // value c8 untuk garis 8

    reg [31:0] m9 = 32'b00000111111101011111000011110100; // value m9 untuk garis 9
    reg [31:0] c9 = 32'b00000000010100010010100000110111; // value c9 untuk garis 9

    // Nilai batas x
    reg [31:0] x1 = 32'b10011111000000000000100111010010;
    reg [31:0] x2 = 32'b10010010001010010010100100100010;
    reg [31:0] x3 = 32'b10001001101111111010001100110000;
    reg [31:0] x4 = 32'b10000011000110110101010001101110;
    reg [31:0] x5 = 32'b00000011000101001100110011010100;
    reg [31:0] x6 = 32'b00001001110001010001110001000111;
    reg [31:0] x7 = 32'b00010010001101011000110000111100;
    reg [31:0] x8 = 32'b00011110111110001110100110010110;

    wire [31:0] m_out;
    wire [31:0] c_out;

    // Instansiasi modul compare_8float untuk menentukan m dan c berdasarkan slice
    compare_8float custom_mux (
        .data  (data_in),
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
        .m     (m_out),
        .c     (c_out)
    );

    // Implementasi y = m*x + c sebagai piecewise linear approximation (PLA)
    // Perkalian
    wire [31:0] out_mul;
    fixed_point_multiply custom_mul (
        .A (data_in),
        .B (m_out),
        .C (out_mul)
    );

    // Penjumlahan
    fixed_point_add custom_add (
        .A (out_mul),
        .B (c_out),
        .C (data_out)
    );

endmodule
