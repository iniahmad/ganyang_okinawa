module compare_4float (
    input wire signed [31:0] data, x1, x2, x3, x4, m1, m2, m3, m4, m5, c1, c2, c3, c4, c5,
    output reg [31:0] m, c
);

wire [3:0] flag;

assign flag[0] = (data < x1) ? 1'b1 : 1'b0; // -> region 1, flag = 1111
assign flag[1] = (data < x2) ? 1'b1 : 1'b0; // -> region 2, flag = 1110
assign flag[2] = (data < x3) ? 1'b1 : 1'b0; // -> region 3, flag = 1100
assign flag[3] = (data < x4) ? 1'b1 : 1'b0; // -> region 4, flag = 1000

always @(flag) begin
case (flag)
    4'b1111: begin 
             assign m = m1;
             assign c = c1;
             end

    4'b1110: begin 
             assign m = m2;
             assign c = c2;
             end

    4'b1100: begin 
             assign m = m3;
             assign c = c3;
             end

    4'b1000: begin 
             assign m = m4;
             assign c = c4;
             end

    default: begin 
             assign m = m5;
             assign c = c5;
             end
endcase
end

endmodule