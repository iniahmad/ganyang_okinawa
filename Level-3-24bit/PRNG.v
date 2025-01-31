module PRNG
#(
    parameter BITSIZE = 24 // Default bit size
)
(
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal
    input wire [4:0] seed,   // Seed input
    output reg [BITSIZE-1:0] random_out, // Random number output
    output reg [4:0] statee
);

reg [4:0] state;
reg initialize;

reg [BITSIZE-1:0] epsilon_LUT [31:0];
initial begin
    epsilon_LUT[0]  = 24'b000000000000000000000000; //1
    epsilon_LUT[1]  = 24'b000000000000000000000000; //2
    epsilon_LUT[2]  = 24'b000000000000111000111000; //3
    epsilon_LUT[3]  = 24'b000000000000111000111000; //4
    epsilon_LUT[4]  = 24'b000000000001110001110001; //5
    epsilon_LUT[5]  = 24'b000000000001110001110001; //6
    epsilon_LUT[6]  = 24'b000000000001110001110001; //7
    epsilon_LUT[7]  = 24'b000000000010101010101010; //8
    epsilon_LUT[8]  = 24'b000000000010101010101010; //9
    epsilon_LUT[9]  = 24'b000000000010101010101010; //10
    epsilon_LUT[10] = 24'b000000000010101010101010; //11
    epsilon_LUT[11] = 24'b000000000011100011100011; //12
    epsilon_LUT[12] = 24'b000000000011100011100011; //13
    epsilon_LUT[13] = 24'b000000000011100011100011; //14
    epsilon_LUT[14] = 24'b000000000011100011100011; //15
    epsilon_LUT[15] = 24'b000000000011100011100011; //16
    epsilon_LUT[16] = 24'b000000000100011100011100; //17
    epsilon_LUT[17] = 24'b000000000100011100011100; //18
    epsilon_LUT[18] = 24'b000000000100011100011100; //19
    epsilon_LUT[19] = 24'b000000000100011100011100; //20
    epsilon_LUT[20] = 24'b000000000100011100011100; //21
    epsilon_LUT[21] = 24'b000000000101010101010101; //22
    epsilon_LUT[22] = 24'b000000000101010101010101; //23
    epsilon_LUT[23] = 24'b000000000101010101010101; //24
    epsilon_LUT[24] = 24'b000000000101010101010101; //25
    epsilon_LUT[25] = 24'b000000000110001110001110; //26
    epsilon_LUT[26] = 24'b000000000110001110001110; //27
    epsilon_LUT[27] = 24'b000000000110001110001110; //28
    epsilon_LUT[28] = 24'b000000000111000111000111; //29
    epsilon_LUT[29] = 24'b000000000111000111000111; //30
    epsilon_LUT[30] = 24'b000000001000000000000000; //31
    epsilon_LUT[31] = 24'b000000001000000000000000; //32
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        random_out <= {BITSIZE{1'b0}};
    end else begin
        random_out <= epsilon_LUT[state];
    end
end

always @(posedge clk or posedge rst) begin
    if (!initialize) begin
        state <= seed; // Initialize state with seed on reset
        initialize <= 1;
    end else if (rst) begin
        state <= seed; // Initialize state with seed on reset
    end else begin
        state <= (state ^ (state << 4)) + 3;
    end
    statee <= state;
end

endmodule
