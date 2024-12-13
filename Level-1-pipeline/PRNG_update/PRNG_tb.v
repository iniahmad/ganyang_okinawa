`include "PRNG.v"

module unique_output_counter(
    input wire clk,               // Clock signal
    input wire reset,             // Reset signal
    input wire [15:0] output_val, // 16-bit output value
    output reg [31:0] count_0,    // Count for output_val == unique_val_0
    output reg [31:0] count_1,    // Count for output_val == unique_val_1
    output reg [31:0] count_2,    // Count for output_val == unique_val_2
    output reg [31:0] count_3,    // Count for output_val == unique_val_3
    output reg [31:0] count_4,    // Count for output_val == unique_val_4
    output reg [31:0] count_5,    // Count for output_val == unique_val_5
    output reg [31:0] count_6,    // Count for output_val == unique_val_6
    output reg [31:0] count_7,    // Count for output_val == unique_val_7
    output reg [31:0] count_8,    // Count for output_val == unique_val_8
    output reg [31:0] count_9     // Count for output_val == unique_val_9
);
    // Define the 9 unique possible values for `output_val`
    localparam [15:0] UNIQUE_VAL_0 = 16'b0000000000000000,
                      UNIQUE_VAL_1 = 16'b0000000011100011,
                      UNIQUE_VAL_2 = 16'b0000000111000111,
                      UNIQUE_VAL_3 = 16'b0000001010101010,
                      UNIQUE_VAL_4 = 16'b0000001110001110,
                      UNIQUE_VAL_5 = 16'b0000010001110001,
                      UNIQUE_VAL_6 = 16'b0000010101010101,
                      UNIQUE_VAL_7 = 16'b0000011000111000,
                      UNIQUE_VAL_8 = 16'b0000011100011100,
                      UNIQUE_VAL_9 = 16'b0000100000000000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all counts to zero
            count_0 <= 0;
            count_1 <= 0;
            count_2 <= 0;
            count_3 <= 0;
            count_4 <= 0;
            count_5 <= 0;
            count_6 <= 0;
            count_7 <= 0;
            count_8 <= 0;
            count_9 <= 0;
        end else begin
            // Increment the appropriate counter based on output_val
            case (output_val)
                UNIQUE_VAL_0: count_0 <= count_0 + 1;
                UNIQUE_VAL_1: count_1 <= count_1 + 1;
                UNIQUE_VAL_2: count_2 <= count_2 + 1;
                UNIQUE_VAL_3: count_3 <= count_3 + 1;
                UNIQUE_VAL_4: count_4 <= count_4 + 1;
                UNIQUE_VAL_5: count_5 <= count_5 + 1;
                UNIQUE_VAL_6: count_6 <= count_6 + 1;
                UNIQUE_VAL_7: count_7 <= count_7 + 1;
                UNIQUE_VAL_8: count_8 <= count_8 + 1;
                UNIQUE_VAL_9: count_9 <= count_9 + 1;
                default: ; // Ignore other values
            endcase
        end
    end
endmodule



module PRNG_tb;
    reg [4:0] seed = 5'b01001;
    reg clk;
    reg reset;
    wire [15:0] output_val;
    wire [31:0] count_0, count_1, count_2, count_3, count_4, count_5, count_6, count_7, count_8, count_9;

    // Instantiate the module
    unique_output_counter uut (
        .clk(clk),
        .reset(reset),
        .output_val(output_val),
        .count_0(count_0),
        .count_1(count_1),
        .count_2(count_2),
        .count_3(count_3),
        .count_4(count_4),
        .count_5(count_5),
        .count_6(count_6),
        .count_7(count_7),
        .count_8(count_8),
        .count_9(count_9)
    );

    PRNG uut2 (
        .clk(clk),
        .rst(reset),          // Reset signal
        .seed(seed),  // -> 4 hex, 15 11 7 3
        .random_out(output_val) // Random number output
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 0;
        #10 reset = 1;
        #10 reset = 0;
        #320
        // // Stimulus: Provide some outputs
        // output_val = 16'h0001; #10; // Increment count_0
        // output_val = 16'h0001; #10; // Increment count_0 again
        // output_val = 16'h0002; #10; // Increment count_1
        // output_val = 16'h0004; #10; // Increment count_2
        // output_val = 16'h0008; #10; // Increment count_3
        // output_val = 16'h0001; #10; // Increment count_0 again
        // output_val = 16'h0010; #10; // Increment count_4
        // output_val = 16'h0100; #10; // Increment count_8
        // output_val = 16'h0008; #10; // Increment count_3 again

        // Print the results
        $display("Counts:");
        $display("Value 0 (%d): %d", 16'b0000000000000000, count_0);
        $display("Value 1 (%d): %d", 16'b0000000011100011, count_1);
        $display("Value 2 (%d): %d", 16'b0000000111000111, count_2);
        $display("Value 3 (%d): %d", 16'b0000001010101010, count_3);
        $display("Value 4 (%d): %d", 16'b0000001110001110, count_4);
        $display("Value 5 (%d): %d", 16'b0000010001110001, count_5);
        $display("Value 6 (%d): %d", 16'b0000010101010101, count_6);
        $display("Value 7 (%d): %d", 16'b0000011000111000, count_7);
        $display("Value 8 (%d): %d", 16'b0000011100011100, count_8);
        $display("Value 9 (%d): %d", 16'b0000100000000000, count_9);

        $finish; // End simulation
    end
endmodule
