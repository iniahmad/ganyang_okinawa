// `include "fixed_point_add.v"
// `include "fixed_point_multiply.v"
// `include "compare_8float.v"

module softplus_8slice_piped_v2
#(parameter BITSIZE = 20)
(
    input clk,
    input reset,
    input wire  [BITSIZE-1:0] data_in,
    output wire [BITSIZE-1:0] data_out
);

    reg [BITSIZE-1:0] m1 = 20'b00000000000010011110;
    reg [BITSIZE-1:0] m2 = 20'b00000000011000100010;
    reg [BITSIZE-1:0] m3 = 20'b00000001001101011100;
    reg [BITSIZE-1:0] m4 = 20'b00000010011110010110;
    reg [BITSIZE-1:0] m5 = 20'b00000011111111110111;
    reg [BITSIZE-1:0] m6 = 20'b00000101100001011001;
    reg [BITSIZE-1:0] m7 = 20'b00000110110010100100;
    reg [BITSIZE-1:0] m8 = 20'b00000111100111100000;
    reg [BITSIZE-1:0] m9 = 20'b00000111111101100001;

    reg [BITSIZE-1:0] c1 = 20'b00000000010100000000;
    reg [BITSIZE-1:0] c2 = 20'b00000001101001110101;
    reg [BITSIZE-1:0] c3 = 20'b00000011100010011010;
    reg [BITSIZE-1:0] c4 = 20'b00000101000110001100;
    reg [BITSIZE-1:0] c5 = 20'b00000101101100110011;
    reg [BITSIZE-1:0] c6 = 20'b00000101000110011001;
    reg [BITSIZE-1:0] c7 = 20'b00000011100010011111;
    reg [BITSIZE-1:0] c8 = 20'b00000001101001100111;
    reg [BITSIZE-1:0] c9 = 20'b00000000010100000000;

    reg [BITSIZE-1:0] x1 = 20'b10011111000111110000; // x1 = -3.8901380866523922
    reg [BITSIZE-1:0] x2 = 20'b10010010001110111101; // x2 = -2.2792356709441695
    reg [BITSIZE-1:0] x3 = 20'b10001001110111100001; // x3 = -1.2334573977617584
    reg [BITSIZE-1:0] x4 = 20'b10000011001010101010; // x4 = -0.3958179538276145
    reg [BITSIZE-1:0] x5 = 20'b00000011001001100011; // x5 = 0.39366939152731323
    reg [BITSIZE-1:0] x6 = 20'b00001001110110001001; // x6 = 1.2307598720011694
    reg [BITSIZE-1:0] x7 = 20'b00010010010001000011; // x7 = 2.2833208227773083
    reg [BITSIZE-1:0] x8 = 20'b00011111000111011111; // x8 = 3.8896355758815835

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