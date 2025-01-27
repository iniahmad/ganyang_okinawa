module enc_control (
    input  wire clk,
    input  wire reset,
    output reg  enc1_start,
    output reg  enc2_start,
    output reg  enc3_start,
    output reg  enc4_start,
    output reg  done_flag
);

localparam offset    = 2;
localparam enc1_cc   = 12;
localparam softplus1 = 3;
localparam enc2_cc   = 8;
localparam softplus2 = 3;
localparam lambda    = 4;
localparam enc3_cc   = 3;
localparam softplus3 = 3;
localparam enc4_cc   = 8;
localparam sigmoid   = 3;

reg [5:0] cc;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        cc <= 0;
        enc1_start <= 1;
        enc2_start <= 1;
        enc3_start <= 1;
        enc4_start <= 1;
        done_flag  <= 0;
    end else begin
        if (!done_flag) begin
            cc = cc + 1;
        end
    end
end

always @(cc) begin
    case (cc)
        offset: 
            enc1_start = 0;

        offset + enc1_cc + softplus1:
            enc2_start = 0;

        offset + enc1_cc + softplus1 + enc2_cc + softplus2 + lambda:
            enc3_start = 0;

        offset + enc1_cc + softplus1 + enc2_cc + softplus2 + lambda + enc3_cc + softplus3:
            enc4_start = 0;

        offset + enc1_cc + softplus1 + enc2_cc + softplus2 + lambda + enc3_cc + softplus3 + enc4_cc + sigmoid:
            done_flag = 1;
    endcase
end

endmodule
