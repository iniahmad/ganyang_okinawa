//`include "compare_8float_v2.v"
//`include "fixed_point_multiply.v"
//`include "fixed_point_add.v"

module sigmoid8_piped 
#(
    parameter BITSIZE = 16 // Adjusting the size to the parameter
)
(
    input clk, reset,
    input wire signed [BITSIZE-1:0] data_in,  // Adjusted to BITSIZE
    output wire signed [BITSIZE-1:0] data_out  // Adjusted to BITSIZE
);

// inisiasi value langsung untuk memperkecil perhitungan m tuh dari ((y2-y1)/(x2-x1)), c tuh (y1 - m*x1)
wire [BITSIZE-1:0] m1 = 16'b0000000000000110; // m1 = 0.0016    value m1 untuk membuat garis 1
wire [BITSIZE-1:0] c1 = 16'b0000000000110100; // c2 = 0.0257    value c1 untuk membuat garis 1

wire [BITSIZE-1:0] m2 = 16'b0000000000110100; // m2 = 0.0258    value m2 untuk membuat garis 2
wire [BITSIZE-1:0] c2 = 16'b0000000100000010; // c2 = 0.1261    value c2 untuk membuat garis 2

wire [BITSIZE-1:0] m3 = 16'b0000000010011100; // m3 = 0.0765    value m3 untuk membuat garis 3
wire [BITSIZE-1:0] c3 = 16'b0000001000110011; // c3 = 0.2751    value c3 untuk membuat garis 3

wire [BITSIZE-1:0] m4 = 16'b0000000100110110; // m4 = 0.1516    value m4 untuk membuat garis 4
wire [BITSIZE-1:0] c4 = 16'b0000001101011001; // c4 = 0.4187    value c4 untuk membuat garis 4

wire [BITSIZE-1:0] m5 = 16'b0000000111010110; // m5 = 0.2295    value m5 untuk membuat garis 5
wire [BITSIZE-1:0] c5 = 16'b0000010000000000; // c5 = 0.5000    value c5 untuk membuat garis 5

wire [BITSIZE-1:0] m6 = 16'b0000000100110110; // m6 = 0.1516    value m6 untuk membuat garis 6
wire [BITSIZE-1:0] c6 = 16'b0000010010100110; // c6 = 0.5813    value c6 untuk membuat garis 6

wire [BITSIZE-1:0] m7 = 16'b0000000010011100; // m7 = 0.0765    value m7 untuk membuat garis 7
wire [BITSIZE-1:0] c7 = 16'b0000010111001100; // c7 = 0.7249    value c7 untuk membuat garis 7

wire [BITSIZE-1:0] m8 = 16'b0000000000110100; // m8 = 0.0258    value m8 untuk membuat garis 8
wire [BITSIZE-1:0] c8 = 16'b0000011011111101; // c8 = 0.8739    value c8 untuk membuat garis 8

wire [BITSIZE-1:0] m9 = 16'b0000000000000110; // m9 = 0.0016    value m9 untuk membuat garis 9
wire [BITSIZE-1:0] c9 = 16'b0000011111001011; // c9 = 0.9743    value c9 untuk membuat garis 9

// Nilai slice x yang optimal
wire [BITSIZE-1:0] x1 = 16'b1010001110001010; // x1 = -4.44276609
wire [BITSIZE-1:0] x2 = 16'b1001011101111001; // x2 = -2.93410561 
wire [BITSIZE-1:0] x3 = 16'b1000111101001101; // x3 = -1.91285689
wire [BITSIZE-1:0] x4 = 16'b1000100001011001; // x4 = -1.04369786  
wire [BITSIZE-1:0] x5 = 16'b0000100001011001; // x5 =  1.04370402  
wire [BITSIZE-1:0] x6 = 16'b0000111101001101; // x6 =  1.91289759 
wire [BITSIZE-1:0] x7 = 16'b0001011101111001; // x7 =  2.93408826  
wire [BITSIZE-1:0] x8 = 16'b0010001110001010; // x8 =  4.44283306

wire signed [BITSIZE-1:0] m_out;
wire signed [BITSIZE-1:0] c_out;

// Stage 2: Compare module
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

always @(posedge clk or posedge reset) begin
    if (reset)
        data_in_2 <= {BITSIZE{1'b0}};  // Reset to zero on reset
    else
        data_in_2 <= data_in;  // Assign data_in to data_in_2 on each clock cycle
end

// Stage 3: Multiplication
wire signed [BITSIZE-1:0] out_mul;
reg signed [BITSIZE-1:0] out_mul_reg; // Register to store the result of multiplication

fixed_point_multiply #(
    .BITSIZE(BITSIZE)  // Pass BITSIZE to the multiply module
) custom_mul (
    .A  (data_in_2), // Use the registered value from Stage 2
    .B  (m_out),     // Output from the compare module
    .C  (out_mul)    // Output from the multiplier
);

// Stage 4: Storing the result of multiplication
reg [BITSIZE-1:0] c_out2; // Register for c_out value

always @(posedge clk or posedge reset) begin
    if (reset) begin
        out_mul_reg <= {BITSIZE{1'b0}};  // Reset the register to zero
        c_out2 <= {BITSIZE{1'b0}};       // Reset c_out2 register to zero
    end else begin
        out_mul_reg <= out_mul;  // Store out_mul value into out_mul_reg
        c_out2 <= c_out;
    end
end

// Stage 5: Addition
fixed_point_add #(
    .BITSIZE(BITSIZE)  // Pass BITSIZE to the add module
) custom_add (
    .A (out_mul_reg),   // Use out_mul_reg for the addition input
    .B (c_out2),        // Use c_out2 for the second input
    .C (data_out)       // Output of the addition
);


endmodule
