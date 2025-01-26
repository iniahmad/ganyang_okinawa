`include "fixed_point_add.v"
`include "fixed_point_multiply.v"

module enc_1 #(parameter BITSIZE = 16) (
    input wire  clk,
    input wire  reset,
    input wire  [BITSIZE*1-1:0]    x,  // Input vector (10 elements)
    input wire  [BITSIZE*6*1-1:0]  w,  // Weight matrix (6x10)
    input wire  [BITSIZE*6-1:0]    b,  // Bias vector (6 elements)
    output wire [BITSIZE*6-1:0]    y   // Output vector (6 elements)
);

// Internal signals
wire [BITSIZE-1:0] out_mul   [5:0];   // Parallel multipliers output (6 elements per row)
wire [BITSIZE-1:0] in_add    [5:0];   // Input to adders (6 elements)
wire [BITSIZE-1:0] out_add   [5:0];   // Output from adders (6 elements)
reg  [BITSIZE-1:0] out_stage [5:0]; // Final output stage (6 elements)
reg  done;

// Combinational logic to determine in_add
assign in_add[0] = b[BITSIZE*0 +: BITSIZE];
assign in_add[1] = b[BITSIZE*1 +: BITSIZE];
assign in_add[2] = b[BITSIZE*2 +: BITSIZE];
assign in_add[3] = b[BITSIZE*3 +: BITSIZE];
assign in_add[4] = b[BITSIZE*4 +: BITSIZE];
assign in_add[5] = b[BITSIZE*5 +: BITSIZE];

// Sequential logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        done <= 0;
        out_stage[0] <= 0; out_stage[1] <= 0; out_stage[2] <= 0; out_stage[3] <= 0; out_stage[4] <= 0; out_stage[5] <= 0;
    end else begin
        if (!done) begin
            out_stage[0] <= out_add[0];
            out_stage[1] <= out_add[1];
            out_stage[2] <= out_add[2];
            out_stage[3] <= out_add[3];
            out_stage[4] <= out_add[4];
            out_stage[5] <= out_add[5];
            done <= 1;
        end
    end
end


// Parallel multiplication logic for 6 elements (1 row)
genvar idx;
generate
    for (idx = 0; idx < 6; idx = idx + 1) begin : multiplier
        fixed_point_multiply mul (
            .A(x[0 +: BITSIZE]),
            .B(w[(BITSIZE*idx) +: BITSIZE]),
            .C(out_mul[idx])
        );
    end
endgenerate

// Parallel addition logic for 6 elements
generate
    for (idx = 0; idx < 6; idx = idx + 1) begin : adder
        fixed_point_add add (
            .A(out_mul[idx]),
            .B(in_add [idx]),
            .C(out_add[idx])
        );
    end
endgenerate

// invert output only
assign y[BITSIZE*0 +: BITSIZE] = out_stage[0];
assign y[BITSIZE*1 +: BITSIZE] = out_stage[1];
assign y[BITSIZE*2 +: BITSIZE] = out_stage[2];
assign y[BITSIZE*3 +: BITSIZE] = out_stage[3];
assign y[BITSIZE*4 +: BITSIZE] = out_stage[4];
assign y[BITSIZE*5 +: BITSIZE] = out_stage[5];

endmodule
