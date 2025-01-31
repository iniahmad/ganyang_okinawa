module PRNG
#(
    parameter BITSIZE = 20 // Default bit size
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
    epsilon_LUT[0] = 20'b00000000000000000000; //1
    epsilon_LUT[1] = 20'b00000000000000000000; //2
    epsilon_LUT[2] = 20'b00000000111000111000; //3
    epsilon_LUT[3] = 20'b00000000111000111000; //4
    epsilon_LUT[4] = 20'b00000001110001110001; //5
    epsilon_LUT[5] = 20'b00000001110001110001; //6
    epsilon_LUT[6] = 20'b00000001110001110001; //7
    epsilon_LUT[7] = 20'b00000010101010101010; //8
    epsilon_LUT[8] = 20'b00000010101010101010; //9
    epsilon_LUT[9] = 20'b00000010101010101010; //10
    epsilon_LUT[10] = 20'b00000010101010101010; //11
    epsilon_LUT[11] = 20'b00000011100011100011; //12
    epsilon_LUT[12] = 20'b00000011100011100011; //13
    epsilon_LUT[13] = 20'b00000011100011100011; //14
    epsilon_LUT[14] = 20'b00000011100011100011; //15
    epsilon_LUT[15] = 20'b00000011100011100011; //16
    epsilon_LUT[16] = 20'b00000100011100011100; //17
    epsilon_LUT[17] = 20'b00000100011100011100; //18
    epsilon_LUT[18] = 20'b00000100011100011100; //19
    epsilon_LUT[19] = 20'b00000100011100011100; //20
    epsilon_LUT[20] = 20'b00000100011100011100; //21
    epsilon_LUT[21] = 20'b00000101010101010101; //22
    epsilon_LUT[22] = 20'b00000101010101010101; //23
    epsilon_LUT[23] = 20'b00000101010101010101; //24
    epsilon_LUT[24] = 20'b00000101010101010101; //25
    epsilon_LUT[25] = 20'b00000110001110001110; //26
    epsilon_LUT[26] = 20'b00000110001110001110; //27
    epsilon_LUT[27] = 20'b00000110001110001110; //28
    epsilon_LUT[28] = 20'b00000111000111000111; //29
    epsilon_LUT[29] = 20'b00000111000111000111; //30
    epsilon_LUT[30] = 20'b00001000000000000000; //31
    epsilon_LUT[31] = 20'b00001000000000000000; //32
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
