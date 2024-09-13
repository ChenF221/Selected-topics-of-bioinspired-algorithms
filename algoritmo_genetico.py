import numpy as np

# Definir la función Langermann
def langermann(x, m=5, a=None, b=None, c=None):
    x1, x2 = x

    # Valores por defecto si no se proporcionan a, b y c
    if a is None:
        a = np.array([3, 5, 2, 1, 7])
    if b is None:
        b = np.array([5, 2, 1, 4, 9])
    if c is None:
        c = np.array([1, 2, 5, 2, 3])
    
    # Asegurarse de que las listas tienen longitud m
    a = np.array(a[:m])
    b = np.array(b[:m])
    c = np.array(c[:m])
    
    # Calcular el valor de la función Langermann
    result = 0
    for i in range(m):
        dist = (x1 - a[i]) ** 2 + (x2 - b[i]) ** 2
        result += c[i] * np.exp(-dist / np.pi) * np.cos(np.pi * dist)
    
    return -result


def create_initial_population(Np, n_var):
    return np.random.uniform(0, 10, (Np, n_var))


# Cruzamiento SBX (Simulated Binary Crossover)
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
                    hijo1[j] = p1
                    hijo2[j] = p2
        else:
            hijo1 = parents[i, :]
            hijo2 = parents[i+1, :]
        Hijos[i, :] = hijo1
        Hijos[i+1, :] = hijo2
    return Hijos



def seleccion_torneo(poblacion, aptitud, Np):

    Nvar = poblacion.shape[1]  # Número de variables (o dimensiones del individuo)
    
    # Inicializa la matriz de padres
    Padres = np.zeros((Np, Nvar))
    
    # Crea la matriz de torneos
    torneo = np.array([np.random.permutation(Np) for _ in range(Np)])
    
    # Determina el ganador de cada torneo
    for i in range(Np):
        idx1, idx2 = torneo[i]
        if aptitud(poblacion[idx1]) < aptitud(poblacion[idx2]):
            Padres[i] = poblacion[idx1]
        else:
            Padres[i] = poblacion[idx2]
    
    return Padres


def mutation_polynomial(Hijos, lb, ub, Pm, Nm):
    Np, Nvar = Hijos.shape
    
    for i in range(Np):
        for j in range(Nvar):
            if np.random.rand() <= Pm:
                r = np.random.rand()
                delta = min((ub[j] - Hijos[i, j]), (Hijos[i, j] - lb[j])) / (ub[j] - lb[j])

                if r <= 0.5:
                    deltaq = -1 + (2*r + (1 - 2*r) * (1 - delta) ** (Nm + 1)) ** (1 / (Nm + 1))
                else:
                    deltaq = 1 - (2*(1-r) + 2*(r - 0.5)*(1 - delta) ** (Nm + 1)) ** (1 / (Nm + 1))
                
                # Mutar el individuo
                Hijos[i, j] = Hijos[i, j] + deltaq * (ub[j] - lb[j])
                
                # Asegurarse de que el valor mutado está dentro de los límites
                Hijos[i, j] = np.clip(Hijos[i, j], lb[j], ub[j])

    return Hijos


def calculate_fitness(population, langermann_func, *langermann_params):
    return np.array([langermann_func(individual, *langermann_params) for individual in population])


def elistismo(poblacion, hijos, best_idx):
    random_idx = np.random.randint(0, len(hijos))
    hijos[random_idx] = poblacion[best_idx]
    return hijos


def main():

    Np = 200                # numero de poplacion
    num_generation = 200   # Número de generaciones
    n_var = 2              # Número de variables de decisión
    pc = 0.9               # Probabilidad de cruzamiento (Crossover)
    Nc = 2                  # Parámetro del SBX
    Nm = 20               # numero de mutacion (indice de distribucion)
    Pm = 0.03               # probabilidad de mutacion
    lb = np.array([0, 0])  
    ub = np.array([10, 10])

    population = create_initial_population(Np, n_var) # 1
    fitness = calculate_fitness(population, langermann) # 2

    for generation in range(num_generation):
        
        best_idx = np.argmin(fitness) # 3

        parents = seleccion_torneo(population, fitness, Np) # 4

        hijos = crossover_SBX(parents, lb, ub, Np, n_var, pc, Nc) # 5
        
        hijos = mutation_polynomial(hijos, lb, ub, Pm, Nm) # 6
        
        new_fitness = calculate_fitness(hijos, langermann) # 7
        
        population = elistismo(population, hijos, best_idx) # 8. Extintiva con elitismo
        
        # mejor resultado de la generacion
        best_idx = np.argmin(new_fitness)
        best_solution = hijos[best_idx]
        print(f"Generación {generation}: Mejor solución = {best_solution}, Valor de la FO = {langermann(best_solution)}")
    
    # mejor solucion
    best_idx = np.argmin(calculate_fitness(population, langermann))
    best_solution = population[best_idx]

    print("\nMejor solución encontrada:", best_solution)
    print("Valor de la función Langermann:", langermann(best_solution))


if __name__ == "__main__":
    main()
    # minimo global = -5.1621259
    # x = [2.00299219, 1.006096]
