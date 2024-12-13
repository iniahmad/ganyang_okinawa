import numpy as np

# Re-defining and re-running the functions and optimization process

def sigmoid(x):
    """Sigmoid function."""
    return 1 / (1 + np.exp(-x))

def calculate_error(slice_points, sigmoid_values, num_slices):
    """
    Calculate error for a given set of slice points.
    The error is the squared difference between actual sigmoid values and the linear approximation.
    """
    error = 0
    for i in range(num_slices - 1):
        # Linear approximation between slice points
        x1, x2 = slice_points[i], slice_points[i + 1]
        y1, y2 = sigmoid_values[i], sigmoid_values[i + 1]
        slope = (y2 - y1) / (x2 - x1)
        intercept = y1 - slope * x1
        
        # Calculate the error for all x in [x1, x2]
        x_values = np.linspace(x1, x2, 100)  # Increase sampling points for better accuracy
        sigmoid_actual = sigmoid(x_values)
        linear_approx = slope * x_values + intercept
        error += np.sum((sigmoid_actual - linear_approx) ** 2)
    return error

def optimize_slices(range_x, num_slices, iterations=1000):
    """
    Optimize slice points to minimize error.
    """
    # Initialize slice points evenly across the range
    slice_points = np.linspace(range_x[0], range_x[1], num_slices)
    sigmoid_values = sigmoid(slice_points)
    
    best_slice_points = slice_points.copy()
    best_error = calculate_error(slice_points, sigmoid_values, num_slices)
    
    for _ in range(iterations):
        # Adjust slice points randomly within the range
        new_slice_points = np.sort(
            np.random.uniform(range_x[0], range_x[1], num_slices - 2)
        )
        new_slice_points = np.concatenate(([range_x[0]], new_slice_points, [range_x[1]]))
        new_sigmoid_values = sigmoid(new_slice_points)
        
        # Calculate error
        new_error = calculate_error(new_slice_points, new_sigmoid_values, num_slices)
        if new_error < best_error:
            best_slice_points = new_slice_points
            best_error = new_error
    return best_slice_points, best_error

# Define parameters
range_x = (-6, 6)  # Typical range for sigmoid function to capture most of its curve
num_slices = 4     # Number of slices to optimize for

# Perform optimization
optimal_slices, min_error = optimize_slices(range_x, num_slices)

# Display results
optimal_slices, min_error
