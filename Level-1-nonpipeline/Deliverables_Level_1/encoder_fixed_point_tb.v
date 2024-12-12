`include "encoder_fixed_point.v"

`timescale 1ns / 1ps

module encoder_fixed_point_tb;
    // Parameters
    parameter N_input = 9;
    parameter M_output = 4;
    parameter BITSIZE = 32; // 1-bit sign, 4-bit exponent, 27-bit mantissa

    // Testbench signals
    reg signed [N_input * BITSIZE - 1:0] x;          // Input data
    reg signed [N_input * M_output * BITSIZE - 1:0] w; // Weights
    reg signed [M_output * BITSIZE - 1:0] b;         // Bias
    wire signed [M_output * BITSIZE - 1:0] out;      // Output data

    // Instantiate the DUT
    encoder_fixed_point #(
        .N_input(N_input),
        .M_output(M_output),
        .BITSIZE(BITSIZE)
    ) dut (
        .x(x),
        .w(w),
        .b(b),
        .out(out)
    );

    initial begin
        // $dumpfile("encoder_fixed_point_tb.vcd");
        // $dumpvars(0, encoder_fixed_point_tb);
        // Initialize inputs
        x = {9{32'b0_0001_100000000000000000000000000}}; // Set all x inputs to 1.0
        w = {36{32'b0_0001_000000000000000000000000000}}; // Set all weights to 1.0
        b = {4{32'b0_0001_000000000000000000000000000}}; // Set all biases to 1.0

        // Wait for a short period to allow calculations to propagate
        #100;
        // Wait for simulation
        #100;

        $stop;
        end

        integer i;
        initial begin
            for (i = 0; i < M_output; i = i + 1) begin
                #1;
                $display("Output[%0d] in Hex: %h, in Binary: %b", i, out[(i+1)*BITSIZE-1 -: BITSIZE], out[(i+1)*BITSIZE-1 -: BITSIZE]);
            end

        
        // End simulation
        $finish;

    end
endmodule
