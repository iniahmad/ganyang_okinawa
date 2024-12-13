import math

def sigmoid(x):
    return (1 / (1 + math.exp(-x)))

def gradien_then_calc_y_approx(x1, x2, x):
    y1 = sigmoid(x1)
    y2 = sigmoid(y2)
    m = ((y2 - y1) / (x2 - x1))
    c = y2 - (m * x1)
    y = (m * x) + c
    return y

def mean_squared_error(y_actual, y_predicted):
    if len(y_actual) != len(y_predicted):
        raise ValueError("The length of actual and predicted values must be the same.")

    squared_errors = []
    
    # Calculate squared errors for each pair of actual and predicted values
    for actual, predicted in zip(y_actual, y_predicted):
        squared_error = (actual - predicted) ** 2
        squared_errors.append(squared_error)
    
    # Calculate MSE by averaging the squared errors
    mse = sum(squared_errors) / len(squared_errors)
    
    return mse

#define number of slice
slices = 4
min_x = [-4, -3.5]
step = 0.1



    