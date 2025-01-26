`include "fixed_point_add.v"
`include "fixed_point_multiply.v"

module enc_2 #(parameter BITSIZE = 16) (
    input wire  clk,
    input wire  reset,
    input wire  [BITSIZE*6-1:0]   x,  // Input vector (6 elements)
    input wire  [BITSIZE*1*6-1:0] w,  // Weight matrix (1x6)
    input wire  [BITSIZE*1-1:0]    b,  // Bias vector (1 element)
    output wire [BITSIZE*1-1:0]    y   // Output vector (1 element)
);

// Internal signals
wire [BITSIZE-1:0] out_mul;   // Output of multiplier
reg  [BITSIZE-1:0] in_add;    // Input to adder
wire [BITSIZE-1:0] out_add;   // Output from adder
reg  [BITSIZE-1:0] out_stage; // Output stage
reg  [2:0] j;                 // Counter for iterations
reg  done;                    // Completion flag

always @(j) begin
    // Combinational logic to determine in_add
    in_add = (j == 0) ? b : out_add;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        j <= 0;
        done <= 0;
        out_stage <= 0;
    end else begin
        if (!done) begin
            // Update the output stage
            out_stage <= out_add;

            // Increment the counter
            if (j < 5) begin
                j <= j + 1;
            end else begin
                done <= 1;
            end
        end
    end
end


// Parallel multiplication logic for 6 elements (1 row)
fixed_point_multiply mul (
    .A(x[BITSIZE*j +: BITSIZE]), // Take x[j]
    .B(w[(BITSIZE*1*j) +: BITSIZE]), // Row j, column idx
    .C(out_mul)
);

// Parallel addition logic
fixed_point_add add (
    .A(out_mul),
    .B(in_add),
    .C(out_add)
);

// Assign output
assign y = out_stage;

endmodule
