`include "sigmoid8.v"

module sigmoid8_tb;
    // INPUT
    reg signed [31:0] data_in;

    // OUTPUT
    wire signed [31:0] data_out;

    // Porting Modul Sigmoid
    sigmoid8 S1
    (
        .data_in(data_in),
        .data_out(data_out)
    );

initial begin
$dumpfile("sigmoid8_tb.vcd");
$dumpvars(0, sigmoid8_tb);

// Data Input
data_in = 32'b00100110101100001011111000001101; //  4.8363
#10;
data_in = 32'b10011110100101011011010101110011; // -3.8231
#10;
data_in = 32'b10011101001001011010111011100110; // -3.6434
#10;
data_in = 32'b10000011010011000110001111110001; // -0,4123
#10;
$display("output: %b", data_out);
end
endmodule