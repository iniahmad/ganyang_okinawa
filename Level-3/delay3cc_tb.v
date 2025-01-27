`include "delay3cc.v"

module tb_delay_3_cycle;

    // Declare inputs and outputs for the testbench
    reg clk;                             // Clock signal
    reg [15:0] in_data;                  // Input data (16-bit)
    wire [15:0] out_data;                // Output data (16-bit)

    // Instantiate the delay_3_cycle module
    delay_3_cycle uut (
        .clk(clk),
        .in_data(in_data),
        .out_data(out_data)
    );

    // Clock generation (period = 10ns for 100MHz clock)
    always begin
        #5 clk = ~clk;  // Toggle clock every 5ns (100MHz)
    end

    // Stimulus generation
    initial begin
        // Initialize signals
        clk = 0;
        in_data = 16'b0;

        // Apply test vectors
        #10 in_data = 16'b0000000000000001;  // Apply input 1
        #10 in_data = 16'b0000000000000010;  // Apply input 2
        #10 in_data = 16'b0000000000000100;  // Apply input 4
        #10 in_data = 16'b0000000000001000;  // Apply input 8
        #10 in_data = 16'b0000000000010000;  // Apply input 16

        // Wait for a few clock cycles to observe the output
        #30;

        // End the simulation
        $finish;
    end

    // Monitor output
    initial begin
        $monitor("At time %t, in_data = %h, out_data = %h", $time, in_data, out_data);
    end

endmodule
