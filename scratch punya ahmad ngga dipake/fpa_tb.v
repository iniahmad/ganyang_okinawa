`include "fixed_point_add.v"

module fpa_tb

reg [31:0] A, B;
wire [31:0] C;

fixed_point_add test (
    .A(A),
    .B(B),
    .C(C)
);

initial begin
    A = 32'b0000010000000000000000000000000;
    B = 32'b0000011000000000000000000000000;

    #5;
    $display("%b", C);
end

endmodule