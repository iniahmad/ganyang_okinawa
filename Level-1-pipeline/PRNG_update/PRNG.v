module PRNG
(
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal
    input wire [4:0] seed,  // -> 4 hex, 15 11 7 3
    output reg [15:0] random_out // Random number output
);

reg [4:0] state;

reg [32*16-1:0] epsilon_LUT;
initial begin
    epsilon_LUT = {
        16'b0000000000000000, //1
        16'b0000000000000000, //2
        16'b0000000011100011, //3
        16'b0000000011100011, //4
        16'b0000000111000111, //5
        16'b0000000111000111, //6
        16'b0000000111000111, //7
        16'b0000001010101010, //8
        16'b0000001010101010, //9
        16'b0000001010101010, //10
        16'b0000001010101010, //11
        16'b0000001110001110, //12
        16'b0000001110001110, //13
        16'b0000001110001110, //14
        16'b0000001110001110, //15
        16'b0000001110001110, //16
        16'b0000010001110001, //17
        16'b0000010001110001, //18
        16'b0000010001110001, //19
        16'b0000010001110001, //20
        16'b0000010001110001, //21
        16'b0000010101010101, //22
        16'b0000010101010101, //23
        16'b0000010101010101, //24
        16'b0000010101010101, //25
        16'b0000011000111000, //26
        16'b0000011000111000, //27
        16'b0000011000111000, //28
        16'b0000011100011100, //29
        16'b0000011100011100, //30
        16'b0000100000000000,  //31
        16'b0000100000000000  //32
    };
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        random_out <= 0;
    end else begin
        random_out = epsilon_LUT[state*16 +: 16];
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        random_out <= 0;
        state <= seed; // Initialize state with seed on reset
    end else begin
        random_out <= epsilon_LUT[state*16 +: 16]; // Corrected access
        if (seed[3])
            state <= state ^ (state << 4) ^ (state >> 5);
        else
            state <= state ^ (state << 4) ^ (state >> 4);
        state <= state + 1;
    end
end





endmodule