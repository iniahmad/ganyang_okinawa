`include "fixed_point_add.v"

module fixed_point_add_tb;
    // Parameter for BITSIZE
    parameter BITSIZE = 16;

    // Testbench signals
    reg [BITSIZE-1:0] A;
    reg [BITSIZE-1:0] B;
    wire [BITSIZE-1:0] C;

    // Instantiate the module under test
    fixed_point_add #(BITSIZE) uut (
        .A(A),
        .B(B),
        .C(C)
    );

    // Testbench logic
    initial begin
        $display("Starting Testbench");

        // Test case 1: Add two positive numbers
        A = 16'b0_000000010000000; // +0.5 in sign-magnitude
        B = 16'b0_000000010000000; // +0.5 in sign-magnitude
        #10;
        $display("Test 1: A=%b, B=%b, C=%b", A, B, C);

        // Test case 2: Add a positive and a negative number
        A = 16'b0_000000100000000; // +1.0 in sign-magnitude
        B = 16'b1_000000010000000; // -0.5 in sign-magnitude
        #10;
        $display("Test 2: A=%b, B=%b, C=%b", A, B, C);

        // Test case 3: Add two negative numbers
        A = 16'b1_000000010000000; // -0.5 in sign-magnitude
        B = 16'b1_000000010000000; // -0.5 in sign-magnitude
        #10;
        $display("Test 3: A=%b, B=%b, C=%b", A, B, C);

        // Test case 4: Add a number with zero
        A = 16'b0_000000010000000; // +0.5 in sign-magnitude
        B = 16'b0_000000000000000; // 0 in sign-magnitude
        #10;
        $display("Test 4: A=%b, B=%b, C=%b", A, B, C);

        // Test case 5: Add zero with zero
        A = 16'b0_000000000000000; // 0 in sign-magnitude
        B = 16'b0_000000000000000; // 0 in sign-magnitude
        #10;
        $display("Test 5: A=%b, B=%b, C=%b", A, B, C);

        // End simulation
        $stop;
    end
endmodule
