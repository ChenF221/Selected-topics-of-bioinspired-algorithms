
function AG()
    % Inputs:
    % tam_poblacion: tamaño de la población
    % num_generaciones: número de generaciones
    % Pc: probabilidad de cruzamiento
    % Pm: probabilidad de mutación
    % num_variables: número de variables en el problema

    num_generaciones = 5000;   % Número de generaciones
    tam_poblacion = 100;      % Tamaño de la población
    proba_cruce = 0.9;         % Probabilidad de cruce
    proba_mutacion = 0;      % Probabilidad de mutación
    Nc = 2;                % Parámetro SBX
    Nm = 20;               % Parámetro de mutación polinomial
    lb = [0, 0];              % Límites inferiores de las variables
    ub = [10, 10];            % Límites superiores de las variables
    alpha = 0.5;                % factor de escala
    %q = 10;                         % cantidad de picos en la funcion


    % Calcular el radio de nicho
    %radioNicho = 0;
    radioNicho = 0.1;
    
    % Generar la población inicial
    poblacion = zeros(tam_poblacion, 2);
    for i= 1:tam_poblacion
        for j= 1:2
            poblacion(i,j)= (lb(j)+rand*(ub(j) - lb(j)));
        end
    end
    % Evaluar la aptitud de la población inicial
    aptitud = evaluar_poblacion(poblacion);
    
    
    % Ciclo del algoritmo genético
    for gen = 1:num_generaciones
        % Ajustar Nc y Nm conforme a las generaciones
        Nc = round(20 * (gen / num_generaciones));   % Va de 2 a 20
        %Nm = round(100 * (gen / num_generaciones)); % Va de 20 a 100
        
        % 3. Selección del mejor miembro (elitismo)
        [~, idx_mejor] = min(aptitud);
        mejor_individuo = poblacion(idx_mejor, :);
        
        % 4. Selección de padres por torneo determinista
        padres = torneo_seleccion(poblacion, aptitud);
        
        % 5. Cruzamiento SBX (Single-Point Crossover)
        hijos = sbx_crossover(padres, proba_cruce, lb, ub, Nc,tam_poblacion);
        
        % 6. no Mutación polinomial, fitness sharing
        %hijos = mutacion_polinomial(hijos, proba_mutacion, lb, ub,Nm);
        hijos = FitnessSharing(hijos, tam_poblacion, alpha, radioNicho);
        
        % 7. Evaluar descendientes
        aptitud_hijos = evaluar_poblacion(hijos);
        
        % 8. Sustitución extintiva con elitismo
        poblacion = sustitucion_extintiva(hijos, aptitud_hijos, mejor_individuo);
        
        % Evaluar nueva población
        aptitud = evaluar_poblacion(poblacion);

        % Calcular media, peor y desviación estándar
        media_aptitud = mean(aptitud);
        peor_aptitud = max(aptitud);
        desviacion_estandar = std(aptitud);
        
        % Mostrar el mejor resultado de la generación actual
        fprintf('Generación %d: Mejor aptitud = %.6f, Mejor individuo = [%f, %f], Media = %.6f, Peor = %.6f, Desviación estándar = %.6f\n', ...
                gen, min(aptitud), mejor_individuo(1), mejor_individuo(2), media_aptitud, peor_aptitud, desviacion_estandar);
            
        % Mostrar el mejor resultado de la generación actual
        %fprintf('Generación %d: Mejor aptitud = %.4f\n', gen, min(aptitud) );
        %fprintf('Generación %d: Mejor aptitud = %.6f, Mejor individuo = [%f, %f]. El media = %.4f, el peor = %.4f, des. estandar = .4f\n', gen, min(aptitud), mejor_individuo(1), mejor_individuo(2));
        %fprintf('Generación %d: Mejor aptitud = %.6f, Mejor individuo = [%f, %f],Nc=%d\n',gen, min(aptitud), mejor_individuo(1), mejor_individuo(2),Nc);

    end
     % Imprimir la ultima población 
     %   fprintf('Población de la generación %d:\n', gen);
      %  disp(poblacion);
end

% Función para evaluar la aptitud de la población
function aptitud = evaluar_poblacion(poblacion)
    tam_poblacion = size(poblacion, 1);
    aptitud = zeros(tam_poblacion, 1);
    for i = 1:tam_poblacion
        aptitud(i) = rastrigin(poblacion(i, :));
    end
end

% funcion Rastrigin
function valor = rastrigin(x)
    term1 = (x(1)^2 - 10 * cos(10 * pi * x(1)));
    term2 = (x(2)^2 - 10 * cos(2 * pi * x(2)));
    
    valor = 20 + term1 + term2;
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
            if rand < proba_mutacion
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

function [m] = FitnessSharing(p, Np, alpha, radioNicho)
    % Función para calcular el valor de aptitud compartida (Fitness Sharing)
    % p: Matriz de población, donde cada fila representa una solución
    % Np: Número de soluciones en la población
    % alpha: Parámetro de sensibilidad de la función de compartición
    % radioNicho: Radio de nicho para determinar el grado de compartición

    % Inicializar el vector de aptitud compartida
    m = zeros(Np, 2);

    for i = 1:Np
        d = inf(Np, 1);
        sh = zeros(Np, 1);

        for j = 1:Np
            if i ~= j
                d(j, 1) = sqrt(sum((p(i, :) - p(j, :)).^2));
            end
            if d(j, 1) < radioNicho
                sh(j,1) = sh(j,1)+(1-(d(j,1)/radioNicho)^alpha);
            end
        end
        m(i, 1) = sum(sh);
    end
end


% function radioNicho = calcular_sigma_share(x_max, x_min, q)
%     % x_max: Vector con los valores máximos para cada variable
%     % x_min: Vector con los valores mínimos para cada variable
%     % q: Número de nichos (parámetro)
% 
%     p = length(x_max); % Número de variables
% 
%     % Calcular el numerador de la fórmula
%     numerador = sum((x_max - x_min).^2);
% 
%     % Calcular el denominador
%     denominador = 2 * (q ^ (1/p));
% 
%     % Calcular sigma_share
%     radioNicho = sqrt(numerador) / denominador;
% end



% Solicitar los parámetros al usuario
%tam_poblacion = input('Introduce el tamaño de la población: ');
%num_generaciones = input('Introduce el número de generaciones: ');
%proba_cruce = input('Introduce la probabilidad de cruzamiento (entre 0 y 1): ');
%proba_mutacion = input('Introduce la probabilidad de mutación (entre 0 y 1): ');
%num_variables = input('Introduce el número de variables en el problema: ');

% Llamar a la función AG para empezar el algoritmo
%AG();

