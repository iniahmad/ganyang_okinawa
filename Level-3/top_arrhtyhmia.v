`timescale 1ns/1ps
// Basic needs
`include "fixed_point_add.v"
`include "fixed_point_multiply.v"
`include "compare_8float_v2.v"

// Big layer
`include "enc_1.v"
`include "enc_2.v"
// lambda layer
`include "lambda_layer.v"
`include "delay3cc.v"
`include "squareroot.v"
`include "PRNG.v"
// Lanjut big layer
`include "enc_3.v"
`include "enc_4.v"

// enc
`include "enc_control.v"

// Activation function
`include "sigmoid8_piped.v"
`include "softplus_8slice_piped.v"

module top_arrhythmia #(parameter BITSIZE = 16) (
    input wire  clk,
    input wire  reset,
    input wire  [BITSIZE*10-1:0]   x,  // Input vector (10 elements)    
    output wire [BITSIZE*2-1:0]    y   // Output vector (2 elements)
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
        w_enc_1 = {
            16'b0000000111100111,
            16'b0000100010000110,
            16'b1000001000101101,
            16'b0000000011010110,
            16'b0000101010000010,
            16'b0000000100101111,
            16'b1000001011111110,
            16'b1000100001110011,
            16'b1000101000100001,
            16'b1000010001010011,
            16'b0000000001110111,
            16'b0000111110000111,
            16'b1000000000011001,
            16'b0000100111001000,
            16'b0000110010111101,
            16'b0000000001101001,
            16'b0000010111110001,
            16'b1001001111000111,
            16'b1000000001001101,
            16'b1000100010010100,
            16'b1000001000100001,
            16'b1000000001010010,
            16'b0000001101101100,
            16'b0000110001000011,
            16'b0000000001100101,
            16'b0000011100011100,
            16'b0000100011010101,
            16'b0000000110110110,
            16'b0000000000001110,
            16'b1001000000000010,
            16'b1000000001000110,
            16'b1000111111011100,
            16'b0000100000111011,
            16'b0000000001011011,
            16'b0000001010101111,
            16'b0000100100110010,
            16'b0000001110000100,
            16'b0001011011111101,
            16'b1001010111101000,
            16'b0000001110101011,
            16'b0000010011011001,
            16'b0000000110001111,
            16'b0000000000101010,
            16'b1000111110111111,
            16'b0000110000000011,
            16'b1000000001010101,
            16'b0000011011111010,
            16'b0000100011100111,
            16'b0000000001111000,
            16'b0001001001110011,
            16'b1000001011010110,
            16'b0000000010101100,
            16'b0000010110000100,
            16'b1000110100111011,
            16'b1000000101111101,
            16'b1000101001000100,
            16'b0000001111110111,
            16'b1000000011111110,
            16'b0000001000110010,
            16'b0000011101110010
            };

            b_enc_1 = {
            16'b0000000110010111,
            16'b1000010011100010,
            16'b1000010101101110,
            16'b0000000111110111,
            16'b0000010011111001,
            16'b1000010111010101
            };

            w_enc_2_mean = {
            16'b0000010010110101,
            16'b1000111000001001,
            16'b1000110111110100,
            16'b0000001011010100,
            16'b0000001111000100,
            16'b1000111010111100
            };
            b_enc_2_mean = {
            16'b0000010001111111
            };
            w_enc_2_var = {
            16'b1000000101011100,
            16'b1000010100000010,
            16'b1000001101011111,
            16'b1000011001011010,
            16'b1000010111001110,
            16'b0000000110111001
            };
            b_enc_2_var = {
            16'b0000000000000000
            };

            w_enc_3 = {
            16'b0100000111100001,
            16'b1000010100100110,
            16'b0100000110100110,
            16'b1000010011010011,
            16'b1000010100110101,
            16'b1000001110000110
            };
            b_enc_3 = {
            16'b0000100000100001,
            16'b0000001010101010,
            16'b0000100000001101,
            16'b0000001001011011,
            16'b0000001011010001,
            16'b0000000011111011
            };

            w_enc_4 = {
            16'b1001110011001110,
            16'b0001101100001111,
            16'b0000001011011011,
            16'b1000001111110111,
            16'b1001110110110110,
            16'b0001100000100111,
            16'b0000100000001110,
            16'b1000000000110000,
            16'b0000011101001110,
            16'b1000001000100010,
            16'b0000001000110110,
            16'b1000010000100001
            };
            b_enc_4 = {
            16'b0000000001100100,
            16'b1000000001100100
            };

    end

    // First layer
    wire [BITSIZE*6-1:0] enc_1_out;

    enc_1 #(.BITSIZE(BITSIZE)) 
    intermediate_layer(
        .clk(clk),
        .reset(reset),
        .x(x),
        .w(w_enc_1),
        .b(b_enc_1),
        .y(enc_1_out)
    );

    wire [BITSIZE*6-1:0] softplus_enc_1_out;

    genvar i;
    generate
        for (i = 0; i < 6; i = i + 1) begin : softplus_layer_enc_1
            softplus_8slice_piped softplus_enc_1 (
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
        .reset(reset),
        .x(softplus_enc_1_out),
        .w(w_enc_2_mean),
        .b(b_enc_2_mean),
        .y(enc_2_mean_out)
    );

    enc_2 #(.BITSIZE(BITSIZE)) 
    var (
        .clk(clk),
        .reset(reset),
        .x(softplus_enc_1_out),
        .w(w_enc_2_var),
        .b(b_enc_2_var),
        .y(enc_2_var_out)
    );

    // LAMBDA layer
    wire [BITSIZE*1-1:0] lambda_out;

    lambda_layer
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
        .reset(reset),
        .x(lambda_out),
        .w(w_enc_3),
        .b(b_enc_3),
        .y(enc_3_out)
    );

    wire [BITSIZE*6-1:0] softplus_enc_3_out;

    generate
        for (i = 0; i < 6; i = i + 1) begin : softplus_layer_enc_3
            softplus_8slice_piped softplus_enc_3 (
                .clk(clk),
                .reset(reset),
                .data_in(enc_3_out[BITSIZE*i +: BITSIZE]),
                .data_out(softplus_enc_3_out[BITSIZE*i +: BITSIZE])
            );
        end
    endgenerate

    // enc_4

endmodule