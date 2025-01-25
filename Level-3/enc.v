`include "fixed_point_add.v"
`include "fixed_point_multiply.v"

module enc_1 #(parameter BITSIZE = 16) (
    input wire clk,
    input wire reset,
    input wire [BITSIZE*10-1:0]   x,
    input wire [BITSIZE*6*10-1:0] w, // never change, initialize in top level. direction -> top left, top right, next row, repeat -> should be 6*10 matrix
    input wire [BITSIZE*6-1:0]    b, // never change, initialize in top level
    output reg [BITSIZE*6-1:0]    y 
);

// Internal signals
wire [BITSIZE-1:0] out_mul [5:0]; // Parallel multipliers (1 row at a time)
reg  [BITSIZE-1:0] in_add [5:0];  // Input to the adders (6 elements)
wire [BITSIZE-1:0] out_add [5:0]; // Output from the adders (6 elements)
reg  [3:0] j; // Counter for 10 iterations

// Sequential logic for controlling the operation
always @(posedge clk or posedge reset) begin
    if (reset) begin
        // Reset logic
        j <= 0;
        y[0] <= 0;
        y[1] <= 0;
        y[2] <= 0;
        y[3] <= 0;
        y[4] <= 0;
        y[5] <= 0;
    end else if (j < 10) begin
        // For the first iteration, use bias vector `b`
        if (j == 0) begin
            in_add[0] <= b[BITSIZE*0 +: BITSIZE];
            in_add[1] <= b[BITSIZE*1 +: BITSIZE];
            in_add[2] <= b[BITSIZE*2 +: BITSIZE];
            in_add[3] <= b[BITSIZE*3 +: BITSIZE];
            in_add[4] <= b[BITSIZE*4 +: BITSIZE];
            in_add[5] <= b[BITSIZE*5 +: BITSIZE];
        end else begin
            // Subsequent iterations add to previous results
            in_add[0] <= y[0];
            in_add[1] <= y[1];
            in_add[2] <= y[2];
            in_add[3] <= y[3];
            in_add[4] <= y[4];
            in_add[5] <= y[5];
        end

        // Save the current outputs into y
        y[0] <= out_add[0];
        y[1] <= out_add[1];
        y[2] <= out_add[2];
        y[3] <= out_add[3];
        y[4] <= out_add[4];
        y[5] <= out_add[5];

        // Increment the counter
        j <= j + 1;
    end
end

// Parallel multiplication logic for 6 elements (1 row)
fixed_point_multiply mul_0 (
    .A(x[BITSIZE*j +: BITSIZE]),
    .B(w[(BITSIZE*j*6) + (BITSIZE*0) +: BITSIZE]),
    .C(out_mul[0])
);
fixed_point_multiply mul_1 (
    .A(x[BITSIZE*j +: BITSIZE]),
    .B(w[(BITSIZE*j*6) + (BITSIZE*1) +: BITSIZE]),
    .C(out_mul[1])
);
fixed_point_multiply mul_2 (
    .A(x[BITSIZE*j +: BITSIZE]),
    .B(w[(BITSIZE*j*6) + (BITSIZE*2) +: BITSIZE]),
    .C(out_mul[2])
);
fixed_point_multiply mul_3 (
    .A(x[BITSIZE*j +: BITSIZE]),
    .B(w[(BITSIZE*j*6) + (BITSIZE*3) +: BITSIZE]),
    .C(out_mul[3])
);
fixed_point_multiply mul_4 (
    .A(x[BITSIZE*j +: BITSIZE]),
    .B(w[(BITSIZE*j*6) + (BITSIZE*4) +: BITSIZE]),
    .C(out_mul[4])
);
fixed_point_multiply mul_5 (
    .A(x[BITSIZE*j +: BITSIZE]),
    .B(w[(BITSIZE*j*6) + (BITSIZE*5) +: BITSIZE]),
    .C(out_mul[5])
);

// Parallel addition logic for 6 elements
fixed_point_add add_0 (
    .A(out_mul[0]),
    .B(in_add[0]),
    .C(out_add[0])
);
fixed_point_add add_1 (
    .A(out_mul[1]),
    .B(in_add[1]),
    .C(out_add[1])
);
fixed_point_add add_2 (
    .A(out_mul[2]),
    .B(in_add[2]),
    .C(out_add[2])
);
fixed_point_add add_3 (
    .A(out_mul[3]),
    .B(in_add[3]),
    .C(out_add[3])
);
fixed_point_add add_4 (
    .A(out_mul[4]),
    .B(in_add[4]),
    .C(out_add[4])
);
fixed_point_add add_5 (
    .A(out_mul[5]),
    .B(in_add[5]),
    .C(out_add[5])
);





endmodule