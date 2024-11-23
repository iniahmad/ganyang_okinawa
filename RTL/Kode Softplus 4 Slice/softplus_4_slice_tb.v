`include "softplus_4_slice.v"

module softplus_4_slice_tb;
    // INPUT
    reg signed [31:0] data_in;

    // OUTPUT
    wire signed [31:0] data_out;

    // Porting Modul Sigmoid
    softplus_4_slice S1
    (
        .data_in(data_in),
        .data_out(data_out)
    );

    initial begin
    $dumpfile("softplus_4_slice_tb.vcd");
    $dumpvars(0, softplus_4_slice_tb);

    // Data Input
    data_in = 32'b0_0111_000000000000000000000000000;
    #10;
    
    $display("input: %b", data_in);
    $display("output: %b", data_out);

    $finish;
    end

endmodule
