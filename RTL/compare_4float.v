module compare_4float (
    input wire [31:0] data, x1, x2, x3, x4,  // Sign-magnitude inputs
    input wire [31:0] m1, m2, m3, m4, m5, 
    input wire [31:0] c1, c2, c3, c4, c5,
    output reg [31:0] m, c
);

    wire [3:0] flag;

    // Split the inputs into sign and magnitude
    wire data_sign = data[31];
    wire [30:0] data_mag = data[30:0];
    
    wire x1_sign = x1[31];
    wire [30:0] x1_mag = x1[30:0];

    wire x2_sign = x2[31];
    wire [30:0] x2_mag = x2[30:0];

    wire x3_sign = x3[31];
    wire [30:0] x3_mag = x3[30:0];

    wire x4_sign = x4[31];
    wire [30:0] x4_mag = x4[30:0];

    // Helper function to compare sign-magnitude numbers
    function compare_sign_mag;
        input sign_a, sign_b;
        input [30:0] mag_a, mag_b;
        begin
            if (sign_a != sign_b) begin
                // If signs differ, the negative number is smaller
                compare_sign_mag = (sign_a > sign_b);  // 1 if A < B
            end else begin
                // If signs are the same, compare magnitudes
                if (sign_a == 1'b1) begin
                    // Both negative: larger magnitude means smaller number
                    compare_sign_mag = (mag_a > mag_b);
                end else begin
                    // Both positive: larger magnitude means larger number
                    compare_sign_mag = (mag_a < mag_b);
                end
            end
        end
    endfunction

    // Generate flags for region checks
    assign flag[0] = compare_sign_mag(data_sign, x1_sign, data_mag, x1_mag); // Region 1
    assign flag[1] = ~flag[0] && compare_sign_mag(data_sign, x2_sign, data_mag, x2_mag); // Region 2
    assign flag[2] = ~flag[0] && ~flag[1] && compare_sign_mag(data_sign, x3_sign, data_mag, x3_mag); // Region 3
    assign flag[3] = ~flag[0] && ~flag[1] && ~flag[2] && compare_sign_mag(data_sign, x4_sign, data_mag, x4_mag); // Region 4

    // Determine m and c based on flag
    always @(*) begin
        if (flag[0]) begin
            m = m1;
            c = c1;
        end else if (flag[1]) begin
            m = m2;
            c = c2;
        end else if (flag[2]) begin
            m = m3;
            c = c3;
        end else if (flag[3]) begin
            m = m4;
            c = c4;
        end else begin
            m = m5;
            c = c5;
        end
    end

endmodule
