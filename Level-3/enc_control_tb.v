`include "enc_control.v"

module tb_matrix_vector_mult;

    parameter CLK_PERIOD = 10;

    // Testbench signals
    reg  clk;
    reg  reset;
    wire [5:0] debug_cc;
    wire enc1_start;
    wire enc2_start;
    wire enc3_start;
    wire enc4_start;
    wire done_flag;

    // Instantiate the DUT
    enc_control dut (
        .clk        (clk),
        .reset      (reset),
        .debug_cc   (debug_cc),
        .enc1_start (enc1_start),
        .enc2_start (enc2_start),
        .enc3_start (enc3_start),
        .enc4_start (enc4_start),
        .done_flag  (done_flag)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever begin
            #(CLK_PERIOD / 2);
            clk = ~clk;
        end
    end

    // Reset logic
    initial begin
        reset = 0;
        #(CLK_PERIOD);
        reset = 1;
        #(CLK_PERIOD);
        reset = 0;
    end

    initial begin
        #(CLK_PERIOD * 70);
        $finish;
    end

    // Monitor outputs
    initial begin
        // #(CLK_PERIOD/2);
        forever begin
            $display("clk: %d, reset: %d,\t cc: %d,\t enc1_start: %d, enc2_start: %d, enc3_start: %d, enc4_start: %d, done_flag: %d", 
                     clk, reset, debug_cc, enc1_start, enc2_start, enc3_start, enc4_start, done_flag);
            #CLK_PERIOD;
        end
    end

endmodule
