def binary24_to_float(binary_str):
    if (len(binary_str) < 24):
        binary_str = binary_str.zfill(24)
    elif (len(binary_str) > 24):
        binary_str = binary_str[-24:]
    
    for i in range(24):
        # print(binary_str[i])
        if binary_str[i] not in ('0', '1'):
            if (binary_str[i] == 'b'):
                binary_str = binary_str[i+1:]
                # print("trig")
                break
            else:
                print(f"Character at index {i} is neither '0' nor '1': {binary_str[i]}")
                return 0
    
    if (len(binary_str) < 24):
        binary_str = binary_str.zfill(24)
    print(binary_str)


    """Convert a 24-bit binary string to a float."""
    sign = int(binary_str[0])
    integer_part = int(binary_str[1:9], 2)
    fractional_part = binary_str[9:]
    frac_value = 0.0
    for i, bit in enumerate(fractional_part):
        if bit == '1':
            frac_value += 1 / (2 ** (i + 1))
    float_value = integer_part + frac_value
    if sign == 1:
        float_value = -float_value
    return float_value

binary_str = input("Input Binary:")
print(binary24_to_float(binary_str))