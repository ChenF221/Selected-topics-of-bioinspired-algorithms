
function tsp_tw_1()
    % Parámetros del Algoritmo Genético
    numGeneraciones = 1000;
    tamPoblacion = 50;
    probMutacion = 0.05;
    probCrossover = 0.9;
    lambda = 50; % Factor de penalización
    
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
    ventanasTiempo = [
        -inf, inf;   % Ciudad de Mexico
        50, 90;      % Leon
        15, 25;      % Guadalajara
        30, 55;      % Tijuana
        15, 75;      % Juarez
        5, 35;       % Monterrey
        150, 200;    % Merida
        25, 50;      % Puebla
        65, 100;     % Torreon
        120, 150;    % Queretaro
        30, 85       % Toluca
    ];
    


    %Generar población inicial
    poblacion = inicializarPoblacion(tamPoblacion, size(distancias, 1));
    
    % Evolución del Algoritmo Genético
    for generacion = 1:numGeneraciones
        % Evaluar la aptitud de la población
        aptitud = evaluarPoblacion(poblacion, distancias, ventanasTiempo, lambda);
        
        % Selección
        nuevaPoblacion = seleccion(poblacion, aptitud);
        
        % Crossover
        nuevaPoblacion = crossover(nuevaPoblacion, probCrossover);
        
        % Mutación
        nuevaPoblacion = mutacion(nuevaPoblacion, probMutacion);
        
        % Remover abruptos
        nuevaPoblacion = removerAbruptos(nuevaPoblacion, distancias);

        % Reemplazar la población actual
        poblacion = nuevaPoblacion;
    end
    
    % % Evaluar la mejor solución encontrada
    aptitudFinal = evaluarPoblacion(poblacion, distancias, ventanasTiempo, lambda);
    [~, mejorIndice] = min(aptitudFinal);
    mejorRuta = poblacion(mejorIndice, :);

    % % Mostrar la mejor ruta encontrada
    % fprintf('Mejor ruta encontrada: ');
    % disp(mejorRuta);
    % fprintf('Costo total: %.2f\n', aptitudFinal(mejorIndice));

    % Calcular la media de los valores de aptitud
    promedioAptitud = mean(aptitudFinal);
    
    % Encontrar el índice de la aptitud más cercana al promedio
    [~, promIndice] = min(abs(aptitudFinal - promedioAptitud));
    
    % Seleccionar la ruta promedio
    promRuta = poblacion(promIndice, :);
    
    % Mostrar los resultados
    fprintf('Mejor ruta encontrada: ');
    disp(mejorRuta);
    fprintf('Costo total de la mejor ruta: %.2f\n', aptitudFinal(mejorIndice));
    fprintf('\n\n');


    fprintf('Ruta promedio encontrada: ');
    disp(promRuta);
    fprintf('Costo total de la ruta promedio: %.2f\n', aptitudFinal(promIndice));

    grafica(mejorRuta)
end

% Funciones auxiliares
function poblacion = inicializarPoblacion(tamPoblacion, numCiudades)
    % Inicializa la población aleatoriamente
    poblacion = zeros(tamPoblacion, numCiudades);
    for i = 1:tamPoblacion
        poblacion(i, :) = randperm(numCiudades);
    end
end

function aptitud = evaluarPoblacion(poblacion, distancias, ventanasTiempo, lambda)
    % Evaluar la aptitud de cada ruta en la población considerando las ventanas de tiempo
    tamPoblacion = size(poblacion, 1);
    aptitud = zeros(tamPoblacion, 1);


    for i = 1:tamPoblacion
        ruta = poblacion(i, :);

        % Encontrar el índice de la ciudad 1 en la ruta
        idxInicio = find(ruta == 1, 1);
        
        % Reorganizar la ruta para que empiece desde la ciudad 1
        ruta = [ruta(idxInicio:end), ruta(1:idxInicio-1)];
        ruta(end + 1) = 1; % Añadir la ciudad 1 al final para el regreso

        % Inicialización de tiempos
        tiempoLlegada = zeros(1, length(ruta));
        penalizacion = 0;

        % Evaluar la ruta completa
        for j = 2:length(ruta)
            ciudadAnterior = ruta(j - 1);
            ciudadActual = ruta(j);

            % Calcular el tiempo de viaje y llegada
            tiempoViaje = distancias(ciudadAnterior, ciudadActual);
            tiempoLlegada(j) = max(ventanasTiempo(ciudadActual, 1), tiempoLlegada(j - 1) + tiempoViaje);

            % Penalización por exceder la ventana de tiempo superior
            exceso = max(0, tiempoLlegada(j) - ventanasTiempo(ciudadActual, 2));
            penalizacion = penalizacion + exceso^2; % Penalización cuadrática
        end

        % Calcular el tiempo total de la ruta y agregar la penalización
        tiempoTotal = tiempoLlegada(end);
        aptitud(i) = tiempoTotal + lambda * penalizacion;
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
    % Operador de crossover cíclico para toda la población
    tamPoblacion = size(poblacion, 1);
    nuevaPoblacion = poblacion;
    for i = 1:2:tamPoblacion-1
        if rand < probCrossover
            % Seleccionar dos padres y realizar el cruzamiento cíclico
            padre1 = poblacion(i, :);
            padre2 = poblacion(i+1, :);
            [hijo1, hijo2] = cruzamientoCiclico(padre1, padre2);
            nuevaPoblacion(i, :) = hijo1;
            nuevaPoblacion(i+1, :) = hijo2;
        end
    end
end

function [descendiente1, descendiente2] = cruzamientoCiclico(padre1, padre2)
    % Esta función implementa el cruzamiento cíclico (Cycle Crossover, CX)
    % Entrada:
    % padre1 - vector del primer padre
    % padre2 - vector del segundo padre
    % Salida:
    % descendiente1 - vector del primer descendiente
    % descendiente2 - vector del segundo descendiente

    % Inicialización de descendientes
    descendiente1 = zeros(1, length(padre1));
    descendiente2 = zeros(1, length(padre2));

    % Identificación de ciclos
    ciclo_inicial = 1; % Comienza desde el primer índice no visitado
    visitados = false(1, length(padre1)); % Marcador para posiciones visitadas

    while any(~visitados)
        % Ciclo actual
        ciclo_indices = [];
        indice_actual = find(~visitados, 1); % Encuentra el primer índice no visitado
        inicio = indice_actual; % Guarda el inicio del ciclo

        % Construcción del ciclo
        while true
            ciclo_indices(end + 1) = indice_actual;
            visitados(indice_actual) = true;
            valor = padre2(indice_actual);
            indice_actual = find(padre1 == valor);

            if indice_actual == inicio
                break;
            end
        end

        % Asignación a los descendientes según el ciclo
        if mod(ciclo_inicial, 2) == 1 % Ciclos impares: copia de Padre 1 a Descendiente 1
            descendiente1(ciclo_indices) = padre1(ciclo_indices);
            descendiente2(ciclo_indices) = padre2(ciclo_indices);
        else % Ciclos pares: intercambio de padres
            descendiente1(ciclo_indices) = padre2(ciclo_indices);
            descendiente2(ciclo_indices) = padre1(ciclo_indices);
        end

        % Avanzar al siguiente ciclo
        ciclo_inicial = ciclo_inicial + 1;
    end

    % Rellenar las posiciones restantes
    descendiente1(descendiente1 == 0) = padre2(descendiente1 == 0);
    descendiente2(descendiente2 == 0) = padre1(descendiente2 == 0);
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


function nuevaPoblacion = removerAbruptos(poblacion, distancias)
    % Esta función ajusta las rutas para eliminar cambios abruptos (saltos innecesarios).
    tamPoblacion = size(poblacion, 1);  % Número de rutas en la población
    nuevaPoblacion = poblacion;        % Copia de la población original

    for i = 1:tamPoblacion
        ruta = nuevaPoblacion(i, :);  % Ruta actual
        mejorRuta = ruta;             % Inicializar mejor ruta como la ruta actual
        mejorCosto = calcularCostoRuta(ruta, distancias); % Evaluar el costo de la ruta actual

        % Intentar intercambiar pares de ciudades para reducir costos
        for j = 2:length(ruta)-1
            for k = j+1:length(ruta)-1
                rutaTemp = ruta;
                % Intercambiar las posiciones j y k
                rutaTemp([j, k]) = rutaTemp([k, j]);
                costoTemp = calcularCostoRuta(rutaTemp, distancias);

                % Si el intercambio reduce el costo, actualizar mejor ruta
                if costoTemp < mejorCosto
                    mejorCosto = costoTemp;
                    mejorRuta = rutaTemp;
                end
            end
        end
        % Reemplazar la ruta actual con la ruta optimizada
        nuevaPoblacion(i, :) = mejorRuta;
    end
end


function costo = calcularCostoRuta(ruta, distancias)
    % Calcula el costo total de una ruta dada con base en las distancias
    costo = 0;
    for i = 1:length(ruta)-1
        costo = costo + distancias(ruta(i), ruta(i+1));
    end
    % Considerar el regreso a la ciudad inicial
    costo = costo + distancias(ruta(end), ruta(1));
end



%%%%%%%%%%%%%%%%%%%%%% GRAFICA %%%%%%%%%%%%%%%%%%%
function grafica(ruta)
    % Coordenadas geográficas de las ciudades (latitud, longitud)
    coordenadas = [
        19.432608, -99.133209;  % Ciudad de México
        21.123619, -101.684957; % León
        20.659699, -103.349609; % Guadalajara
        32.514947, -117.038247; % Tijuana
        31.739558, -106.486931; % Juárez
        25.686613, -100.316116; % Monterrey
        20.967370, -89.592587;  % Mérida
        19.041296, -98.206200;  % Puebla
        25.539869, -103.448670; % Torreón
        20.588793, -100.389888; % Querétaro
        19.285443, -99.699312   % Toluca
    ];

    % Reorganizar la ruta para asegurar que empieza y termina en Ciudad de México
    idxInicio = find(ruta == 1, 1);
    ruta = [ruta(idxInicio:end), ruta(1:idxInicio-1)];
    ruta(end + 1) = 1; % Añadir la Ciudad de México al final

    % Extraer las coordenadas de la ruta
    latitudes = coordenadas(ruta, 1);
    longitudes = coordenadas(ruta, 2);

    % Crear la gráfica sobre un mapa
    figure;
    geoplot(latitudes, longitudes, '-o', 'LineWidth', 2, 'MarkerSize', 6);
    geobasemap('streets'); % Mostrar el mapa base
    hold on;

    % Etiquetas para las ciudades
    for i = 1:length(ruta)
        text(latitudes(i), longitudes(i), num2str(ruta(i)), ...
             'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right', ...
             'FontSize', 8, 'Color', 'blue');
    end

    % Configuración de título y etiquetas
    title('Ruta óptima en un mapa real de México');
    %xlabel('Longitud');
    %ylabel('Latitud');

    hold off;
end
