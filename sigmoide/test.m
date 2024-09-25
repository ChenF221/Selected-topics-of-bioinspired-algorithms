function test()

    Np = 200;               % número de población
    num_generation = 200;    % Número de generaciones
    n_var = 2;               % Número de variables de decisión
    pc = 0.85;               % Probabilidad de cruzamiento (Crossover)
    Pm = 0.03;               % Probabilidad de mutación
    Nc = 2;                  % Parámetro del SBX
    Nm = 100;                % Número de mutación (índice de distribución)
    lb = [0, 0];             % Límite inferior
    ub = [10, 10];           % Límite superior

    population = create_initial_population(Np, n_var); % 1. Generación de población inicial
    fitness = calculate_fitness(population, @langermann); % 2. Evaluación de población en la FO (cálculo de aptitud)

    for generation = 1:num_generation
        % 3 Selección del miembro de la población de mejor aptitud
        [~, best_idx] = min(fitness);
        best_individual = population(best_idx, :);

        parents = seleccion_torneo(population, fitness, Np, n_var); % 4. Selección de padres (Torneo determinista de dos individuos)
        hijos = crossover_SBX(parents, lb, ub, Np, n_var, pc, Nc);  % 5. SBX
        hijos = mutation_polynomial(hijos, lb, ub, Pm, Nm);         % 6. Mutación (Polinomial)

        population = elitismo(hijos, best_individual);              % 7. Sustitución (Extintiva con elitismo)

        fitness = calculate_fitness(population, @langermann);       % 8. Evaluación de los descendientes en la FO (cálculo de aptitud)

        % Mejor resultado de la generación
        [~, best_idx] = min(fitness);
        best_solution = population(best_idx, :);

        % Promedio de la generación
        avr_solucion = mean(fitness);

        % El peor de la generación
        [~, worst_idx] = max(fitness);
        worst_solution = population(worst_idx, :);

        % Desviación estándar
        desv_est = std(fitness);

        fprintf('Generación %d: Mejor solución = [%f, %f] -> Valor = %.9f. Peor solucion = [%f, %f] -> Valor = %.9f. Solucion media = %.9f. Desv. estandar = %.9f\n', ...
            generation, best_solution(1), best_solution(2), langermann(best_solution), ...
            worst_solution(1), worst_solution(2), langermann(worst_solution), ...
            avr_solucion, desv_est);
    end

    % Mejor solución encontrada
    fitness = calculate_fitness(population, @langermann);
    [~, best_idx] = min(fitness);
    best_solution = population(best_idx, :);

    fprintf('\nMejor solución encontrada: [%f, %f]\n', best_solution(1), best_solution(2));
    fprintf('Valor de la función Langermann: %.9f\n', langermann(best_solution));

end

function population = create_initial_population(Np, n_var)
    population = rand(Np, n_var) * 10;
end

function fitness = calculate_fitness(population, langermann_func)
    Np = size(population, 1);
    fitness = zeros(Np, 1);
    for i = 1:Np
        fitness(i) = langermann_func(population(i, :));
    end
end

function hijos = crossover_SBX(parents, lb, ub, Np, Nvar, Pc, Nc)
    hijos = zeros(Np, Nvar);
    for i = 1:2:Np-1
        if rand() <= Pc
            u = rand();
            hijo1 = zeros(1, Nvar);
            hijo2 = zeros(1, Nvar);
            for j = 1:Nvar
                p1 = parents(i, j);
                p2 = parents(i+1, j);
                if p1 ~= p2
                    beta = 1 + (2 / (p2 - p1)) * min(p1 - lb(j), ub(j) - p2);
                    alpha = 2 - abs(beta)^-(Nc + 1);
                    if u <= 1 / alpha
                        beta_c = (u * alpha)^(1 / (Nc + 1));
                    else
                        beta_c = (1 / (2 - u * alpha))^(1 / (Nc + 1));
                    end
                    hijo1(j) = 0.5 * ((p1 + p2) - beta_c * abs(p2 - p1));
                    hijo2(j) = 0.5 * ((p1 + p2) + beta_c * abs(p2 - p1));
                else
                    hijo1(j) = p1;
                    hijo2(j) = p2;
                end
            end
        else
            hijo1 = parents(i, :);
            hijo2 = parents(i+1, :);
        end
        hijos(i, :) = hijo1;
        hijos(i+1, :) = hijo2;
    end
end

function padres = seleccion_torneo(poblacion, aptitud, Np, Nvar)
    padres = zeros(Np, Nvar);
    torneo = [randperm(Np)', randperm(Np)'];
    for i = 1:Np
        if aptitud(torneo(i, 1)) < aptitud(torneo(i, 2))
            padres(i, :) = poblacion(torneo(i, 1), :);
        else
            padres(i, :) = poblacion(torneo(i, 2), :);
        end
    end
end

function hijos = mutation_polynomial(Hijos, lb, ub, Pm, Nm)
    [Np, Nvar] = size(Hijos);
    hijos = Hijos; % Asignar la matriz Hijos a hijos para asegurar que se devuelva algo
    
    for i = 1:Np
        for j = 1:Nvar
            if rand() <= Pm
                r = rand();
                delta = min((ub(j) - Hijos(i, j)), (Hijos(i, j) - lb(j))) / (ub(j) - lb(j));
                if r <= 0.5
                    deltaq = -1 + (2*r + (1 - 2*r) * (1 - delta)^(Nm + 1))^(1 / (Nm + 1));
                else
                    deltaq = 1 - (2*(1-r) + 2*(r - 0.5)*(1 - delta)^(Nm + 1))^(1 / (Nm + 1));
                end
                hijos(i, j) = Hijos(i, j) + deltaq * (ub(j) - lb(j));
                hijos(i, j) = max(lb(j), min(ub(j), hijos(i, j))); % Asegurarse que el valor esté dentro de los límites
            end
        end
    end
end


function hijos = elitismo(hijos, best_individual)
    random_idx = randi([1, size(hijos, 1)]);
    hijos(random_idx, :) = best_individual;
end

function result = langermann(x)
    m = 5;
    a = [3, 5, 2, 1, 7];
    b = [5, 2, 1, 4, 9];
    c = [1, 2, 5, 2, 3];

    x1 = x(1);
    x2 = x(2);

    result = 0;
    for i = 1:m
        dist = (x1 - a(i))^2 + (x2 - b(i))^2;
        result = result + c(i) * exp(-dist / pi) * cos(pi * dist);
    end
    result = -result;
end
