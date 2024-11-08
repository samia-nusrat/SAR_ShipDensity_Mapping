% List of files to process
files = {'nov2023.csv', 'nov2023_2.csv', 'nov2023_3.csv', 'nov2023_4.csv', 'nov2023_5.csv', 'nov2023_6.csv'};

% Initialize arrays to store combined latitude and longitude data
all_lat = [];
all_lon = [];

% Loop through each file and extract lat/lon data
for i = 1:length(files)
    filename = files{i};
    
    % Load the CSV file to keep original column names
    opts = detectImportOptions(filename);
    opts.VariableNamingRule = 'preserve';
    data = readtable(filename, opts);

    % Extract latitude and longitude values
    % Assuming Var4 contains latitude values
    lat = data.Var4; 
    % Assuming Var5 contains longitude values
    lon = data.Var5; 

    % Convert lat and lon to numeric arrays
    if iscell(lat)
        % Convert cell array to numeric
        lat = str2double(lat); 
    end
    if iscell(lon)
        lon = str2double(lon); 
    end

    % Append to combined latitude and longitude arrays
    all_lat = [all_lat; lat];
    all_lon = [all_lon; lon];
end

% Remove duplicates based on lat-lon pairs
unique_coords = unique([all_lat, all_lon], 'rows', 'stable');
unique_lat = unique_coords(:,1);
unique_lon = unique_coords(:,2);

% Calculate min and max values for latitude and longitude
min_lat = min(unique_lat);
max_lat = max(unique_lat);
min_lon = min(unique_lon);
max_lon = max(unique_lon);

% Plotting using geoplot
figure;
geoplot(unique_lat, unique_lon, 'b*') 
geobasemap streets 

% Set map limits to the correct region based on data
latlim = [min_lat max_lat]; 
lonlim = [min_lon max_lon]; 
geolimits(latlim, lonlim);

% Define the coordinates of the boundary box using min and max values
boundary_lat = [min_lat, min_lat, max_lat, max_lat, min_lat];
boundary_lon = [min_lon, max_lon, max_lon, min_lon, min_lon];

% Plot the boundary box outline
hold on; 
geoplot(boundary_lat, boundary_lon, 'r-', 'LineWidth', 2); 
hold off;

% Add title
title('Geoplot of Ship Density Points from Multiple Files with Boundary Outline');


scalebar('Length', 500, 'Units', 'km', 'Color', 'black');
