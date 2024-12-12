`include "decoder_fixed_point.v"

module decoder_fixed_point_tb;

    // Parameters
    parameter N_input = 2;       // Jumlah input
    parameter M_output = 9;      // Jumlah output
    parameter BITSIZE = 32;      // Fixed Point 32-bit

    // Ports for decoder module
    reg signed [N_input*BITSIZE-1:0] z;          // Input
    reg signed [N_input*M_output*BITSIZE-1:0] w; // Weight
    reg signed [M_output*BITSIZE-1:0] b;         // Bias
    wire signed [M_output*BITSIZE-1:0] out;      // Output

    // Instantiate the decoder module
    decoder_fixed_point #(
        .N_input(N_input),
        .M_output(M_output),
        .BITSIZE(BITSIZE)
    ) 
    decoder_inst
    (
        .z(z),
        .w(w),
        .b(b),
        .out(out)
    );

    initial begin
        // Test Case 1
        // Input data: 32-bit fixed-point, flattened
        z =
        {
            32'b1_0001_000000000000000000000000000, // z[1]
            32'b0_0001_000000000000000000000000000  // z[0]
        };

        // Weights: 32-bit fixed-point, flattened
        w =
        {
            32'b0_0001_000000000000000000000000000, // w[1][8]
            32'b0_0001_000000000000000000000000000, // w[0][8]
            32'b0_0011_100000000000000000000000000, // w[1][7]
            32'b0_0110_000000000000000000000000000, // w[0][7]
            32'b1_0111_000000000000000000000000000, // w[1][6]
            32'b0_0111_000000000000000000000000000, // w[0][6]
            32'b0_0111_100000000000000000000000000, // w[1][5]
            32'b1_0111_000000000000000000000000000, // w[0][5]
            32'b0_0111_000000000000000000000000000, // w[1][4]
            32'b1_0111_100000000000000000000000000, // w[0][4]
            32'b0_0111_100000000000000000000000000, // w[1][3]
            32'b1_0111_000000000000000000000000000, // w[0][3]
            32'b0_0111_000000000000000000000000000, // w[1][2]
            32'b0_0111_000000000000000000000000000, // w[0][2]
            32'b0_0011_000000000000000000000000000, // w[1][1]
            32'b0_0110_000000000000000000000000000, // w[0][1]
            32'b0_0001_000000000000000000000000000, // w[1][0]
            32'b0_0001_000000000000000000000000000  // w[0][0]
        };

        // Biases: 32-bit fixed-point, flattened
        b =
        {
            32'b0_0001_000000000000000000000000000, // b[8]
            32'b0_0111_100000000000000000000000000, // b[7]
            32'b1_0111_000000000000000000000000000, // b[6]
            32'b0_0111_000000000000000000000000000, // b[5]
            32'b0_0111_100000000000000000000000000, // b[4]
            32'b1_0111_000000000000000000000000000, // b[3]
            32'b0_0001_000000000000000000000000000, // b[2]
            32'b0_0001_000000000000000000000000000, // b[1]
            32'b1_0001_000000000000000000000000000  // b[0]
        };

        #10;
        // Stop
        $stop;
    end

    integer i;
    initial begin
        for (i = 0; i < M_output; i = i + 1) begin
            #1;
            $display("Output[%0d] in Hex: %h, in Binary: %b", i, out[i*BITSIZE +: BITSIZE], out[i*BITSIZE +: BITSIZE]);
        end
    end
endmodule
