import numpy as np

# Define your custom function
def float_to_custom_binary(float_value):
    # Determine the sign bit
    sign_bit = 0 if float_value >= 0 else 1

    # Get the absolute value of the float for further processing
    abs_value = abs(float_value)

    # Separate the integer and fractional parts
    integer_part = int(abs_value)
    fractional_part = abs_value - integer_part

    # Convert the integer part to binary (4 bits)
    integer_binary = format(integer_part & 0b1111, '04b')

    # Convert the fractional part to binary (27 bits)
    fractional_binary = ''
    for _ in range(27):
        fractional_part *= 2
        bit = int(fractional_part)
        fractional_binary += str(bit)
        fractional_part -= bit

    # Combine all parts into a single binary string
    custom_binary = f"{sign_bit}{integer_binary}{fractional_binary}"

    return custom_binary

# Data arrays
w2 = np.array([-0.0033, 0.0026, -0.0035, 0.0025, -0.0044, 0.0029, 0.4614, 0.1543, 0.2542,
               -0.9801, 0.2782, -0.9518, -0.5551, -0.2942, -0.4738, -1.2922, -0.3987, -1.2404,
               -0.0002, -0.0032, 0.0009, -0.0028, 0.0057, -0.0038, -0.1973, 1.2975, 0.4131,
               -1.0131, -0.0954, -0.5927, -0.5650, -0.0613, -0.4846, -1.6800, -0.1214, -0.7809])

b2 = np.array([-0.6678, -1.8547, -0.8391, -2.2616])

w3 = np.array([2.9018, -0.0947, 1.0031, 5.8119, 2.9684, -0.1314, 1.2482, 5.7844,
               -0.0283, -5.8888, 1.2856, 5.7943, 2.8900, -0.1277, 1.0408, 5.8097,
               2.8919, -0.1222])

b3 = np.array([4.2917, -0.3433, 4.2707, -0.3862, 0.1678, -0.3960, 4.2877, -0.3504, 4.2880])

# Function to apply the conversion to all elements in an array
def convert_array_to_custom_binary(data_array):
    return [float_to_custom_binary(value) for value in data_array]

# Convert the arrays
w2_custom = convert_array_to_custom_binary(w2)
b2_custom = convert_array_to_custom_binary(b2)
w3_custom = convert_array_to_custom_binary(w3)
b3_custom = convert_array_to_custom_binary(b3)

# Custom function to print the binary data
def custom_print(label, data):
    print(f"{label}:")
    print("\n".join(data))

# Convert the arrays
w2_custom = convert_array_to_custom_binary(w2)
b2_custom = convert_array_to_custom_binary(b2)
w3_custom = convert_array_to_custom_binary(w3)
b3_custom = convert_array_to_custom_binary(b3)

# Custom printing for each dataset
custom_print("w2_custom", w2_custom)
custom_print("b2_custom", b2_custom)
custom_print("w3_custom", w3_custom)
custom_print("b3_custom", b3_custom)