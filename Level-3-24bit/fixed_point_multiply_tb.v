`timescale 1ns / 1ps
`include "fixed_point_multiply.v"

module fixed_point_multiply_tb;

    // Parameters
    parameter BITSIZE = 24;

    // Inputs
    reg [BITSIZE-1:0] A;
    reg [BITSIZE-1:0] B;

    // Outputs
    wire [BITSIZE-1:0] C;

    // Instantiate the Unit Under Test (UUT)
    fixed_point_multiply #(BITSIZE) uut (
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
        // Normal multiplication
        A = 24'b0_0000_0100_000000000000000; // 0.5 in one's complement
        B = 24'b0_0000_0100_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 24'b0_0000_0000_100000000000000; // 0.5 in one's complement
        B = 24'b0_0000_0000_100000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 24'b1_0000_0000_010000000000000; // 0.5 in one's complement
        B = 24'b0_0000_0000_010000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 24'b1_0000_0000_010000000000000; // 0.5 in one's complement
        B = 24'b0_0000_0100_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        // Normal multiplication
        A = 24'b0_1000_0000_000000000000000; // 0.5 in one's complement
        B = 24'b0_0000_0100_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        A = 24'b1_0000_0100000000000000000; // 0.5 in one's complement
        B = 24'b0_1000_0000000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        A = 24'b1_0000_0000000000000000001; // 0.5 in one's complement
        B = 24'b0_1000_0000000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 24'b1_0000_0000_000000000000001; // 0.5 in one's complement
        B = 24'b0_0001_0000_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 24'b1_0000_0000_000000000000001; // 0.5 in one's complement
        B = 24'b0_0000_0100_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 24'b1_0000_0000_000000000000001; // 0.5 in one's complement
        B = 24'b0_0000_0000_000000000000001; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Enol", A, B, C);

        // Overflow case
        A = 24'h7FFFFF; // Maximum positive value
        B = 24'h100000;
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Underflow case
        A = 24'hFFFFFF; // Maximum negative value
        B = 24'h400000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Mixed sign multiplication
        A = 24'h400000; // 0.5 in one's complement
        B = 24'hC00000; // -0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Both negative multiplication
        A = 24'hC00000; // -0.5 in one's complement
        B = 24'hC00000; // -0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // End simulation
        $finish;
    end

endmodule
