`timescale 1ns / 1ps
`include "fixed_point_add.v"

module fixed_point_add_tb;

    // Parameters
    parameter BITSIZE = 16;

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
        A = 16'h1000; // Small positive number
        B = 16'h1000; // Small positive number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // Overflow case
        A = 16'h7FFF; // Maximum positive value
        B = 16'h1000; // Small positive number
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Subtraction resulting in negative
        A = 16'h2000; // Positive number
        B = 16'h6000; // Larger positive number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // Mixed sign addition
        A = 16'h4000; // Positive number
        B = 16'hC000; // Negative number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // Both negative addition
        A = 16'hC000; // Negative number
        B = 16'hC000; // Negative number
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        A = 16'b1_1000_00000000000; // 0.5 in one's complement
        B = 16'b0_1000_00000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 16'b1_0100_00000000000; // 0.5 in one's complement
        B = 16'b0_1000_00000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 16'b1_1000_00000000000; // 0.5 in one's complement
        B = 16'b0_0100_00000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        // End simulation
        $finish;
    end

endmodule
