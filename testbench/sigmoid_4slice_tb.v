`include "sigmoid_4slice.v"

module sigmoid_4slice_tb;

reg [31:0] in;
wire [31:0] out;
sigmoid_4slice test (
    .data_in (in),
    .data_out(out)
);

initial begin
    $dumpfile("sigmoid_4slice_tb.vcd");
    $dumpvars(0, sigmoid_4slice_tb);

    in = 32'b1_0011_000000000000000000000000000;

    #10;

    $display("input: %b", in);
    $display("output: %b", out);
    
    $finish;
end

endmodule
