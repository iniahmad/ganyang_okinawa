`include "enc_4.v"

module tb_matrix_vector_mult;

    parameter BITSIZE = 16;
    parameter CLK_PERIOD = 10;

    // Testbench signals
    reg clk;
    reg reset;
    reg  [BITSIZE*2*6-1:0]  w; // Flattened 6x10 matrix
    reg  [BITSIZE*6-1:0]    x;   // Flattened 10-element vector
    reg  [BITSIZE*2-1:0]    b;    // Flattened bias vector
    wire [BITSIZE-1:0] out_stage [1:0]; // 6-element output
    wire [BITSIZE*2-1:0]    y; 

    // Instantiate the DUT
    enc_4 #(
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
        w = 192'h100010001000100010001000100010001000100010001000;

        // x = generate_random_data(10); // 10-element vector
        x = 96'h080008000800080008000800;

        // b = generate_random_data(6);  // 6-element bias vector
        b = 32'h04000400;
        // b = 0;

        // Simulation runtime
        // #(CLK_PERIOD * (2));
        // $finish;
        #(CLK_PERIOD * (10+1) + 5); // Run for 20 clock cycles
        $finish;
    end

    // Monitor outputs
    initial begin
        $display("Time\t Reset\t out_stage[0]\t out_stage[1]");
        #(CLK_PERIOD/2);
        forever begin
            $display("%0t\t\t %b\t\t %h\t\t\t %h",
                     $time, reset, out_stage[0], out_stage[1]);
            #CLK_PERIOD;
        end
    end

endmodule
