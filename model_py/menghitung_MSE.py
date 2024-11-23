import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Load Verilog output
data = pd.read_csv("D:\Kuliah\S7\VLSI\LSA\LSA sebagian sebagian\output_data.csv", names=["data_in", "piecewise_sigmoid"])

# Convert Verilog fixed-point to floating-point
def fixed_to_float(binary_str):
    sign = int(binary_str[0])
    integer = int(binary_str[1:5], 2)
    fraction = int(binary_str[5:], 2) / (2**27)
    value = (-1)**sign * (integer + fraction)
    return value

data["x"] = data["data_in"].apply(fixed_to_float)
data["piecewise_sigmoid"] = data["piecewise_sigmoid"].apply(fixed_to_float)

# Compute true sigmoid values
data["true_sigmoid"] = 1 / (1 + np.exp(-data["x"]))

# Compute errors
data["abs_error"] = np.abs(data["true_sigmoid"] - data["piecewise_sigmoid"])
mae = data["abs_error"].mean()
max_error = data["abs_error"].max()

print(f"Mean Absolute Error (MAE): {mae}")
print(f"Max Error: {max_error}")

# Plot the results
plt.plot(data["x"], data["true_sigmoid"], label="True Sigmoid", color="blue")
plt.plot(data["x"], data["piecewise_sigmoid"], label="Piecewise Sigmoid", color="red", linestyle="dashed")
plt.xlabel("Input (x)")
plt.ylabel("Sigmoid Output")
plt.legend()
plt.title("Piecewise vs True Sigmoid")
plt.show()
