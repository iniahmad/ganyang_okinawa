def binary_to_float(binary_str):
    """Convert a 32-bit binary string to a float."""
    sign = int(binary_str[0])
    integer_part = int(binary_str[1:4], 2)
    fractional_part = binary_str[5:]
    frac_value = 0.0
    for i, bit in enumerate(fractional_part):
        if bit == '1':
            frac_value += 1 / (2 ** (i + 1))
    float_value = integer_part + frac_value
    if sign == 1:
        float_value = -float_value
    return float_value

# Input from the user
user_input = input("Please enter a binary0 value: ")

float_data = binary_to_float(user_input)
print(f"Custom binary representation: {float_data:.10f}")