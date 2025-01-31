`include "top_arrhythmia.v"

module top_arrhythmia_tb;

    // Parameters
    parameter BITSIZE = 20;

    // Inputs
    reg clk;
    reg reset;
    reg [BITSIZE*10-1:0] x;
    reg [6:0] test_index;
    // reg valid;

    // Outputs
    wire [BITSIZE-1:0] y1;
    wire [BITSIZE-1:0] y2;
    wire [BITSIZE*2-1:0] y;
    wire done_flag;
    // wire [BITSIZE-1:0] y2;

    // Instantiate the Unit Under Test (UUT)
    top_arrhythmia #(BITSIZE) uut (
        .clk(clk),
        .reset(reset),
        .x(x),
        .y({y1,y2}),
        .done_flag_out(done_flag)
    );

/// for output ///
    localparam max_data = 101;
    integer i;
    integer sum;
    integer true;
    logic pred  [max_data-1:0];
    logic reall [max_data-1:0];

    function logic compare_sign_mag;
        input [15:0] val_a;
        input [15:0] val_b;  // Declare inputs as 16-bit
        logic sign_a;
        logic sign_b;
        logic [14:0] mag_a;
        logic [14:0] mag_b;

        begin
            // Extract sign and magnitude
            sign_a = val_a[15];
            sign_b = val_b[15];
            mag_a = val_a[14:0];
            mag_b = val_b[14:0];

            // Compare based on sign and magnitude
            if (sign_a != sign_b) begin
                // If signs differ, the negative number is smaller
                compare_sign_mag = (sign_a < sign_b);  // 1 if A > B
            end else begin
                // If signs are the same, compare magnitudes
                if (sign_a == 1'b1) begin
                    // Both negative: larger magnitude means smaller number
                    compare_sign_mag = (mag_a < mag_b);  // 1 if (-)A > (-)B
                end else begin
                    // Both positive: larger magnitude means larger number
                    compare_sign_mag = (mag_a > mag_b);  // 1 if A > B
                end
            end
        end
    endfunction
/// for output ///

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10 time units period
    end

    // Test sequence
    initial begin
        $dumpfile("top_arrhythmia_tb.vcd");
        $dumpvars(0, top_arrhythmia_tb);
        // Initialize Inputs
        reset = 1;
        x = 0;

        // Wait for global reset to finish
        #10;
        reset = 0;




        
        // Initialize variables
        sum = 0;
        true = 0;

        for (i = 0; i < max_data; i = i + 1) begin
            if (!(reall[i] === 1'bx || pred[i] === 1'bx)) begin
                $display("testcase: %d, real: %b, pred: %b", i, reall[i], pred[i]);
                sum = sum + 1;
                if (reall[i] == pred[i]) begin
                    true = true + 1;
                end
            end
        end

        if (sum > 0) begin
            $display("accuracy = (%d / %d) = %.3f%%", true, sum, true * 100.0 / sum);
        end else begin
            $display("No valid test cases to calculate accuracy.");
        end

        // Finish simulation
        $finish;
    end

    initial begin
        // // Initialize variables
        // sum = 0;
        // true = 0;

        // for (i = 0; i < 25; i = i + 1) begin
        //     if (!(reall[i] === 1'bx || pred[i] === 1'bx)) begin
        //         $display("testcase: %d, real: %b, pred: %b", i, reall[i], pred[i]);
        //         sum = sum + 1;
        //         if (reall[i] == pred[i]) begin
        //             true = true + 1;
        //         end
        //     end
        // end

        // if (sum > 0) begin
        //     $display("accuracy = %4d / %4d = %4f", true, sum, true * 1.0 / sum);
        // end else begin
        //     $display("No valid test cases to calculate accuracy.");
        // end
    end

endmodule
