function mostrarMapaMexico()

    % Ruta al archivo shapefile
    shapefile_path = '110m_cultural/ne_110m_admin_0_countries.shp';  % Cambia esta ruta según tu archivo
    
    % Verificar que el archivo existe
    if exist(shapefile_path, 'file') ~= 2
        error('Archivo shapefile no encontrado. Verifica la ruta.');
    end

    % Cargar el shapefile
    S = shaperead(shapefile_path);

    % Filtrar los datos de México
    mexico = S(strcmpi({S.NAME}, 'MEXICO'));
    if isempty(mexico)
        error('No se encontraron datos de México en el shapefile.');
    end

    % Crear una figura para mostrar el mapa
    figure;
    hold on;

    % Mostrar el mapa de México
    geoshow(mexico, 'FaceColor', [0.8, 0.8, 0.8]);

    % Ajustar la visualización
    title('Mapa de México');
    xlabel('Longitud');
    ylabel('Latitud');
    xlim([-120, -85]);  % Ajusta según sea necesario
    ylim([14, 33]);     % Ajusta según sea necesario
    grid on;

    hold off;
end
