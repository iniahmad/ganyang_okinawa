// `include "fixed_point_multiply.v" // Modul custom multiplier
// `include "fixed_point_add.v"      // Modul custom adder 
// `include "compare_8float_v2.v"       // Modul compare untuk piecewise

module squareroot_piped_v2 #(
    parameter BITSIZE = 16        // Fixed Point 16-bit
)(
    input wire clk,                              // Clock input
    input wire reset,                              // Reset input
    input wire [BITSIZE-1:0] data_in,            // Input data
    output wire [BITSIZE-1:0] data_out           // Output data
);

// UNTUK PIECEWISE SQUARE ROOT
// inisiasi value langsung untuk memperkecil perhitungan m tuh dari ((y2-y1)/(x2-x1)), c tuh (y1 - m*x1)
wire [BITSIZE-1:0] m1 = 16'b0101001110001101; // m1 = 10.4443   value m1 untuk membuat garis 1
wire [BITSIZE-1:0] c1 = 16'b0000000000000000; // c1 = 0.00000   value c1 untuk membuat garis 1

wire [BITSIZE-1:0] m2 = 16'b0001001111100011; // m2 = 2.4860    value m2 untuk membuat garis 2
wire [BITSIZE-1:0] c2 = 16'b0000000010010101; // c2 = 0.0730    value c2 untuk membuat garis 2

wire [BITSIZE-1:0] m3 = 16'b0000100011001001; // m3 = 1.0983    value m3 untuk membuat garis 3
wire [BITSIZE-1:0] c3 = 16'b0000000110100000; // c3 = 0.2033    value c3 untuk membuat garis 3

wire [BITSIZE-1:0] m4 = 16'b0000010100110111; // m4 = 0.6523    value m4 untuk membuat garis 4
wire [BITSIZE-1:0] c4 = 16'b0000001011101101; // c4 = 0.3660    value c4 untuk membuat garis 4

wire [BITSIZE-1:0] m5 = 16'b0000001110001101; // m5 = 0.4443   value m5 untuk membuat garis 5
wire [BITSIZE-1:0] c5 = 16'b0000010001011101; // c5 = 0.5456    value c5 untuk membuat garis 5

wire [BITSIZE-1:0] m6 = 16'b0000001010101001; // m6 = 0.3326    value m6 untuk membuat garis 6
wire [BITSIZE-1:0] c6 = 16'b0000010111101101; // c6 = 0.7407    value c6 untuk membuat garis 6

wire [BITSIZE-1:0] m7 = 16'b0000001000011111; // m7 = 0.2654    value m7 untuk membuat garis 7
wire [BITSIZE-1:0] c7 = 16'b0000011101110011; // c7 = 0.9315    value c7 untuk membuat garis 7

wire [BITSIZE-1:0] m8 = 16'b0000000110111111; // m8 = 0.2184    value m8 untuk membuat garis 8
wire [BITSIZE-1:0] c8 = 16'b0000100100010100; // c8 = 1.1352    value c8 untuk membuat garis 8

wire [BITSIZE-1:0] m9 = 16'b0000000110000000; // m9 = 0.1878    value m9 untuk membuat garis 9
wire [BITSIZE-1:0] c9 = 16'b0000101010011011; // c9 = 1.3257    value c9 untuk membuat garis 9

// Nilai slice x yang optimal
wire [BITSIZE-1:0] x1 = 16'b0000000000010010; // x1 = 0.00916727
wire [BITSIZE-1:0] x2 = 16'b0000000011000000; // x2 = 0.09394428
wire [BITSIZE-1:0] x3 = 16'b0000001011101011; // x3 = 0.36476698
wire [BITSIZE-1:0] x4 = 16'b0000011011100111; // x4 = 0.86324246 
wire [BITSIZE-1:0] x5 = 16'b0000110111111000; // x5 = 1.74648981 
wire [BITSIZE-1:0] x6 = 16'b0001011010111001; // x6 = 2.84044815
wire [BITSIZE-1:0] x7 = 16'b0010001010110011; // x7 = 4.33743198 
wire [BITSIZE-1:0] x8 = 16'b0011000111001110; // x8 = 6.2260287

wire signed [BITSIZE-1:0] m_out;
wire signed [BITSIZE-1:0] c_out;

// Stage 1: Compare module
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
    .clk(clk),
    .reset(reset),
    .m     (m_out),
    .c     (c_out)
);

// Register to store data_in for use in the next stage
reg [BITSIZE-1:0] data_in_2;
reg [BITSIZE-1:0] data_in_3;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        data_in_2 <= {BITSIZE{1'b0}};  // Reset to zero on reset
        data_in_3 <= {BITSIZE{1'b0}};  // Reset to zero on reset
    end else begin
        data_in_2 <= data_in;  // Assign data_in to data_in_2 on each clock cycle
        data_in_3 <= data_in_2;  // Assign data_in to data_in_2 on each clock cycle
    end
end

// Stage 2: Multiplication
wire signed [BITSIZE-1:0] out_mul;
//reg signed [BITSIZE-1:0] out_mul_reg; // Register to store the result of multiplication

fixed_point_multiply #(
    .BITSIZE(BITSIZE)  // Pass BITSIZE to the multiply module
) custom_mul (
    .A  (data_in_3), // Use the registered value from Stage 2
    .B  (m_out),     // Output from the compare module
    .C  (out_mul)    // Output from the multiplier
);

 // Stage 4: Storing the result of multiplication
 reg [BITSIZE-1:0] c_out2; // Register for c_out value
 reg [BITSIZE-1:0] out_mul_reg; // Register for c_out value

 always @(posedge clk or posedge reset) begin
     if (reset) begin
         out_mul_reg <= {BITSIZE{1'b0}};  // Reset the register to zero
         c_out2 <= {BITSIZE{1'b0}};       // Reset c_out2 register to zero
     end else begin
         out_mul_reg <= out_mul;  // Store out_mul value into out_mul_reg
         c_out2 <= c_out;
     end
 end

//wire [BITSIZE-1:0] data_out_wire;
// Stage 5: Addition
fixed_point_add #(
    .BITSIZE(BITSIZE)  // Pass BITSIZE to the add module
) custom_add (
//    .A (out_mul),   // Use out_mul_reg for the addition input
    .A (out_mul_reg),   // Use out_mul_reg for the addition input
    .B (c_out2),        // Use c_out2 for the second input
//    .B (c_out),        // Use c_out2 for the second input
    .C (data_out)       // Output of the addition
);

//always @(posedge clk or posedge reset) begin
//    if (reset) begin
//        data_out <= {BITSIZE{1'b0}};  // Reset the register to zero
//    end else begin
//        data_out <= data_out_wire;  // Store out_mul value into out_mul_reg
//    end
//end

endmodule