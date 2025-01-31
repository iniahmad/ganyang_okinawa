`include "top_arrhythmia.v"

module top_arrhythmia_tb;

    // Parameters
    parameter BITSIZE = 20;

    // Inputs
    reg clk;
    reg reset;
    reg [BITSIZE*10-1:0] x;
    reg [6:0] test_index;
    // reg valid;

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

/// for output ///
    localparam max_data = 101;
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


// Testcase 0 True
test_index = 16'd0;
x = {
20'b00000100001011000011,
20'b00000001111111000101,
20'b00000110010111111100,
20'b00000100011001110010,
20'b00000100001101110100,
20'b00000001010011110011,
20'b00000001010100101110,
20'b00000101111010011110,
20'b00000011101101100101,
20'b00000010101111111000
};
#600;
reall[0] = 1;

pred [0] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 1 False
test_index = 16'd1;
x = {
20'b00000100011100011100,
20'b00000011101101000010,
20'b00000011010010010100,
20'b00000011011010111011,
20'b00000010101011100001,
20'b00000100100110110010,
20'b00000010101001110011,
20'b00000100001100000100,
20'b00000011100110001001,
20'b00000011011010111011
};
#600;
reall[1] = 0;

pred [1] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 2 False
test_index = 16'd2;
x = {
20'b00000101110110111000,
20'b00000110000011011101,
20'b00000101111110011011,
20'b00000101110100010111,
20'b00000101101011100011,
20'b00000101101010010011,
20'b00000101100001011111,
20'b00000101101110000100,
20'b00000101110011000110,
20'b00000110000010001100
};
#600;
reall[2] = 0;

pred [2] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 3 True
test_index = 16'd3;
x = {
20'b00000011010101000100,
20'b00000010110110010001,
20'b00000010111010010101,
20'b00000011001011010101,
20'b00000010110100101010,
20'b00000010111001100001,
20'b00000011000011001111,
20'b00000010001100111101,
20'b00000100010111011111,
20'b00000011010001110100
};
#600;
reall[3] = 1;

pred [3] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 4 True
test_index = 16'd4;
x = {
20'b00000011101110110010,
20'b00000110010111101010,
20'b00000010111010000101,
20'b00000101101111110111,
20'b00000011010110000011,
20'b00000011000010101100,
20'b00000011000010101100,
20'b00000100101110010000,
20'b00000100100101101001,
20'b00000100110101110010
};
#600;
reall[4] = 1;

pred [4] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 5 False
test_index = 16'd5;
x = {
20'b00000101100110100001,
20'b00000101010010011001,
20'b00000101010110001011,
20'b00000101111101001010,
20'b00000110000000111100,
20'b00000101011110111110,
20'b00000101100100000000,
20'b00000101100110100001,
20'b00000101101011100011,
20'b00000101010001001000
};
#600;
reall[5] = 0;

pred [5] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 6 True
test_index = 16'd6;
x = {
20'b00000100011000111100,
20'b00000010101111111010,
20'b00001000000000000000,
20'b00000101111011011001,
20'b00000101110011100001,
20'b00000011110000001111,
20'b00000111100101101111,
20'b00000101111011011001,
20'b00000101110111011101,
20'b00000011101101100111
};
#600;
reall[6] = 1;

pred [6] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 7 True
test_index = 16'd7;
x = {
20'b00000100010110100101,
20'b00000011110110010100,
20'b00000011001011010010,
20'b00000100100110101110,
20'b00000001110010000001,
20'b00000001110011000101,
20'b00000111010010110100,
20'b00000011010110000011,
20'b00000101101101101101,
20'b00000011100010111101
};
#600;
reall[7] = 1;

pred [7] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 8 False
test_index = 16'd8;
x = {
20'b00000110010001000111,
20'b00000110010001000111,
20'b00000101100001010010,
20'b00000101011111000111,
20'b00000101111100011101,
20'b00000110000000110100,
20'b00000101111000000111,
20'b00000101010110011010,
20'b00000101111110101001,
20'b00000110010011010010
};
#600;
reall[8] = 0;

pred [8] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 9 False
test_index = 16'd9;
x = {
20'b00000110000011111110,
20'b00000101111010011011,
20'b00000101110000111001,
20'b00000110001011111011,
20'b00000110000111001001,
20'b00000101111111001101,
20'b00000101110101101010,
20'b00000101111111001101,
20'b00000101111000110110,
20'b00000110000011111110
};
#600;
reall[9] = 0;

pred [9] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 10 True
test_index = 16'd10;
x = {
20'b00000001011111011100,
20'b00000010000110110111,
20'b00000001110110010001,
20'b00000001110001000101,
20'b00000001101000010001,
20'b00000010101000000100,
20'b00000001100111101111,
20'b00000010000110110111,
20'b00000001110100001100,
20'b00000001100101001001
};
#600;
reall[10] = 1;

pred [10] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 11 True
test_index = 16'd11;
x = {
20'b00000010111101100100,
20'b00000011000100110111,
20'b00000001000110011110,
20'b00000001000110011110,
20'b00000100010010101000,
20'b00000011010111011111,
20'b00000001010011011100,
20'b00000000110011110110,
20'b00000011100010110101,
20'b00000011110010001110
};
#600;
reall[11] = 1;

pred [11] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 12 False
test_index = 16'd12;
x = {
20'b00000101111111101000,
20'b00000101111110001001,
20'b00000101111011001101,
20'b00000101111100101011,
20'b00000110001011011011,
20'b00000101111011001101,
20'b00000110000001000110,
20'b00000101110110110001,
20'b00000101110101010011,
20'b00000101111011001101
};
#600;
reall[12] = 0;

pred [12] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 13 False
test_index = 16'd13;
x = {
20'b00000100111011101101,
20'b00000101000000111010,
20'b00000100111100110000,
20'b00000101000000111010,
20'b00000100111110110101,
20'b00000100111111110111,
20'b00000101001100010101,
20'b00000100011100100011,
20'b00000101011011111010,
20'b00000101001111011100
};
#600;
reall[13] = 0;

pred [13] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 14 True
test_index = 16'd14;
x = {
20'b00000011000000110111,
20'b00000101100000000000,
20'b00000010111100100010,
20'b00000101000110111010,
20'b00000011110011111001,
20'b00000011100000110111,
20'b00000011110101100111,
20'b00000100101101110101,
20'b00000100011001000101,
20'b00000100011100100010
};
#600;
reall[14] = 1;

pred [14] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 15 False
test_index = 16'd15;
x = {
20'b00000101101111010011,
20'b00000101101000111100,
20'b00000101101100000111,
20'b00000101100010100101,
20'b00000101110000111001,
20'b00000101110010011111,
20'b00000101101100000111,
20'b00000101100010100101,
20'b00000101101000111100,
20'b00000101101010100010
};
#600;
reall[15] = 0;

pred [15] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 16 True
test_index = 16'd16;
x = {
20'b00000110001101011001,
20'b00000100111010000010,
20'b00000100101111101000,
20'b00000100110100000101,
20'b00000100101110001000,
20'b00000100110001000111,
20'b00000011000111011100,
20'b00000110011001010011,
20'b00000100011010110010,
20'b00000101001010011010
};
#600;
reall[16] = 1;

pred [16] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 17 False
test_index = 16'd17;
x = {
20'b00000101110011011010,
20'b00000101111010010110,
20'b00000101101101010101,
20'b00000101011011000111,
20'b00000101011101101110,
20'b00000101101111111100,
20'b00000101110111110000,
20'b00000101100110011001,
20'b00000101010111101001,
20'b00000101011100110110
};
#600;
reall[17] = 0;

pred [17] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 18 False
test_index = 16'd18;
x = {
20'b00000010110010001110,
20'b00000011001100111101,
20'b00000010111111001100,
20'b00000010110110010001,
20'b00000010111100110000,
20'b00000011101011101111,
20'b00000011010111011111,
20'b00000100001101110001,
20'b00000010101110001011,
20'b00000010110100101010
};
#600;
reall[18] = 0;

pred [18] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 19 False
test_index = 16'd19;
x = {
20'b00000101100100000000,
20'b00000101100101010001,
20'b00000101110100010111,
20'b00000101111001011001,
20'b00000101111110011011,
20'b00000101101100110100,
20'b00000101100001011111,
20'b00000101100000001111,
20'b00000101100100000000,
20'b00000101101110000100
};
#600;
reall[19] = 0;

pred [19] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 20 False
test_index = 16'd20;
x = {
20'b00000100111000100001,
20'b00000100101111011000,
20'b00000100111011110110,
20'b00000100111100101011,
20'b00000100101011001110,
20'b00000100111011000000,
20'b00000100110100010111,
20'b00000111001101010011,
20'b00000011101100111000,
20'b00000101011011011011
};
#600;
reall[20] = 0;

pred [20] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 21 False
test_index = 16'd21;
x = {
20'b00000101100000001110,
20'b00000101011110010111,
20'b00000110011011000110,
20'b00000110110100010100,
20'b00000110100111001111,
20'b00000111001001110011,
20'b00000110110100010100,
20'b00000101110011110110,
20'b00000110010111010110,
20'b00000110010110011011
};
#600;
reall[21] = 0;

pred [21] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 22 False
test_index = 16'd22;
x = {
20'b00000011010100111001,
20'b00000011010010010100,
20'b00000100011011100101,
20'b00000011101010011100,
20'b00000011100101010001,
20'b00000100000100010011,
20'b00000100110000010001,
20'b00000101000100000110,
20'b00000011100011100011,
20'b00000011100101010001
};
#600;
reall[22] = 0;

pred [22] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 23 False
test_index = 16'd23;
x = {
20'b00000101111111001011,
20'b00000101111010001110,
20'b00000101011001001011,
20'b00000110010111111100,
20'b00000101101110101010,
20'b00000110001010101111,
20'b00000110011001100110,
20'b00000110010100101001,
20'b00000110000100001000,
20'b00000101111111001011
};
#600;
reall[23] = 0;

pred [23] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 24 False
test_index = 16'd24;
x = {
20'b00000110000101100010,
20'b00000110000010100101,
20'b00000110000010100101,
20'b00000110001110011000,
20'b00000110001001111101,
20'b00000110000101100010,
20'b00000110001000011110,
20'b00000110010100010010,
20'b00000110010001010101,
20'b00000101111110001001
};
#600;
reall[24] = 0;

pred [24] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 25 False
test_index = 16'd25;
x = {
20'b00000100100111000011,
20'b00000100011110010111,
20'b00000100000111001110,
20'b00000100001000101011,
20'b00000100001011100100,
20'b00000100000100010101,
20'b00000100001101000001,
20'b00000100001101000001,
20'b00000100100001010000,
20'b00000011101011110000
};
#600;
reall[25] = 0;

pred [25] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 26 False
test_index = 16'd26;
x = {
20'b00000100011011011110,
20'b00000100011111110100,
20'b00000100100100001010,
20'b00000100101011011000,
20'b00000100100100001010,
20'b00000100011011011110,
20'b00000100001111111010,
20'b00000100001010000111,
20'b00000100001011100100,
20'b00000100010100001111
};
#600;
reall[26] = 0;

pred [26] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 27 False
test_index = 16'd27;
x = {
20'b00000010101010001000,
20'b00000011110001011010,
20'b00000011000100110111,
20'b00000011111000101101,
20'b00000010101100100011,
20'b00000010101010001000,
20'b00000010100001001101,
20'b00000010101011101111,
20'b00000011001000111010,
20'b00000011011101111110
};
#600;
reall[27] = 0;

pred [27] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 28 True
test_index = 16'd28;
x = {
20'b00000101000010111110,
20'b00000100110101100101,
20'b00000100111000100011,
20'b00000100101100101001,
20'b00000100111000100011,
20'b00000100011010110010,
20'b00000101010011010110,
20'b00000100111110100000,
20'b00000011010100110101,
20'b00000110011001010011
};
#600;
reall[28] = 1;

pred [28] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 29 False
test_index = 16'd29;
x = {
20'b00000101111000110110,
20'b00000110000000110010,
20'b00000110000111001001,
20'b00000101111010011011,
20'b00000101110101101010,
20'b00000101111101100111,
20'b00000110001000101111,
20'b00000101111010011011,
20'b00000101101100000111,
20'b00000101110000111001
};
#600;
reall[29] = 0;

pred [29] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 30 True
test_index = 16'd30;
x = {
20'b00000110000110110111,
20'b00000010111000100011,
20'b00000010101011010011,
20'b00000011011001101010,
20'b00000011000101110010,
20'b00000100011010111110,
20'b00000100100011011111,
20'b00000101001000011001,
20'b00000011000100110110,
20'b00000111001100111001
};
#600;
reall[30] = 1;

pred [30] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
        
        // Initialize variables
        sum = 0;
        true = 0;

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
            $display("accuracy = (%d / %d) = %.3f%%", true, sum, true * 100.0 / sum);
        end else begin
            $display("No valid test cases to calculate accuracy.");
        end

        // Finish simulation
        $finish;
    end

    initial begin
        // // Initialize variables
        // sum = 0;
        // true = 0;

        // for (i = 0; i < 25; i = i + 1) begin
        //     if (!(reall[i] === 1'bx || pred[i] === 1'bx)) begin
        //         $display("testcase: %d, real: %b, pred: %b", i, reall[i], pred[i]);
        //         sum = sum + 1;
        //         if (reall[i] == pred[i]) begin
        //             true = true + 1;
        //         end
        //     end
        // end

        // if (sum > 0) begin
        //     $display("accuracy = %4d / %4d = %4f", true, sum, true * 1.0 / sum);
        // end else begin
        //     $display("No valid test cases to calculate accuracy.");
        // end
    end

endmodule
