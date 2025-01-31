`timescale 1ns / 1ps
`include "fixed_point_add.v"

module fixed_point_add_tb;

    // Parameters
    parameter BITSIZE = 20;

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
        A = 20'h10000; // Small positive number
        B = 20'h10000; // Small positive number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // Overflow case
        A = 20'h7FFFF; // Maximum positive value
        B = 20'h10000; // Small positive number
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        A = 20'h7FFFF; // Maximum positive value
        B = 20'h00001; // Small positive number
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Subtraction resulting in negative
        A = 20'h20000; // Positive number
        B = 20'h60000; // Larger positive number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // Mixed sign addition
        A = 20'h40000; // Positive number
        B = 20'hC0000; // Negative number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // Both negative addition
        A = 20'hC0000; // Negative number
        B = 20'hC0000; // Negative number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        A = 20'b1_1000_000000000000000; // 0.5 in one's complement
        B = 20'b0_1000_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 20'b1_0100_000000000000000; // 0.5 in one's complement
        B = 20'b0_1000_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 20'b1_1000_000000000000000; // 0.5 in one's complement
        B = 20'b0_0100_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        // End simulation
        $finish;
    end

endmodule