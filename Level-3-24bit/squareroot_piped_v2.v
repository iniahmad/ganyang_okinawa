// `include "fixed_point_multiply.v" // Modul custom multiplier
// `include "fixed_point_add.v"      // Modul custom adder 
// `include "compare_8float_v2.v"       // Modul compare untuk piecewise

module squareroot_piped_v2 #(
    parameter BITSIZE = 20       // Fixed Point 20-bit
)(
    input wire clk,                              // Clock input
    input wire reset,                              // Reset input
    input wire [BITSIZE-1:0] data_in,            // Input data
    output wire [BITSIZE-1:0] data_out           // Output data
);

// UNTUK PIECEWISE SQUARE ROOT
// inisiasi value langsung untuk memperkecil perhitungan m tuh dari ((y2-y1)/(x2-x1)), c tuh (y1 - m*x1)
wire [BITSIZE-1:0] m1 = 24'b000000011011101110011111; // m1 = 3.465816303979238
wire [BITSIZE-1:0] c1 = 24'b000000000000000000000000; // c1 = 0.0

wire [BITSIZE-1:0] m2 = 24'b000000001001101111111000; // m2 = 1.2185340908581663
wire [BITSIZE-1:0] c2 = 24'b000000000001011111110010; // c2 = 0.18708825902267867

wire [BITSIZE-1:0] m3 = 24'b000000000101111110101011; // m3 = 0.7474170248570834
wire [BITSIZE-1:0] c3 = 24'b000000000010100100000101; // c3 = 0.3204888080093203

wire [BITSIZE-1:0] m4 = 24'b000000000100001100010101; // m4 = 0.5240865269463421
wire [BITSIZE-1:0] c4 = 24'b000000000011101110010101; // c4 = 0.4655058417154543

wire [BITSIZE-1:0] m5 = 24'b000000000011001100001011; // m5 = 0.39878119011982677
wire [BITSIZE-1:0] c5 = 24'b000000000100111100010010; // c5 = 0.6177507810402665

wire [BITSIZE-1:0] m6 = 24'b000000000010100010010010; // m6 = 0.3169824679029359
wire [BITSIZE-1:0] c6 = 24'b000000000110001111000000; // c6 = 0.7793095362913977

wire [BITSIZE-1:0] m7 = 24'b000000000010000100100011; // m7 = 0.2589108690795313
wire [BITSIZE-1:0] c7 = 24'b000000000111101001111111; // c7 = 0.9570266703372873

wire [BITSIZE-1:0] m8 = 24'b000000000001101111110001; // m8 = 0.21830936672516196
wire [BITSIZE-1:0] c8 = 24'b000000001001000110110011; // c8 = 1.1382959056453372

wire [BITSIZE-1:0] m9 = 24'b000000000001100000101011; // m9 = 0.18881733266966005
wire [BITSIZE-1:0] c9 = 24'b000000001010100010110000; // c9 = 1.3178884633889099

wire [BITSIZE-1:0] x1 = 24'b000000000000101010100111; // x1 = 0.08325089654086953
wire [BITSIZE-1:0] x2 = 24'b000000000010010000111110; // x2 = 0.2831579635163014
wire [BITSIZE-1:0] x3 = 24'b000000000101001100011101; // x3 = 0.6493382456170096
wire [BITSIZE-1:0] x4 = 24'b000000001001101110000100; // x4 = 1.2149916610143643
wire [BITSIZE-1:0] x5 = 24'b000000001111110011001111; // x5 = 1.9750767600348946
wire [BITSIZE-1:0] x6 = 24'b000000011000011110111000; // x6 = 3.06031067934476
wire [BITSIZE-1:0] x7 = 24'b000000100011101101110111; // x7 = 4.464594283382292
wire [BITSIZE-1:0] x8 = 24'b000000110000101101110101; // x8 = 6.089527680782957

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