function AG()
    % Inputs:
    % tam_poblacion: tamaño de la población
    % num_generaciones: número de generaciones
    % Pc: probabilidad de cruzamiento
    % Pm: probabilidad de mutación
    % num_variables: número de variables en el problema

    num_generaciones = 200;   % Número de generaciones
    tam_poblacion = 200;      % Tamaño de la población
    proba_cruce = 0.7;         % Probabilidad de cruce
    proba_mutacion = 0.2;      % Probabilidad de mutación
    %Nc = 2;                % Parámetro SBX
    %Nm = 20;               % Parámetro de mutación polinomial
    lb = [0, 0];              % Límites inferiores de las variables
    ub = [10, 10];            % Límites superiores de las variables
    lambda = 1000;              % parametro de penalizacion exterior


    % Generar la población inicial
    poblacion = zeros(tam_poblacion, 2);
    for i= 1:tam_poblacion
        for j= 1:2
            poblacion(i,j)= (lb(j)+rand*(ub(j) - lb(j)));
        end
    end
    % Evaluar la aptitud de la población inicial
    aptitud = evaluar_poblacion(poblacion, lambda);
    
    % Ciclo del algoritmo genético
    for gen = 1:num_generaciones
        % Ajustar Nc y Nm conforme a las generaciones
        Nc = round(20 * (gen / num_generaciones));   % Va de 2 a 20
        Nm = round(100 * (gen / num_generaciones)); % Va de 20 a 100
        
        % 3. Selección del mejor miembro (elitismo)
        [~, idx_mejor] = min(aptitud);
        mejor_individuo = poblacion(idx_mejor, :);
        
        % 4. Selección de padres por torneo determinista
        padres = torneo_seleccion(poblacion, aptitud);
        
        % 5. Cruzamiento SBX (Single-Point Crossover)
        hijos = sbx_crossover(padres, proba_cruce, lb, ub, Nc,tam_poblacion);
        
        % 6. Mutación polinomial
        hijos = mutacion_polinomial(hijos, proba_mutacion, lb, ub,Nm);
        
        % 7. Evaluar descendientes
        aptitud_hijos = evaluar_poblacion(hijos, lambda);
        
        % 8. Sustitución extintiva con elitismo
        poblacion = sustitucion_extintiva(hijos, aptitud_hijos, mejor_individuo);
        
        % Evaluar nueva población
        aptitud = evaluar_poblacion(poblacion, lambda);
        
        % Mostrar el mejor resultado de la generación actual
        %fprintf('Generación %d: Mejor aptitud = %.4f\n', gen, min(aptitud) );
        %fprintf('Generación %d: Mejor aptitud = %.6f, Mejor individuo = [%f, %f]\n', gen, min(aptitud), mejor_individuo(1), mejor_individuo(2));
        fprintf('Generación %d: Mejor aptitud = %.6f, Mejor individuo = [%f, %f],Nm=%d,Nc=%d\n', ...
                              gen, min(aptitud), mejor_individuo(1), mejor_individuo(2),Nm,Nc);

    end
     % Imprimir la ultima población 
     %   fprintf('Población de la generación %d:\n', gen);
      %  disp(poblacion);
end

% Función para evaluar la aptitud de la población con penalización
function aptitud = evaluar_poblacion(poblacion, lambda)
    tam_poblacion = size(poblacion, 1);
    aptitud = zeros(tam_poblacion, 1);
    
    for i = 1:tam_poblacion
        x = poblacion(i, :);
        
        f = 4 * (x(1) - 3)^2 + 3 * (x(2) - 3)^2;

        g1 = 2 * x(1) + x(2) - 2;
        g2 = 3 * x(1) + 4 * x(2) - 6;
        
        Rd = [g1 g2];
        Ri = [0 0];
        
        P = sum(max(Rd, 0).^2, 2) + sum((Ri).^2, 2);
        
        aptitud(i) = f + lambda * P;
    end
end

% Función Langerman para el cálculo de la aptitud
function valor = langerman(x)
    a = [3, 5, 2, 1, 7];
    b = [5, 2, 1, 4, 9]; 
    c = [1, 2, 5, 2, 3]; 
    
    suma = 0;
    for i = 1:5
        term = (x(1) - a(i))^2 + (x(2) - b(i))^2;
        term2 = c(i)*cos(pi*term);
        term3 = exp(term/pi);
        suma= suma+ (term2/term3);
    end
    valor = -suma; 
end

% Selección por torneo
function padres = torneo_seleccion(poblacion, aptitud)
    tam_poblacion = size(poblacion, 1);
    padres = zeros(tam_poblacion, size(poblacion, 2));
    for i = 1:2:tam_poblacion
        idx1 = randi(tam_poblacion);
        idx2 = randi(tam_poblacion);
        if aptitud(idx1) < aptitud(idx2)
            padres(i, :) = poblacion(idx1, :);
        else
            padres(i, :) = poblacion(idx2, :);
        end
        idx3 = randi(tam_poblacion);
        idx4 = randi(tam_poblacion);
        if aptitud(idx3) < aptitud(idx4)
            padres(i+1, :) = poblacion(idx3, :);
        else
            padres(i+1, :) = poblacion(idx4, :);
        end
    end
end

% Operador de cruzamiento SBX
function hijos = sbx_crossover(padres, proba_cruce, lb, ub,Nc,tam_poblacion)
    Np=tam_poblacion;
    Nvar=2; 
    hijos = zeros(Np, Nvar);
    hijo1 = zeros(1, Nvar);
    hijo2 = zeros(1, Nvar);
    for i = 1:2:Np-1
        if rand <= proba_cruce
            U = rand;
            for j = 1:Nvar
                P1 = padres(i, j);
                P2 = padres(i+1, j);
                beta = 1 + 2/(P2-P1)* min([P1 - lb(j), ub(j) - P2]);
                alpha = 2 - beta^-(Nc + 1);
                if U <= 1/alpha
                    beta_c = (U * alpha)^(1/(Nc + 1));
                else
                    beta_c = (1 / (2 - U * alpha))^(1/(Nc + 1));
                end
                hijos(i, j) = 0.5 * ((P1 + P2) - beta_c * abs(P2 - P1));
                hijos(i, j) = 0.5 * ((P1 + P2) + beta_c * abs(P2 - P1));
            end
        else
            hijo1= padres(i,:);
            hijo2 = padres(i+1,:);
        end
        hijos(i,:)=hijo1;
        hijos(i+1,:)=hijo2;
    end
end

% Operador de mutación polinomial
function mutantes = mutacion_polinomial(hijos, proba_mutacion, lb, ub, Nm)
    [Np, Nvar] = size(hijos);
    mutantes = hijos; 
    
    for i = 1:Np
        for j = 1:Nvar
            if rand <= proba_mutacion
                r = rand;
                delta = min((ub(j) - mutantes(i,j)), (mutantes(i,j) - lb(j))) / (ub(j) - lb(j));
                
                if r <= 0.5
                    deltaq = (2*r + (1 - 2*r) * (1 - delta)^(Nm + 1))^(1/(Nm + 1)) - 1;
                else
                    deltaq = 1 - (2*(1 - r) + 2*(r - 0.5) * (1 - delta)^(Nm + 1))^(1/(Nm + 1));
                end
                
                % Mutar el individuo
                mutantes(i,j) = mutantes(i,j) + deltaq * (ub(j) - lb(j));
            end
        end
    end
end


% Función para la sustitución extintiva con elitismo
function nueva_poblacion = sustitucion_extintiva(hijos, aptitud_hijos, mejor_individuo)
    % Mantener al mejor individuo de la generación anterior
    [~, peor_idx] = max(aptitud_hijos);
    hijos(peor_idx, :) = mejor_individuo;
    nueva_poblacion = hijos;
end

% Solicitar los parámetros al usuario
%tam_poblacion = input('Introduce el tamaño de la población: ');
%num_generaciones = input('Introduce el número de generaciones: ');
%proba_cruce = input('Introduce la probabilidad de cruzamiento (entre 0 y 1): ');
%proba_mutacion = input('Introduce la probabilidad de mutación (entre 0 y 1): ');
%num_variables = input('Introduce el número de variables en el problema: ');

% Llamar a la función AG para empezar el algoritmo
%AG();

