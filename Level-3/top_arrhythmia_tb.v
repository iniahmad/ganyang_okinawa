`include "top_arrhythmia.v"

module top_arrhythmia_tb;

    // Parameters
    parameter BITSIZE = 16;

    // Inputs
    reg clk;
    reg reset;
    reg [BITSIZE*10-1:0] x;
    reg valid;

    // Outputs
    wire [BITSIZE-1:0] y1;
    wire [BITSIZE-1:0] y2;
    wire [BITSIZE*2-1:0] y;
    // wire [BITSIZE-1:0] y2;

    // Instantiate the Unit Under Test (UUT)
    top_arrhythmia #(BITSIZE) uut (
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units period
    end

    // Test sequence
    initial begin
        $dumpfile("top_arrhythmia_tb.vcd");
        $dumpvars(0, top_arrhythmia_tb);
        // Initialize Inputs
        reset = 1;
        x = 0;

        // Wait for global reset to finish
        #10;
        reset = 0;

        // Test case 1
        x = {
        16'b0000010000101100,
        16'b0000000111111100,
        16'b0000011001011111,
        16'b0000010001100111,
        16'b0000010000110111,
        16'b0000000101001111,
        16'b0000000101010010,
        16'b0000010111101001,
        16'b0000001110110110,
        16'b0000001010111111
        };

        #500;
        valid = 1;
        #100
        valid = 0;

        x = {
        16'b0000010000101100,
        16'b0000000111111100,
        16'b0000011001011111,
        16'b0000010001100111,
        16'b0000010000110111,
        16'b0000000101001111,
        16'b0000000101010010,
        16'b0000010111101001,
        16'b0000001110110110,
        16'b0000001010111111
        };

        #500;
        valid = 1;
        #100
        valid = 0;

        // // Test case 2
        // x = {16'd10, 16'd9, 16'd8, 16'd7, 16'd6, 16'd5, 16'd4, 16'd3, 16'd2, 16'd1};
        // #10;

        // // Test case 3
        // x = {16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0, 16'd0};
        // #10;

        // Add more test cases as needed

        // Finish simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        // $monitor("Time: %0t | Reset: %b | x: %h | y: %h", $time, reset, x, y);
    end

endmodule
