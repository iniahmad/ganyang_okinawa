`include "encoder_fixed_point_sequential.v"

module encoder_fixed_point_tb_sequential;
    // Parameters
    parameter N_input = 9;
    parameter M_output = 4;
    parameter BITSIZE = 32; // Fixed-point format: 1-bit sign, 4-bit exponent, 27-bit mantissa

    // Testbench signals
    reg clk;
    reg reset;
    reg signed [N_input * BITSIZE - 1:0] x;          // Input data
    reg signed [N_input * M_output * BITSIZE - 1:0] w; // Weights
    reg signed [M_output * BITSIZE - 1:0] b;         // Bias
    wire signed [M_output * BITSIZE - 1:0] out;      // Output data

    // Instantiate the DUT
    encoder_fixed_point_sequential #(
        .N_input(N_input),
        .M_output(M_output),
        .BITSIZE(BITSIZE)
    ) dut (
        .clk(clk),
        .reset(reset),
        .x(x),
        .w(w),
        .b(b),
        .out(out)
    );
    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time unit clock cycle period
    end

    // Reset Periodik
    initial begin
        reset = 0; // Initially reset is low
        forever begin
            #50 reset = 0; // Reset bernilai LOW untuk 50 time unit
            #50 reset = 1; // Reset bernilai HIGH untuk 50 time unit
        end
    end

    // Simulation control
    initial begin
        $dumpfile("encoder_fixed_point_tb_sequential.vcd");
        $dumpvars(0, encoder_fixed_point_tb_sequential);

        // Test case: Simple inputs
        x = {9{32'b0_0001_100000000000000000000000000}};  // x = 1.5
        w = {36{32'b0_0001_000000000000000000000000000}}; // w = 1.0
        b = {4{32'b0_0001_000000000000000000000000000}};  // b = 1.0
        #50;
        
        // Wait for simulation
        #1000;
        
        $finish;
    end

    integer i;
    initial begin
        $dumpfile("encoder_fixed_point_tb_sequential.vcd");
        $dumpvars(0, encoder_fixed_point_tb_sequential);
        #50
        for (i = 0; i < M_output; i = i + 1) begin
            #10;
        end      
    end

endmodule
