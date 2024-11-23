module compare_4float (
    input wire signed [31:0] data, x1, x2, x3, x4, 
    input wire signed [31:0] m1, m2, m3, m4, m5, 
    input wire signed [31:0] c1, c2, c3, c4, c5,
    output reg [31:0] m, c // Use reg type for outputs
);

    wire [3:0] flag;

    // Compare data with x1, x2, x3, x4
    assign flag[0] = (data < x1) ? 1'b1 : 1'b0; // -> region 1, flag = 1111
    assign flag[1] = (data < x2) ? 1'b1 : 1'b0; // -> region 2, flag = 1110
    assign flag[2] = (data < x3) ? 1'b1 : 1'b0; // -> region 3, flag = 1100
    assign flag[3] = (data < x4) ? 1'b1 : 1'b0; // -> region 4, flag = 1000

    // Combinational logic to determine m and c based on flag
    always @(*) begin
        if (flag[0] == 1'b1) begin
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