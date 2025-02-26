`include "enc_1.v"

module tb_matrix_vector_mult;

    parameter BITSIZE = 16;
    parameter CLK_PERIOD = 10;

    // Testbench signals
    reg clk;
    reg reset;
    reg [BITSIZE*10*6-1:0] w; // Flattened 6x10 matrix
    reg [BITSIZE*10-1:0] x;   // Flattened 10-element vector
    reg [BITSIZE*6-1:0] b;    // Flattened bias vector
    wire [BITSIZE-1:0] out_stage [5:0]; // 6-element output
    wire [BITSIZE*6-1:0] y; 

    // Instantiate the DUT
    enc_1 #(
        .BITSIZE(BITSIZE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .w(w),
        .x(x),
        .b(b),
        .y(y)
    );

    assign out_stage[0] = y[BITSIZE*0 +: BITSIZE];
    assign out_stage[1] = y[BITSIZE*1 +: BITSIZE];
    assign out_stage[2] = y[BITSIZE*2 +: BITSIZE];
    assign out_stage[3] = y[BITSIZE*3 +: BITSIZE];
    assign out_stage[4] = y[BITSIZE*4 +: BITSIZE];
    assign out_stage[5] = y[BITSIZE*5 +: BITSIZE];

    // Clock generation
    initial begin
        clk = 0;
        forever begin
            #(CLK_PERIOD / 2);
            clk = ~clk;
        end
    end

    // Reset logic
    initial begin
        reset = 1;
        #(CLK_PERIOD);
        reset = 0;
    end

    // Test vector generation
    initial begin
        // Randomized inputs using the specified fixed-point values
        // w = generate_random_data(60); // 6x10 matrix = 60 values
        // w = 960'h080008000000000000000800080000000000040000000800000004000400040000000000000000000000000000000000000000000800080000000000000004000400040000000000000000000000000000000000000000000000000008000800000000000800080004000400080008000400040000000400;
        w = {
        16'b0000000011100011,
        16'b0000000011100111,
        16'b0000001011011001,
        16'b1000001000101111,
        16'b1000010010111011,
        16'b0000000001000111,
        16'b1000001011101100,
        16'b1000000011010011,
        16'b1000000110011100,
        16'b0000000101011000,
        16'b1000001101110100,
        16'b1000100000000011,
        16'b0000011010001110,
        16'b1000010011000010,
        16'b1000000101100111,
        16'b0000001111100111,
        16'b1000001011111000,
        16'b0000101011100101,
        16'b1000010110010011,
        16'b0000100010100101,
        16'b0000001100001000,
        16'b1000001010100101,
        16'b1000001010110010,
        16'b0000110011101111,
        16'b0000001110010011,
        16'b1000011001100110,
        16'b1000000011001101,
        16'b1000001000110110,
        16'b1000001000100100,
        16'b1000001101001001,
        16'b1000011110011100,
        16'b0000010101010000,
        16'b1000000010000110,
        16'b1000010110000001,
        16'b0000000100010100,
        16'b1000001010110000,
        16'b0000010111100110,
        16'b1000001111000011,
        16'b1000000101000011,
        16'b0000001101010010,
        16'b0000000000101000,
        16'b0000101011010100,
        16'b1000001110111100,
        16'b0000001010000110,
        16'b1000001110110001,
        16'b1000010000111001,
        16'b1000000000010011,
        16'b1000000000000111,
        16'b0000011000110101,
        16'b1000001001111001,
        16'b1000000010111100,
        16'b0000000010001000,
        16'b0000001010101001,
        16'b0000101101000110,
        16'b1000000110100110,
        16'b0000001000111010,
        16'b1000001111000100,
        16'b1000000110011101,
        16'b1000010010001000,
        16'b1000000101010111
        };
        // x = generate_random_data(10); // 10-element vector
        // x = 160'h0000080008000800080004000400000000000000;
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


        // b = generate_random_data(6);  // 6-element bias vector
        // b = 96'h040004000000040004000800;
        // b = 0;
        b = {
        16'b1000000100110001,
        16'b1000000100101101,
        16'b1000000011010000,
        16'b1000000011011000,
        16'b0000000000000000,
        16'b0000010000010100
        };

        // Simulation runtime
        #(CLK_PERIOD * (12+1) + 5); // Run for 20 clock cycles
        $finish;
    end

    // Function to generate randomized fixed-point data
    function [BITSIZE*60-1:0] generate_random_data;
        input integer num_elements;
        reg [BITSIZE-1:0] rand_val;
        integer i;
        begin
            generate_random_data = 0;
            for (i = 0; i < num_elements; i = i + 1) begin
                case ($random % 3)
                    0: rand_val = 16'h0000; // 0
                    1: rand_val = 16'h0400; // 0.5
                    2: rand_val = 16'h0800; // 1
                endcase
                // $display("%2d, %d", i, ((rand_val == 16'h0000) ? 0 :
                //                         (rand_val == 16'h0400) ? 2 :
                //                         (rand_val == 16'h0800) ? 1 : -1));
                generate_random_data = (generate_random_data << BITSIZE) | rand_val;
            end
        end
    endfunction

    // Monitor outputs
    initial begin
        $display("Time\t Reset\t out_stage[0]\t out_stage[1]\t out_stage[2]\t out_stage[3]\t out_stage[4]\t out_stage[5]");
        #(CLK_PERIOD/2);
        forever begin
            $display("%0t\t\t %b\t\t %b\t\t\t %b\t\t\t %b\t\t\t %b\t\t\t %b\t\t\t %b\t\t\t",
                     $time, reset, out_stage[0], out_stage[1], out_stage[2], out_stage[3], out_stage[4], out_stage[5]);
            #CLK_PERIOD;
        end
    end

endmodule
