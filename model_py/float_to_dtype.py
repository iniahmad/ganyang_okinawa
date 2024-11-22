def float_to_custom_binary(float_value):
    # Determine the sign bit
    sign_bit = 0 if float_value >= 0 else 1

    # Get the absolute value of the float for further processing
    abs_value = abs(float_value)

    # Separate the integer and fractional parts
    integer_part = int(abs_value)
    fractional_part = abs_value - integer_part

    # Convert the integer part to binary (4 bits)
    integer_binary = format(integer_part, '04b')

    # Convert the fractional part to binary (26 bits)
    fractional_binary = ''
    for _ in range(26):
        fractional_part *= 2
        bit = int(fractional_part)
        fractional_binary += str(bit)
        fractional_part -= bit

    # Combine all parts into a single binary string
    custom_binary = f"{sign_bit}{integer_binary}{fractional_binary}"

    return custom_binary

# Input from the user
user_input = input("Please enter a float value: ")

try:
    float_value = float(user_input)
    custom_binary = float_to_custom_binary(float_value)
    print("Custom binary representation:", custom_binary)
except ValueError:
    print("Invalid input. Please enter a valid float value.")