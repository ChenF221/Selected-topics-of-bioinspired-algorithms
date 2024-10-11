clc;
close all; 
warning off all;

disp("SUSTITUCIÓN EXTINTIVA CON ELITISMO");

% Capturar los parámetros para el algoritmo
Np = input('Ingrese el número de individuos de la población: ');
Nvar = 2;
lix = input('Ingrese el limite inferior de x: ');
liy = input('Ingrese el limite inferior de y: ');
li = [lix, liy]; 
lsx = input('Ingrese el limite superior de x: ');
lsy = input('Ingrese el limite superior de y: ');
ls = [lsx, lsy];

% Generación de la población inicial
Poblacion = zeros(Np, Nvar);
for i = 1:Np
    for j = 1:Nvar
        Poblacion(i,j) = li(j) + rand() * (ls(j) - li(j));
    end
end

% Evaluación de la población en la función de Langermann
a = [3,5,2,1,7];
b = [5,2,1,4,9];
c = [1,2,5,2,3];

aptitud = zeros(Np, 1); % Inicializar la aptitud
for i = 1:Np
    sumatoria = 0;
    for t = 1:5
        sumatoria = sumatoria + c(t) * cos(pi * ((Poblacion(i,1) - a(t))^2 + (Poblacion(i,2) - b(t))^2)) / exp(((Poblacion(i,1) - a(t))^2 + (Poblacion(i,2) - b(t))^2) / pi);
    end
    aptitud(i) = -sumatoria;
end

% Generación máxima
GenMax = input('Ingrese la cantidad de generaciones: ');

% Inicializar la matriz de padres y para guardar las mejores coordenadas
Padres = zeros(Np, Nvar); 
mejores_coordenadas = zeros(GenMax, Nvar+1); % Para guardar las coordenadas

for generacion = 1:GenMax
    
    % Condición para cambiar los parámetros de Nc y Nm
    % nc bajo (2-5) favorecen la exploración, nc alto (10- 20) explotación
    % nm bajo (20) favorece la exploración y (100) favorece la explotación
    if (generacion < 50)
        Nc = 2;
        Nm = 20;
        Pm = 0.1;

    elseif generacion >= 50 && generacion < 100
        Nc = 5;
        Nm = 30;
        Pm = 0.1;

    elseif generacion >= 100 && generacion < 150
        Nc = 10;
        Nm = 60;
        Pm = 0.03;

    else
        Nc = 20;
        Nm = 100;
        Pm = 0.03;

    end

    % Selección por torneo
    torneo = [randperm(Np); randperm(Np)]'; 
    for i = 1:Np
        if aptitud(torneo(i, 1)) < aptitud(torneo(i, 2))
            Padres(i, :) = Poblacion(torneo(i, 1), :);
        else
            Padres(i, :) = Poblacion(torneo(i, 2), :);
        end
    end
    
    % CRUZAMIENTO SBX
    Hijos = zeros(Np, Nvar);
    Pc = 0.9; 

    for i = 1:2:Np-1
        U = rand();
        hijo1 = zeros(1, Nvar); 
        hijo2 = zeros(1, Nvar); 
        if U <= Pc
            for j = 1:Nvar
                P1 = Padres(i,j);
                P2 = Padres(i+1,j);
                beta = 1 + 2 * min([P1 - li(j), ls(j) - P2]) / abs(P2 - P1);
                alpha = 2 - beta^(-(Nc + 1));
                if U <= 1 / alpha
                    beta_c = (U * alpha)^(1 / (Nc + 1));
                else
                    beta_c = (1 / (2 - U * alpha))^(1 / (Nc + 1));
                end
                hijo1(1,j) = 0.5 * ((P1 + P2) - beta_c * abs(P2 - P1));
                hijo2(1,j) = 0.5 * ((P1 + P2) + beta_c * abs(P2 - P1));
            end
        else
            hijo1 = Padres(i, :);
            hijo2 = Padres(i+1, :);
        end
        Hijos(i,:) = hijo1;
        Hijos(i+1,:) = hijo2;
    end
    
    % Mutación
    for i = 1:Np 
        for j = 1:Nvar
            r = rand();
            if r <= Pm
                delta = min((ls(j) - Hijos(i,j)), (Hijos(i,j) - li(j))) / (ls(j) - li(j));
                if r <= 0.5
                    deltaq = (2 * r + (1 - 2 * r) * (1 - delta)^(Nm + 1))^(1 / (Nm + 1)) - 1;
                else
                    deltaq = 1 - (2 * (1 - r) + 2 * (r - 0.5) * (1 - delta)^(Nm + 1))^(1 / (Nm + 1));
                end
                Hijos(i,j) = Hijos(i,j) + deltaq * (ls(j) - li(j));
            end
        end
    end
    
    % Evaluación de la población en la función de Langermann
    aptitudHijos = zeros(Np, 1); 
    for i = 1:Np
        sumatoria = 0;
        for t = 1:5
            sumatoria = sumatoria + c(t) * cos(pi * ((Hijos(i,1) - a(t))^2 + (Hijos(i,2) - b(t))^2)) / exp(((Hijos(i,1) - a(t))^2 + (Hijos(i,2) - b(t))^2) / pi);
        end
        aptitudHijos(i) = -sumatoria;
    end

    % Evaluar aptitudes tanto de los padres como de los hijos
    aptitudPadres = aptitud; % Guardar aptitud de los padres antes de ser sobrescritos

    % Buscar el mejor individuo entre padres e hijos
    [mejorAptitudPadres, idxMejorPadre] = min(aptitudPadres); % Mejor padre
    [mejorAptitudHijos, idxMejorHijo] = min(aptitudHijos); % Mejor hijo

    if mejorAptitudPadres < mejorAptitudHijos
        mejorAptitud = mejorAptitudPadres;
        mejorIndividuo = Padres(idxMejorPadre, :); % El mejor individuo es el de los padres
    else
        mejorAptitud = mejorAptitudHijos;
        mejorIndividuo = Hijos(idxMejorHijo, :); % El mejor individuo es el de los hijos
    end

    % Sustitución de la población por los hijos
    Poblacion = Hijos;

    % Reemplazar al peor hijo con el mejor individuo
    [~, idxPeorHijo] = max(aptitudHijos); % Índice del peor hijo
    Poblacion(idxPeorHijo, :) = mejorIndividuo; % Reemplazar peor hijo con el mejor individuo

    % Actualizar aptitud de la población después del elitismo
    aptitud = aptitudHijos;
    aptitud(idxPeorHijo) = mejorAptitud; % Asegurarse de que la aptitud del mejor individuo sea correcta

    % Guardar coordenadas del mejor individuo de la generación
    mejores_coordenadas(generacion,1:2) = mejorIndividuo;
    mejores_coordenadas(generacion,3) = mejorAptitud;

    % Mostrar resultados de la generación
    fprintf('\n Generación: %d',generacion);
    fprintf('\nSolucion: %f \nCoordenadas del mejor Individuo (%f, %f)\n',mejorAptitud,mejorIndividuo(1),mejorIndividuo(2));
    disp('-------------------------------------------------');
end

% Graficar las coordenadas de los mejores individuos
figure;
plot3(mejores_coordenadas(:,1), mejores_coordenadas(:,2),mejores_coordenadas(:,3), 'ro','MarkerFaceColor','r');
xlabel('X');
ylabel('Y');
title('Gráfica de los mejores individuos');
grid on;
