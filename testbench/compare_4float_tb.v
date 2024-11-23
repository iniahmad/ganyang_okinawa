`include "../RTL/compare_4float.v"
module compare_4float_tb;

reg signed [31:0] data_in;
// Fixed-point test data
reg signed [31:0] m1 = 32'b00000000000011100100011111110111;
reg signed [31:0] c1 = 32'b00000000011100101110111110001111;

reg signed [31:0] m2 = 32'b00000000100110011000110101111001;
reg signed [31:0] c2 = 32'b00000010010010111100101010110101;

reg signed [31:0] m3 = 32'b00000001101001111011011100100100;
reg signed [31:0] c3 = 32'b00000100000000000000000000010101;

reg signed [31:0] m4 = 32'b00000000100110011000110101010101;
reg signed [31:0] c4 = 32'b00000101101101000011010101011011;

reg signed [31:0] m5 = 32'b00000000000011100100011111101011;
reg signed [31:0] c5 = 32'b00000111100011010001000011010100;

reg signed [31:0] x1 = 32'b10011011001010010110010000001010;
reg signed [31:0] x2 = 32'b10001100111010101011101010001011;
reg signed [31:0] x3 = 32'b00001100111010101011100000100100;
reg signed [31:0] x4 = 32'b00011011001010010110110100101000;

wire signed [31:0] m_out;
wire signed [31:0] c_out;

// Custom module instantiation
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

initial begin
    // Test case: input a signed number
    data_in = 32'b1_0011_000000000000000000000000000; // -3 in fixed-point
    #5;
    $display("output m = %b, c = %b", m_out, c_out);
    $finish;
end

endmodule
