initialize;

% Load codebook
code_book = hdf5read(config.codebookFile, '/clusters');

% Create kdtree
kdtreeFile = fullfile(config.dataPath, 'flann_kdtree.bin');
kdsearchFile = fullfile(config.dataPath, 'flann_kdtree_search.mat');
global kdtree;

if exist(kdtreeFile, 'file')
    fprintf('Loading kdtree...\n');
    kdtree = flann_load_index(kdtreeFile, code_book);
    load(kdsearchFile);
else
    fprintf('Building kdtree...\n');
    [kdtree, search_parameters] = flann_build_index(code_book, config.quantStruct.buildconfig);
    flann_save_index(kdtree, kdtreeFile);
    save(kdsearchFile, 'search_parameters');
end

% Quantize and build Bag of Words

%%%% for dataset
fprintf('Quantizing dataset images...\n');
quantize_images(fullfile(config.dataPath, 'feature'), fullfile(config.dataPath, 'quantize'), search_parameters, config.quantStruct.knn);
fprintf('Making BoW vectors for all data images...\n');
makeBoW(fullfile(config.dataPath, 'quantize'), fullfile(config.dataPath, 'bow'), config.histLen);

%%%% for queries
fprintf('Quantizing query images...\n');
quantize_images(fullfile(config.queryPath, 'feature'), fullfile(config.queryPath, 'quantize'), search_parameters, config.quantStruct.knn);
fprintf('Making BoW vectors for all query images...\n');
makeBoW(fullfile(config.queryPath, 'quantize'), fullfile(config.queryPath, 'bow'), config.histLen);

clear;