module compare_8float #(parameter BITSIZE = 24) (
    input wire [BITSIZE-1:0] data, x1, x2, x3, x4, x5, x6, x7, x8, // Sign-magnitude inputs
    input wire [BITSIZE-1:0] m1, m2, m3, m4, m5, m6, m7, m8, m9,
    input wire [BITSIZE-1:0] c1, c2, c3, c4, c5, c6, c7, c8, c9,
    input wire clk,
    input wire reset,
    output reg [BITSIZE-1:0] m, c
);
    reg [7:0] flag;

    // Split the inputs into sign and magnitude
    wire data_sign = data[BITSIZE-1];
    wire [BITSIZE-2:0] data_mag = data[BITSIZE-2:0];
    
    wire x1_sign = x1[BITSIZE-1];
    wire [BITSIZE-2:0] x1_mag = x1[BITSIZE-2:0];

    wire x2_sign = x2[BITSIZE-1];
    wire [BITSIZE-2:0] x2_mag = x2[BITSIZE-2:0];

    wire x3_sign = x3[BITSIZE-1];
    wire [BITSIZE-2:0] x3_mag = x3[BITSIZE-2:0];

    wire x4_sign = x4[BITSIZE-1];
    wire [BITSIZE-2:0] x4_mag = x4[BITSIZE-2:0];

    wire x5_sign = x5[BITSIZE-1];
    wire [BITSIZE-2:0] x5_mag = x5[BITSIZE-2:0];

    wire x6_sign = x6[BITSIZE-1];
    wire [BITSIZE-2:0] x6_mag = x6[BITSIZE-2:0];

    wire x7_sign = x7[BITSIZE-1];
    wire [BITSIZE-2:0] x7_mag = x7[BITSIZE-2:0];

    wire x8_sign = x8[BITSIZE-1];
    wire [BITSIZE-2:0] x8_mag = x8[BITSIZE-2:0];

    // Helper function to compare sign-magnitude numbers
    function compare_sign_mag;
        input sign_a, sign_b;
        input [BITSIZE-2:0] mag_a, mag_b;
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
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            flag <= 8'b0;
        end else begin
            flag[0] <= compare_sign_mag(data_sign, x1_sign, data_mag, x1_mag); // Region 1
            flag[1] <= compare_sign_mag(data_sign, x2_sign, data_mag, x2_mag); // Region 2
            flag[2] <= compare_sign_mag(data_sign, x3_sign, data_mag, x3_mag); // Region 3
            flag[3] <= compare_sign_mag(data_sign, x4_sign, data_mag, x4_mag); // Region 4
            flag[4] <= compare_sign_mag(data_sign, x5_sign, data_mag, x5_mag); // Region 5
            flag[5] <= compare_sign_mag(data_sign, x6_sign, data_mag, x6_mag); // Region 6
            flag[6] <= compare_sign_mag(data_sign, x7_sign, data_mag, x7_mag); // Region 7
            flag[7] <= compare_sign_mag(data_sign, x8_sign, data_mag, x8_mag); // Region 8
        end
    end

    // Determine m and c based on flag
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            m <= {BITSIZE{1'b0}};
            c <= {BITSIZE{1'b0}};
        end else begin
            if (flag[3]) begin
                if (flag[1]) begin
                    if (flag[0]) begin
                        m <= m1;
                        c <= c1;
                    end else begin
                        m <= m2;
                        c <= c2;
                    end
                end else begin
                    if (flag[2]) begin
                        m <= m3;
                        c <= c3;
                    end else begin
                        m <= m4;
                        c <= c4;
                    end
                end
            end else begin
                if (flag[5]) begin
                    if(flag[4]) begin
                        m <= m5;
                        c <= c5;
                    end else begin
                        m <= m6;
                        c <= c6;
                    end
                end else begin
                    if(flag[6]) begin
                        m <= m7;
                        c <= c7;
                    end else begin
                        if (flag[7]) begin
                            m <= m8;
                            c <= c8;
                        end else begin
                            m <= m9;
                            c <= c9;
                        end
                    end
                end
            end
        end
    end

endmodule
