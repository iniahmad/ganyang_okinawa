`include "fixed_point_add.v"
`include "fixed_point_multiply.v"

module enc_2 #(parameter BITSIZE = 16) (
    input wire  clk,
    input wire  reset,
    input wire  [BITSIZE*6-1:0]   x,  // Input vector (6 elements)
    input wire  [BITSIZE*1*6-1:0] w,  // Weight matrix (1x6)
    input wire  [BITSIZE*1-1:0]    b,  // Bias vector (1 elements)
    output wire [BITSIZE*1-1:0]    y   // Output vector (1 elements)
);

// Internal signals
wire [BITSIZE-1:0] out_mul;   // Parallel multipliers output (1 elements per row)
reg  [BITSIZE-1:0] in_add;    // Input to adders (1 elements)
wire [BITSIZE-1:0] out_add;   // Output from adders (1 elements)
reg  [BITSIZE-1:0] out_stage; // Final output stage (1 elements)
reg  [2:0] j;                 // Counter for 6 iterations
reg  done;

// Sequential logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        j <= 0;
        done <= 0;
        in_add <= 0;
        out_stage <= 0;

    end else begin 
        if (j == 6 && !done) begin
        // Accumulate results
            in_add = out_add;
            done <= 1;
        // $display("%h", in_add[0]);

        end
        if (j < 6) begin
            // Increment iteration
            in_add = (j==0) ? b : out_add;
            j = j + 1;
        end
    end

    // $display("time: %0t\t\t, clk: %b, reset: %b\t\t, j = %d, in1mul = %h in2mul = %h out_mul: %h\t\t\t, in_add = %h out_add: %h\t\t\t, output: %h\t\t\t",
    //           $time, clk, reset, j, x[BITSIZE*j +: BITSIZE], w[(BITSIZE*1*j) +: BITSIZE], out_mul, in_add, out_add, y);
end


// Parallel multiplication logic for 6 elements (1 row)
fixed_point_multiply mul (
    .A(x[BITSIZE*j +: BITSIZE]), // Take x[j]
    .B(w[(BITSIZE*1*j) +: BITSIZE]), // Row j, column idx
    .C(out_mul)
);

// Parallel addition logic for 6 elements
fixed_point_add add (
    .A(out_mul),
    .B(in_add ),
    .C(out_add)
);

// Assign final output
always @(posedge clk) begin
    // if(j < 6) begin
        out_stage = out_add;
    // end
end

// assign output
assign y = out_stage;

endmodule
