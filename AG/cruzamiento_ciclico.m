padre1 = [4 7 1 3 9 6 5 8 2];
padre2 = [3 9 4 2 5 6 7 1 8];


ciclo = 0;
posicion = 1;
posiciones_visitadas = false(1, 9);


hijos1 = zeros(1, 9);
hijos2 = zeros(1, 9);


while true
    % Asignar valor1 y valor2 a hijo1 e hijo2 dependiendo del ciclo
    if ciclo == 0
        hijo1 = padre1(posicion);
        hijo2 = padre2(posicion);
    else
        hijo1 = padre2(posicion);
        hijo2 = padre1(posicion);
    end
    
    % Almacenar los valores en las listas de hijos
    hijos1(posicion) = hijo1;
    hijos2(posicion) = hijo2;
    
    % Registrar la posición como visitada
    posiciones_visitadas(posicion) = true;
    
    % Verificar si todos los valores han sido visitados
    if all(posiciones_visitadas)  % Si hemos visitado todas las posiciones
        break;
    end
    
    nueva_posicion = posicion + 1;
    
    % Verificar si la nueva posición ya fue visitada
    if posiciones_visitadas(nueva_posicion)  % Si la nueva posición ya fue visitada
        if ciclo == 0
            ciclo = 1;
        else
            ciclo = 0;
        end
        % Reiniciar la posición para el siguiente ciclo
        posicion = 1;  % Regresar a la primera posición para el nuevo ciclo
    else
        % Si la nueva posición no fue visitada, actualizamos la posición
        posicion = nueva_posicion;
    end
end


disp('Hijo 1:');
disp(hijos1);

disp('Hijo 2:');
disp(hijos2);
