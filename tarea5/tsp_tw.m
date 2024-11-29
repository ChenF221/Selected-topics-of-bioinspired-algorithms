
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

%%%%%%%%%%%%%%%%%%%%%% GRAFICA %%%%%%%%%%%%%%%%%%%
function grafica(ciudades_conectadas)

    % Coordenadas de las ciudades (lat, lon)
    ciudades = {
        'New York', 40.7128, -74.0060;
        'Los Angeles', 34.0522, -118.2437;
        'Chicago', 41.8781, -87.6298;
        'Houston', 29.7604, -95.3698;
        'Phoenix', 33.4484, -112.0740;
        'Philadelphia', 39.9526, -75.1652;
        'San Diego', 32.7157, -117.1611;
        'Dallas', 32.7767, -96.7970;
        'San Francisco', 37.7749, -122.4194;
        'Austin', 30.2672, -97.7431;
        'Las Vegas', 36.1699, -115.1398
    };
    
    % Arreglo de ciudades que final regrese al inicio
    ciudades_conectadas = [ciudades_conectadas, ciudades_conectadas(1)];
    
    % Cargar el archivo shapefile de los países
    shapefile_path = '110m_cultural/ne_110m_admin_0_countries.shp';  % Reemplaza con la ruta correcta
    S = shaperead(shapefile_path);
    
    % Filtrar solo los datos de Estados Unidos
    usa = S(strcmp({S.NAME}, 'United States of America'));
    
    % Crear la figura
    figure;
    hold on;
    
    % Mostrar el mapa de los EE.UU. de fondo
    geoshow(usa, 'FaceColor', [0.8 0.8 0.8]);
    
    % Graficar las ciudades con sus coordenadas
    for i = 1:length(ciudades_conectadas)
        ciudad_id = ciudades_conectadas(i);
        nombre = ciudades{ciudad_id, 1};
        lat = ciudades{ciudad_id, 2};
        lon = ciudades{ciudad_id, 3};
        plot(lon, lat, 'ro');  % 'ro' para marcar las ciudades con puntos rojos
        text(lon + 1, lat + 1, nombre, 'FontSize', 9);  % Etiquetar las ciudades
    end
    
    % Conectar las ciudades en el orden especificado
    for i = 1:length(ciudades_conectadas) - 1
        ciudad_inicio = ciudades_conectadas(i);
        ciudad_fin = ciudades_conectadas(i + 1);
        lat1 = ciudades{ciudad_inicio, 2};
        lon1 = ciudades{ciudad_inicio, 3};
        lat2 = ciudades{ciudad_fin, 2};
        lon2 = ciudades{ciudad_fin, 3};
        plot([lon1 lon2], [lat1 lat2], 'b-', 'LineWidth', 2);  % Línea azul conectando las ciudades
    end
    
    % Ajustes del gráfico
    title('Grafica del mejor ruta sin ventanas de tiempo');
    xlabel('Longitud');
    ylabel('Latitud');
    xlim([-125, -65]);  % Limites de longitud para EE.UU.
    ylim([24, 50]);     % Limites de latitud para EE.UU.
    grid on;
    hold off;

end

