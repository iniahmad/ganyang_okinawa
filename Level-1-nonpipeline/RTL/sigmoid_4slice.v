`include "compare_4float.v"
`include "fixed_point_multiply.v"
`include "fixed_point_add.v"


module sigmoid_4slice (
    input wire  [31:0] data_in,
    output wire [31:0] data_out
);


// inisiasi value langsung untuk memperkecil perhitungan m tuh dari ((y2-y1)/(x2-x1)), c tuh (y1 - m*x1)
reg [31:0] m1 = 32'b00000000000011100100011111110111; // value m1 untuk membuat garis 1
reg [31:0] c1 = 32'b00000000011100101110111110001111; // value c1 untuk membuat garis 1

reg [31:0] m2 = 32'b00000000100110011000110101111001; // value m1 untuk membuat garis 2
reg [31:0] c2 = 32'b00000010010010111100101010110101; // value c1 untuk membuat garis 2

reg [31:0] m3 = 32'b00000001101001111011011100100100; // value m1 untuk membuat garis 3
reg [31:0] c3 = 32'b00000100000000000000000000010101; // value c1 untuk membuat garis 3

reg [31:0] m4 = 32'b00000000100110011000110101010101; // value m1 untuk membuat garis 4
reg [31:0] c4 = 32'b00000101101101000011010101011011; // value c1 untuk membuat garis 4

reg [31:0] m5 = 32'b00000000000011100100011111101011; // value m1 untuk membuat garis 5
reg [31:0] c5 = 32'b00000111100011010001000011010100; // value c1 untuk membuat garis 5

reg [31:0] x1 = 32'b10011011001010010110010000001010;
reg [31:0] x2 = 32'b10001100111010101011101010001011;
reg [31:0] x3 = 32'b00001100111010101011100000100100;
reg [31:0] x4 = 32'b00011011001010010110110100101000;

wire [31:0] m_out;
wire [31:0] c_out;

// custom mux
compare_4float custom_mux (
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
    .m     (m_out),
    .c     (c_out)
);


//implementasi y = m*x + c sebagai piece wise
// perkalian
wire [31:0] out_mul;

fixed_point_multiply custom_mul (
    .A (data_in),
    .B (m_out),
    .C (out_mul)
);

//penjumlahan
fixed_point_add custom_add (
    .A (out_mul),
    .B (c_out),
    .C (data_out)
);

endmodule