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

module top_arrhythmia #(parameter BITSIZE = 24) (
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
        
         w_enc_1 = {
24'b000000000101100111111001,
24'b000000001011100110110110,
24'b000000000111110000010011,
24'b000000000100000110111111,
24'b000000000001100000101101,
24'b000000000100001010011011,
24'b100000000010010110011100,
24'b100000000001010111101100,
24'b100000000000000101101000,
24'b100000000001100101000010,
24'b000000000000001101111000,
24'b100000000000100010011100,
24'b000000001000100110110001,
24'b000000001000010001100000,
24'b000000000011111100111111,
24'b000000000010111111011000,
24'b100000000010100100000111,
24'b000000000001100100011010,
24'b100000001001100010000101,
24'b000000000110000010100101,
24'b100000010001100011110001,
24'b000000000000001111111100,
24'b000000010010110101001000,
24'b000000000001100001111100,
24'b000000001101010000110001,
24'b100000000000010000000010,
24'b000000001100111000011100,
24'b100000000001001100000011,
24'b100000010001000111100111,
24'b100000000001011110111101,
24'b100000010011000111001000,
24'b000000000000000110010001,
24'b000000000011010111111001,
24'b100000000010011000111001,
24'b000000001000110001100101,
24'b100000000010000011000001,
24'b000000011001110110101010,
24'b000000000011010011001010,
24'b100000000111011101111011,
24'b000000000010100010010011,
24'b100000001011001011100001,
24'b000000000000001110101101,
24'b100000001101101101101001,
24'b100000000000110010101100,
24'b100000000010010101111110,
24'b000000000000010100101111,
24'b000000001001110010101010,
24'b100000000001011000000001,
24'b000000000011110111000001,
24'b100000000001000000100111,
24'b000000001111111010011100,
24'b100000000001101000011101,
24'b100000001101001001000111,
24'b100000000001111010110010,
24'b100000000101111000110110,
24'b000000000100010011001001,
24'b100000001001111101101000,
24'b000000000000010100011100,
24'b000000001100010101100000,
24'b000000000001101010100000
};
b_enc_1 = {
24'b100000000100101101101101,
24'b000000000101011000100100,
24'b100000000101110101100011,
24'b000000000100111100111001,
24'b100000000011101110011100,
24'b000000000000101101101000
};
w_enc_2_mean = {
24'b000000001101111001100100,
24'b100000000101010010000001,
24'b000000001011111111001010,
24'b100000000011100111000100,
24'b000000010010110101001110,
24'b100000000111011001010101
};
b_enc_2_mean = {
24'b100000000011000110111111
};
w_enc_2_var = {
24'b100000010110101110111011,
24'b100000011000010100100010,
24'b100000001111111101110101,
24'b100000100001000111100010,
24'b100000010010101110110001,
24'b100000010010011011011000
};
b_enc_2_var = {
24'b100000010111010010110011
};
w_enc_3 = {
24'b000000001001000100010001,
24'b000000001010000001100100,
24'b100000000000010001011110,
24'b100001000010110010010111,
24'b100001100101011100011100,
24'b000000001000000001001111
};
b_enc_3 = {
24'b000000000010000000010000,
24'b000000000010001100101000,
24'b100000001001000010111110,
24'b100000000000111001101111,
24'b000000000110001110101000,
24'b000000000000110010011110
};
w_enc_4 = {
24'b000000000101001101110100,
24'b100000000110101011010010,
24'b000000000011111110000100,
24'b100000000011111110110110,
24'b000000000010011111101100,
24'b000000000100101010100101,
24'b100000001000010101111011,
24'b000000000101101011101011,
24'b100000011001000111111000,
24'b000000011000110011111011,
24'b000000000000000101101101,
24'b100000000111111011110101
};
b_enc_4 = {
24'b100000000000110101100001,
24'b000000000000110101100001
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
//        .reset(reset),
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
    
    reg [BITSIZE*6-1:0] softplus_enc_1_out_reg;
    
    always @(posedge clk or posedge reset) begin
     if (reset) begin
         softplus_enc_1_out_reg <= {BITSIZE*6{1'b0}};  // Reset the register to zero
     end else begin
         softplus_enc_1_out_reg <= softplus_enc_1_out;  // Reset the register to zero
     end
    end

    // enc_2 before lambda
    wire [BITSIZE*1-1:0] enc_2_mean_out;
    wire [BITSIZE*1-1:0] enc_2_var_out;

    enc_2 #(.BITSIZE(BITSIZE)) 
    mean (
        .clk(clk),
        .reset(enc2_start),
        .x(softplus_enc_1_out_reg),
        .w(w_enc_2_mean),
        .b(b_enc_2_mean),
        .y(enc_2_mean_out)
    );

    enc_2 #(.BITSIZE(BITSIZE)) 
    var (
        .clk(clk),
        .reset(enc2_start),
        .x(softplus_enc_1_out_reg),
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
    
    reg [BITSIZE*6-1:0] softplus_enc_3_out_reg;
    
    always @(posedge clk or posedge reset) begin
     if (reset) begin
         softplus_enc_3_out_reg <= {BITSIZE*6{1'b0}};  // Reset the register to zero
     end else begin
         softplus_enc_3_out_reg <= softplus_enc_3_out;  // Reset the register to zero
     end
    end

    // enc_4
    wire [BITSIZE*2-1:0] enc_4_out;

    enc_4 #(.BITSIZE(BITSIZE))
    classifier_output (
        .clk(clk),
        .reset(enc4_start),
        .x(softplus_enc_3_out_reg),
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