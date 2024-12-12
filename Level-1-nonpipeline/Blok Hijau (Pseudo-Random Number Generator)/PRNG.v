module PRNG
#(
    // Parameter for seed initialization
    parameter SEED = 32'hDEADBEEF,
    parameter a = 13, b = 17, c = 5
)
(
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal
    output reg [31:0] random_out // Random number output
);
    parameter MIN_VALUE = 32'b000000000000000000000000;
    parameter MAX_VALUE = 32'b000001000000000000000000;

    // Internal state
    reg [31:0] state;

    // XORSHIFT logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= SEED; // Initialize state with seed on reset
        end else begin
            // XORSHIFT algorithm with a, b, c
            state <= state ^ (state >> a);
            state <= state ^ (state << b);
            state <= state ^ (state >> c);
        end
    end

    // Assign state to output
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            random_out <= 0; // Reset output
        end else begin
            random_out <= (state % (MAX_VALUE - MIN_VALUE + 1)) + MIN_VALUE;
        end
    end
endmodule
