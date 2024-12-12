`include "../RTL/fixed_point_multiply.v"

module fixed_point_multiply_tb;
    reg signed [31:0] A, B;  // 32-bit signed inputs
    wire signed [31:0] C;    // 32-bit signed output

    // Instantiate the multiplier module
    fixed_point_multiply uut (
        .A(A),
        .B(B),
        .C(C)
    );

    initial begin
        // Test case 1: A = 0.5, B = 0.5
        A = 32'b00000100000000000000000000000000;  // 0.5 in fixed-point format
        B = 32'b00000100000000000000000000000000;  // 0.5 in fixed-point format
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // Test case 2: A = -0.5, B = 0.5
        A = 32'b11111000000000000000000000000000;  // -0.5 in fixed-point format
        B = 32'b00000100000000000000000000000000;  // 0.5 in fixed-point format
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // Test case 3: A = 2.0, B = 0.25
        A = 32'b00010000000000000000000000000000;  // 2.0 in fixed-point format
        B = 32'b00000100000000000000000000000000;  // 0.25 in fixed-point format
        #10;
        $display("A = %b, B = %b, C = %b", A, B, C);

        // $stop;
        $finish;
    end
endmodule
