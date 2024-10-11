%% Actitud compartida (fitness function)
% Cada fila representa un individuo [x1, x2, aptitud]
poblacion = [
    1.0, 3.0, 10.2;
    1.1, 2.9, 15.5;
    2.0, 4.0, 8.3;
    10.0, 10.0, 9.1
];


x_max = [10, 10]; 
x_min = [0, 0];   
p = 2;            % Número de dimensiones
q = 2;

poblacionModificada = FitnessSharing(poblacion, x_max, x_min, p, q);

disp('Población original:');
disp(poblacion(:, 3));

disp('Población después de aplicar Fitness Sharing:');
disp(poblacionModificada(:, 3));



function poblacion = FitnessSharing(poblacion, x_max, x_min, p, q)

    numIndividuos = size(poblacion, 1); % Número de individuos en la población
    aptitud = poblacion(:, end); % Supongamos que la última columna es la aptitud
    aptitudCompartida = aptitud; % Inicializar con la aptitud original

    suma = sum((x_max - x_min).^2);
    radioDeNicho = sqrt(suma) / (2^p * sqrt(q));

    for i = 1:numIndividuos
        compartido = 0;

        for j = 1:numIndividuos
            if i ~= j
                distancia = sqrt(sum((poblacion(i, 1:end-1) - poblacion(j, 1:end-1)).^2));
                
                if distancia < radioDeNicho
                    sh_dij = sharingFunction(distancia, radioDeNicho);
                    compartido = compartido + sh_dij;
                end
            end
        end
        aptitudCompartida(i) = aptitud(i) * (1 + compartido);
    end
    
    poblacion(:, end) = aptitudCompartida;
end

function sh_dij = sharingFunction(distancia, radioDeNicho)
    a = 1;
    if distancia < radioDeNicho
        sh_dij = (1 - (distancia / radioDeNicho))^a;
    else
        sh_dij = 0;
    end
end
