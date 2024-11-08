clc;
% Clear previous data
clear all_ship_density_100km all_ship_density_50km all_ship_density_20km all_ship_density_10km;

% Initialize arrays to hold ship density values for all grid sizes
all_ship_density_100km = [];
all_ship_density_50km = [];
all_ship_density_20km = [];
all_ship_density_10km = [];

% List of all CSV file names
fileNames = {'nov2023.csv', 'nov2023_2.csv', 'nov2023_3.csv', 'nov2023_4.csv', 'nov2023_5.csv', 'nov2023_6.csv'};

% Loop through each specified CSV file
for fileIndex = 1:length(fileNames)
    % Read the CSV file as a table
    data = readtable(fileNames{fileIndex});

    % Display column names and first few rows for checking
    disp(data.Properties.VariableNames);
    disp(data(1:min(5, end), :));

    % Extract ship density values from the 'Var1' column
    ship_density_raw = data.Var1;

    % Initialize an array to hold ship density values for this file
    ship_density = zeros(size(ship_density_raw));

    % Loop through each row to extract the density value (second part of the string)
    for i = 1:length(ship_density_raw)
        % Split the string by commas
        parts = strsplit(ship_density_raw{i}, ',');
        if length(parts) >= 3  
            ship_density(i) = str2double(parts{2});  % Extract the second part (density value)
        else
            ship_density(i) = NaN;  % Handle missing or incorrect data
        end
    end

    % Remove NaN values
    ship_density = ship_density(~isnan(ship_density));
    
    % 100 km grid size (10000 rows)
    for i = 1:10000:length(ship_density)
        if i + 9999 <= length(ship_density)
            all_ship_density_100km(end + 1) = mean(ship_density(i:i + 9999));  % Average density
        end
    end
    
    % 50 km grid size (2500 rows)
    for i = 1:2500:length(ship_density)
        if i + 2499 <= length(ship_density)
            all_ship_density_50km(end + 1) = mean(ship_density(i:i + 2499));  % Average density
        end
    end

    % 20 km grid size (400 rows)
    for i = 1:400:length(ship_density)
        if i + 399 <= length(ship_density)
            all_ship_density_20km(end + 1) = mean(ship_density(i:i + 399));  % Average density
        end
    end

    % 10 km grid size (100 rows)
    for i = 1:100:length(ship_density)
        if i + 99 <= length(ship_density)
            all_ship_density_10km(end + 1) = mean(ship_density(i:i + 99));  % Average density
        end
    end
end

% Check if there are any values left to plot
if isempty(all_ship_density_100km) && isempty(all_ship_density_50km) && ...
   isempty(all_ship_density_20km) && isempty(all_ship_density_10km)
    disp('No valid ship density values to plot.');
else
    % Create a figure with multiple subplots
    figure;

    % Set a fixed bin width
    bin_width = 0.05;  % Increased width for thicker bars
    
    % Plot for 100 km grid size
    subplot(2, 2, 1);
    histogram(all_ship_density_100km, 'FaceColor', [1 0 1], 'EdgeColor', 'k', 'BinWidth', bin_width); % Pink color
    title('Ship Density Histogram (100 km Grid Size)');
    xlabel('Ship Density');
    ylabel('Number of Grid Points');
    xlim([0, prctile(all_ship_density_100km, 95)]);
    grid on;
    text(0.5, 0.9, ['Total Cells: ', num2str(length(all_ship_density_100km))], 'Units', 'normalized', 'HorizontalAlignment', 'center');
    
    % Plot for 50 km grid size
    subplot(2, 2, 2);
    histogram(all_ship_density_50km, 'FaceColor', [0 1 0], 'EdgeColor', 'k', 'BinWidth', bin_width); % Green color
    title('Ship Density Histogram (50 km Grid Size)');
    xlabel('Ship Density');
    ylabel('Number of Grid Points');
    xlim([0, prctile(all_ship_density_50km, 95)]);
    grid on;
    text(0.5, 0.9, ['Total Cells: ', num2str(length(all_ship_density_50km))], 'Units', 'normalized', 'HorizontalAlignment', 'center');
    
    % Plot for 20 km grid size
    subplot(2, 2, 3);
    histogram(all_ship_density_20km, 'FaceColor', [0 0 1], 'EdgeColor', 'k', 'BinWidth', bin_width); % Blue color
    title('Ship Density Histogram (20 km Grid Size)');
    xlabel('Ship Density');
    ylabel('Number of Grid Points');
    xlim([0, prctile(all_ship_density_20km, 95)]);
    grid on;
    text(0.5, 0.9, ['Total Cells: ', num2str(length(all_ship_density_20km))], 'Units', 'normalized', 'HorizontalAlignment', 'center');
    
    % Plot for 10 km grid size
    subplot(2, 2, 4);
    histogram(all_ship_density_10km, 'FaceColor', [0 1 1], 'EdgeColor', 'k', 'BinWidth', bin_width); % Cyan color
    title('Ship Density Histogram (10 km Grid Size)');
    xlabel('Ship Density');
    ylabel('Number of Grid Points');
    xlim([0, prctile(all_ship_density_10km, 95)]);
    grid on;
    text(0.5, 0.9, ['Total Cells: ', num2str(length(all_ship_density_10km))], 'Units', 'normalized', 'HorizontalAlignment', 'center');
    % Add a title for the whole figure
    sgtitle('Nov 2023');
    
end
