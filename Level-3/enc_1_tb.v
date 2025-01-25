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

    assign out_stage[0] = y [BITSIZE*0 +: BITSIZE];
    assign out_stage[1] = y [BITSIZE*1 +: BITSIZE];
    assign out_stage[2] = y [BITSIZE*2 +: BITSIZE];
    assign out_stage[3] = y [BITSIZE*3 +: BITSIZE];
    assign out_stage[4] = y [BITSIZE*4 +: BITSIZE];
    assign out_stage[5] = y [BITSIZE*5 +: BITSIZE];

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
        w = 960'h080008000000000000000800080000000000040000000800000004000400040000000000000000000000000000000000000000000800080000000000000004000400040000000000000000000000000000000000000000000000000008000800000000000800080004000400080008000400040000000400;

        // x = generate_random_data(10); // 10-element vector
        x = 160'h0000080008000800080004000400000000000000;

        // b = generate_random_data(6);  // 6-element bias vector
        b = 96'h040004000000040004000800;
        // b = 0;

        // Simulation runtime
        #(CLK_PERIOD * (10+1) + 5); // Run for 20 clock cycles
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
            $display("%0t\t\t %b\t\t %h\t\t\t %h\t\t\t %h\t\t\t %h\t\t\t %h\t\t\t %h\t\t\t",
                     $time, reset, out_stage[0], out_stage[1], out_stage[2], out_stage[3], out_stage[4], out_stage[5]);
            #CLK_PERIOD;
        end
    end

endmodule
