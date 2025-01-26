`include "enc_2.v"

module tb_matrix_vector_mult;

    parameter BITSIZE = 16;
    parameter CLK_PERIOD = 10;

    // Testbench signals
    reg clk;
    reg reset;
    reg [BITSIZE*1*6-1:0] w; // Flattened 1x6 matrix
    reg [BITSIZE*6-1:0] x;   // Flattened 6-element vector
    reg [BITSIZE*1-1:0] b;    // Flattened bias vector
    wire [BITSIZE-1:0] out_stage; // 1-element output
    wire [BITSIZE*1-1:0] y; 

    // Instantiate the DUT
    enc_2 #(
        .BITSIZE(BITSIZE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .w(w),
        .x(x),
        .b(b),
        .y(y)
    );

    assign out_stage = y;

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
        // w = generate_random_data(6); // 1x6 matrix = 6 values
        w = 96'100008001000080010000800;

        // x = generate_random_data(6); // 6-element vector
        x = 96'080010000800100008001000;

        // b = generate_random_data(1);  // 1-element bias vector
        b = 16'0400;
        // b = 0;

        // Simulation runtime
        #(CLK_PERIOD * (6+1) + 5); // Run for 20 clock cycles
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
        $display("Time\t Reset\t out_stage\t");
        #(CLK_PERIOD/2);
        forever begin
            $display("%0t\t\t %b\t\t %h\t\t\t",
                     $time, reset, out_stage);
            #CLK_PERIOD;
        end
    end

endmodule
