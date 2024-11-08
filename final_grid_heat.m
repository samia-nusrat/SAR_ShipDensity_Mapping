% Clear previous data
clear; clc;

% List of files to process
files = {'feb2023.csv', 'feb2023_2.csv', 'feb2023_3.csv', 'feb2023_4.csv'};

% Initialize arrays to store all data
allLat = [];
allLon = [];
allDensity = [];

% Load and clean data from each file
for i = 1:length(files)
    data = readtable(files{i}); % Read the data file
    
    % Extract ship density, latitude, and longitude
    density = data.Var1; % Var1 contains ship density
    lat = data.Var4;     % Var4 contains latitude values
    lon = data.Var5;     % Var5 contains longitude values
    
    % Convert density and coordinates to numeric
    if iscell(density)
        density = cellfun(@str2double, regexprep(density, '[^\d.]', ''));
    end
    if iscell(lat)
        lat = cellfun(@str2double, lat);
    end
    if iscell(lon)
        lon = cellfun(@str2double, lon);
    end
    
    % Remove NaN values
    validIndices = ~isnan(density) & ~isnan(lat) & ~isnan(lon);
    allDensity = [allDensity; density(validIndices)];
    allLat = [allLat; lat(validIndices)];
    allLon = [allLon; lon(validIndices)];
end

% Define the grid sizes 
gridSizes = [10, 20, 50, 100];  % Grid sizes: 10km, 20km, 50km, 100km

% Reference conversion constant (1 degree latitude ~ 111 km)
kmPerDegree = 111;

% Loop through each grid size and sum the density
for gridSize = gridSizes
    % Determine the number of 1 km x 1 km cells in the larger grid
    cellsPerSide = (gridSize / 1);  % Since each 1 km x 1 km cell is a unit
    
    % Calculate the grid boundaries based on the current grid size
    minLat = min(allLat);
    maxLat = max(allLat);
    minLon = min(allLon);
    maxLon = max(allLon);
    
    % Calculate the number of cells needed for the current grid size
    numLatCells = floor((maxLat - minLat) / (gridSize / kmPerDegree));
    numLonCells = floor((maxLon - minLon) / (gridSize / (kmPerDegree * cosd(mean([minLat, maxLat])))));
    
    % Initialize arrays for the sumd grid data
    gridDensity = zeros(numLatCells, numLonCells);
    gridLat = zeros(numLatCells, numLonCells);
    gridLon = zeros(numLatCells, numLonCells);
    
    % Loop through the grid cells and sum the data
    for latIdx = 1:numLatCells
        for lonIdx = 1:numLonCells
            % Define the latitude and longitude boundaries for the current grid cell
            latStart = minLat + (latIdx - 1) * (gridSize / kmPerDegree);
            latEnd = latStart + (gridSize / kmPerDegree);
            lonStart = minLon + (lonIdx - 1) * (gridSize / (kmPerDegree * cosd(latStart)));
            lonEnd = lonStart + (gridSize / (kmPerDegree * cosd(latStart)));
            
            % Find the indices of data points within this grid cell
            inBlock = allLat >= latStart & allLat < latEnd & allLon >= lonStart & allLon < lonEnd;
            
            % Only sum if there are valid (sea) data points
            if any(inBlock)
                % sum the densities by summing within this block
                gridDensity(latIdx, lonIdx) = sum(allDensity(inBlock));
                gridLat(latIdx, lonIdx) = (latStart + latEnd) / 2;
                gridLon(latIdx, lonIdx) = (lonStart + lonEnd) / 2;
            end
        end
    end
    
  
    gridLat = gridLat(:);
    gridLon = gridLon(:);
    gridDensity = gridDensity(:);
    
    % Plot the density map for the current grid size
    figure;
    geobasemap('colorterrain');
    hold on;
    
    % Define density ranges and color map
    densityRanges = [0, 1, 2, 5, 10, 20, 50, 100, 200];
    cmap = [
        1.0, 1.0, 0.8;   % Light yellow for 0 - 1
        1.0, 0.9, 0.6;   % Pale orange for 1 - 2
        1.0, 0.7, 0.4;   % Orange for 2 - 5
        1.0, 0.5, 0.2;   % Red-orange for 5 - 10
        1.0, 0.3, 0.3;   % Red for 10 - 20
        0.8, 0.1, 0.1;   % Dark red for 20 - 50
        0.6, 0.0, 0.0;   % Brown for 50 - 100
        0.3, 0.0, 0.0;   % Dark brown for 100 - 200
    ];
    

    discretizedDensity = discretize(gridDensity, densityRanges);
  
    for k = 1:length(densityRanges) - 1
        rangeIndices = (discretizedDensity == k);
        geoscatter(gridLat(rangeIndices), gridLon(rangeIndices), ...
            10, 'filled', 'MarkerFaceColor', cmap(k, :), 'MarkerEdgeAlpha', 0.1);
    end
    
    % Colorbar setup
    colormap(cmap);
    caxis([0 200]);
    colorbar('Ticks', densityRanges, 'TickLabels', string(densityRanges));
    title(['Density Map for ', num2str(gridSize), ' km Grid']);
    

    geolimits([minLat, maxLat], [minLon, maxLon]);
    
    hold off;
end
