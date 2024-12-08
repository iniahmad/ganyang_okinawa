#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

void float_to_custom_binary(float float_value, char *custom_binary) {
    // Determine the sign bit
    int sign_bit = (float_value >= 0) ? 0 : 1;

    // Get the absolute value of the float for further processing
    float abs_value = fabs(float_value);

    // Separate the integer and fractional parts
    int integer_part = (int)abs_value;
    float fractional_part = abs_value - integer_part;

    // Convert the integer part to binary (4 bits)
    char integer_binary[5]; // 4 bits + null terminator
    snprintf(integer_binary, sizeof(integer_binary), "%04d", integer_part & 0b1111);

    // Convert the fractional part to binary (27 bits)
    char fractional_binary[28]; // 27 bits + null terminator
    fractional_binary[0] = '\0'; // Initialize as empty string

    for (int i = 0; i < 27; i++) {
        fractional_part *= 2;
        int bit = (int)fractional_part;
        strncat(fractional_binary, (bit ? "1" : "0"), 1);
        fractional_part -= bit;
    }

    // Combine all parts into a single binary string
    snprintf(custom_binary, 33, "%d%s%s", sign_bit, integer_binary, fractional_binary);
}

float binary_to_float(const char *binary_str) {
    // Extract the sign bit
    int sign = binary_str[0] - '0';

    // Extract and convert the integer part (bits 1-4)
    int integer_part = 0;
    for (int i = 1; i <= 4; i++) {
        integer_part = (integer_part << 1) | (binary_str[i] - '0');
    }

    // Extract and convert the fractional part (bits 5-31)
    float fractional_part = 0.0;
    for (int i = 5; i < 32; i++) {
        if (binary_str[i] == '1') {
            fractional_part += 1.0 / (1 << (i - 4)); // 1 / 2^(i - 4)
        }
    }

    // Combine integer and fractional parts
    float float_value = integer_part + fractional_part;

    // Apply the sign
    if (sign == 1) {
        float_value = -float_value;
    }

    return float_value;
}


// int main() {
//     const char *binary_str = "100000000000011100001101010000";
//     float result = binary_to_float(binary_str);
//     printf("Float value: %.7f\n", result);

//     return 0;
// }

// int main() {
//     float value = -0.0033;
//     char custom_binary[33]; // 1 sign bit + 4 integer bits + 27 fractional bits + null terminator

//     float_to_custom_binary(value, custom_binary);

//     printf("Custom binary: %s\n", custom_binary);

//     return 0;
// }
