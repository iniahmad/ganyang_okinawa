`timescale 1ns / 1ps
`include "sigmoid8_piped.v"
`include "compare_8float_v2.v"
`include "fixed_point_multiply.v"
`include "fixed_point_add.v"

module sigmoid8_piped_tb;

    // Inputs
    reg clk;
    reg reset;
    reg signed [15:0] data_in;

    // Outputs
    wire signed [15:0] data_out;

    // Instantiate the sigmoid8 module
    sigmoid8_piped uut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 1;
        forever #5 clk = ~clk; // 10ns period clock
    end

    // Test stimulus
    initial begin
        $dumpfile("sigmoid8_piped_tb.vcd");  // Nama file output
        $dumpvars(0, sigmoid8_piped_tb);     // Simpan semua variabel dalam testbench
        // Initialize input and reset
        data_in = 16'b0;
        reset = 1;
        
        // Apply reset
        #10 reset = 0;

        // Monitor the signals
        $monitor("Time: %0t | clk: %b | reset: %b | data_in: %h | data_out: %h", $time, clk, reset, data_in, data_out);

        // Test cases
        #10 data_in = 16'b1010001110001010; // Test with value around x1
        #20 data_in = 16'b1001011101111001; // Test with value around x2
        #10 data_in = 16'b1000111101001101; // Test with value around x3
        #10 data_in = 16'b1000100001011001; // Test with value around x4
        #10 data_in = 16'b0000000000000000; // Test with zero
        #10 data_in = 16'b0000100001011001; // Test with value around x5
        #10 data_in = 16'b0000111101001101; // Test with value around x6
        #10 data_in = 16'b0001011101111001; // Test with value around x7
        #10 data_in = 16'b0010001110001010; // Test with value around x8

        // Finish simulation
        #10 $finish;
    end

endmodule
