`timescale 1ns / 1ps
`include "sampling.v"                 // Random generator module

module sampling_VAE_tb;

    // Parameters
    parameter N_input = 2;
    parameter M_output = 2;
    parameter BITSIZE = 16;

    // Testbench signals
    reg clk;
    reg rst;
    reg [N_input*BITSIZE-1:0] ac;
    reg [N_input*BITSIZE-1:0] ad;
    wire [M_output*BITSIZE-1:0] a;
    wire [N_input*BITSIZE-1:0] epsilon;

    // Instantiate the sampling_VAE module
    sampling_VAE #(
        .N_input(N_input),
        .M_output(M_output),
        .BITSIZE(BITSIZE)
    ) uut (
        .clk(clk),
        .rst(rst),
        .ac(ac),
        .ad(ad),
        .a(a),
        .epsilon(epsilon)
    );

    // Clock generation: 10 ns period -> 100 MHz
    always begin
        #5 clk = ~clk;
    end

    // Stimulus generation
    initial begin

    $dumpfile("sampling_tb.vcd");
    $dumpvars(0, sampling_VAE_tb);

        // Initialize signals
        clk = 0;
        rst = 0;
        ac = 0;
        ad = 0;

        #10;
        rst = 1;

        // Apply reset
        #20;
        rst = 0;

        // Apply some input values for ac (mean) and ad (variance)
        ac =
        {
            16'b0001101101110000, // ac2 = 3.43 (MSB)
            16'b0010110100110011  // ac1 = 5.65 (LSB)
        };
        ad =
        {
            16'b0000011100001010, // ad2 = 0.88 (MSB)
            16'b0001000100001010  // ad1 = 2.13 (LSB)
        };

        // Run for some time to observe the outputs
        #200;

        // Change inputs to observe different behavior
        ac =
        {
            16'b0001011100001010, // ac2 = 2.88 (MSB)
            16'b0000100111010111  // ac1 = 1.23 (LSB)
        };
        ad =
        {
            16'b0010101010100011, // ad2 = 5.33 (MSB)
            16'b0011011111101011  // ad1 = 6.99 (LSB)
        };

        #200;

        // Finish simulation
        $finish;
    end

    // Monitor outputs
    initial begin
        $monitor(
        "Time = %0t | ac = %b %b | ad = %b %b | a[0] = %b | a[1] = %b | epsilon = %b",
        $time, 
        ac[15:0], ac[31:16],          // Display `ac` as ac[0] and ac[1]
        ad[15:0], ad[31:16],          // Display `ad` as ad[0] and ad[1]
        a[15:0], a[31:16],            // Display `a` as a[0] and a[1]
        epsilon[15:0]                 // Display `epsilon`
    );
    end

endmodule
