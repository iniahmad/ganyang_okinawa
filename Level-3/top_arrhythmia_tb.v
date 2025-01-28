`include "top_arrhythmia.v"

module top_arrhythmia_tb;

    // Parameters
    parameter BITSIZE = 16;

    // Inputs
    reg clk;
    reg reset;
    reg [BITSIZE*10-1:0] x;
    reg true_label;
    reg [6:0] test_index;

    // Outputs
    wire [BITSIZE-1:0] y1;
    wire [BITSIZE-1:0] y2;
    wire [BITSIZE*2-1:0] y;
    wire done_flag;

    // wire [BITSIZE-1:0] y2;

    // Instantiate the Unit Under Test (UUT)
    top_arrhythmia #(BITSIZE) uut (
        .clk(clk),
        .reset(reset),
        .x(x),
        .y({y1,y2}),
        .done_flag_out(done_flag)
    );

    // terus bagian inisialisasi:

/// for output ///
    localparam max_data = 25;
    integer i;
    integer sum;
    integer true;
    logic pred  [max_data-1:0];
    logic reall [max_data-1:0];

    function logic compare_sign_mag;
        input [15:0] val_a;
        input [15:0] val_b;  // Declare inputs as 16-bit
        logic sign_a;
        logic sign_b;
        logic [14:0] mag_a;
        logic [14:0] mag_b;

        begin
            // Extract sign and magnitude
            sign_a = val_a[15];
            sign_b = val_b[15];
            mag_a = val_a[14:0];
            mag_b = val_b[14:0];

            // Compare based on sign and magnitude
            if (sign_a != sign_b) begin
                // If signs differ, the negative number is smaller
                compare_sign_mag = (sign_a < sign_b);  // 1 if A > B
            end else begin
                // If signs are the same, compare magnitudes
                if (sign_a == 1'b1) begin
                    // Both negative: larger magnitude means smaller number
                    compare_sign_mag = (mag_a < mag_b);  // 1 if (-)A > (-)B
                end else begin
                    // Both positive: larger magnitude means larger number
                    compare_sign_mag = (mag_a > mag_b);  // 1 if A > B
                end
            end
        end
    endfunction
/// for output ///

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

//         // Test case index 0 True (y1 > y2)
//         x = {
//         16'b0000010000101100,
//         16'b0000000111111100,
//         16'b0000011001011111,
//         16'b0000010001100111,
//         16'b0000010000110111,
//         16'b0000000101001111,
//         16'b0000000101010010,
//         16'b0000010111101001,
//         16'b0000001110110110,
//         16'b0000001010111111
//         };
//         #600;

//         reset = 1;
//         x = 0;
//         // Wait for global reset to finish
//         #10;
//         reset = 0;

//         // Testcase index 2 False (y1 < y2)
//         x = {
//         16'b0000010111011011,
//         16'b0000011000001101,
//         16'b0000010111111001,
//         16'b0000010111010001,
//         16'b0000010110101110,
//         16'b0000010110101001,
//         16'b0000010110000101,
//         16'b0000010110111000,
//         16'b0000010111001100,
//         16'b0000011000001000
//         };
//         #600;

//         reset = 1;
//         x = 0;
//         // Wait for global reset to finish
//         #10;
//         reset = 0;

//         // Testcase index 4 True (y1 > y2)
//         x = {
//         16'b0000001110111011,
//         16'b0000011001011110,
//         16'b0000001011101000,
//         16'b0000010110111111,
//         16'b0000001101011000,
//         16'b0000001100001010,
//         16'b0000001100001010,
//         16'b0000010010111001,
//         16'b0000010010010110,
//         16'b0000010011010111
//         };
//         #600;

//         reset = 1;
//         x = 0;
//         // Wait for global reset to finish
//         #10;
//         reset = 0;

//         // Testcase 5 False (y1 < y2)
//         x = {
//         16'b0000010110011010,
//         16'b0000010101001001,
//         16'b0000010101011000,
//         16'b0000010111110100,
//         16'b0000011000000011,
//         16'b0000010101111011,
//         16'b0000010110010000,
//         16'b0000010110011010,
//         16'b0000010110101110,
//         16'b0000010101000100
//         };
//         #600;

//         reset = 1;
//         x = 0;
//         // Wait for global reset to finish
//         #10;
//         reset = 0;

//         // Testcase 6 True (y1 > y2)
//         x = {
//         16'b0000010001100011,
//         16'b0000001010111111,
//         16'b0000100000000000,
//         16'b0000010111101101,
//         16'b0000010111001110,
//         16'b0000001111000000,
//         16'b0000011110010110,
//         16'b0000010111101101,
//         16'b0000010111011101,
//         16'b0000001110110110
//         };
//         #600;

//         reset = 1;
//         x = 0;
//         // Wait for global reset to finish
//         #10;
//         reset = 0;

//         // Testcase 9 False (y1 < y2)
//         x = {
//         16'b0000011000001111,
//         16'b0000010111101001,
//         16'b0000010111000011,
//         16'b0000011000101111,
//         16'b0000011000011100,
//         16'b0000010111111100,
//         16'b0000010111010110,
//         16'b0000010111111100,
//         16'b0000010111100011,
//         16'b0000011000001111
//         };
//         #600;

//         reset = 1;
//         x = 0;
//         // Wait for global reset to finish
//         #10;
//         reset = 0;

// // Testcase 12 False
// x = {
// 16'b0000010111111110,
// 16'b0000010111111000,
// 16'b0000010111101100,
// 16'b0000010111110010,
// 16'b0000011000101101,
// 16'b0000010111101100,
// 16'b0000011000000100,
// 16'b0000010111011011,
// 16'b0000010111010101,
// 16'b0000010111101100
// };

// #600;
// reset = 1;
// x = 0;
// // Wait for global reset to finish
// #10;
// reset = 0;

// // Testcase 13 False
// x = {
// 16'b0000010011101110,
// 16'b0000010100000011,
// 16'b0000010011110011,
// 16'b0000010100000011,
// 16'b0000010011111011,
// 16'b0000010011111111,
// 16'b0000010100110001,
// 16'b0000010001110010,
// 16'b0000010101101111,
// 16'b0000010100111101
// };

// #600;
// reset = 1;
// x = 0;
// // Wait for global reset to finish
// #10;
// reset = 0;

// // Testcase 14 True
// x = {
// 16'b0000001100000011,
// 16'b0000010110000000,
// 16'b0000001011110010,
// 16'b0000010100011011,
// 16'b0000001111001111,
// 16'b0000001110000011,
// 16'b0000001111010110,
// 16'b0000010010110111,
// 16'b0000010001100100,
// 16'b0000010001110010
// };

// #600;
// reset = 1;
// x = 0;
// // Wait for global reset to finish
// #10;
// reset = 0;

// // Testcase 15 True
// x = {
// 16'b0000010110111101,
// 16'b0000010110100011,
// 16'b0000010110110000,
// 16'b0000010110001010,
// 16'b0000010111000011,
// 16'b0000010111001001,
// 16'b0000010110110000,
// 16'b0000010110001010,
// 16'b0000010110100011,
// 16'b0000010110101010
// };

// #600;
// reset = 1;
// x = 0;
// // Wait for global reset to finish
// #10;
// reset = 0;

// // Testcase 20 False
// x = {
// 16'b0000010011100010,
// 16'b0000010010111101,
// 16'b0000010011101111,
// 16'b0000010011110010,
// 16'b0000010010101100,
// 16'b0000010011101100,
// 16'b0000010011010001,
// 16'b0000011100110101,
// 16'b0000001110110011,
// 16'b0000010101101101
// };

// #600;
// reset = 1;
// x = 0;
// // Wait for global reset to finish
// #10;
// reset = 0;

// // Testcase 23 False
// x = {
// 16'b0000010111111100,
// 16'b0000010111101000,
// 16'b0000010101100100,
// 16'b0000011001011111,
// 16'b0000010110111010,
// 16'b0000011000101010,
// 16'b0000011001100110,
// 16'b0000011001010010,
// 16'b0000011000010000,
// 16'b0000010111111100
// };

// #600;
// reset = 1;
// x = 0;
// // Wait for global reset to finish
// #10;
// reset = 0;

// Testcase 71 False
test_index = 16'd71;
x = {
16'b0000010000101011,
16'b0000001010010000,
16'b0000001001110111,
16'b0000001011000010,
16'b0000001010101101,
16'b0000001001011110,
16'b0000001110100010,
16'b0000001011100011,
16'b0000001100000100,
16'b0000001101111101
};
true_label = 0;

    #600;
    reset = 1;
    x = 0;
    // Wait for global reset to finish
    #10;
    reset = 0;
    
// Testcase 72 False
test_index = 16'd72;
x = {
16'b0000010000101110,
16'b0000010010000101,
16'b0000010001100010,
16'b0000010010101101,
16'b0000010010010110,
16'b0000010010010110,
16'b0000010000011100,
16'b0000010000101110,
16'b0000010000001011,
16'b0000010000110100
};
true_label = 0;

    #600;
    reset = 1;
    x = 0;
    // Wait for global reset to finish
    #10;
    reset = 0;
    
// Testcase 73 False
test_index = 16'd73;
x = {
16'b0000011001110101,
16'b0000011010000110,
16'b0000011011101000,
16'b0000011011101000,
16'b0000011011100011,
16'b0000011001010100,
16'b0000011000011000,
16'b0000010111110111,
16'b0000011000110100,
16'b0000011010110111
};
true_label = 0;

    #600;
    reset = 1;
    x = 0;
    // Wait for global reset to finish
    #10;
    reset = 0;
    
// Testcase 74 False
test_index = 16'd74;
x = {
16'b0000010110110000,
16'b0000010111010000,
16'b0000010110111101,
16'b0000010111110000,
16'b0000010111011101,
16'b0000010111011101,
16'b0000010110101010,
16'b0000010111111100,
16'b0000010111101001,
16'b0000010111010110
};
true_label = 0;

    #600;
    reset = 1;
    x = 0;
    // Wait for global reset to finish
    #10;
    reset = 0;
    
// Testcase 75 False
test_index = 16'd75;
x = {
16'b0000011011000011,
16'b0000011011010101,
16'b0000011001001111,
16'b0000011001101110,
16'b0000011001010011,
16'b0000011001011000,
16'b0000011010001001,
16'b0000011011010000,
16'b0000011010101000,
16'b0000011000101111
};
true_label = 0;

    #600;
    reset = 1;
    x = 0;
    // Wait for global reset to finish
    #10;
    reset = 0;
    
// Testcase 76 False
test_index = 16'd76;
x = {
16'b0000011001001100,
16'b0000011010000100,
16'b0000011001011110,
16'b0000011001101011,
16'b0000011001111110,
16'b0000011010101001,
16'b0000011001100101,
16'b0000011001110001,
16'b0000011001111110,
16'b0000011001111110
};
true_label = 0;

    #600;
    reset = 1;
    x = 0;
    // Wait for global reset to finish
    #10;
    reset = 0;
    
// Testcase 77 False
test_index = 16'd77;
x = {
16'b0000010011010100,
16'b0000010011001100,
16'b0000010011011000,
16'b0000010011100011,
16'b0000010011000101,
16'b0000010010110101,
16'b0000010011100111,
16'b0000010011100011,
16'b0000010011000001,
16'b0000010011100111
};
true_label = 0;

    #600;
    reset = 1;
    x = 0;
    // Wait for global reset to finish
    #10;
    reset = 0;
    
// Testcase 78 False
test_index = 16'd78;
x = {
16'b0000010010011100,
16'b0000010010100001,
16'b0000010011000111,
16'b0000010010101011,
16'b0000010010001110,
16'b0000010001111010,
16'b0000010010100110,
16'b0000010010100110,
16'b0000010010101011,
16'b0000001101000001
};
true_label = 0;

    #600;
    reset = 1;
    x = 0;
    // Wait for global reset to finish
    #10;
    reset = 0;
    
// Testcase 79 True
test_index = 16'd79;
x = {
16'b0000000110100101,
16'b0000001000011101,
16'b0000000111010000,
16'b0000000110101001,
16'b0000000100101000,
16'b0000000100101000,
16'b0000000111010100,
16'b0000000101111001,
16'b0000000101101111,
16'b0000001001110110
};
true_label = 1;

    #600;
    reset = 1;
    x = 0;
    // Wait for global reset to finish
    #10;
    reset = 0;

    for (i = 0; i < max_data; i = i + 1) begin
            if (!(reall[i] === 1'bx || pred[i] === 1'bx)) begin
                $display("testcase: %d, real: %b, pred: %b", i, reall[i], pred[i]);
                sum = sum + 1;
                if (reall[i] == pred[i]) begin
                    true = true + 1;
                end
            end
        end

        if (sum > 0) begin
            $display("accuracy = (%d / %d) = %4f", true, sum, true * 1.0 / sum);
        end else begin
            $display("No valid test cases to calculate accuracy.");
        end
    

    

        // Finish simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        // $monitor("Time: %0t | Reset: %b | x: %h | y: %h", $time, reset, x, y);
    end

endmodule
