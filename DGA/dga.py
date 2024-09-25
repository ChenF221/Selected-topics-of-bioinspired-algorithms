import numpy as np

# Definir la función Langermann
def langermann(x, m=5, a=None, b=None, c=None):
    x1, x2 = x
    if a is None:
        a = np.array([3, 5, 2, 1, 7])
    if b is None:
        b = np.array([5, 2, 1, 4, 9])
    if c is None:
        c = np.array([1, 2, 5, 2, 3])
    a = np.array(a[:m])
    b = np.array(b[:m])
    c = np.array(c[:m])
    result = 0
    for i in range(m):
        dist = (x1 - a[i]) ** 2 + (x2 - b[i]) ** 2
        result += c[i] * np.exp(-dist / np.pi) * np.cos(np.pi * dist)
    return -result

# Creación de población diploide
def create_initial_population(Np, n_var):
    return np.random.uniform(0, 10, (Np, n_var, 2))

# Selección de alelo dominante
def select_dominant(population_diploide, dominancia_probs):
    Np, Nvar, _ = population_diploide.shape
    dominant_population = np.zeros((Np, Nvar))
    for i in range(Np):
        for j in range(Nvar):
            if np.random.rand() < dominancia_probs[i, j]:
                dominant_population[i, j] = population_diploide[i, j, 0]  # Primer alelo
            else:
                dominant_population[i, j] = population_diploide[i, j, 1]  # Segundo alelo
    return dominant_population

# Cálculo de aptitud
def calculate_fitness(population, langermann_func, *langermann_params):
    return np.array([langermann_func(individual, *langermann_params) for individual in population])

# Cruzamiento Aritmético Simple para diploides
def crossover_aritmetico_diploide(parents, lb, ub, Np, Nvar, Pc):
    Hijos = np.zeros((Np, Nvar, 2))
    for i in range(0, Np - 1, 2):
        if np.random.rand() <= Pc:
            for j in range(Nvar):
                p1 = parents[i, j, 0]
                p2 = parents[i + 1, j, 0]
                p1_b = parents[i, j, 1]
                p2_b = parents[i + 1, j, 1]

                # Promedio aritmético
                Hijos[i, j, 0] = 0.5 * (p1 + p2)
                Hijos[i + 1, j, 0] = Hijos[i, j, 0]
                Hijos[i, j, 1] = 0.5 * (p1_b + p2_b)
                Hijos[i + 1, j, 1] = Hijos[i, j, 1]
        else:
            Hijos[i, :, :] = parents[i, :, :]
            Hijos[i + 1, :, :] = parents[i + 1, :, :]
    return Hijos

# Mutación diploide
def mutation_polynomial_diploide(Hijos, lb, ub, Pm, Nm):
    Np, Nvar, _ = Hijos.shape
    for i in range(Np):
        for j in range(Nvar):
            for k in range(2):
                if np.random.rand() <= Pm:
                    r = np.random.rand()
                    delta = min((ub[j] - Hijos[i, j, k]), (Hijos[i, j, k] - lb[j])) / (ub[j] - lb[j])
                    if r <= 0.5:
                        deltaq = -1 + (2 * r + (1 - 2 * r) * (1 - delta) ** (Nm + 1)) ** (1 / (Nm + 1))
                    else:
                        deltaq = 1 - (2 * (1 - r) + 2 * (r - 0.5) * (1 - delta) ** (Nm + 1)) ** (1 / (Nm + 1))
                    Hijos[i, j, k] = Hijos[i, j, k] + deltaq * (ub[j] - lb[j])
                    Hijos[i, j, k] = np.clip(Hijos[i, j, k], lb[j], ub[j])
    return Hijos

# Selección por torneo para diploides
def seleccion_torneo_diploide(poblacion, aptitud, Np):
    padres = np.zeros((Np, poblacion.shape[1], 2))
    torneo = np.column_stack((np.random.permutation(Np), np.random.permutation(Np)))
    for i in range(Np):
        if aptitud[torneo[i, 0]] < aptitud[torneo[i, 1]]:
            padres[i, :, :] = poblacion[torneo[i, 0], :, :]
        else:
            padres[i, :, :] = poblacion[torneo[i, 1], :, :]
    return padres

# Sustitución extintiva con elitismo
def sustitucion_extintiva_con_elitismo(hijos, best_individual):
    # Encuentra el peor individuo en términos de aptitud
    worst_idx = np.argmax(calculate_fitness(select_dominant(hijos, np.full((hijos.shape[0], hijos.shape[1]), 0.5)), langermann))
    hijos[worst_idx, :, :] = best_individual
    return hijos


# Actualización de la probabilidad de dominancia
def update_dominance_probs(dominancia_probs, population_diploide, best_individual, alpha=0.1):
    Np, Nvar, _ = population_diploide.shape
    for i in range(Np):
        for j in range(Nvar):
            # Compara cada alelo del individuo con el mejor alelo
            best_allele = best_individual[0, j]  # El alelo dominante del mejor individuo
            
            # Comparación con el primer alelo
            if population_diploide[i, j, 0] == best_allele:
                dominancia_probs[i, j] = dominancia_probs[i, j] * (1 - alpha) + alpha
            # Comparación con el segundo alelo
            elif population_diploide[i, j, 1] == best_allele:
                dominancia_probs[i, j] = dominancia_probs[i, j] * (1 - alpha)
            else:
                # En caso de que ninguno coincida, no cambia la probabilidad
                dominancia_probs[i, j] = dominancia_probs[i, j] * (1 - alpha)

            # Asegura que las probabilidades estén entre 0 y 1
            dominancia_probs[i, j] = np.clip(dominancia_probs[i, j], 0, 1)

    return dominancia_probs


def main():
    # INPUTS
    Np = 200                # número de población
    num_generation = 200    # Número de generaciones
    n_var = 2               # Número de variables de decisión
    pc = 0.5                # Probabilidad de cruzamiento (Crossover)
    Pm = 0.3                # probabilidad de mutación
    Nm = 20                 # índice de distribución para la mutación
    lb = np.array([0, 0])  
    ub = np.array([10, 10])
    alpha = 0.1             # tasa de aprendizaje 

    # 1. Generación de población inicial (diploide)
    population_diploide = create_initial_population(Np, n_var)
    dominancia_probs = np.full((Np, n_var), 0.5)  # Probabilidades iniciales de dominancia
    fitness = np.zeros(Np)

    # 2. Selección de fenotipos por dominancia y evaluación
    phenotypes = select_dominant(population_diploide, dominancia_probs)

    # 3. Evaluación FO
    fitness = calculate_fitness(phenotypes, langermann)

    # Inicializa la mejor aptitud y el mejor individuo
    best_fitness = np.min(fitness)
    best_individual = population_diploide[np.argmin(fitness), :, :]

    # Bucle evolutivo
    for gen in range(num_generation):
        print(f"Generación {gen + 1} | Mejor aptitud: {best_fitness}")
        
        # 4. Selección de padres por torneo
        parents = seleccion_torneo_diploide(population_diploide, fitness, Np)

        # 5. Cruzamiento
        offspring = crossover_aritmetico_diploide(parents, lb, ub, Np, n_var, pc)

        # 6. Mutación
        offspring = mutation_polynomial_diploide(offspring, lb, ub, Pm, Nm)

        # 7. Evaluación de descendientes
        offspring_phenotypes = select_dominant(offspring, dominancia_probs)
        offspring_fitness = calculate_fitness(offspring_phenotypes, langermann)

        # 8. Sustitución con elitismo
        offspring = sustitucion_extintiva_con_elitismo(offspring, best_individual)

        # 9. Actualización de probabilidades de dominancia
        dominancia_probs = update_dominance_probs(dominancia_probs, population_diploide, best_individual, alpha)

        # 10. Actualización de la población y aptitud
        population_diploide = offspring
        fitness = offspring_fitness

        # Actualizar la mejor solución
        current_best_fitness = np.min(fitness)
        if current_best_fitness < best_fitness:
            best_fitness = current_best_fitness
            best_individual = offspring[np.argmin(fitness), :, :]

    print(f"\nMejor solución: {select_dominant(np.array([best_individual]), dominancia_probs)[0]}")
    print(f"Mejor aptitud: {best_fitness}")

if __name__ == "__main__":
    main()
