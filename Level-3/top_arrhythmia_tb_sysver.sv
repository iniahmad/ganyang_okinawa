// `include "top_arrhythmia.v"
// how to run:
// iverilog -g2012 -o top_arrhythmia_tb_sysver.v.out top_arrhythmia_tb_sysver.sv top_arrhythmia.v
// vvp top_arrhythmia_tb_sysver.v.out

module top_arrhythmia_tb;

    // Parameters
    parameter BITSIZE = 16;

    // Inputs
    reg clk;
    reg reset;
    reg [BITSIZE*10-1:0] x;
    // reg valid;

    reg [BITSIZE-1:0] test_index;
    // Outputs
    wire [BITSIZE-1:0] y1;
    wire [BITSIZE-1:0] y2;
    wire [BITSIZE*2-1:0] y;
    wire done_flag;
    // wire [BITSIZE-1:0] y2;

// tambahan debugging
    wire [BITSIZE*1-1:0] out_intermediate [5:0];
    wire [BITSIZE*1-1:0] out_zvar;
    wire [BITSIZE*1-1:0] out_zmean;
    wire [BITSIZE*1-1:0] out_sampling;
    wire [BITSIZE*1-1:0] out_hidden_classifier [5:0];
//

// Instantiate the Unit Under Test (UUT)
    top_arrhythmia #(BITSIZE) uut (
        .clk(clk),
        .reset(reset),
        .x(x),

    //tambahan debugging
        .out_intermediate({out_intermediate[0],out_intermediate[1],out_intermediate[2],out_intermediate[3],out_intermediate[4],out_intermediate[5]}),
        .out_zvar(out_zvar),
        .out_zmean(out_zmean),
        .out_sampling(out_sampling),
        .out_hidden_classifier({out_hidden_classifier[0],out_hidden_classifier[1],out_hidden_classifier[2],out_hidden_classifier[3],out_hidden_classifier[4],out_hidden_classifier[5]}),
    //

        .y({y1,y2}),
        .done_flag_out(done_flag)
    );
//

/// for output ///
    localparam max_data = 51;
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

    function real b2f(input logic [15:0] binary_str);
        bit sign;  // Better as 'bit' since it's only 0 or 1
        logic [3:0] integer_part;
        logic [10:0] fractional_part;
        real frac_value;
        real float_value;
        int i;

        // Extract sign, integer, and fractional parts
        sign = binary_str[15];  // Sign bit
        integer_part = binary_str[14:11];  // 4-bit integer part
        fractional_part = binary_str[10:0];  // 11-bit fractional part

        // Calculate fractional value
        frac_value = 0.0;
        for (i = 10; i >= 0; i = i - 1) begin
            if (fractional_part[i] == 1'b1) begin
                frac_value = frac_value + (1.0 / (2 ** (11 - i)));
            end
        end

        // Combine integer and fractional parts
        float_value = integer_part + frac_value;

        // Apply sign
        if (sign == 1'b1) begin
            float_value = -float_value;
        end

        return float_value;
    endfunction

///

// Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units period
    end
//

    // Test sequence
    initial begin

    #60;
    reset = 1;
    x = 0;
    // Wait for global reset to finish
    #20;
    reset = 0;

// Testcase 1 False
// test_index = 16'd1;
// x = {
// 16'b0000010001110001,
// 16'b0000001110110100,
// 16'b0000001101001001,
// 16'b0000001101101011,
// 16'b0000001010101110,
// 16'b0000010010011011,
// 16'b0000001010100111,
// 16'b0000010000110000,
// 16'b0000001110011000,
// 16'b0000001101101011
// };
// true_label = 0;

// //reversed
// // x = {
// // 16'b0000001101101011,
// // 16'b0000001110011000,
// // 16'b0000010000110000,
// // 16'b0000001010100111,
// // 16'b0000010010011011,
// // 16'b0000001010101110,
// // 16'b0000001101101011,
// // 16'b0000001101001001,
// // 16'b0000001110110100,
// // 16'b0000010001110001
// // };

// // PS E:\Kuliah\LSI\ganyang_okinawa\Level-3> iverilog -g2012 -o top_arrhythmia_tb_sysver.v.out top_arrhythmia_tb_sysver.sv top_arrhythmia.v
// // PS E:\Kuliah\LSI\ganyang_okinawa\Level-3> vvp top_arrhythmia_tb_sysver.v.out

//     #1000;

//     reall[0] = 0;
//     pred[0] = compare_sign_mag(y1, y2);

    // reset = 1;
    // x = 0;
    // // Wait for global reset to finish
    // #20;
    // reset = 0;

     // Test case index 0 True (y1 > y2)
x = {
16'b0000000101111101,
16'b0000001000011011,
16'b0000000111011001,
16'b0000000111000100,
16'b0000000110100001,
16'b0000001010100000,
16'b0000000110011110,
16'b0000001000011011,
16'b0000000111010000,
16'b0000000110010100
};

/*
        // $dumpfile("top_arrhythmia_tb.vcd");
        // $dumpvars(0, top_arrhythmia_tb);
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
        reall[0] = 1;
        pred[0] = compare_sign_mag(y1, y2);

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
        reall[2] = 0;
        pred [2] = compare_sign_mag(y1, y2);

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
        reall[4] = 1;
        pred [4] = compare_sign_mag(y1, y2);

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
        reall[5] = 0;
        pred [5] = compare_sign_mag(y1, y2);

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
        reall[6] = 1;
        pred [6] = compare_sign_mag(y1, y2);

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
        reall[9] = 0;
        pred [9] = compare_sign_mag(y1, y2);

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
        reall[12] = 0;
        pred [12] = compare_sign_mag(y1, y2);

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
        reall[13] = 0;
        pred [13] = compare_sign_mag(y1, y2);

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
        reall[14] = 1;
        pred [14] = compare_sign_mag(y1, y2);

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
        reall[15] = 1;
        pred [15] = compare_sign_mag(y1, y2);

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
        reall[20] = 0;
        pred [20] = compare_sign_mag(y1, y2);

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
        reall[23] = 0;
        pred [23] = compare_sign_mag(y1, y2);

        reset = 1;
        x = 0;
        // Wait for global reset to finish
        #10;
        reset = 0;
*/

/*
// Testcase 0 True
test_index = 16'd0;
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
16'b0000010001110001,
16'b0000001110110100,
16'b0000001101001001,
16'b0000001101101011,
16'b0000001010101110,
16'b0000010010011011,
16'b0000001010100111,
16'b0000010000110000,
16'b0000001110011000,
16'b0000001101101011
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
16'b0000001101010100,
16'b0000001011011001,
16'b0000001011101001,
16'b0000001100101101,
16'b0000001011010010,
16'b0000001011100110,
16'b0000001100001100,
16'b0000001000110011,
16'b0000010001011101,
16'b0000001101000111
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
16'b0000010001011010,
16'b0000001111011001,
16'b0000001100101101,
16'b0000010010011010,
16'b0000000111001000,
16'b0000000111001100,
16'b0000011101001011,
16'b0000001101011000,
16'b0000010110110110,
16'b0000001110001011
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
16'b0000011001000100,
16'b0000011001000100,
16'b0000010110000101,
16'b0000010101111100,
16'b0000010111110001,
16'b0000011000000011,
16'b0000010111100000,
16'b0000010101011001,
16'b0000010111111010,
16'b0000011001001101
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
16'b0000000101111101,
16'b0000001000011011,
16'b0000000111011001,
16'b0000000111000100,
16'b0000000110100001,
16'b0000001010100000,
16'b0000000110011110,
16'b0000001000011011,
16'b0000000111010000,
16'b0000000110010100
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
16'b0000001011110110,
16'b0000001100010011,
16'b0000000100011001,
16'b0000000100011001,
16'b0000010001001010,
16'b0000001101011101,
16'b0000000101001101,
16'b0000000011001111,
16'b0000001110001011,
16'b0000001111001000
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
16'b0000011000110101,
16'b0000010011101000,
16'b0000010010111110,
16'b0000010011010000,
16'b0000010010111000,
16'b0000010011000100,
16'b0000001100011101,
16'b0000011001100101,
16'b0000010001101011,
16'b0000010100101001
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
16'b0000010111001101,
16'b0000010111101001,
16'b0000010110110101,
16'b0000010101101100,
16'b0000010101110110,
16'b0000010110111111,
16'b0000010111011111,
16'b0000010110011001,
16'b0000010101011110,
16'b0000010101110011
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
16'b0000001011001000,
16'b0000001100110011,
16'b0000001011111100,
16'b0000001011011001,
16'b0000001011110011,
16'b0000001110101110,
16'b0000001101011101,
16'b0000010000110111,
16'b0000001010111000,
16'b0000001011010010
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
16'b0000010110010000,
16'b0000010110010101,
16'b0000010111010001,
16'b0000010111100101,
16'b0000010111111001,
16'b0000010110110011,
16'b0000010110000101,
16'b0000010110000000,
16'b0000010110010000,
16'b0000010110111000
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
16'b0000010110000000,
16'b0000010101111001,
16'b0000011001101100,
16'b0000011011010001,
16'b0000011010011100,
16'b0000011100100111,
16'b0000011011010001,
16'b0000010111001111,
16'b0000011001011101,
16'b0000011001011001
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
16'b0000001101010011,
16'b0000001101001001,
16'b0000010001101110,
16'b0000001110101001,
16'b0000001110010101,
16'b0000010000010001,
16'b0000010011000001,
16'b0000010100010000,
16'b0000001110001110,
16'b0000001110010101
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
16'b0000011000010110,
16'b0000011000001010,
16'b0000011000001010,
16'b0000011000111001,
16'b0000011000100111,
16'b0000011000010110,
16'b0000011000100001,
16'b0000011001010001,
16'b0000011001000101,
16'b0000010111111000
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
16'b0000010010011100,
16'b0000010001111001,
16'b0000010000011100,
16'b0000010000100010,
16'b0000010000101110,
16'b0000010000010001,
16'b0000010000110100,
16'b0000010000110100,
16'b0000010010000101,
16'b0000001110101111
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
16'b0000010001101101,
16'b0000010001111111,
16'b0000010010010000,
16'b0000010010101101,
16'b0000010010010000,
16'b0000010001101101,
16'b0000010000111111,
16'b0000010000101000,
16'b0000010000101110,
16'b0000010001010000
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
16'b0000001010101000,
16'b0000001111000101,
16'b0000001100010011,
16'b0000001111100010,
16'b0000001010110010,
16'b0000001010101000,
16'b0000001010000100,
16'b0000001010101110,
16'b0000001100100011,
16'b0000001101110111
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
16'b0000010100001011,
16'b0000010011010110,
16'b0000010011100010,
16'b0000010010110010,
16'b0000010011100010,
16'b0000010001101011,
16'b0000010101001101,
16'b0000010011111010,
16'b0000001101010011,
16'b0000011001100101
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
16'b0000010111100011,
16'b0000011000000011,
16'b0000011000011100,
16'b0000010111101001,
16'b0000010111010110,
16'b0000010111110110,
16'b0000011000100010,
16'b0000010111101001,
16'b0000010110110000,
16'b0000010111000011
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
16'b0000011000011011,
16'b0000001011100010,
16'b0000001010101101,
16'b0000001101100110,
16'b0000001100010111,
16'b0000010001101011,
16'b0000010010001101,
16'b0000010100100001,
16'b0000001100010011,
16'b0000011100110011
};
#600;
reall[30] = 1;

pred [30] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 31 True
test_index = 16'd31;
x = {
16'b0000000110010100,
16'b0000001100110000,
16'b0000000111010011,
16'b0000010001001000,
16'b0000001111111001,
16'b0000001000101100,
16'b0000001101100000,
16'b0000001111001111,
16'b0000001010000000,
16'b0000001100100010
};
#600;
reall[31] = 1;

pred [31] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 32 False
test_index = 16'd32;
x = {
16'b0000010011010111,
16'b0000010100111001,
16'b0000010110000011,
16'b0000010110110000,
16'b0000010101011010,
16'b0000010101011010,
16'b0000010101011110,
16'b0000010100011101,
16'b0000010011000111,
16'b0000010100010101
};
#600;
reall[32] = 0;

pred [32] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 33 False
test_index = 16'd33;
x = {
16'b0000011010010000,
16'b0000011010000100,
16'b0000011010010000,
16'b0000011010100011,
16'b0000011011011011,
16'b0000011100000000,
16'b0000011011110100,
16'b0000011011001000,
16'b0000011011111010,
16'b0000011100011111
};
#600;
reall[33] = 0;

pred [33] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 34 False
test_index = 16'd34;
x = {
16'b0000010101100111,
16'b0000010110011100,
16'b0000011000110100,
16'b0000010101111011,
16'b0000010101111011,
16'b0000010111110110,
16'b0000011011101101,
16'b0000010111100010,
16'b0000010111001001,
16'b0000011000101100
};
#600;
reall[34] = 0;

pred [34] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 35 False
test_index = 16'd35;
x = {
16'b0000010111001001,
16'b0000010111111100,
16'b0000011000010110,
16'b0000010111110000,
16'b0000010111001001,
16'b0000010111011101,
16'b0000010111100011,
16'b0000011000001111,
16'b0000011000100010,
16'b0000010111010110
};
#600;
reall[35] = 0;

pred [35] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 36 True
test_index = 16'd36;
x = {
16'b0000010011101001,
16'b0000000101110111,
16'b0000001010000101,
16'b0000010110011100,
16'b0000010001000001,
16'b0000010101110101,
16'b0000010001111111,
16'b0000010011110011,
16'b0000010001110001,
16'b0000010100000001
};
#600;
reall[36] = 1;

pred [36] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 37 False
test_index = 16'd37;
x = {
16'b0000010011100001,
16'b0000010001111111,
16'b0000010001100010,
16'b0000010000011100,
16'b0000010000010111,
16'b0000010000100010,
16'b0000010001001011,
16'b0000010001110011,
16'b0000010010011100,
16'b0000010011010000
};
#600;
reall[37] = 0;

pred [37] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 38 True
test_index = 16'd38;
x = {
16'b0000001010110000,
16'b0000001010111100,
16'b0000011000010011,
16'b0000001001010110,
16'b0000010111010011,
16'b0000001010011010,
16'b0000010111001111,
16'b0000001011111100,
16'b0000010110001011,
16'b0000001011000111
};
#600;
reall[38] = 1;

pred [38] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 39 False
test_index = 16'd39;
x = {
16'b0000010011001010,
16'b0000010011001111,
16'b0000010010111011,
16'b0000010010100111,
16'b0000010010111011,
16'b0000010011100100,
16'b0000010010110001,
16'b0000010010101100,
16'b0000010010100111,
16'b0000010011000101
};
#600;
reall[39] = 0;

pred [39] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 40 False
test_index = 16'd40;
x = {
16'b0000011000111111,
16'b0000011000100110,
16'b0000011000000111,
16'b0000011001010010,
16'b0000011001001100,
16'b0000011000111111,
16'b0000011000011010,
16'b0000011001001100,
16'b0000011000111001,
16'b0000011000111111
};
#600;
reall[40] = 0;

pred [40] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 41 False
test_index = 16'd41;
x = {
16'b0000010110110000,
16'b0000010111101110,
16'b0000011000000011,
16'b0000010111101110,
16'b0000010101101011,
16'b0000011001000000,
16'b0000011010011010,
16'b0000011000011111,
16'b0000010100001000,
16'b0000010100001100
};
#600;
reall[41] = 0;

pred [41] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 42 False
test_index = 16'd42;
x = {
16'b0000010110110101,
16'b0000011000001111,
16'b0000011000011111,
16'b0000010101110011,
16'b0000010011100011,
16'b0000010110010100,
16'b0000011001001000,
16'b0000011001110101,
16'b0000010111010001,
16'b0000010111110010
};
#600;
reall[42] = 0;

pred [42] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 43 True
test_index = 16'd43;
x = {
16'b0000001011101101,
16'b0000011100111010,
16'b0000001011110001,
16'b0000011100100111,
16'b0000001011101001,
16'b0000011101000010,
16'b0000001011110001,
16'b0000001110001000,
16'b0000001110001100,
16'b0000010011101111
};
#600;
reall[43] = 1;

pred [43] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 44 False
test_index = 16'd44;
x = {
16'b0000010110001111,
16'b0000010110101110,
16'b0000010110110011,
16'b0000010110011001,
16'b0000010110100100,
16'b0000010110111001,
16'b0000010110001111,
16'b0000010110100100,
16'b0000010101111010,
16'b0000010101110100
};
#600;
reall[44] = 0;

pred [44] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 45 False
test_index = 16'd45;
x = {
16'b0000011101000010,
16'b0000011100100011,
16'b0000011101100101,
16'b0000011101011100,
16'b0000011100101100,
16'b0000011101110111,
16'b0000011100101100,
16'b0000011101001011,
16'b0000011100011110,
16'b0000011101000010
};
#600;
reall[45] = 0;

pred [45] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 46 False
test_index = 16'd46;
x = {
16'b0000011000000111,
16'b0000011000010110,
16'b0000011001011110,
16'b0000011010101010,
16'b0000011010100101,
16'b0000011001000100,
16'b0000011000011100,
16'b0000011001011001,
16'b0000011010011011,
16'b0000011010011011
};
#600;
reall[46] = 0;

pred [46] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 47 True
test_index = 16'd47;
x = {
16'b0000011111010110,
16'b0000011001001100,
16'b0000001011001011,
16'b0000001010000111,
16'b0000011101101000,
16'b0000011001100111,
16'b0000001100000100,
16'b0000001010110100,
16'b0000011110100101,
16'b0000011000100110
};
#600;
reall[47] = 1;

pred [47] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 48 False
test_index = 16'd48;
x = {
16'b0000010011010100,
16'b0000010011101000,
16'b0000010011001100,
16'b0000010010110001,
16'b0000010011000100,
16'b0000010011011100,
16'b0000010010100101,
16'b0000010010011010,
16'b0000010010111101,
16'b0000010010100101
};
#600;
reall[48] = 0;

pred [48] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 49 False
test_index = 16'd49;
x = {
16'b0000001101010101,
16'b0000001100010000,
16'b0000001010000010,
16'b0000001111010110,
16'b0000001111100111,
16'b0000010000011000,
16'b0000001001100110,
16'b0000010000011011,
16'b0000001000111100,
16'b0000010001010011
};
#600;
reall[49] = 0;

pred [49] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;
    
// Testcase 50 True
test_index = 16'd50;
x = {
16'b0000011100011011,
16'b0000001111100001,
16'b0000010111001000,
16'b0000001110101110,
16'b0000010010001101,
16'b0000001100000110,
16'b0000010101100000,
16'b0000001110100001,
16'b0000010011101100,
16'b0000001110011101
};
#600;
reall[50] = 1;

pred [50] = compare_sign_mag(y1, y2);
reset = 1;
x = 0;
// Wait for global reset to finish
#10;
reset = 0;


*/

        // // Initialize variables
        // sum = 0;
        // true = 0;

        // for (i = 0; i < max_data; i = i + 1) begin
        //     if (!(reall[i] === 1'bx || pred[i] === 1'bx)) begin
        //         $display("testcase: %d, real: %b, pred: %b", i, reall[i], pred[i]);
        //         sum = sum + 1;
        //         if (reall[i] == pred[i]) begin
        //             true = true + 1;
        //         end
        //     end
        // end

        // if (sum > 0) begin
        //     $display("accuracy = (%d / %d) = %.3f%%", true, sum, true * 100.0 / sum);
        // end else begin
        //     $display("No valid test cases to calculate accuracy.");
        // end
        #600;
        $display("testcase: %d, real: %b, pred: %b ------ y1_out: %b, y2_out: %b, in float: %f, %f", 0, reall[0], pred[0], y1, y2, b2f(y1), b2f(y2));
        $display("output per layer:");
        $display("  layer input         : %f, %f, %f, %f, %f, %f, %f, %f, %f, %f", b2f(x[159:144]), b2f(x[143:128]), b2f(x[127:112]), b2f(x[111:96]), b2f(x[95:80]), b2f(x[79:64]), b2f(x[63:48]), b2f(x[47:32]), b2f(x[31:16]), b2f(x[15:0]));
        $display("  layer intermediate  : %f, %f, %f, %f, %f, %f", b2f(out_intermediate[5]), b2f(out_intermediate[4]), b2f(out_intermediate[3]), b2f(out_intermediate[2]), b2f(out_intermediate[1]), b2f(out_intermediate[0]));
        $display("  layer zmean         : %f, %b", b2f(out_zmean), out_zmean);
        $display("  layer zvar          : %f, %b", b2f(out_zvar), out_zvar);
        $display("  layer sampling      : %f, %b", b2f(out_sampling), out_sampling);
        $display("  layer hidden class  : %f, %f, %f, %f, %f, %f", b2f(out_hidden_classifier[5]), b2f(out_hidden_classifier[4]), b2f(out_hidden_classifier[3]), b2f(out_hidden_classifier[2]), b2f(out_hidden_classifier[1]), b2f(out_hidden_classifier[0]));
        $display("  layer output        : %f, %f", b2f(y1), b2f(y2));
        


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
