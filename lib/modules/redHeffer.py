# python file which implements a red-heffer star product of two scattering matrices
import numpy as np

def redheffer_star_4x4(S1, S2):
    """
    Calculate the Redheffer star product of two 4x4 scattering matrices S1 and S2.
    
    Parameters:
        S1, S2: The 4x4 scattering matrices. Each should be a 4x4 matrix.
        
    Returns:
        The 4x4 Redheffer star product of S1 and S2.
    """
    # Partition matrices into 2x2 blocks
    r1, t1_prime = S1[:2, :2], S1[:2, 2:]
    t1, r1_prime = S1[2:, :2], S1[2:, 2:]

    r2, t2_prime = S2[:2, :2], S2[:2, 2:]
    t2, r2_prime = S2[2:, :2], S2[2:, 2:]

    # Compute individual elements of the result
    eye2 = np.eye(2)

    new_r1 = r1 + t1_prime @ r2_prime @ np.linalg.pinv(eye2 - r1 @ r2_prime) @ t1
    new_t1_prime = t1_prime @ np.linalg.pinv(eye2 - r2_prime @ r1) @ t2_prime
    
    new_t1 = t2 @ np.linalg.pinv(eye2 - r1 @ r2_prime) @ t1
    new_r1_prime = r2_prime + t2 @ r1 @ np.linalg.pinv(eye2 - r2_prime @ r1) @ t1_prime
    
    # Combine the 2x2 blocks into a 4x4 result
    return np.block([[new_r1, new_t1_prime], [new_t1, new_r1_prime]])

# Example usage
S1 = np.array([[0.5, -0.5, -0.5, -0.5], 
               [-0.5, 0.5, -0.5, -0.5], 
               [0.5, -0.5, 0.5, -0.5], 
               [0.5, -0.5, -0.5, 0.5]])
S2 = np.array([[0.5, -0.5, -0.5, -0.5], 
               [-0.5, 0.5, -0.5, -0.5], 
               [0.5, -0.5, 0.5, -0.5], 
               [0.5, -0.5, -0.5, 0.5]])


result = redheffer_star_4x4(S1, S2)
print("S1 * S2 = ")
print(result)
