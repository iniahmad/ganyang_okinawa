`include "compare_4float.v"
`include "fixed_point_multiply.v"


module sigmoid_4slice (
    input wire  [31:0] data_in,
    output wire [31:0] data_out
);


// inisiasi value langsung untuk memperkecil perhitungan m tuh dari ((y2-y1)/(x2-x1)), c tuh (y1 - m*x1)
wire m1 [31:0]; // value m1 untuk membuat garis 1
wire c1 [31:0]; // value c1 untuk membuat garis 1

wire m2 [31:0]; // value m1 untuk membuat garis 1
wire c2 [31:0]; // value c1 untuk membuat garis 1

wire m3 [31:0]; // value m1 untuk membuat garis 1
wire c3 [31:0]; // value c1 untuk membuat garis 1

wire m4 [31:0]; // value m1 untuk membuat garis 1
wire c4 [31:0]; // value c1 untuk membuat garis 1

wire m5 [31:0]; // value m1 untuk membuat garis 1
wire c5 [31:0]; // value c1 untuk membuat garis 1

wire x1 [31:0];
wire x2 [31:0];
wire x3 [31:0];
wire x4 [31:0];

wire m_out [31:0];
wire c_out [31:0];

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
    .m_out (m),
    .c_out (c)
);


//implementasi y = m*x + c sebagai piece wise
// perkalian
wire [31:0] out_mul;

fixed_point_multiply custom_mul (
    .data_in  (A),
    .m_out    (B),
    .out_mul  (C)
);

// penjumlahan
assign data_out = out_mul + c_out;

endmodule