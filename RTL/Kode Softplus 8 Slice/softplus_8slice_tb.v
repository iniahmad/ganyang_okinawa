`include "softplus_8slice.v"

module softplus_8slice_tb;
    // Input
    reg signed [31:0] in;

    // Output
    wire signed [31:0] out;

    softplus_8slice test (
        .data_in (in),
        .data_out(out)
    );

initial begin
    $dumpfile("softplus_8slice_tb.vcd");
    $dumpvars(0, softplus_8slice_tb);

    // Test inuts
    in = 32'b10100000000000000000000000000000;   // -4
    #10;
    in = 32'b10011000000000000000000000000000;   // -3
    #10;
    in = 32'b10010000000000000000000000000000;   // -2
    #10;
    in = 32'b10001000000000000000000000000000;   // -1
    #10;
    in = 32'b00000000000000000000000000000000;   // 0
    #10;
    in = 32'b00001000000000000000000000000000;   // 1
    #10;
    in = 32'b00010000000000000000000000000000;   // 2
    #10;
    in = 32'b00011000000000000000000000000000;   // 3
    #10;
    in = 32'b00100000000000000000000000000000;   // 4
    #10;
    
    $finish;
end

endmodule
