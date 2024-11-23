`include "sigmoid_4slice.v"

module sigmoid_4slice_tb;

reg signed [31:0] in;
wire signed [31:0] out;
sigmoid_4slice test (
    .data_in (in),
    .data_out(out)
);

// File handling variables
integer file;
integer i;
initial begin
    // Open the CSV file for writing
    file = $fopen("output_data.csv", "w");

    // Write the CSV header
    $fwrite(file, "data_in,data_out\n");
    i = 1;
        // Test case: Loop through input values
        for (in = 32'b0_0000_000000000000000000000000000; // Start
             in <= 32'b1_1111_111000000000000000000000000 && i <= 5000 ; // End (tambahan 5000 batas iterasi jika ternyata fail)
             in = in + 32'b0_0000_001000000000000000000000000) begin // Small increment
            #10; // Wait for the module to compute
            $fwrite(file, "%b,%b\n", in, out); // Write data to the file
            i=i+1;
        end

    // Close the file
    $fclose(file);

    $finish;
end


// initial begin
//     $dumpfile("sigmoid_4slice_tb.vcd");
//     $dumpvars(0, sigmoid_4slice_tb);

//     in = 32'b1_0001_000000000000000000000000000;

//     #10;

//     $display("input : %b", in);
//     $display("output: %b", out);
    
//     $finish;
// end

endmodule
