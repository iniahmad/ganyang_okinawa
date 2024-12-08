`timescale 1ns / 1ps

module top_vae #(
    parameter N_input_enc = 9,    // Input size of encoder
    parameter M_output_enc = 4,  // Output size of encoder
    parameter N_input_dec = 2,   // Input size of decoder (latent space)
    parameter M_output_dec = 9,  // Output size of decoder
    parameter BITSIZE = 32       // Fixed Point 32-bit
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
            32'b1_00000_00000001101100001000100110,
            32'b0_00000_00000001010101001100100110,
            32'b1_00000_00000001110010101100000010,
            32'b0_00000_00000001010001111010111000,
            32'b1_00000_00000010010000001011011110,
            32'b0_00000_00000001011111000001101111,
            32'b0_00000_11101100001111001001111011,
            32'b0_00000_01001111000000000110100011,
            32'b0_00000_10000010001001101000000010,
            32'b1_00001_11110101110011111010101011,
            32'b0_00000_10001110011100000011101011,
            32'b1_00001_11100111010100100101010001,
            32'b1_00001_00011100001101100001000100,
            32'b1_00000_10010110101000010110000111,
            32'b1_00000_11110010100101011110100111,
            32'b1_00010_10010101100110110011110100,
            32'b1_00000_11001100001000100110100000,
            32'b1_00010_01111011000101011011010101,
            32'b1_00000_00000000000110100011011011,
            32'b1_00000_00000001101000110110111000,
            32'b0_00000_00000000011101011111011011,
            32'b1_00000_00000001011011110000000001,
            32'b0_00000_00000010111010110001110001,
            32'b1_00000_00000001111100100001001011,
            32'b1_00000_01100101000001001000000101,
            32'b0_00010_10011000010100011110101110,
            32'b0_00000_11010011100000011101011111,
            32'b1_00010_00000110101101010000101100,
            32'b1_00000_00110000110110000100010011,
            32'b1_00001_00101111011101100101111111,
            32'b1_00001_00100001010001111010111000,
            32'b1_00000_00011111011000101011011010,
            32'b1_00000_11111000000111010111110110,
            32'b1_00011_01011100001010001111010111,
            32'b1_00000_00111110001010000010010000,
            32'b1_00001_10001111110100100001111111
        };

        // Encoder biases
        b_enc = {
            32'b1_00001_01010101111010011110000110,
            32'b1_00011_10110101100110110011110100,
            32'b1_00001_10101101100111101000001111,
            32'b1_00100_10000101111100000110111101
        };

        // Decoder weights
        w_dec = {
            32'b0_00101_11001101101110001011101011,
            32'b1_00000_00110000011111001000010010,
            32'b0_00010_00000001100101100101001010,
            32'b0_01011_10011111101100010101101101,
            32'b0_00101_11101111110100100001111111,
            32'b1_00000_01000011010001101101110001,
            32'b0_00010_01111111000101000001001000,
            32'b0_01011_10010001100111001110000001,
            32'b1_00000_00001110011111010101011001,
            32'b1_01011_11000111000100001100101100,
            32'b0_00010_10010010001110100010100111,
            32'b0_01011_10010110101011100111110101,
            32'b0_00101_11000111101011100001010001,
            32'b1_00000_01000001011000011110010011,
            32'b0_00010_00010100111000111011110011,
            32'b0_01011_10011110100100001111111110,
            32'b0_00101_11001000101001110001110111,
            32'b1_00000_00111110100100001111111110
        };

        // Decoder biases
        b_dec = {
            32'b0_01000_10010101010110011011001111,
            32'b1_00000_10101111110001010000010010,
            32'b0_01000_10001010100110010011000010,
            32'b1_00000_11000101101111000000000110,
            32'b0_00000_01010101111010011110000110,
            32'b1_00000_11001010110000001000001100,
            32'b0_01000_10010011010011010110101000,
            32'b1_00000_10110011011001111010000011,
            32'b0_01000_10010011011101001011110001
        };
    end
    
    // Internal wires for interconnecting modules
    wire signed [M_output_enc*BITSIZE-1:0] encoder_out;      // Encoder output
    wire signed [BITSIZE-1:0] softplus_out_2, softplus_out_4; // Softplus outputs
    wire signed [M_output_enc*BITSIZE-1:0] softplus_out_combined; // Flattened output to sampling
    wire signed [N_input_dec*BITSIZE-1:0] z;                 // Latent space (sampling output)
    wire signed [M_output_dec*BITSIZE-1:0] decoder_out;      // Decoder output
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

    // Flatten softplus outputs with other encoder outputs
    assign softplus_out_combined = {
        encoder_out[1*BITSIZE-1:0],         // Pass unchanged [1*BITSIZE-1:0]
        softplus_out_2,                     // Softplus output for [2*BITSIZE-1:1*BITSIZE-1]
        encoder_out[3*BITSIZE-1:2*BITSIZE], // Pass unchanged [3*BITSIZE-1:2*BITSIZE]
        softplus_out_4                      // Softplus output for [4*BITSIZE-1:3*BITSIZE-1]
    };

    // Instantiate sampling
    sampling #(
        .N_input(M_output_enc),
        .M_output(N_input_dec),
        .BITSIZE(BITSIZE)
    ) sampling_inst (
        .ac(softplus_out_combined),
        .ad(softplus_out_combined), // Assuming variance is also processed similarly
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

