module compare_4float (
    input wire signed [31:0] data, x1, x2, x3, x4, 
    input wire signed [31:0] m1, m2, m3, m4, m5, 
    input wire signed [31:0] c1, c2, c3, c4, c5,
    output reg [31:0] m, c // Use reg type for outputs
);

    wire [3:0] flag;

    // Split the input data into integer and fractional parts
    wire signed [4:0] data_int = data[31:27];       // Integer part (5 bits)
    wire [26:0] data_frac = data[26:0];            // Fractional part (27 bits)
    
    wire signed [4:0] x1_int = x1[31:27];          // Integer part of x1
    wire [26:0] x1_frac = x1[26:0];               // Fractional part of x1

    wire signed [4:0] x2_int = x2[31:27];
    wire [26:0] x2_frac = x2[26:0];

    wire signed [4:0] x3_int = x3[31:27];
    wire [26:0] x3_frac = x3[26:0];

    wire signed [4:0] x4_int = x4[31:27];
    wire [26:0] x4_frac = x4[26:0];

    // Comparison logic
    assign flag[0] = (data_int < x1_int) || ((data_int == x1_int) && (data_frac < x1_frac)) ? 1'b1 : 1'b0;
    assign flag[1] = (data_int < x2_int) || ((data_int == x2_int) && (data_frac < x2_frac)) ? 1'b1 : 1'b0;
    assign flag[2] = (data_int < x3_int) || ((data_int == x3_int) && (data_frac < x3_frac)) ? 1'b1 : 1'b0;
    assign flag[3] = (data_int < x4_int) || ((data_int == x4_int) && (data_frac < x4_frac)) ? 1'b1 : 1'b0;

    // Determine m and c based on flag
    always @(*) begin
        if (flag[0] == 1'b0) begin
            m = m1;
            c = c1;
        end else if (flag[1] == 1'b0) begin
            m = m2;
            c = c2;
        end else if (flag[2] == 1'b0) begin
            m = m3;
            c = c3;
        end else if (flag[3] == 1'b0) begin
            m = m4;
            c = c4;
        end else begin
            m = m5;
            c = c5;
        end
    end

endmodule
