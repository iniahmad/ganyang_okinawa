`include "compare_4float.v"
`include "fixed_point_multiply.v"
`include "fixed_point_add.v"

module softplus_4_slice
(
    input wire [31:0] data_in,
    output wire [31:0] data_out
);

// inisiasi value langsung untuk memperkecil perhitungan m tuh dari ((y2-y1)/(x2-x1)), c tuh (y1 - m*x1)
reg [31:0] m1 = 32'b00000000000110100101011101101001; // value m1 untuk membuat garis 1
reg [31:0] c1 = 32'b00000000110100110110101100101001; // value c1 untuk membuat garis 1

reg [31:0] m2 = 32'b00000001010110011110000111100110; // value m1 untuk membuat garis 1
reg [31:0] c2 = 32'b00000100000111001111010100110111; // value c1 untuk membuat garis 1

reg [31:0] m3 = 32'b00000100000000000001100110101111; // value m1 untuk membuat garis 1
reg [31:0] c3 = 32'b00000110000101101111000001010000; // value c1 untuk membuat garis 1

reg [31:0] m4 = 32'b00000110101001100001111000001001; // value m1 untuk membuat garis 1
reg [31:0] c4 = 32'b00000100000111001101010001101110; // value c1 untuk membuat garis 1

reg [31:0] m5 = 32'b00000111111001011010010101010010; // value m1 untuk membuat garis 1
reg [31:0] c5 = 32'b00000000110100111000010101000111; // value c1 untuk membuat garis 1

reg [31:0] x1 = 32'b10010101000100011001011010100010;
reg [31:0] x2 = 32'b10000101111101111110011001000010;
reg [31:0] x3 = 32'b00000101111110001011110100110100;
reg [31:0] x4 = 32'b00010101000100000101001100100010;

wire [31:0] m_out;
wire [31:0] c_out;

// custom mux
compare_4float custom_mux
(
    .data  (data_in),
    .x1    (x1),
    .x2    (x2),
    .x3    (x3),
    .x4    (x4),
    .m1    (m1),
    .m2    (m2),
    .m3    (m3),
    .m4    (m4),
    .m5    (m5),
    .c1    (c1),
    .c2    (c2),
    .c3    (c3),
    .c4    (c4),
    .c5    (c5),
    .m (m_out),
    .c (c_out)
);

//implementasi y = m*x + c sebagai piece wise

// perkalian
wire [31:0] out_mul;

fixed_point_multiply custom_mul
(
    .A  (data_in),
    .B  (m_out),
    .C  (out_mul)
);

//penjumlahan
fixed_point_add custom_add (
    .A (out_mul),
    .B (c_out),
    .C (data_out)
);

endmodule
