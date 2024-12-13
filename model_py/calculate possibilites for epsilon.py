import numpy as np
def simple_prng(state):
    state &= 0b11111  # Ensure state is 5 bits

    # Apply XORSHIFT
    state ^= (state << 4) & 0b11111
    state ^= (state >> 5) & 0b11111
    # state ^= (state >> 1) & 0b11111
    

    # Add a constant to avoid zero absorption
    state = (state + 1) & 0b11111  # Ensure result is still 5 bits

    return state


# Simulate the PRNG
def test_prng(seed, iterations=50):
    state = seed
    visited = []

    for _ in range(iterations):
        if state in visited:
            break
        visited.append(state)
        state = simple_prng(state)

    return visited


# Example usage
seed = 0  # Start with seed 0
sequence = test_prng(seed)

print(f"Generated sequence ({len(sequence)} states): {sequence}")

# print(f"Visited states: {len(states)}")
# print(f"States: {sorted(states)}")

seq = np.array([0, 1, 22, 20, 18, 23, 7, 19, 4, 6, 8, 11, 30, 26, 29, 15, 25, 12, 16, 21, 5, 17, 2, 3, 24, 31, 13, 27, 10, 9])
print(np.unique(seq))
