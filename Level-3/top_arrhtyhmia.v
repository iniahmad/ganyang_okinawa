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
`include "softplus_8slice_piped_v2.v"

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
        16'b0000010000010001,
        16'b0000010111100111,
        16'b0000010010101000,
        16'b1000000100000110,
        16'b0000001000100000,
        16'b0000001101001001,
        16'b1000000101100100,
        16'b0000001001101110,
        16'b1000101011010000,
        16'b1000001101110010,
        16'b1000001110110000,
        16'b0000100010001101,
        16'b0000001010101100,
        16'b0000010110010011,
        16'b0001000101001000,
        16'b0000001101001101,
        16'b0000001000101110,
        16'b1000110000000000,
        16'b1000001000010000,
        16'b0000001101011000,
        16'b1001001111110110,
        16'b1000100110000011,
        16'b1000010010001011,
        16'b0001001011011111,
        16'b0000001000101101,
        16'b0000010011110011,
        16'b0001000011010011,
        16'b0000001110011101,
        16'b0000010000110110,
        16'b1000101001101111,
        16'b1000001011010011,
        16'b1000001000111100,
        16'b1000101101100011,
        16'b1000000000011111,
        16'b1000000111110101,
        16'b0000010100101110,
        16'b1000000000100001,
        16'b0000011101110011,
        16'b0000110100010100,
        16'b1000001000011001,
        16'b0000000100000011,
        16'b1000011011110111,
        16'b1000001101110111,
        16'b1000001010101111,
        16'b1001001010101011,
        16'b0001001010111010,
        16'b1000001010000110,
        16'b1000000100011110,
        16'b0000001011111110,
        16'b0000011001110000,
        16'b0001010101100000,
        16'b1001000001101011,
        16'b0000001110011100,
        16'b1000000110011100,
        16'b0000000101100000,
        16'b0000010110101001,
        16'b1000100000101101,
        16'b0000101000110010,
        16'b0000000110111111,
        16'b0000010100111010
        };
        b_enc_1 = {
        16'b0000001111101011,
        16'b0000010110111011,
        16'b1000010111111101,
        16'b1000001100001000,
        16'b0000000110100100,
        16'b1000000000111110
        };


           w_enc_2_mean = {
            16'b0000011110111111,
            16'b0000001100011010,
            16'b1001000011001011,
            16'b1000101000000101,
            16'b0000011010000001,
            16'b1000110010101100
            };
            b_enc_2_mean = {
            16'b0000001000011110
            };
            w_enc_2_var = {
            16'b1001001001011000,
            16'b1001101010110101,
            16'b1001000000011100,
            16'b1001101001100110,
            16'b1001001110000011,
            16'b1001001001111010
            };
            b_enc_2_var = {
            16'b1001010110101110
            };
            w_enc_3 = {
            16'b1000010110100100,
            16'b0101010011011001,
            16'b1000100111100110,
            16'b1000100110011101,
            16'b1000100011001110,
            16'b0101101010001000
            };
            b_enc_3 = {
            16'b0000000010100000,
            16'b0000001110101100,
            16'b1000000001110110,
            16'b1000001000010001,
            16'b0000001101011000,
            16'b0000010011111101
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
            softplus_8slice_piped_v2 softplus_enc_3 (
                .clk(clk),
                .reset(reset),
                .data_in(enc_3_out[BITSIZE*i +: BITSIZE]),
                .data_out(softplus_enc_3_out[BITSIZE*i +: BITSIZE])
            );
        end
    endgenerate

    // enc_4
    

endmodule