`timescale 1ns/1ps
`include "softplus_8slice_piped.v"

module softplus_8slice_piped_tb;
    reg [15:0] data_in;
    reg clk, reset;
    wire [15:0] data_out;

    initial begin
        clk = 0;
        forever #1 clk = ~clk; // Clock with 10ns period
    end

    // Instantiate the pipelined module
    softplus_8slice_piped dut
    (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
        $dumpfile("softplus_8slice_piped_tb.vcd");
        $dumpvars(0, softplus_8slice_piped_tb);

        // Reset the pipeline
        reset = 1;
        data_in = 16'b0;
        #20 reset = 0;

        // Apply input test cases with appropriate delays
        #10 data_in = 16'b1001111100000000; // Input 1
        #10 data_in = 16'b1000100110111111; // Input 2
        #10 data_in = 16'b0000000000000000; // Input 3
        #10 data_in = 16'b0000001100010100; // Input 4
        #10 data_in = 16'b0001111011111000; // Input 5

        // Hold steady after last input
        #50 data_in = 16'b0;

        // Wait for the pipeline to flush out results
        #100 $finish;
    end

    // Monitor pipeline behavior, considering latency
    initial begin
        #20 $monitor("Input = %h | Output = %h", data_in, data_out);
    end
endmodule