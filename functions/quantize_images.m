function quantize_images(input_path, output_path, search_parameters, knn)
    files = dir(fullfile(input_path, '*.mat'));
    files = {files.name};
    global kdtree;
    
    for i=1:numel(files)
        feature_file = fullfile(input_path, files{i});
        quantize_file = fullfile(output_path, files{i});
        load(feature_file, 'imageDesc');
        
        if ~exist(quantize_file, 'file')
            [bins, sqrDists] = flann_search(kdtree, single(imageDesc), knn, search_parameters);
            save(quantize_file, 'bins','sqrDists');
        end
        fprintf('Quantize: %d/%d files\n', i, numel(files));
    end
end