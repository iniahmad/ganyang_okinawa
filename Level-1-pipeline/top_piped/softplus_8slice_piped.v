//`include "compare_8float.v"
//`include "fixed_point_multiply.v"
//`include "fixed_point_add.v"

module softplus_8slice_piped #(
    parameter BITSIZE = 16
) (
    input wire clk, reset,
    input wire  [BITSIZE-1:0] data_in,
    output wire [BITSIZE-1:0] data_out
);

    // Inisialisasi nilai m dan c untuk setiap slice
    wire [BITSIZE-1:0] m1 = 16'b0000000000001010; // value m1 untuk garis 1
    wire [BITSIZE-1:0] c1 = 16'b0000000001010000; // value c1 untuk garis 1

    wire [BITSIZE-1:0] m2 = 16'b0000000001100011; // value m2 untuk garis 2
    wire [BITSIZE-1:0] c2 = 16'b0000000110101010; // value c2 untuk garis 2

    wire [BITSIZE-1:0] m3 = 16'b0000000100111000; // value m3 untuk garis 3
    wire [BITSIZE-1:0] c3 = 16'b0000001110001111; // value c3 untuk garis 3

    wire [BITSIZE-1:0] m4 = 16'b0000001001111110; // value m4 untuk garis 4
    wire [BITSIZE-1:0] c4 = 16'b0000010100011100; // value c4 untuk garis 4

    wire [BITSIZE-1:0] m5 = 16'b0000001111111111; // value m5 untuk garis 5
    wire [BITSIZE-1:0] c5 = 16'b0000010110110001; // value c5 untuk garis 5

    wire [BITSIZE-1:0] m6 = 16'b0000010110000001; // value m6 untuk garis 6
    wire [BITSIZE-1:0] c6 = 16'b0000010100011100; // value c6 untuk garis 6

    wire [BITSIZE-1:0] m7 = 16'b0000001110001110; // value m7 untuk garis 7
    wire [BITSIZE-1:0] c7 = 16'b0000101010100111; // value c7 untuk garis 7

    wire [BITSIZE-1:0] m8 = 16'b0000000110101001; // value m8 untuk garis 8
    wire [BITSIZE-1:0] c8 = 16'b0000110001111011; // value c8 untuk garis 8

    wire [BITSIZE-1:0] m9 = 16'b0000011111110101; // value m9 untuk garis 9
    wire [BITSIZE-1:0] c9 = 16'b0000000001010001; // value c9 untuk garis 9

    // Nilai batas x
    wire [BITSIZE-1:0] x1 = 16'b1001111100000000;
    wire [BITSIZE-1:0] x2 = 16'b1001001000101001;
    wire [BITSIZE-1:0] x3 = 16'b1000100110111111;
    wire [BITSIZE-1:0] x4 = 16'b1000001100011011;
    wire [BITSIZE-1:0] x5 = 16'b0000001100010100;
    wire [BITSIZE-1:0] x6 = 16'b0000100111000101;
    wire [BITSIZE-1:0] x7 = 16'b0001001000110101;
    wire [BITSIZE-1:0] x8 = 16'b0001111011111000;

    wire [BITSIZE-1:0] m_out;
    wire [BITSIZE-1:0] c_out;

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
        .clk (clk),
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