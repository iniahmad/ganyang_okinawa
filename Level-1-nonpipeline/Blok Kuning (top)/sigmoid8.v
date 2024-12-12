
module sigmoid8 (
    input wire signed [31:0] data_in,
    output wire signed [31:0] data_out
);


// inisiasi value langsung untuk memperkecil perhitungan m tuh dari ((y2-y1)/(x2-x1)), c tuh (y1 - m*x1)
wire [31:0] m1 = 32'b00000000000001101000000000101100; // m1 = 0.0032    value m1 untuk membuat garis 1
wire [31:0] c1 = 32'b00000000001101001011000100111000; // c2 = 0.0257    value c1 untuk membuat garis 1

wire [31:0] m2 = 32'b00000000001101001100001011011010; // m2 = 0.0258    value m2 untuk membuat garis 2
wire [31:0] c2 = 32'b00000001000000100011011101111010; // c2 = 0.1261    value c2 untuk membuat garis 2

wire [31:0] m3 = 32'b00000000100111001100000101100001; // m3 = 0.0765    value m3 untuk membuat garis 3
wire [31:0] c3 = 32'b00000010001100110101100011000111; // c3 = 0.2751    value c3 untuk membuat garis 3

wire [31:0] m4 = 32'b00000001001101101000000110000110; // m4 = 0.1516    value m4 untuk membuat garis 4
wire [31:0] c4 = 32'b00000011010110010111001100011010; // c4 = 0.4187    value c4 untuk membuat garis 4

wire [31:0] m5 = 32'b00000001110101100001010100111010; // m5 = 0.2295    value m5 untuk membuat garis 5
wire [31:0] c5 = 32'b00000011111111111111111111110000; // c5 = 0.5000    value c5 untuk membuat garis 5

wire [31:0] m6 = 32'b00000001001101101000000001100111; // m6 = 0.1516    value m6 untuk membuat garis 6
wire [31:0] c6 = 32'b00000100101001101000111000110010; // c6 = 0.5813    value c6 untuk membuat garis 6

wire [31:0] m7 = 32'b00000000100111001100000011100100; // m7 = 0.0765    value m7 untuk membuat garis 7
wire [31:0] c7 = 32'b00000101110011001010100011101001; // c7 = 0.7249    value c7 untuk membuat garis 7

wire [31:0] m8 = 32'b00000000001101001100001010101000; // m8 = 0.0258    value m8 untuk membuat garis 8
wire [31:0] c8 = 32'b00000110111111011100100011100110; // c8 = 0.8739    value c8 untuk membuat garis 8

wire [31:0] m9 = 32'b00000000000001101000000000010111; // m9 = 0.0032    value m9 untuk membuat garis 9
wire [31:0] c9 = 32'b00000111110010110100111101101111; // c9 = 0.9743    value c9 untuk membuat garis 9

// Nilai slice x yang optimal
wire [31:0] x1 = 32'b10100011100010101100100011110010; // x1 = -4.44276609
wire [31:0] x2 = 32'b10010111011110010000110001011100; // x2 = -2.93410561 
wire [31:0] x3 = 32'b10001111010011011000011111101010; // x3 = -1.91285689
wire [31:0] x4 = 32'b10001000010110010111111001000011; // x4 = -1.04369786  
wire [31:0] x5 = 32'b00001000010110011000000101111101; // x5 =  1.04370402  
wire [31:0] x6 = 32'b00001111010011011001110101000000; // x6 =  1.91289759 
wire [31:0] x7 = 32'b00010111011110010000001101000100; // x7 =  2.93408826  
wire [31:0] x8 = 32'b00100011100010101110110000001111; // x8 =  4.44283306

wire [31:0] m_out;
wire [31:0] c_out;

// custom mux
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


//implementasi y = m*x + c sebagai piece wise
// perkalian
wire [31:0] out_mul;

fixed_point_multiply custom_mul (
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