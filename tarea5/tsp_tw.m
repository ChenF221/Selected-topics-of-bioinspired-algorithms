function tsp_tw()
    % Parámetros del Algoritmo Genético
    numGeneraciones = 1000;
    tamPoblacion = 50;
    probMutacion = 0.05;
    probCrossover = 0.85;
    
    % Datos del problema: Costos entre ciudades y ventanas de tiempo
    distancias = [
        0, 61.82, 18.54, 37.52, 54.08, 1.88, 59.98, 32.82, 69.42, 36.76, 60.26;
        61.82, 0, 50.84, 33.62, 7.5, 59.88, 2.76, 28.84, 7.78, 28.14, 5.8;
        18.54, 50.84, 0, 26.74, 43.38, 18.6, 49.28, 22, 58.7, 23.36, 49.3;
        37.52, 33.62, 26.74, 0, 26.16, 35.56, 32.06, 4.8, 41.5, 3.26, 32.08;
        54.08, 7.5, 43.38, 26.16, 0, 52.06, 7.32, 21.38, 15.34, 20.68, 5.92;
        1.88, 59.88, 18.6, 35.56, 52.06, 0, 57.96, 30.86, 67.38, 34.8, 58.3;
        59.98, 2.76, 49.28, 32.06, 7.32, 57.96, 0, 27.28, 10.62, 26.58, 6.76;
        32.82, 28.84, 22, 4.8, 21.38, 30.86, 27.28, 0, 36.72, 4.02, 27.3;
        69.42, 7.78, 58.7, 41.5, 15.34, 67.38, 10.62, 36.72, 0, 36.02, 12.14;
        36.76, 28.14, 23.36, 3.26, 20.68, 34.8, 26.58, 4.02, 36.02, 0, 26.6;
        60.26, 5.8, 49.3, 32.08, 5.92, 58.3, 6.76, 27.3, 12.14, 26.6, 0
    ];
    
    % Ventanas de tiempo para cada ciudad (en horas)
    % ventanasTiempo = [
    %     -inf, inf;   % New York
    %     50, 90;      % Los Angeles
    %     15, 25;      % Chicago
    %     30, 55;      % Houston
    %     15, 75;      % Phoenix
    %     5, 35;       % Philadelphia
    %     150, 200;    % San Diego
    %     25, 50;      % Dallas
    %     65, 100;     % San Francisco
    %     120, 150;    % Austin
    %     30, 85       % Las Vegas
    % ];
    
    ventanasTiempo = [
    -inf, inf;   % New York
    -inf, inf;   % Los Angeles
    -inf, inf;   % Chicago
    -inf, inf;   % Houston
    -inf, inf;   % Phoenix
    -inf, inf;   % Philadelphia
    -inf, inf;   % San Diego
    -inf, inf;   % Dallas
    -inf, inf;   % San Francisco
    -inf, inf;   % Austin
    -inf, inf    % Las Vegas
    ];
    % Generar población inicial
    poblacion = inicializarPoblacion(tamPoblacion, size(distancias, 1));
    
    % Evolución del Algoritmo Genético
    for generacion = 1:numGeneraciones
        % Evaluar la aptitud de la población
        aptitud = evaluarPoblacion(poblacion, distancias, ventanasTiempo);
        
        % Selección
        nuevaPoblacion = seleccion(poblacion, aptitud);
        
        % Crossover
        nuevaPoblacion = crossover(nuevaPoblacion, probCrossover);
        
        % Mutación
        nuevaPoblacion = mutacion(nuevaPoblacion, probMutacion);
        
        % Reemplazar la población actual
        poblacion = nuevaPoblacion;
    end
    
    % Evaluar la mejor solución encontrada
    aptitudFinal = evaluarPoblacion(poblacion, distancias, ventanasTiempo);
    [~, mejorIndice] = min(aptitudFinal);
    mejorRuta = poblacion(mejorIndice, :);
    
    % Mostrar la mejor ruta encontrada
    fprintf('Mejor ruta encontrada: ');
    disp(mejorRuta);
    fprintf('Costo total: %.2f\n', aptitudFinal(mejorIndice));
end

% Funciones auxiliares
function poblacion = inicializarPoblacion(tamPoblacion, numCiudades)
    % Inicializa la población aleatoriamente
    poblacion = zeros(tamPoblacion, numCiudades);
    for i = 1:tamPoblacion
        poblacion(i, :) = randperm(numCiudades);
    end
end

function aptitud = evaluarPoblacion(poblacion, distancias, ventanasTiempo)
    % Calcula la aptitud de cada individuo en la población
    tamPoblacion = size(poblacion, 1);
    aptitud = zeros(tamPoblacion, 1);
    for i = 1:tamPoblacion
        ruta = poblacion(i, :);
        costo = 0;
        for j = 1:length(ruta)-1
            costo = costo + distancias(ruta(j), ruta(j+1));
        end
        costo = costo + distancias(ruta(end), ruta(1)); % Regresar al inicio
        aptitud(i) = costo;
    end
end

function nuevaPoblacion = seleccion(poblacion, aptitud)
    % Selección por torneo
    tamPoblacion = size(poblacion, 1);
    nuevaPoblacion = poblacion;
    for i = 1:tamPoblacion
        idx1 = randi(tamPoblacion);
        idx2 = randi(tamPoblacion);
        if aptitud(idx1) < aptitud(idx2)
            nuevaPoblacion(i, :) = poblacion(idx1, :);
        else
            nuevaPoblacion(i, :) = poblacion(idx2, :);
        end
    end
end

function nuevaPoblacion = crossover(poblacion, probCrossover)
    % Operador de crossover (cruce de orden)
    tamPoblacion = size(poblacion, 1);
    nuevaPoblacion = poblacion;
    for i = 1:2:tamPoblacion-1
        if rand < probCrossover
            % Seleccionar dos padres y realizar el cruce
            padre1 = poblacion(i, :);
            padre2 = poblacion(i+1, :);
            puntoCorte = randi(length(padre1) - 1);
            hijo1 = [padre1(1:puntoCorte), padre2(~ismember(padre2, padre1(1:puntoCorte)))];
            hijo2 = [padre2(1:puntoCorte), padre1(~ismember(padre1, padre2(1:puntoCorte)))];
            nuevaPoblacion(i, :) = hijo1;
            nuevaPoblacion(i+1, :) = hijo2;
        end
    end
end

function nuevaPoblacion = mutacion(poblacion, probMutacion)
    % Operador de mutación (intercambio de dos ciudades)
    tamPoblacion = size(poblacion, 1);
    numCiudades = size(poblacion, 2);
    nuevaPoblacion = poblacion;
    for i = 1:tamPoblacion
        if rand < probMutacion
            idx1 = randi(numCiudades);
            idx2 = randi(numCiudades);
            % Intercambiar dos ciudades en la ruta
            temp = nuevaPoblacion(i, idx1);
            nuevaPoblacion(i, idx1) = nuevaPoblacion(i, idx2);
            nuevaPoblacion(i, idx2) = temp;
        end
    end
end