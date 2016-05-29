initialize;

% dataset feature extraction
fprintf('Extracting features of images in dataset...\n');
extractFeatures(fullfile(config.dataPath, 'images'), fullfile(config.dataPath, 'feature'));

% query feature extraction
fprintf('Extract features of query images...\n');
extractFeatures(fullfile(config.queryPath, 'images'), fullfile(config.queryPath, 'feature'));

clear;