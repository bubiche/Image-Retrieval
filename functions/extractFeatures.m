function extractFeatures(input_path, output_path)
    global config
    files = dir(fullfile(input_path, '*.jpg'));
    files = {files.name};
    featureDetector = fullfile('lib', 'feature_detector', 'hesaff.exe');
    
    config.extract = @(fi, fo)config.cmd([featureDetector, ' ', fi, ' ', fo]);
    
    for i = 1:numel(files)
        inFile = fullfile(input_path, files{i});
        tempFile = fullfile(config.tempPath, strrep(files{i}, '.jpg', ''));
        outFile = fullfile(output_path, strrep(files{i}, '.jpg', '.mat'));
        
        if ~exist(outFile, 'file')
            config.extract(inFile, tempFile);
            if ~exist(tempFile, 'file')
                imageKp = zeros(config.kpLen, 0);
                imageDesc = zeros(config.descLen, 0);
            else
                [imageKp, imageDesc] = vl_ubcread(tempFile, 'format', 'oxford');
                
                sift = double(imageDesc);
                imageDesc = single(sqrt(sift ./ repmat(sum(sift), config.descLen, 1)));

            end
            
            save(outFile, 'imageKp', 'imageDesc');
            
        end
        
        fprintf('Feature Extraction: %d/%d images \n', i, numel(files));
    end
end