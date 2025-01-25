`timescale 1ns / 1ps
// `include "fixed_point_multiply.v"

module fixed_point_multiply_tb;
    
    // Parameters
    parameter BITSIZE = 16;
    parameter FRAC = 11;
    
    // Inputs
    reg clk;
    reg rst;
    reg [BITSIZE-1:0] A;
    reg [BITSIZE-1:0] B;

    // Outputs
    wire [BITSIZE-1:0] C;

    // Instantiate the Unit Under Test (UUT)
    fixed_point_multiply #(BITSIZE, FRAC) uut (
        .clk(clk),
        .rst(rst),
        .A(A),
        .B(B),
        .C(C)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    initial begin
        // Initialize inputs
        A = 0;
        B = 0;
        rst = 1;

        // Wait for global reset
        #15;
        rst = 0;
        
        // Test cases
        // Normal multiplication
        A = 16'b0_0000_10000000000; // 0.5 in one's complement
        B = 16'b0_0000_10000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        // Normal multiplication
        A = 16'b0_1000_00000000000; // 0.5 in one's complement
        B = 16'b0_0000_10000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 16'b1_0000_10000000000; // 0.5 in one's complement
        B = 16'b0_1000_00000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 16'b1_0000_00000000001; // 0.5 in one's complement
        B = 16'b0_1000_00000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 16'b1_0000_00000000001; // 0.5 in one's complement
        B = 16'b0_0001_00000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        A = 16'b1_0000_00000000001; // 0.5 in one's complement
        B = 16'b0_0000_10000000000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Normal", A, B, C);

        // Overflow case
        A = 16'h7FFF; // Maximum positive value
        B = 16'h1000;
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Underflow case
        A = 16'hFFFF; // Maximum negative value
        B = 16'h4000; // 0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Mixed sign multiplication
        A = 16'h4000; // 0.5 in one's complement
        B = 16'hC000; // -0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // Both negative multiplication
        A = 16'hC000; // -0.5 in one's complement
        B = 16'hC000; // -0.5 in one's complement
        #10;
        $display("A = %b, B = %b, C = %b Overflow", A, B, C);

        // End simulation
        $finish;
    end

endmodule
