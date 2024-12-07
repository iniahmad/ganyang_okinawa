`include "sampling.v"

module sampling_VAE_tb;

    // Parameters
    parameter N_input = 2;       // Jumlah input
    parameter M_output = 2;      // Jumlah output
    parameter BITSIZE = 32;      // Fixed Point 32-bit

    // Ports for decoder module
    reg [N_input*BITSIZE-1:0] ac;          // Input Mean
    reg [N_input*BITSIZE-1:0] ad;          // Input Variance
    wire [M_output*BITSIZE-1:0] a;         // Output
    wire [M_output*BITSIZE-1:0] epsilon;         // Output

    // Instantiate the decoder module
    sampling_VAE #(
        .N_input(N_input),
        .M_output(M_output),
        .BITSIZE(BITSIZE)
    ) 
    sampling_VAE_inst
    (
        .ac(ac),
        .ad(ad),
        .a(a),
        .epsilon(epsilon)
    );

    initial begin

        ac =
        {
            32'b00011011011100001010001111010111, // ac2 = 3.43 (MSB)
            32'b00101101001100110011001100110011  // ac1 = 5.65 (LSB)
        };

        ad =
        {
            32'b00000111000010100011110101110000, // ad2 = 0.88 (MSB)
            32'b00010001000010100011110101110000  // ad1 = 2.13 (LSB)
        };

        #10;
        // Stop
        $stop;
    end

    integer i;
    initial begin
        for (i = 0; i < M_output; i = i + 1) begin
            #1;
            $display("Output[%0d] in Hex: %h, in Binary: %b", i, a[(i+1)*BITSIZE-1 -: BITSIZE], a[(i+1)*BITSIZE-1 -: BITSIZE]);
            $display("Epsilon[%0d] in Hex: %h, in Binary: %b", i, epsilon[(i+1)*BITSIZE-1 -: BITSIZE], epsilon[(i+1)*BITSIZE-1 -: BITSIZE]);
        end

        $finish;
    end

endmodule