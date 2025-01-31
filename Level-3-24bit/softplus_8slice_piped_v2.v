// `include "fixed_point_add.v"
// `include "fixed_point_multiply.v"
// `include "compare_8float.v"

module softplus_8slice_piped_v2
#(parameter BITSIZE = 24)
(
    input clk,
    input reset,
    input wire  [BITSIZE-1:0] data_in,
    output wire [BITSIZE-1:0] data_out
);

    reg [BITSIZE-1:0] m1 = 24'b000000000000000010011110; // m1 = 0.004842248557421633
reg [BITSIZE-1:0] c1 = 24'b000000000000010100000000; // c1 = 0.039073394832268724

reg [BITSIZE-1:0] m2 = 24'b000000000000011000100010; // m2 = 0.04793533562853845
reg [BITSIZE-1:0] c2 = 24'b000000000001101001110101; // c2 = 0.20671145411904807

reg [BITSIZE-1:0] m3 = 24'b000000000001001101011100; // m3 = 0.15125706481194004
reg [BITSIZE-1:0] c3 = 24'b000000000011100010011010; // c3 = 0.4422060248574901

reg [BITSIZE-1:0] m4 = 24'b000000000010011110010110; // m4 = 0.3092724242005919
reg [BITSIZE-1:0] c4 = 24'b000000000101000110001100; // c4 = 0.6371112388554057

reg [BITSIZE-1:0] m5 = 24'b000000000011111111110111; // m5 = 0.49973486368094405
reg [BITSIZE-1:0] c5 = 24'b000000000101101100110011; // c5 = 0.7124996919315345

reg [BITSIZE-1:0] m6 = 24'b000000000101100001011001; // m6 = 0.6902191441234874
reg [BITSIZE-1:0] c6 = 24'b000000000101000110011001; // c6 = 0.6375118611542004

reg [BITSIZE-1:0] m7 = 24'b000000000110110010100100; // m7 = 0.8487791881378295
reg [BITSIZE-1:0] c7 = 24'b000000000011100010011111; // c7 = 0.4423625216786089

reg [BITSIZE-1:0] m8 = 24'b000000000111100111100000; // m8 = 0.9521697448164382
reg [BITSIZE-1:0] c8 = 24'b000000000001101001100111; // c8 = 0.20628871073580424

reg [BITSIZE-1:0] m9 = 24'b000000000111111101100001; // m9 = 0.9951558937011522
reg [BITSIZE-1:0] c9 = 24'b000000000000010100000000; // c9 = 0.03908825676367833

reg [BITSIZE-1:0] x1 = 24'b100000011111000111110000; // x1 = -3.8901380866523922
reg [BITSIZE-1:0] x2 = 24'b100000010010001110111101; // x2 = -2.2792356709441695
reg [BITSIZE-1:0] x3 = 24'b100000001001110111100001; // x3 = -1.2334573977617584
reg [BITSIZE-1:0] x4 = 24'b100000000011001010101010; // x4 = -0.3958179538276145
reg [BITSIZE-1:0] x5 = 24'b000000000011001001100011; // x5 = 0.39366939152731323
reg [BITSIZE-1:0] x6 = 24'b000000001001110110001001; // x6 = 1.2307598720011694
reg [BITSIZE-1:0] x7 = 24'b000000010010010001000011; // x7 = 2.2833208227773083
reg [BITSIZE-1:0] x8 = 24'b000000011111000111011111; // x8 = 3.8896355758815835

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