import numpy as np
import statistics

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
    for i in range(0, Np-1, 2):
        if np.random.rand() <= Pc:
            hijo1 = np.zeros((Nvar, 2))
            hijo2 = np.zeros((Nvar, 2))
            for j in range(Nvar):
                p1 = parents[i, j, 0]
                p2 = parents[i+1, j, 0]
                p1_b = parents[i, j, 1]
                p2_b = parents[i+1, j, 1]

                # Promedio aritmético para el primer alelo
                hijo1[j, 0] = 0.5 * (p1 + p2)
                hijo2[j, 0] = 0.5 * (p1 + p2)

                # Promedio aritmético para el segundo alelo
                hijo1[j, 1] = 0.5 * (p1_b + p2_b)
                hijo2[j, 1] = 0.5 * (p1_b + p2_b)
        else:
            hijo1 = parents[i, :, :]
            hijo2 = parents[i+1, :, :]
        Hijos[i, :, :] = hijo1
        Hijos[i+1, :, :] = hijo2
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
                        deltaq = -1 + (2*r + (1 - 2*r) * (1 - delta) ** (Nm + 1)) ** (1 / (Nm + 1))
                    else:
                        deltaq = 1 - (2*(1-r) + 2*(r - 0.5)*(1 - delta) ** (Nm + 1)) ** (1 / (Nm + 1))
                    Hijos[i, j, k] = Hijos[i, j, k] + deltaq * (ub[j] - lb[j])
                    Hijos[i, j, k] = np.clip(Hijos[i, j, k], lb[j], ub[j])
    return Hijos

# Selección por torneo para diploides
def seleccion_torneo_diploide(poblacion, aptitud, Np, Nvar):
    padres = np.zeros((Np, Nvar, 2))
    torneo = np.column_stack((np.random.permutation(Np), np.random.permutation(Np)))
    for i in range(Np):
        if aptitud[torneo[i, 0]] < aptitud[torneo[i, 1]]:
            padres[i, :, :] = poblacion[torneo[i, 0], :, :]
        else:
            padres[i, :, :] = poblacion[torneo[i, 1], :, :]
    return padres

# Sustitución extintiva con elitismo
def sustitucion_extintiva_con_elitismo(hijos, best_individual):
    # Crea una nueva población a partir de los hijos
    nueva_poblacion = hijos.copy()
    
    # Encuentra el índice del peor individuo en la nueva población
    worst_idx = np.random.randint(0, len(hijos))
    
    # Reemplaza el peor hijo con el mejor individuo
    nueva_poblacion[worst_idx, :, :] = best_individual
    
    return nueva_poblacion


# Actualización de la probabilidad de dominancia
def update_dominance_probs(dominancia_probs, population_diploide, best_individual, learning_rate=0.1):
    Np, Nvar, _ = population_diploide.shape
    for i in range(Np):
        for j in range(Nvar):
            # Obtiene los alelos y el mejor alelo
            allele1 = population_diploide[i, j, 0]
            allele2 = population_diploide[i, j, 1]
            best_allele = best_individual[j]

            # Calcula las distancias
            dist1 = abs(allele1 - best_allele)
            dist2 = abs(allele2 - best_allele)

            # Actualiza la probabilidad de dominancia
            if dist1 < dist2:
                dominancia_probs[i, j] += learning_rate * (1 - dominancia_probs[i, j])
            else:
                dominancia_probs[i, j] -= learning_rate * dominancia_probs[i, j]

            # Asegura que las probabilidades estén entre 0 y 1
            dominancia_probs[i, j] = np.clip(dominancia_probs[i, j], 0, 1)
    return dominancia_probs

def main():
    # INPUTS
    Np = 200                # número de población
    num_generation = 200    # Número de generaciones
    n_var = 2               # Número de variables de decisión
    pc = 0.85               # Probabilidad de cruzamiento (Crossover)
    Pm = 0.03               # probabilidad de mutación
    Nm = 20                 # índice de distribución para la mutación
    lb = np.array([0, 0])  
    ub = np.array([10, 10])

    # 1. Generación de población inicial (diploide)
    population_diploide = create_initial_population(Np, n_var)
    dominancia_probs = np.random.uniform(0, 1, (Np, n_var))  # Probabilidades iniciales de dominancia
    fitness = np.zeros(Np)

    # 2. Selección de fenotipos por dominancia y evaluación
    phenotypes = select_dominant(population_diploide, dominancia_probs)
    fitness = calculate_fitness(phenotypes, langermann)

    # Inicializa la mejor solución
    best_idx = np.argmin(fitness)
    best_solution = phenotypes[best_idx]
    best_fitness = fitness[best_idx]

    for generation in range(num_generation):
        # 4. Selección del mejor miembro de la población
        best_idx = np.argmin(fitness)
        current_best_solution = phenotypes[best_idx]
        current_best_fitness = fitness[best_idx]

        if current_best_fitness < best_fitness:
            best_fitness = current_best_fitness
            best_solution = current_best_solution

        # 5. Actualización de la probabilidad de dominancia usando el mejor individuo
        dominancia_probs = update_dominance_probs(dominancia_probs, population_diploide, current_best_solution)

        # 6. Selección de padres (Torneo)
        parents = seleccion_torneo_diploide(population_diploide, fitness, Np, n_var)

        # 7. Cruzamiento y mutación
        hijos = crossover_aritmetico_diploide(parents, lb, ub, Np, n_var, pc)
        hijos = mutation_polynomial_diploide(hijos, lb, ub, Pm, Nm)

        # 8. Selección de fenotipos por dominancia
        phenotypes = select_dominant(hijos, dominancia_probs)

        # 9. Evaluación de los descendientes
        fitness = calculate_fitness(phenotypes, langermann)

        # 10. Sustitución (extintiva con elitismo)
        population_diploide = sustitucion_extintiva_con_elitismo(hijos, current_best_solution)

        print(f"Generación {generation}: Mejor solución = {current_best_solution} -> Valor = {current_best_fitness:.9f}")

    # Mejor solución encontrada
    print("Mejor solución encontrada:", best_solution)
    print("Valor de la función Langermann:", langermann(best_solution))

if __name__ == "__main__":
    main()
