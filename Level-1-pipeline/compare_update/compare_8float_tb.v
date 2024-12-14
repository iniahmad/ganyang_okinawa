`include "compare_8float.v"
module compare_8float_tb;

reg clk;
reg reset;

reg signed [15:0] data_in;
// Fixed-point test data
// reg signed [15:0] m1 = 16'b00000000000011100100011111110111;
// reg signed [15:0] c1 = 16'b00000000011100101110111110001111;
reg signed [15:0] m1 = 1;
reg signed [15:0] c1 = 1;

// reg signed [15:0] m2 = 16'b00000000100110011000110101111001;
// reg signed [15:0] c2 = 16'b00000010010010111100101010110101;
reg signed [15:0] m2 = 2;
reg signed [15:0] c2 = 2;

// reg signed [15:0] m3 = 16'b00000001101001111011011100100100;
// reg signed [15:0] c3 = 16'b00000100000000000000000000010101;
reg signed [15:0] m3 = 3;
reg signed [15:0] c3 = 3;

// reg signed [15:0] m4 = 16'b00000000100110011000110101010101;
// reg signed [15:0] c4 = 16'b00000101101101000011010101011011;
reg signed [15:0] m4 = 4;
reg signed [15:0] c4 = 4;

// reg signed [15:0] m5 = 16'b00000000000011100100011111101011;
// reg signed [15:0] c5 = 16'b00000111100011010001000011010100;
reg signed [15:0] m5 = 5;
reg signed [15:0] c5 = 5;

// reg signed [15:0] m6 = 16'b00000000000011100100011111101011;
// reg signed [15:0] c6 = 16'b00000111100011010001000011010100;
reg signed [15:0] m6 = 6;
reg signed [15:0] c6 = 6;

// reg signed [15:0] m7 = 16'b00000000000011100100011111101011;
// reg signed [15:0] c7 = 16'b00000111100011010001000011010100;
reg signed [15:0] m7 = 7;
reg signed [15:0] c7 = 7;

// reg signed [15:0] m8 = 16'b00000000000011100100011111101011;
// reg signed [15:0] c8 = 16'b00000111100011010001000011010100;
reg signed [15:0] m8 = 8;
reg signed [15:0] c8 = 8;

// reg signed [15:0] m9 = 16'b00000000000011100100011111101011;
// reg signed [15:0] c9 = 16'b00000111100011010001000011010100;
reg signed [15:0] m9 = 9;
reg signed [15:0] c9 = 9;


reg signed [15:0] x1 = 16'b1_0100_00000000000;
reg signed [15:0] x2 = 16'b1_0011_00000000000;
reg signed [15:0] x3 = 16'b1_0010_00000000000;
reg signed [15:0] x4 = 16'b1_0001_00000000000;
reg signed [15:0] x5 = 16'b0_0001_00000000000;
reg signed [15:0] x6 = 16'b0_0010_00000000000;
reg signed [15:0] x7 = 16'b0_0011_00000000000;
reg signed [15:0] x8 = 16'b0_0100_00000000000;

wire signed [15:0] m_out;
wire signed [15:0] c_out;

// Custom module instantiation
compare_8float custom_mux (
    .data (data_in),
    .x1   (x1),
    .x2   (x2),
    .x3   (x3),
    .x4   (x4),
    .x5   (x5),
    .x6   (x6),
    .x7   (x7),
    .x8   (x8),

    .m1   (m1),    .c1   (c1),
    .m2   (m2),    .c2   (c2),
    .m3   (m3),    .c3   (c3),
    .m4   (m4),    .c4   (c4),
    .m5   (m5),    .c5   (c5),
    .m6   (m6),    .c6   (c6),
    .m7   (m7),    .c7   (c7),
    .m8   (m8),    .c8   (c8),
    .m9   (m9),    .c9   (c9),

    .m    (m_out),
    .c    (c_out),

    .clk(clk),
    .reset(reset)
);

initial begin
    // Test case: input a signed number
    data_in = 16'b0_0100_10000000000; // harusnya region 9

    clk = 0;
    reset = 0;
    #1 reset = 1;
    #1 reset = 0;

    #1 clk = 1;
    #1 clk = 0;
    #1 clk = 1;
    #1

    $display("data_in = %b", data_in);
    $display("x1 = %b", x1);
    $display("x2 = %b", x2);
    $display("x3 = %b", x3);
    $display("x4 = %b", x4);
    
    #5;
    $display("output region = %d", c_out);
    $finish;
end

endmodule