`include "sampling.v"
`include "encoder_fixed_point.v"
`include "decoder_fixed_point.v"

`include "sigmoid8.v"
`include "softplus_8slice.v"

`include "fixed_point_multiply.v" // Modul custom multiplier
`include "fixed_point_add.v"      // Modul custom adder 
`include "compare_8float.v"       // Modul compare untuk piecewise
`include "PRNG.v"                 // Modul random generator

module top_vae #(
    parameter N_input_enc = 9,       // Input size of encoder
    parameter M_output_enc = 4,      // Output size of encoder
    parameter N_input_sampling = 2,  // Input sampling dari output enc dibagi 2
    parameter M_output_sampling = 2, // besar input output sama
    parameter N_input_dec = 2,       // Input size of decoder (latent space)
    parameter M_output_dec = 9,      // Output size of decoder
    parameter BITSIZE = 32           // Fixed Point 32-bit
)(
    input wire rst,
    input wire signed [N_input_enc*BITSIZE-1:0] x,           // Input for encoder
    output reg signed [M_output_dec*BITSIZE-1:0] sigmoid_out // Final sigmoid output
);

    // Internal constants
    reg signed [N_input_enc*M_output_enc*BITSIZE-1:0] w_enc;  // Encoder weights
    reg signed [M_output_enc*BITSIZE-1:0] b_enc;      // Encoder bias
    reg signed [N_input_dec*M_output_dec*BITSIZE-1:0] w_dec; // Decoder weights
    reg signed [M_output_dec*BITSIZE-1:0] b_dec;      // Decoder bias

    // Initialize constants
    initial begin
        // Encoder weights
        w_enc = {
            32'b1_0000_000000001101100001000100110,
            32'b0_0000_000000001010101001100100110,
            32'b1_0000_000000001110010101100000010,
            32'b0_0000_000000001010001111010111000,
            32'b1_0000_000000010010000001011011110,
            32'b0_0000_000000001011111000001101111,
            32'b0_0000_011101100001111001001111011,
            32'b0_0000_001001111000000000110100011,
            32'b0_0000_010000010001001101000000010,
            32'b1_0000_111110101110011111010101011,
            32'b0_0000_010001110011100000011101011,
            32'b1_0000_111100111010100100101010001,
            32'b1_0000_100011100001101100001000100,
            32'b1_0000_010010110101000010110000111,
            32'b1_0000_011110010100101011110100111,
            32'b1_0001_010010101100110110011110100,
            32'b1_0000_011001100001000100110100000,
            32'b1_0001_001111011000101011011010101,
            32'b1_0000_000000000000110100011011011,
            32'b1_0000_000000001101000110110111000,
            32'b0_0000_000000000011101011111011011,
            32'b1_0000_000000001011011110000000001,
            32'b0_0000_000000010111010110001110001,
            32'b1_0000_000000001111100100001001011,
            32'b1_0000_001100101000001001000000101,
            32'b0_0001_010011000010100011110101110,
            32'b0_0000_011010011100000011101011111,
            32'b1_0001_000000110101101010000101100,
            32'b1_0000_000110000110110000100010011,
            32'b1_0000_100101111011101100101111111,
            32'b1_0000_100100001010001111010111000,
            32'b1_0000_000011111011000101011011010,
            32'b1_0000_011111000000111010111110110,
            32'b1_0001_101011100001010001111010111,
            32'b1_0000_000111110001010000010010000,
            32'b1_0000_110001111110100100001111111
        };

        // Encoder biases
        b_enc = {
            32'b1_0000_101010101111010011110000110,
            32'b1_0001_110110101100110110011110100,
            32'b1_0000_110101101100111101000001111,
            32'b1_0010_010000101111100000110111101
        };

        // Decoder weights
        w_dec = {
            32'b0_0010_111001101101110001011101011,
            32'b1_0000_000110000011111001000010010,
            32'b0_0001_000000001100101100101001010,
            32'b0_0101_110011111101100010101101101,
            32'b0_0010_111101111110100100001111111,
            32'b1_0000_001000011010001101101110001,
            32'b0_0001_001111111000101000001001000,
            32'b0_0101_110010001100111001110000001,
            32'b1_0000_000001110011111010101011001,
            32'b1_0101_111000111000100001100101100,
            32'b0_0001_010010010001110100010100111,
            32'b0_0101_110010110101011100111110101,
            32'b0_0010_111000111101011100001010001,
            32'b1_0000_001000001011000011110010011,
            32'b0_0001_000010100111000111011110011,
            32'b0_0101_110011110100100001111111110,
            32'b0_0010_111001000101001110001110111,
            32'b1_0000_000111110100100001111111110
        };

        // Decoder biases
        b_dec = {
            32'b0_0100_010010101010110011011001111,
            32'b1_0000_010101111110001010000010010,
            32'b0_0100_010001010100110010011000010,
            32'b1_0000_011000101101111000000000110,
            32'b0_0000_001010101111010011110000110,
            32'b1_0000_011001010110000001000001100,
            32'b0_0100_010010011010011010110101000,
            32'b1_0000_010110011011001111010000011,
            32'b0_0100_010010011011101001011110001
        };
    end
    
    // Internal wires for interconnecting modules
    wire signed [M_output_enc*BITSIZE-1:0] encoder_out;           // Encoder output
    wire signed [BITSIZE-1:0] softplus_out_2, softplus_out_4;     // Softplus outputs
    wire signed [N_input_sampling*BITSIZE-1:0] in_mean, in_var;   // Flattened output to input sampling
    wire signed [M_output_sampling*BITSIZE-1:0] z;                // Latent space (sampling output)
    wire signed [M_output_dec*BITSIZE-1:0] decoder_out;           // Decoder output
    wire signed [BITSIZE-1:0] sigmoid_outputs [M_output_dec-1:0]; // Sigmoid intermediate outputs

    // Instantiate encoder
    encoder_fixed_point #(
        .N_input(N_input_enc),
        .M_output(M_output_enc),
        .BITSIZE(BITSIZE)
    ) encoder_inst (
        .x(x),
        .w(w_enc),
        .b(b_enc),
        .out(encoder_out)
    );

    // Instantiate softplus for [2*BITSIZE-1:1*BITSIZE-1] and [4*BITSIZE-1:3*BITSIZE-1]
    softplus_8slice softplus_2_inst (
        .data_in(encoder_out[2*BITSIZE-1:1*BITSIZE]),
        .data_out(softplus_out_2)
    );

    softplus_8slice softplus_4_inst (
        .data_in(encoder_out[4*BITSIZE-1:3*BITSIZE]),
        .data_out(softplus_out_4)
    );

    // flatten input for mean (out enc pass unchanged)
    assign in_mean = {
        encoder_out[1*BITSIZE-1:0],
        encoder_out[3*BITSIZE-1:2*BITSIZE]
    };

    // flatten input for variance (out end then softplus then flatten)
    assign in_var = {
        softplus_out_2,
        softplus_out_4
    };

    // Instantiate sampling
    sampling #(
        .N_input(N_input_sampling), // *2 masing masing untuk ac dan ad
        .M_output(M_output_sampling),
        .BITSIZE(BITSIZE)
    ) sampling_inst (
        .ac(in_mean),
        .ad(in_var),
        .a(z),
        .epsilon() // Unused
    );

    // Instantiate decoder
    decoder_fixed_point #(
        .N_input(N_input_dec),
        .M_output(M_output_dec),
        .BITSIZE(BITSIZE)
    ) decoder_inst (
        .z(z),
        .w(w_dec),
        .b(b_dec),
        .out(decoder_out)
    );

    // Instantiate sigmoid for each output of decoder
    genvar i;
    generate
        for (i = 0; i < M_output_dec; i = i + 1) begin : sigmoid_gen
            sigmoid8 sigmoid_inst (
                .data_in(decoder_out[i*BITSIZE +: BITSIZE]),
                .data_out(sigmoid_outputs[i])
            );
        end
    endgenerate

    always @(*) begin
    if (rst) begin
        sigmoid_out <= {BITSIZE*M_output_dec{1'b0}}; // Reset output to zero
    end else begin
        sigmoid_out <= {sigmoid_outputs[8], sigmoid_outputs[7], sigmoid_outputs[6],
                        sigmoid_outputs[5], sigmoid_outputs[4], sigmoid_outputs[3],
                        sigmoid_outputs[2], sigmoid_outputs[1], sigmoid_outputs[0]};
    end
    end

endmodule

