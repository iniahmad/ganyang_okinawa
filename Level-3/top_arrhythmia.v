`timescale 1ns/1ps
// Basic needs
`include "fixed_point_add.v"
`include "fixed_point_multiply.v"
`include "compare_8float_v2.v"

// Big layer
`include "enc_1.v"
`include "enc_2.v"
// lambda layer
`include "lambda_layer_v2.v"
`include "delay3cc_v2.v"
`include "squareroot_piped_v2.v"
`include "PRNG.v"
// Lanjut big layer
`include "enc_3.v"
`include "enc_4.v"

// enc
`include "enc_control.v"

// Activation function
`include "sigmoid8_piped.v"
`include "softplus_8slice_piped_v2.v"

module top_arrhythmia #(parameter BITSIZE = 16) (
    input wire  clk,
    input wire  reset,
    input wire  [BITSIZE*10-1:0]   x,  // Input vector (10 elements)    
    output wire [BITSIZE*2-1:0]    y,   // Output vector (2 elements)
    output wire done_flag_out
);
    // First Layer
    reg signed[BITSIZE*10*6-1:0] w_enc_1;
    reg signed[BITSIZE*6-1:0] b_enc_1;

    // Second Layer
    reg signed[BITSIZE*6-1:0] w_enc_2_mean;
    reg signed[BITSIZE*1-1:0] b_enc_2_mean;

    reg signed[BITSIZE*6-1:0] w_enc_2_var;
    reg signed[BITSIZE*1-1:0] b_enc_2_var;

    // Layer after lambda
    reg signed[BITSIZE*6-1:0] w_enc_3;
    reg signed[BITSIZE*6-1:0] b_enc_3;

    // Output layer
    reg signed[BITSIZE*2*6-1:0] w_enc_4;
    reg signed[BITSIZE*2-1:0] b_enc_4;

    initial begin
    //    w_enc_1 = {
    //     16'b0000010000010001,
    //     16'b0000010111100111,
    //     16'b0000010010101000,
    //     16'b1000000100000110,
    //     16'b0000001000100000,
    //     16'b0000001101001001,
    //     16'b1000000101100100,
    //     16'b0000001001101110,
    //     16'b1000101011010000,
    //     16'b1000001101110010,
    //     16'b1000001110110000,
    //     16'b0000100010001101,
    //     16'b0000001010101100,
    //     16'b0000010110010011,
    //     16'b0001000101001000,
    //     16'b0000001101001101,
    //     16'b0000001000101110,
    //     16'b1000110000000000,
    //     16'b1000001000010000,
    //     16'b0000001101011000,
    //     16'b1001001111110110,
    //     16'b1000100110000011,
    //     16'b1000010010001011,
    //     16'b0001001011011111,
    //     16'b0000001000101101,
    //     16'b0000010011110011,
    //     16'b0001000011010011,
    //     16'b0000001110011101,
    //     16'b0000010000110110,
    //     16'b1000101001101111,
    //     16'b1000001011010011,
    //     16'b1000001000111100,
    //     16'b1000101101100011,
    //     16'b1000000000011111,
    //     16'b1000000111110101,
    //     16'b0000010100101110,
    //     16'b1000000000100001,
    //     16'b0000011101110011,
    //     16'b0000110100010100,
    //     16'b1000001000011001,
    //     16'b0000000100000011,
    //     16'b1000011011110111,
    //     16'b1000001101110111,
    //     16'b1000001010101111,
    //     16'b1001001010101011,
    //     16'b0001001010111010,
    //     16'b1000001010000110,
    //     16'b1000000100011110,
    //     16'b0000001011111110,
    //     16'b0000011001110000,
    //     16'b0001010101100000,
    //     16'b1001000001101011,
    //     16'b0000001110011100,
    //     16'b1000000110011100,
    //     16'b0000000101100000,
    //     16'b0000010110101001,
    //     16'b1000100000101101,
    //     16'b0000101000110010,
    //     16'b0000000110111111,
    //     16'b0000010100111010
    //     };
    //     b_enc_1 = {
    //     16'b0000001111101011,
    //     16'b0000010110111011,
    //     16'b1000010111111101,
    //     16'b1000001100001000,
    //     16'b0000000110100100,
    //     16'b1000000000111110
    //     };
    //     w_enc_2_mean = {
    //     16'b0000011110111111,
    //     16'b0000001100011010,
    //     16'b1001000011001011,
    //     16'b1000101000000101,
    //     16'b0000011010000001,
    //     16'b1000110010101100
    //     };
    //     b_enc_2_mean = {
    //     16'b0000001000011110
    //     };
    //     w_enc_2_var = {
    //     16'b1001001001011000,
    //     16'b1001101010110101,
    //     16'b1001000000011100,
    //     16'b1001101001100110,
    //     16'b1001001110000011,
    //     16'b1001001001111010
    //     };
    //     b_enc_2_var = {
    //     16'b1001010110101110
    //     };
    //     w_enc_3 = {
    //     16'b1000010110100100,
    //     16'b0101010011011001,
    //     16'b1000100111100110,
    //     16'b1000100110011101,
    //     16'b1000100011001110,
    //     16'b0101101010001000
    //     };
    //     b_enc_3 = {
    //     16'b0000000010100000,
    //     16'b0000001110101100,
    //     16'b1000000001110110,
    //     16'b1000001000010001,
    //     16'b0000001101011000,
    //     16'b0000010011111101
    //     };
    //     w_enc_4 = {
    //     16'b0000011011100100,
    //     16'b1000001000000011,
    //     16'b1001010101110010,
    //     16'b0001001111000011,
    //     16'b0000000011001100,
    //     16'b1000001010110110,
    //     16'b1000000010110100,
    //     16'b0000001101110111,
    //     16'b0000100110010010,
    //     16'b1000100011011110,
    //     16'b1001011100010111,
    //     16'b0001010000001110
    //     };
    //     b_enc_4 = {
    //     16'b1000000000000011,
    //     16'b0000000000000011
    //     };
    w_enc_1 = {
16'b0000010110011111,
16'b0000101110011011,
16'b0000011111000001,
16'b0000010000011011,
16'b0000000110000010,
16'b0000010000101001,
16'b1000001001011001,
16'b1000000101011110,
16'b1000000000010110,
16'b1000000110010100,
16'b0000000000110111,
16'b1000000010001001,
16'b0000100010011011,
16'b0000100001000110,
16'b0000001111110011,
16'b0000001011111101,
16'b1000001010010000,
16'b0000000110010001,
16'b1000100110001000,
16'b0000011000001010,
16'b1001000110001111,
16'b0000000000111111,
16'b0001001011010100,
16'b0000000110000111,
16'b0000110101000011,
16'b1000000001000000,
16'b0000110011100001,
16'b1000000100110000,
16'b1001000100011110,
16'b1000000101111011,
16'b1001001100011100,
16'b0000000000011001,
16'b0000001101011111,
16'b1000001001100011,
16'b0000100011000110,
16'b1000001000001100,
16'b0001100111011010,
16'b0000001101001100,
16'b1000011101110111,
16'b0000001010001001,
16'b1000101100101110,
16'b0000000000111010,
16'b1000110110110110,
16'b1000000011001010,
16'b1000001001010111,
16'b0000000001010010,
16'b0000100111001010,
16'b1000000101100000,
16'b0000001111011100,
16'b1000000100000010,
16'b0000111111101001,
16'b1000000110100001,
16'b1000110100100100,
16'b1000000111101011,
16'b1000010111100011,
16'b0000010001001100,
16'b1000100111110110,
16'b0000000001010001,
16'b0000110001010110,
16'b0000000110101010
};
b_enc_1 = {
16'b1000010010110110,
16'b0000010101100010,
16'b1000010111010110,
16'b0000010011110011,
16'b1000001110111001,
16'b0000000010110110
};
w_enc_2_mean = {
16'b0000110111100110,
16'b1000010101001000,
16'b0000101111111100,
16'b1000001110011100,
16'b0001001011010100,
16'b1000011101100101
};
b_enc_2_mean = {
16'b1000001100011011
};
w_enc_2_var = {
16'b1001011010111011,
16'b1001100001010010,
16'b1000111111110111,
16'b1010000100011110,
16'b1001001010111011,
16'b1001001001101101
};
b_enc_2_var = {
16'b1001011101001011
};
w_enc_3 = {
16'b0000100100010001,
16'b0000101000000110,
16'b1000000001000101,
16'b1100001011001001,
16'b1110010101110001,
16'b0000100000000100
};
b_enc_3 = {
16'b0000001000000001,
16'b0000001000110010,
16'b1000100100001011,
16'b1000000011100110,
16'b0000011000111010,
16'b0000000011001001
};
w_enc_4 = {
16'b0000010100110111,
16'b1000011010101101,
16'b0000001111111000,
16'b1000001111111011,
16'b0000001001111110,
16'b0000010010101010,
16'b1000100001010111,
16'b0000010110101110,
16'b1001100100011111,
16'b0001100011001111,
16'b0000000000010110,
16'b1000011111101111
};
b_enc_4 = {
16'b1000000011010110,
16'b0000000011010110
};

    end

    // Controller
    wire  enc1_start;
    wire  enc2_start;
    wire  enc3_start;
    wire  enc4_start;
    wire  done_flag;
    assign done_flag_out = done_flag;

    enc_control enc_control_1(
    .clk(clk),
    .reset(reset),
    .debug_cc(),
    .enc1_start(enc1_start),
    .enc2_start(enc2_start),
    .enc3_start(enc3_start),
    .enc4_start(enc4_start),
    .done_flag(done_flag)
    );

    // First layer
    wire [BITSIZE*6-1:0] enc_1_out;

    enc_1 #(.BITSIZE(BITSIZE)) 
    intermediate_layer(
        .clk(clk),
        .reset(enc1_start),
        .x(x),
        .w(w_enc_1),
        .b(b_enc_1),
        .y(enc_1_out)
    );

    wire [BITSIZE*6-1:0] softplus_enc_1_out;

    genvar i;
    generate
        for (i = 0; i < 6; i = i + 1) begin : softplus_layer_enc_1
            softplus_8slice_piped_v2 softplus_enc_1 (
                .clk(clk),
                .reset(reset),
                .data_in(enc_1_out[BITSIZE*i +: BITSIZE]),
                .data_out(softplus_enc_1_out[BITSIZE*i +: BITSIZE])
            );
        end
    endgenerate

    // enc_2 before lambda
    wire [BITSIZE*1-1:0] enc_2_mean_out;
    wire [BITSIZE*1-1:0] enc_2_var_out;

    enc_2 #(.BITSIZE(BITSIZE)) 
    mean (
        .clk(clk),
        .reset(enc2_start),
        .x(softplus_enc_1_out),
        .w(w_enc_2_mean),
        .b(b_enc_2_mean),
        .y(enc_2_mean_out)
    );

    enc_2 #(.BITSIZE(BITSIZE)) 
    var (
        .clk(clk),
        .reset(enc2_start),
        .x(softplus_enc_1_out),
        .w(w_enc_2_var),
        .b(b_enc_2_var),
        .y(enc_2_var_out)
    );

    // LAMBDA layer
    wire [BITSIZE*1-1:0] lambda_out;

    lambda_layer_v2
    lambda (
    .clk(clk),
    .reset(reset),
    .mean(enc_2_mean_out),
    .var(enc_2_var_out),
    .lambda_out(lambda_out)
    );

    // enc_3
    wire [BITSIZE*6-1:0] enc_3_out;

    enc_3 #(.BITSIZE(BITSIZE))
    hidden_classifier(
        .clk(clk),
        .reset(enc3_start),
        .x(lambda_out),
        .w(w_enc_3),
        .b(b_enc_3),
        .y(enc_3_out)
    );

    wire [BITSIZE*6-1:0] softplus_enc_3_out;

    generate
        for (i = 0; i < 6; i = i + 1) begin : softplus_layer_enc_3
            softplus_8slice_piped_v2 softplus_enc_3 (
                .clk(clk),
                .reset(reset),
                .data_in(enc_3_out[BITSIZE*i +: BITSIZE]),
                .data_out(softplus_enc_3_out[BITSIZE*i +: BITSIZE])
            );
        end
    endgenerate

    // enc_4
    wire [BITSIZE*2-1:0] enc_4_out;

    enc_4 #(.BITSIZE(BITSIZE))
    classifier_output (
        .clk(clk),
        .reset(enc4_start),
        .x(softplus_enc_3_out),
        .w(w_enc_4),
        .b(b_enc_4),
        .y(enc_4_out)
    );

    wire [BITSIZE*2-1:0] sigmoid_enc_4_out;

    generate
        for (i = 0; i < 2; i = i + 1) begin : sigmoid_layer_enc_4
            sigmoid8_piped sigmoid_enc_4 (
                .clk(clk),
                .reset(reset),
                .data_in(enc_4_out[BITSIZE*i +: BITSIZE]),
                .data_out(sigmoid_enc_4_out[BITSIZE*i +: BITSIZE])
            );
        end
    endgenerate

    assign y = sigmoid_enc_4_out;

endmodule