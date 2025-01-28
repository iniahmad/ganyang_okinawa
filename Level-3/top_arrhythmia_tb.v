`include "top_arrhythmia.v"

module top_arrhythmia_tb;

    // Parameters
    parameter BITSIZE = 16;

    // Inputs
    reg clk;
    reg reset;
    reg [BITSIZE*10-1:0] x;
    // reg valid;

    // Outputs
    wire [BITSIZE-1:0] y1;
    wire [BITSIZE-1:0] y2;
    wire [BITSIZE*2-1:0] y;
    wire don_flag;
    // wire [BITSIZE-1:0] y2;

    // Instantiate the Unit Under Test (UUT)
    top_arrhythmia #(BITSIZE) uut (
        .clk(clk),
        .reset(reset),
        .x(x),
        .y({y1,y2}),
        .done_flag_out(done_flag)
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

        // Test case index 0 True (y1 > y2)
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
        #600;

        reset = 1;
        x = 0;
        // Wait for global reset to finish
        #10;
        reset = 0;

        // Testcase index 2 False (y1 < y2)
        x = {
        16'b0000010111011011,
        16'b0000011000001101,
        16'b0000010111111001,
        16'b0000010111010001,
        16'b0000010110101110,
        16'b0000010110101001,
        16'b0000010110000101,
        16'b0000010110111000,
        16'b0000010111001100,
        16'b0000011000001000
        };
        #600;

        reset = 1;
        x = 0;
        // Wait for global reset to finish
        #10;
        reset = 0;

        // Testcase index 4 True (y1 > y2)
        x = {
        16'b0000001110111011,
        16'b0000011001011110,
        16'b0000001011101000,
        16'b0000010110111111,
        16'b0000001101011000,
        16'b0000001100001010,
        16'b0000001100001010,
        16'b0000010010111001,
        16'b0000010010010110,
        16'b0000010011010111
        };
        #600;

        reset = 1;
        x = 0;
        // Wait for global reset to finish
        #10;
        reset = 0;

        // Testcase 5 False (y1 < y2)
        x = {
        16'b0000010110011010,
        16'b0000010101001001,
        16'b0000010101011000,
        16'b0000010111110100,
        16'b0000011000000011,
        16'b0000010101111011,
        16'b0000010110010000,
        16'b0000010110011010,
        16'b0000010110101110,
        16'b0000010101000100
        };
        #600;

        reset = 1;
        x = 0;
        // Wait for global reset to finish
        #10;
        reset = 0;

        // Testcase 6 True (y1 > y2)
        x = {
        16'b0000010001100011,
        16'b0000001010111111,
        16'b0000100000000000,
        16'b0000010111101101,
        16'b0000010111001110,
        16'b0000001111000000,
        16'b0000011110010110,
        16'b0000010111101101,
        16'b0000010111011101,
        16'b0000001110110110
        };
        #600;

        reset = 1;
        x = 0;
        // Wait for global reset to finish
        #10;
        reset = 0;

        // Testcase 9 False (y1 < y2)
        x = {
        16'b0000011000001111,
        16'b0000010111101001,
        16'b0000010111000011,
        16'b0000011000101111,
        16'b0000011000011100,
        16'b0000010111111100,
        16'b0000010111010110,
        16'b0000010111111100,
        16'b0000010111100011,
        16'b0000011000001111
        };
        #600;

        reset = 1;
        x = 0;
        // Wait for global reset to finish
        #10;
        reset = 0;

// Testcase 12 False
x = {
16'b0000010111111110,
16'b0000010111111000,
16'b0000010111101100,
16'b0000010111110010,
16'b0000011000101101,
16'b0000010111101100,
16'b0000011000000100,
16'b0000010111011011,
16'b0000010111010101,
16'b0000010111101100
};

#600;
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;

// Testcase 13 False
x = {
16'b0000010011101110,
16'b0000010100000011,
16'b0000010011110011,
16'b0000010100000011,
16'b0000010011111011,
16'b0000010011111111,
16'b0000010100110001,
16'b0000010001110010,
16'b0000010101101111,
16'b0000010100111101
};

#600;
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;

// Testcase 14 True
x = {
16'b0000001100000011,
16'b0000010110000000,
16'b0000001011110010,
16'b0000010100011011,
16'b0000001111001111,
16'b0000001110000011,
16'b0000001111010110,
16'b0000010010110111,
16'b0000010001100100,
16'b0000010001110010
};

#600;
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;

// Testcase 15 True
x = {
16'b0000010110111101,
16'b0000010110100011,
16'b0000010110110000,
16'b0000010110001010,
16'b0000010111000011,
16'b0000010111001001,
16'b0000010110110000,
16'b0000010110001010,
16'b0000010110100011,
16'b0000010110101010
};

#600;
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;

// Testcase 20 False
x = {
16'b0000010011100010,
16'b0000010010111101,
16'b0000010011101111,
16'b0000010011110010,
16'b0000010010101100,
16'b0000010011101100,
16'b0000010011010001,
16'b0000011100110101,
16'b0000001110110011,
16'b0000010101101101
};

#600;
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;

// Testcase 23 False
x = {
16'b0000010111111100,
16'b0000010111101000,
16'b0000010101100100,
16'b0000011001011111,
16'b0000010110111010,
16'b0000011000101010,
16'b0000011001100110,
16'b0000011001010010,
16'b0000011000010000,
16'b0000010111111100
};

#600;
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;


        // Finish simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        // $monitor("Time: %0t | Reset: %b | x: %h | y: %h", $time, reset, x, y);
    end

endmodule
