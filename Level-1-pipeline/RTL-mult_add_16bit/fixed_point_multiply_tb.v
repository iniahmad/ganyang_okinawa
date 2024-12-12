`include "fixed_point_multiply.v"

module fixed_point_multiply_tb;
    // Parameter for BITSIZE
    parameter BITSIZE = 16;

    // Testbench signals
    reg [BITSIZE-1:0] A;
    reg [BITSIZE-1:0] B;
    wire [BITSIZE-1:0] C;

    // Instantiate the module under test
    fixed_point_multiply #(BITSIZE) uut (
        .A(A),
        .B(B),
        .C(C)
    );

    // Testbench logic
    initial begin
        // Test case 1: Multiply two positive numbers
        A = 16'b0_000000100000000; // +0.5 in sign-magnitude
        B = 16'b0_000000100000000; // +0.5 in sign-magnitude
        #10;
        $display("Test 1: A=%b, B=%b, C=%b", A, B, C);

        // Test case 2: Multiply a positive and a negative number
        A = 16'b0_100000100000000; // +0.5 in sign-magnitude
        B = 16'b1_000000100000000; // -0.5 in sign-magnitude
        #10;
        $display("Test 2: A=%b, B=%b, C=%b", A, B, C);

        // Test case 3: Multiply two negative numbers
        A = 16'b1_100000100000000; // -0.5 in sign-magnitude
        B = 16'b1_000000100000000; // -0.5 in sign-magnitude
        #10;
        $display("Test 3: A=%b, B=%b, C=%b", A, B, C);

        // Test case 4: Multiply a number with zero
        A = 16'b0_000000000000000; // 0 in sign-magnitude
        B = 16'b0_000000100000000; // +0.5 in sign-magnitude
        #10;
        $display("Test 4: A=%b, B=%b, C=%b", A, B, C);

        // Test case 5: Multiply zero with zero
        A = 16'b0_000000000000000; // 0 in sign-magnitude
        B = 16'b0_000000000000000; // 0 in sign-magnitude
        #10;
        $display("Test 5: A=%b, B=%b, C=%b", A, B, C);

        // End simulation
        $finish;
    end

    // $finish;
endmodule