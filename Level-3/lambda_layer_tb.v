`include "lambda_layer.v"
`timescale 1ns/1ps

module lambda_layer_tb;

    // Parameters
    localparam CLK_PERIOD = 10; // Clock period in nanoseconds

    // Inputs
    reg clk;
    reg reset;
    reg [15:0] mean;
    reg [15:0] var;

    // Outputs
    wire [15:0] lambda_out;

    // Instantiate the DUT (Device Under Test)
    lambda_layer dut (
        .clk(clk),
        .reset(reset),
        .mean(mean),
        .var(var),
        .lambda_out(lambda_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Testbench variables
    integer i;

    // Stimulus process
    initial begin
        // Initialize inputs
        reset = 1;
        mean = 16'd0;
        var = 16'd0;

        // Wait for a few clock cycles
        #(CLK_PERIOD * 5);

        // Release reset
        reset = 0;

        // Apply test vectors
        for (i = 0; i < 5; i = i + 1) begin
            mean = $random % 65536; // Random 16-bit mean
            var = $random % 65536; // Random 16-bit variance
            #(CLK_PERIOD * 10); // Wait for some cycles
        end

        // Apply edge cases
        mean = 16'd0;   // Test with mean = 0
        var = 16'd0;    // Test with var = 0
        #(CLK_PERIOD * 10);

        mean = 16'd65535; // Test with maximum mean
        var = 16'd65535;  // Test with maximum var
        #(CLK_PERIOD * 10);

        // Finish simulation
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor($time, " clk=%b, reset=%b, mean=%d, var=%d, lambda_out=%d",
                 clk, reset, mean, var, lambda_out);
    end

endmodule
