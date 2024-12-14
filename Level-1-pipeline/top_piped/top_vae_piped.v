`include "sampling.v"
`include "encoder_fixed_point.v"
`include "decoder_fixed_point.v"

`include "sigmoid8.v"
`include "softplus_8slice.v"

`include "fixed_point_multiply.v" // Modul custom multiplier
`include "fixed_point_add.v"      // Modul custom adder 
`include "compare_8float.v"       // Modul compare untuk piecewise
`include "PRNG.v"                 // Modul random generator

module top_vae_piped #(
    parameter N_input_enc = 9,       // Input size of encoder
    parameter M_output_enc = 4,      // Output size of encoder
    parameter N_input_sampling = 2,  // Input sampling dari output enc dibagi 2
    parameter M_output_sampling = 2, // besar input output sama
    parameter N_input_dec = 2,       // Input size of decoder (latent space)
    parameter M_output_dec = 9,      // Output size of decoder
    parameter BITSIZE = 16           // Fixed Point 32-bit
)(
    input wire clk, rst,
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
            16'b1_0000_00000000110,
            16'b0_0000_00000000101,
            16'b1_0000_00000000111,
            16'b0_0000_00000000101,
            16'b1_0000_00000001001,
            16'b0_0000_00000000101,
            16'b0_0000_01110110000,
            16'b0_0000_00100111100,
            16'b0_0000_01000001000,
            16'b1_0000_11111010111,
            16'b0_0000_01000111001,
            16'b1_0000_11110011101,
            16'b1_0000_10001110000,
            16'b1_0000_01001011010,
            16'b1_0000_01111001010,
            16'b1_0001_01001010110,
            16'b1_0000_01100110000,
            16'b1_0001_00111101100,
            16'b1_0000_00000000000,
            16'b1_0000_00000000110,
            16'b0_0000_00000000001,
            16'b1_0000_00000000101,
            16'b0_0000_00000001011,
            16'b1_0000_00000000111,
            16'b1_0000_00110010100,
            16'b0_0001_01001100001,
            16'b0_0000_01101001110,
            16'b1_0001_00000011010,
            16'b1_0000_00011000011,
            16'b1_0000_10010111101,
            16'b1_0000_10010000101,
            16'b1_0000_00001111101,
            16'b1_0000_01111100000,
            16'b1_0001_10101110000,
            16'b1_0000_00011111000,
            16'b1_0000_11000111111
        };

        // Encoder biases
        b_enc = {
            16'b1_0000_10101010111,
            16'b1_0001_11011010110,
            16'b1_0000_11010110110,
            16'b1_0010_01000010111
        };

        // Decoder weights
        w_dec = {
            16'b0_0010_11100110110,
            16'b1_0000_00011000001,
            16'b0_0001_00000000110,
            16'b0_0101_11001111110,
            16'b0_0010_11110111111,
            16'b1_0000_00100001101,
            16'b0_0001_00111111100,
            16'b0_0101_11001000110,
            16'b1_0000_00000111001,
            16'b1_0101_11100011100,
            16'b0_0001_01001001000,
            16'b0_0101_11001011010,
            16'b0_0010_11100011110,
            16'b1_0000_00100000101,
            16'b0_0001_00001010011,
            16'b0_0101_11001111010,
            16'b0_0010_11100100010,
            16'b1_0000_00011111010
        };

        // Decoder biases
        b_dec = {
            16'b0_0100_01001010101,
            16'b1_0000_01010111111,
            16'b0_0100_01000101010,
            16'b1_0000_01100010110,
            16'b0_0000_00101010111,
            16'b1_0000_01100101011,
            16'b0_0100_01001001101,
            16'b1_0000_01011001101,
            16'b0_0100_01001001101
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
    encoder_fixed_point_sequential #(
        .N_input(N_input_enc),
        .M_output(M_output_enc),
        .BITSIZE(BITSIZE)
    ) encoder_inst (
        .clk(clk),
        .reset(rst), 
        .x(x),
        .w(w_enc),
        .b(b_enc),
        .out(encoder_out)
    );

    // Instantiate softplus for [2*BITSIZE-1:1*BITSIZE-1] and [4*BITSIZE-1:3*BITSIZE-1]
    softplus_8slice_piped softplus_2_inst (
        .clk(clk),
        .reset(rst),
        .data_in(encoder_out[2*BITSIZE-1:1*BITSIZE]),
        .data_out(softplus_out_2)
    );

    softplus_8slice_piped softplus_4_inst (
        .clk(clk),
        .reset(rst),
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
    sampling_VAE #(
        .N_input(N_input_sampling), // *2 masing masing untuk ac dan ad
        .M_output(M_output_sampling),
        .BITSIZE(BITSIZE)
    ) sampling_inst (
        .clk(clk),
        .rst(rst),
        .ac(in_mean),
        .ad(in_var),
        .a(z),
        .epsilon() // Unused
    );

    // Instantiate decoder
    decoder_fixed_point_pipeline #(
        .N_input(N_input_dec),
        .M_output(M_output_dec),
        .BITSIZE(BITSIZE)
    ) decoder_inst (
        .clk(clk),
        .reset(rst),
        .z(z),
        .w(w_dec),
        .b(b_dec),
        .out(decoder_out)
    );

    // Instantiate sigmoid for each output of decoder
    genvar i;
    generate
        for (i = 0; i < M_output_dec; i = i + 1) begin : sigmoid_gen
            sigmoid8_piped sigmoid_inst (
                .clk(clk),
                .reset(rst),
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

