`timescale 1ns / 1ps
`include "fixed_point_add.v"

module fixed_point_add_tb;

    // Parameters
    parameter BITSIZE = 24;

    // Inputs
    reg [BITSIZE-1:0] A;
    reg [BITSIZE-1:0] B;

    // Outputs
    wire [BITSIZE-1:0] C;

    // Instantiate the Unit Under Test (UUT)
    fixed_point_add #(BITSIZE) uut (
        .A(A), 
        .B(B), 
        .C(C)
    );

    initial begin
        // Initialize inputs
        A = 0;
        B = 0;

        // Wait for global reset
        #100;
        
        // Test cases
        // Normal addition
        A = 24'h100000; // Small positive number
        B = 24'h100000; // Small positive number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // Overflow case
        A = 24'h7FFFFF; // Maximum positive value
        B = 24'h100000; // Small positive number
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        A = 24'h7FFFFF; // Maximum positive value
        B = 24'h000001; // Small positive number
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Subtraction resulting in negative
        A = 24'h200000; // Positive number
        B = 24'h600000; // Larger positive number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // Mixed sign addition
        A = 24'h400000; // Positive number
        B = 24'hC00000; // Negative number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // Both negative addition
        A = 24'hC00000; // Negative number
        B = 24'hC00000; // Negative number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        A = 24'b1_0000_1000_000000000000000; // 0.5 in one's complement
        B = 24'b0_0000_1000_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 24'b1_0000_0100_000000000000000; // 0.5 in one's complement
        B = 24'b0_0000_1000_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 24'b1_0000_1000_000000000000000; // 0.5 in one's complement
        B = 24'b0_0000_0100_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        // End simulation
        $finish;
    end

endmodule