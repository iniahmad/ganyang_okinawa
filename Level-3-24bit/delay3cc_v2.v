module delay_3_cycle_v2 #(parameter BITSIZE = 24) (
    input  wire clk,                     // Clock signal
    input  wire [BITSIZE-1:0] in_data,   // Input data (parameterized bit-width)
    output reg  [BITSIZE-1:0] out_data   // Output data (parameterized bit-width)
);

    // Shift register to hold intermediate values
    reg [BITSIZE-1:0] shift_reg [0:2];

    always @(posedge clk) begin
        // Shift data
        shift_reg[0] <= in_data;
        shift_reg[1] <= shift_reg[0];
        // shift_reg[2] <= shift_reg[1]; // Uncomment if needed for 3-cycle delay

        // Output delayed data
        out_data <= shift_reg[1]; // Adjust index if using 3-cycle delay
    end

endmodule