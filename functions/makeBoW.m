function makeBoW(input_path, output_path, histLen)
    files = dir(fullfile(input_path, '*.mat'));
    files = {files.name};
    global config;
    
    for i = 1:numel(files)
        quantize_file = fullfile(input_path, files{i});
        bow_file = fullfile(output_path, files{i});
        
        if ~exist(bow_file, 'file')
            load(quantize_file);
            
            imageBoW = zeros(histLen, 1);
            imageFreq = zeros(histLen, 1);
            bins = reshape(bins(:), 1, []);
            
            weights = exp(-sqrDists./(2 * config.quantStruct.deltaSqr));
            weights = weights./repmat(sum(weights, 1), size(weights, 1), 1);
            weights = reshape(weights, 1, []);
            
            imageFreq = vl_binsum(imageFreq, ones(size(bins)), bins);
            imageBoW = vl_binsum(imageBoW, weights, bins);
            imageBoW = sqrt(imageBoW) ./ sqrt(imageFreq + 1);
            
            imageBoW = sparse(imageBoW);
            imageFreq = sparse(imageFreq);
            
            save(bow_file, 'imageBoW', 'imageFreq');
        end
        
        fprintf('Make Bag of Words: %d/%d files\n', i, numel(files));
    end
end