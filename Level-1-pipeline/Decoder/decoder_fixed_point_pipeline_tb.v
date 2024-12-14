`include "decoder_fixed_point_pipeline.v"

module decoder_fixed_point_pipeline_tb;

    // Parameter
    parameter N_input = 2;       // Jumlah Input
    parameter M_output = 9;      // Jumlah Output
    parameter BITSIZE = 16;      // Fixed Point 16-bit

    // Port untuk Modul Decoder
    reg clk;                                          
    reg signed [N_input*BITSIZE-1:0] z;               // Input
    reg signed [N_input*M_output*BITSIZE-1:0] w;      // Weight
    reg signed [M_output*BITSIZE-1:0] b;              // Bias
    wire signed [M_output*BITSIZE-1:0] out;           // Output

    // Instansiasi Modul
    decoder_fixed_point_pipeline #(
        .N_input(N_input),
        .M_output(M_output),
        .BITSIZE(BITSIZE)
    )

    decoder_pipeline_inst
    (
        .clk(clk),
        .z(z),
        .w(w),
        .b(b),
        .out(out)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time unit periode clock cycle
    end

    initial begin
        // Test Case 1
        // Input data: 16-bit fixed-point, flattened
        z =
        {
            16'b1_0001_00000000000, // z[1]
            16'b0_0001_00000000000  // z[0]
        };

        // Weight: 16-bit fixed-point, flattened
        w =
        {
            16'b0_0001_00000000000, // w[1][8]
            16'b0_0001_00000000000, // w[0][8]
            16'b0_0011_00000000000, // w[1][7]
            16'b0_0110_00000000000, // w[0][7]
            16'b1_0111_00000000000, // w[1][6]
            16'b0_0111_00000000000, // w[0][6]
            16'b0_0111_10000000000, // w[1][5]
            16'b1_0111_00000000000, // w[0][5]
            16'b0_0111_00000000000, // w[1][4]
            16'b1_0111_10000000000, // w[0][4]
            16'b0_0111_10000000000, // w[1][3]
            16'b1_0111_00000000000, // w[0][3]
            16'b0_0111_00000000000, // w[1][2]
            16'b0_0111_00000000000, // w[0][2]
            16'b0_0011_00000000000, // w[1][1]
            16'b0_0110_00000000000, // w[0][1]
            16'b0_0001_00000000000, // w[1][0]
            16'b0_0001_00000000000  // w[0][0]
        };

        // Bias: 16-bit fixed-point, flattened
        b =
        {
            16'b0_0001_00000000000, // b[8]
            16'b0_0111_10000000000, // b[7]
            16'b1_0111_00000000000, // b[6]
            16'b0_0111_00000000000, // b[5]
            16'b0_0111_10000000000, // b[4]
            16'b1_0111_00000000000, // b[3]
            16'b0_0001_00000000000, // b[2]
            16'b0_0001_00000000000, // b[1]
            16'b1_0001_00000000000  // b[0]
        };

        #200;
        $stop;
    end

    integer i;
    initial begin
    $dumpfile("decoder_fixed_point_pipeline_tb.vcd");
    $dumpvars(0, decoder_fixed_point_pipeline_tb);
    #50
        for (i = 0; i < M_output; i = i + 1) begin
            #10;
            $display("Output[%0d] in Hex: %h, in Binary: %b", 
                     i, 
                     out[i*BITSIZE +: BITSIZE], 
                     out[i*BITSIZE +: BITSIZE]);
        end
    end
endmodule
