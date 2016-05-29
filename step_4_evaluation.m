initialize;

% Compute average precision
files = dir(fullfile(config.rankListPath, '*.txt'));
files = {files.name};

% compute_ap code is from the tutorial at https://www.robots.ox.ac.uk/~vgg/data/oxbuildings/compute_ap.cpp
compute_ap_file = fullfile(config.groundtruthPath, 'compute_ap.exe');

for i = 1:numel(files)
    file = files{i};
    fprintf('Computing AP for: %s\n', file);
    
    output = fullfile(config.apPath, files{i});
    dos([compute_ap_file, ' ', fullfile(config.groundtruthPath, files{i}(1:end - 4)), ' ', fullfile(config.rankListPath, files{i}), ' >', output]);
end
fprintf('Computing AP done! AP files are saved in the folder ap.\n');

% Compute mean average precision
files = dir(fullfile(config.apPath, '*.txt'));
files = {files.name};
p = zeros(numel(files), 1);

for i = 1:numel(files)
    file = files{i};
    fid = fopen(fullfile(config.apPath, file), 'r');
    p(i) = fscanf(fid, '%f');
    fclose(fid);
end

MAP_value = mean(p) * 100;
MAP_file = fopen('MAP.txt', 'w');
fprintf(MAP_file, 'MAP = %f%%\n', MAP_value);
fclose(MAP_file);

fprintf('MAP = %f%%\n', MAP_value);

clear;