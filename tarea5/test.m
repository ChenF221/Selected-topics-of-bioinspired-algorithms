warning('off', 'all');
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

% Arreglo de ciudades en el orden que quieres conectar
ciudades_conectadas = [5, 11, 2, 9, 10, 7, 1, 6, 3, 8, 4];
ciudades_conectadas = [ciudades_conectadas, ciudades_conectadas(1)];

% Cargar el archivo shapefile de los países
shapefile_path = 'D:/Escom/Semestre_6/Bioinpirados/tarea5/110m_cultural/ne_110m_admin_0_countries.shp';  % Reemplaza con la ruta correcta
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
title('Ciudades Conectadas en los Estados Unidos');
xlabel('Longitud');
ylabel('Latitud');
xlim([-125, -65]);  % Limites de longitud para EE.UU.
ylim([24, 50]);     % Limites de latitud para EE.UU.
grid on;
hold off;
