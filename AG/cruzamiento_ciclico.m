% Padres
padre1 = [5 3 9 8 2 1 7 4 6];
padre2 = [3 9 5 6 4 7 1 8 2];
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

% Mostrar resultados
disp('Descendiente 1:');
disp(descendiente1);
disp('Descendiente 2:');
disp(descendiente2);
