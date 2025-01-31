module sigmoid8_piped 
#(
    parameter BITSIZE = 24 // Adjusting the size to the parameter
)
(
    input clk, reset,
    input wire signed [BITSIZE-1:0] data_in,  
    output wire signed [BITSIZE-1:0] data_out
);

// Coefficients m and c
wire [BITSIZE-1:0] m1 = 24'b000000000000000001101000; // m1 = 0.0031741621402230497
wire [BITSIZE-1:0] c1 = 24'b000000000000001101001011; // c1 = 0.025728647252250877

wire [BITSIZE-1:0] m2 = 24'b000000000000001101001100; // m2 = 0.025762281854866415
wire [BITSIZE-1:0] c2 = 24'b000000000001000000100011; // c2 = 0.12608237948214115

wire [BITSIZE-1:0] m3 = 24'b000000000000100111001100; // m3 = 0.0765407194630673
wire [BITSIZE-1:0] c3 = 24'b000000000010001100110101; // c3 = 0.2750716779412371

wire [BITSIZE-1:0] m4 = 24'b000000000001001101101000; // m4 = 0.15161423805378726
wire [BITSIZE-1:0] c4 = 24'b000000000011010110010111; // c4 = 0.41867657553390436

wire [BITSIZE-1:0] m5 = 24'b000000000001110101100001; // m5 = 0.22953267961679014
wire [BITSIZE-1:0] c5 = 24'b000000000011111111111111; // c5 = 0.49999988634179554

wire [BITSIZE-1:0] m6 = 24'b000000000001001101101000; // m6 = 0.1516120979016112
wire [BITSIZE-1:0] c6 = 24'b000000000100101001101000; // c6 = 0.5813259105355278

wire [BITSIZE-1:0] m7 = 24'b000000000000100111001100; // m7 = 0.07653978795258685
wire [BITSIZE-1:0] c7 = 24'b000000000101110011001010; // c7 = 0.7249315512325286

wire [BITSIZE-1:0] m8 = 24'b000000000000001101001100; // m8 = 0.025761903369186687
wire [BITSIZE-1:0] c8 = 24'b000000000110111111011100; // c8 = 0.8739183462650908

wire [BITSIZE-1:0] m9 = 24'b000000000000000001101000; // m9 = 0.003174005551133446
wire [BITSIZE-1:0] c9 = 24'b000000000111110010110100; // c9 = 0.974272605460466

wire [BITSIZE-1:0] x1 = 24'b100000100011100010101100; // x1 = -4.442766086671359
wire [BITSIZE-1:0] x2 = 24'b100000010111011110010000; // x2 = -2.934105606176305
wire [BITSIZE-1:0] x3 = 24'b100000001111010011011000; // x3 = -1.9128568939942916
wire [BITSIZE-1:0] x4 = 24'b100000001000010110010111; // x4 = -1.0436978612070313
wire [BITSIZE-1:0] x5 = 24'b000000001000010110011000; // x5 = 1.0437040176496777
wire [BITSIZE-1:0] x6 = 24'b000000001111010011011001; // x6 = 1.9128975889314177
wire [BITSIZE-1:0] x7 = 24'b000000010111011110010000; // x7 = 2.934088260172768
wire [BITSIZE-1:0] x8 = 24'b000000100011100010101110; // x8 = 4.44283306059441

wire signed [BITSIZE-1:0] m_out;
wire signed [BITSIZE-1:0] c_out;

// Stage 1: Compare module
compare_8float #(BITSIZE) custom_mux (
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
        data_in_3 <= data_in_2;  // Assign data_in_2 to data_in_3 on each clock cycle
    end
end

// Stage 2: Multiplication
wire signed [BITSIZE-1:0] out_mul;

fixed_point_multiply #(
    .BITSIZE(BITSIZE)  // Pass BITSIZE to the multiply module
) custom_mul (
    .A  (data_in_3), // Use the registered value from Stage 2
    .B  (m_out),     // Output from the compare module
    .C  (out_mul)    // Output from the multiplier
);

// Stage 4: Storing the result of multiplication
reg [BITSIZE-1:0] c_out2; // Register for c_out value
reg [BITSIZE-1:0] out_mul_reg; // Register for multiplication result

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
