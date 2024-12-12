module PRNG
#(
    // Parameter for seed initialization
    parameter SEED = 32'hDEADBEEF,
    parameter a = 13, b = 17, c = 5
)
(
    output reg [31:0] random_out // Random number output
);
    parameter MIN_VALUE = 32'b000000000000000000000000;
    parameter MAX_VALUE = 32'b000001000000000000000000;

    // Internal state initialized with the seed
    reg [31:0] state = SEED;

    // XORSHIFT algorithm with a, b, c
    always @* begin
        state = state ^ (state >> a);
        state = state ^ (state << b);
        state = state ^ (state >> c);
        random_out = (state % (MAX_VALUE - MIN_VALUE + 1)) + MIN_VALUE;
    end

endmodule
