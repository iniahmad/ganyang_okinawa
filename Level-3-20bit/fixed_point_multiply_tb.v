`timescale 1ns / 1ps
`include "fixed_point_multiply.v"

module fixed_point_multiply_tb;

    // Parameters
    parameter BITSIZE = 20;

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
        A = 20'b0_0000_010000000000000; // 0.5 in one's complement
        B = 20'b0_0000_010000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        // Normal multiplication
        A = 20'b0_1000_000000000000000; // 0.5 in one's complement
        B = 20'b0_0000_010000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 20'b1_0000_010000000000000; // 0.5 in one's complement
        B = 20'b0_1000_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 20'b1_0000_000000000000001; // 0.5 in one's complement
        B = 20'b0_1000_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 20'b1_0000_000000000000001; // 0.5 in one's complement
        B = 20'b0_0001_000000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 20'b1_0000_000000000000001; // 0.5 in one's complement
        B = 20'b0_0000_010000000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        // Overflow case
        A = 20'h7FFFF; // Maximum positive value
        B = 20'h10000;
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Underflow case
        A = 20'hFFFFF; // Maximum negative value
        B = 20'h40000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Mixed sign multiplication
        A = 20'h40000; // 0.5 in one's complement
        B = 20'hC0000; // -0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Both negative multiplication
        A = 20'hC0000; // -0.5 in one's complement
        B = 20'hC0000; // -0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // End simulation
        $finish;
    end

endmodule
