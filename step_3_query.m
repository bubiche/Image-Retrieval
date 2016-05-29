initialize;

%%%%%%%%%%%%%%%%%%%%%%%%% Prepare dataset %%%%%%%%%%%%%%%%%%%%%%%%%%
% Build dataset Keypoints file
files = dir(fullfile(config.dataPath, 'feature', '*.mat'));
files = {files.name};
n_files = numel(files);

fprintf('Creating dataset Keypoints file...\n');
file = config.allDataKpFile;
if ~exist(file, 'file')
    allDataKp = cell(n_files, 1);
    
    for i = 1:n_files
        load(fullfile(config.dataPath, 'feature', files{i}));
        allDataKp{i} = imageKp;
    end
    save(file, 'allDataKp');
else
    load(file);
end
fprintf('Dataset Keypoints file created!\n');



% Build dataset Bin file
fprintf('Creating dataset Bin file...\n');
files = dir(fullfile(config.dataPath, 'quantize', '*.mat'));
files = {files.name};

file = config.allDataBinsFile;
if ~exist(file, 'file')
    allDataBins = cell(n_files, 1);
    for i = 1:n_files
        load(fullfile(config.dataPath, 'quantize', files{i}));
        allDataBins{i} = bins;
        clear bins;
    end   
    save(file, 'allDataBins');
else
    load(file);
end
fprintf('Dataset Bin file created!\n');



% Build dataset Bag of Words file
fprintf('Creating dataset BoW file...\n');
files = dir(fullfile(config.dataPath, 'bow', '*.mat'));
files = {files.name};

file = config.allDataBoWFile;
if ~exist(file, 'file')
    allDataBoW = sparse(numel(files), config.histLen);
    for i = 1:n_files
        load(fullfile(config.dataPath, 'bow', files{i}));
        allDataBoW(i, :) = imageBoW';
        fprintf('Dataset BoW: %d/%d files\n', i, numel(files));
    end
    save(file, 'allDataBoW', '-v7.3');
else
    load(file);
end
fprintf('Dataset BoW file created!\n');

% Build IDF file
fprintf('Creating IDF file...\n');
file = config.idfFile;
if ~exist(file, 'file')
    idfWeight = zeros(config.histLen, 1);
    for i = 1:n_files
        index = find(allDataBoW(i, :));
        for j = 1:length(index)
            idfWeight(index(j)) = idfWeight(index(j)) + 1;
        end
    end
    
    
    for i = 1:config.histLen
        if idfWeight(i) > 0
            idfWeight(i) = log(n_files / idfWeight(i));
        end
    end
    save(file, 'idfWeight');
else
    load(file);
end
fprintf('IDF file created!\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Query %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('Querying...\n');
queryBoWPath = fullfile(config.queryPath, 'bow');
queryBinPath = fullfile(config.queryPath, 'quantize');
queryKpPath = fullfile(config.queryPath, 'feature');
queryFiles = dir(fullfile(queryBoWPath, '*.mat'));
queryFiles = {queryFiles.name};

for i = 1:numel(queryFiles)
    file = queryFiles{i};
    fprintf('Querying with %s\n', file);
    load(fullfile(queryBoWPath, file));
    load(fullfile(queryBinPath, file));
    load(fullfile(queryKpPath, file));
    queryBoW = imageBoW;
    queryBin = bins;
    queryKp = imageKp;
    clear imageBoW;
    clear bins;
    clear imageKp;
    
    % use dot product as distance
    distance = allDataBoW * (queryBoW .* idfWeight);
    
    [~, sortedIndex] = sort(distance, 'descend');
    
    % Query Expansion based on Geometric Verification
    queryBoW = sparse(config.histLen, 1);
    nVerified = 0;
    
    for j = 1:config.quantStruct.topK
        matchedWords = get_match_words(queryBin(1, :), allDataBins{sortedIndex(j)}(1, :));
        matchedWords = [matchedWords get_match_words(queryBin(2, :), allDataBins{sortedIndex(j)}(2, :))];
        matchedWords = [matchedWords get_match_words(queryBin(3, :), allDataBins{sortedIndex(j)}(3, :))];
        
        % Only sample 1000 matched words to run faster, this does not affect performance much
        % Comment out this section for sampling all matched words
        if (size(matchedWords, 2) > 1000)
            matchedWords = matchedWords(:, randperm(size(matchedWords, 2), 1000));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % geometricVerification function is taken from:
        % https://github.com/vedaldi/practical-object-instance-recognition/blob/master/geometricVerification.m
        if (numel(matchedWords) > 0)
            inliers = geometricVerification(queryKp, allDataKp{sortedIndex(j)}, matchedWords);
        end
        
        if (numel(inliers) > 20)
            temp = reshape(allDataBins{sortedIndex(j)}(:, matchedWords(2, inliers)), 1, []);
            temp = sparse(temp, ones(numel(temp), 1), ones(numel(temp), 1), config.histLen, 1) > 0;
            nVerified = nVerified + 1;
            queryBoW = queryBoW + allDataBoW(sortedIndex(j), :)' .* temp;
        end
    end
    
    queryBoW = queryBoW ./ queryBoW;
    
    distance = allDataBoW * (queryBoW .* idfWeight);
    [~, sorted_index] = sort(distance, 'descend');
    
    fid = fopen(fullfile(config.rankListPath, strrep(file, 'mat', 'txt')), 'w');
    for j = 1:n_files
        fprintf(fid, '%s\n', files{sortedIndex(j)}(1:end - 4));
    end
    fclose(fid);
end

clear;
