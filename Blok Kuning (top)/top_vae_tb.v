`timescale 1ns/1ps

module top_vae_tb;

    // Parameter definitions
    parameter N_input_enc = 9;    // Input size of encoder
    parameter M_output_enc = 4;  // Output size of encoder
    parameter N_input_dec = 2;   // Input size of decoder (latent space)
    parameter M_output_dec = 9;  // Output size of decoder
    parameter BITSIZE = 32;      // Fixed Point 32-bit

    // Testbench signals
    reg rst;
    reg signed [N_input_enc*BITSIZE-1:0] tb_x;           // Input for encoder
    wire signed [M_output_dec*BITSIZE-1:0] tb_sigmoid_out; // Final sigmoid output
    reg signed [BITSIZE-1:0] sigmoid_out_split [0:M_output_dec-1]; // Split sigmoid output array

    // Instantiate the DUT (Design Under Test)
    top_vae #(
        .N_input_enc(N_input_enc),
        .M_output_enc(M_output_enc),
        .N_input_dec(N_input_dec),
        .M_output_dec(M_output_dec),
        .BITSIZE(BITSIZE)
    ) uut (
        .rst(rst),
        .x(tb_x),
        .sigmoid_out(tb_sigmoid_out)
    );

    // Testbench variables
    integer i;

    // Task to initialize inputs
    task initialize_inputs;
        integer j;
        begin
            // Initialize tb_x with manual values
        tb_x[0*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[0]
        tb_x[1*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[1]
        tb_x[2*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[2]
        tb_x[3*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[3]
        tb_x[4*BITSIZE +: BITSIZE] = 32'b00000000000000000000000000000000;  // Manual input for tb_x[4]
        tb_x[5*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[5]
        tb_x[6*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[6]
        tb_x[7*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[7]
        tb_x[8*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[8]
        
//        tb_x[0*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[0]
//        tb_x[1*BITSIZE +: BITSIZE] = 32'b00000000000000000000000000000000;  // Manual input for tb_x[1]
//        tb_x[2*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[2]
//        tb_x[3*BITSIZE +: BITSIZE] = 32'b00000000000000000000000000000000;  // Manual input for tb_x[3]
//        tb_x[4*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[4]
//        tb_x[5*BITSIZE +: BITSIZE] = 32'b00000000000000000000000000000000;  // Manual input for tb_x[5]
//        tb_x[6*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[6]
//        tb_x[7*BITSIZE +: BITSIZE] = 32'b00000000000000000000000000000000;  // Manual input for tb_x[7]
//        tb_x[8*BITSIZE +: BITSIZE] = 32'b00001000000000000000000000000000;  // Manual input for tb_x[8]

        // Optional: Display initialized values for debugging
        $display("tb_x manually initialized:");
        for (j = 0; j < N_input_enc; j = j + 1) begin
            $display("tb_x[%0d]: %0d", j, tb_x[j*BITSIZE +: BITSIZE]);
        end
        
        #10; // Wait for some time after initialization
        end
    endtask

    // Task to split tb_sigmoid_out into individual 32-bit values
    task split_sigmoid_output;
        integer idx;
        begin
            for (idx = 0; idx < M_output_dec; idx = idx + 1) begin
                sigmoid_out_split[idx] = tb_sigmoid_out[idx*BITSIZE +: BITSIZE];
            end
        end
    endtask

    // Testbench stimulus
    initial begin
        // Initialize signals
        $display("Initializing inputs...");
        initialize_inputs();

        // Display inputs
        $display("Inputs Initialized:");
        $display("tb_x: %h", tb_x);

        // Simulate for some time to observe outputs
        #10;

        // Split tb_sigmoid_out into individual components
        split_sigmoid_output();

        // Display outputs
        $display("Outputs:");
        $display("tb_sigmoid_out: %h", tb_sigmoid_out);
        for (i = 0; i < M_output_dec; i = i + 1) begin
            $display("sigmoid_out_split[%0d]: %h", i, sigmoid_out_split[i]);
        end
    
        #10
        // End simulation
        $finish;
    end

endmodule
