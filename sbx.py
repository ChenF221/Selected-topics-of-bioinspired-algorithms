import numpy as np

""" Cruzamiento SBX(SIMULATED BINARY CROSSOVER)"""
def crossover_SBX(parents, lb, ub, Np, Nvar, Pc, Nc):
    Hijos = np.zeros((Np, Nvar))

    for i in range(0, Np-1, 2):
        if np.random.rand() <= Pc:
            u = np.random.rand()

            hijo1 = np.zeros(Nvar)
            hijo2 = np.zeros(Nvar)

            for j in range(Nvar):
                p1 = parents[i, j]
                p2 = parents[i+1, j]

                if p1 != p2:
                    beta = 1 + (2 / (p2 - p1)) * min(p1 - lb[j], ub[j] - p2)
                    alpha = 2 - abs(beta) ** -(Nc + 1)

                    if u <= 1 / alpha:
                        beta_c = (u * alpha) ** (1 / (Nc + 1))
                    else:
                        beta_c = (1 / (2 - u * alpha)) ** (1 / (Nc + 1))

                    hijo1[j] = 0.5 * ((p1 + p2) - beta_c * abs(p2 - p1))
                    hijo2[j] = 0.5 * ((p1 + p2) + beta_c * abs(p2 - p1))
                else:
                    # If p1 == p2, the offspring will be the same as the parents
                    hijo1[j] = p1
                    hijo2[j] = p2
        else:
            hijo1 = parents[i, :]
            hijo2 = parents[i+1, :]

        Hijos[i, :] = hijo1
        Hijos[i+1, :] = hijo2

    return Hijos

def main():
    parents = np.array([[2.3, 4.5],
                        [1.4, -0.2]])
    lb = [1, -1] # lower bound
    ub = [3, 5] # upper bound
    Np = 2  # Number of parents (even number)
    Nvar = 2  # Number of variables
    Pc = 0.9  # Probability of crossover
    Nc = 2  # Distribution index

    hijos = crossover_SBX(parents, lb, ub, Np, Nvar, Pc, Nc)
    print(hijos)

if __name__ == "__main__":
    main()
